# =============================================================
# deploy-aci.ps1
# Oracle 21c XE 開発 DB を Azure Container Instances にデプロイ
#
# 前提条件:
#   - Azure CLI ログイン済み (az login)
#   - Docker Desktop は不要（ACR Tasks でリモートビルド）
#
# 使い方:
#   .\scripts\deploy-aci.ps1
#   .\scripts\deploy-aci.ps1 -ResourceGroup "my-rg" -Location "japanwest"
#   .\scripts\deploy-aci.ps1 -SkipImageBuild   # イメージ再ビルド不要時
# =============================================================

param(
    [string]$ResourceGroup = "rg-divingapp-dev",
    [string]$Location = "japaneast",
    [string]$AcrName = "acrdivingapp7659",
    [string]$OraclePassword = "oracle123",
    [string]$AppDbUsername = "DIVINGAPP",
    [string]$AppDbPassword = "divingapp123",
    [switch]$SkipImageBuild
)

$ErrorActionPreference = "Stop"

# プロジェクトルートの特定
$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptDir
if (-not (Test-Path "$ProjectRoot\infra\main.bicep")) {
    Write-Error "プロジェクトルートが見つかりません: $ProjectRoot\infra\main.bicep"
    exit 1
}

$ImageTag = "divingapp/oracle-dev:latest"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Oracle 21c XE Dev DB - ACI Deploy" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Resource Group : $ResourceGroup"
Write-Host "Location       : $Location"
Write-Host "ACR Name       : $AcrName"
Write-Host "Image          : $AcrName.azurecr.io/$ImageTag"
Write-Host "Project Root   : $ProjectRoot"
Write-Host ""

# --- Step 1: リソースグループ作成 ---
Write-Host "[1/6] リソースグループ確認..." -ForegroundColor Cyan
$rgExists = az group exists --name $ResourceGroup 2>$null
if ($rgExists -eq "true") {
    Write-Host "  -> $ResourceGroup (既存)" -ForegroundColor Green
} else {
    az group create --name $ResourceGroup --location $Location --output none
    Write-Host "  -> $ResourceGroup 作成完了" -ForegroundColor Green
}

# --- Step 2: ACR 作成 & ベースイメージインポート ---
Write-Host "[2/6] ACR 確認..." -ForegroundColor Cyan
$acrExists = az acr show --name $AcrName --resource-group $ResourceGroup --query "name" -o tsv 2>$null
if ($acrExists) {
    Write-Host "  -> $AcrName (既存)" -ForegroundColor Green
} else {
    az acr create --resource-group $ResourceGroup --name $AcrName --sku Basic --admin-enabled true --output none
    Write-Host "  -> $AcrName 作成完了" -ForegroundColor Green

    # ベースイメージのインポート（Docker Hub → ACR）
    Write-Host "  ベースイメージインポート中..."
    az acr import --name $AcrName --source docker.io/gvenzl/oracle-xe:21-slim --image gvenzl/oracle-xe:21-slim --output none
    Write-Host "  -> ベースイメージインポート完了" -ForegroundColor Green
}

# --- Step 3: ACR Tasks でリモートビルド ---
if (-not $SkipImageBuild) {
    Write-Host "[3/6] ACR リモートビルド..." -ForegroundColor Cyan
    Push-Location $ProjectRoot
    az acr build --registry $AcrName --image $ImageTag --file docker/oracle/Dockerfile.aci . 2>&1 | ForEach-Object {
        if ($_ -match "Run ID:.*successful") { Write-Host "  $_" -ForegroundColor Green }
    }
    Pop-Location
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ACR ビルドに失敗しました"
        exit 1
    }
    Write-Host "  -> イメージビルド完了" -ForegroundColor Green
} else {
    Write-Host "[3/6] イメージビルド: スキップ (-SkipImageBuild)" -ForegroundColor Yellow
}

# --- Step 4: 既存コンテナ削除 + Bicep デプロイ ---
Write-Host "[4/6] ACI デプロイ..." -ForegroundColor Cyan
$containerName = "aci-divingapp-oracledb"
$existing = az container show --resource-group $ResourceGroup --name $containerName --query "name" -o tsv 2>$null
if ($existing) {
    Write-Host "  既存コンテナを削除中..."
    az container delete --resource-group $ResourceGroup --name $containerName --yes --output none
    Start-Sleep -Seconds 10
}

$deployment = az deployment group create `
    --resource-group $ResourceGroup `
    --template-file "$ProjectRoot\infra\main.bicep" `
    --parameters "$ProjectRoot\infra\main.parameters.json" `
    --parameters oraclePassword=$OraclePassword appDbPassword=$AppDbPassword acrName=$AcrName `
    --query "properties.outputs" `
    --output json | ConvertFrom-Json

if (-not $deployment) {
    Write-Error "Bicep デプロイに失敗しました"
    exit 1
}

$fqdn = $deployment.containerFqdn.value
$ip = $deployment.containerIpAddress.value
$jdbcUrl = $deployment.jdbcUrl.value
Write-Host "  -> Bicep デプロイ完了" -ForegroundColor Green

# --- Step 5: Oracle 起動待ち ---
Write-Host "[5/6] Oracle 起動待ち..." -ForegroundColor Cyan
Write-Host "  Oracle 21c XE の初回起動には約5分かかります"
$maxRetries = 20
$retryInterval = 20

for ($i = 1; $i -le $maxRetries; $i++) {
    Start-Sleep -Seconds $retryInterval
    $logs = az container logs --resource-group $ResourceGroup --name $containerName 2>$null
    if ($logs -match "DATABASE IS READY TO USE") {
        Write-Host "  -> Oracle 起動完了!" -ForegroundColor Green
        break
    }
    $state = az container show --resource-group $ResourceGroup --name $containerName --query "containers[0].instanceView.currentState.state" -o tsv 2>$null
    Write-Host "  状態: $state ($i/$maxRetries)"
    if ($state -eq "Terminated") {
        $exitCode = az container show --resource-group $ResourceGroup --name $containerName --query "containers[0].instanceView.currentState.exitCode" -o tsv 2>$null
        if ($exitCode -eq "0") {
            Write-Host "  -> Oracle 起動完了 (exit 0)" -ForegroundColor Green
            break
        } else {
            Write-Host "  Warning: コンテナが異常終了 (exit $exitCode)" -ForegroundColor Yellow
            Write-Host "  ログ: az container logs -g $ResourceGroup -n $containerName" -ForegroundColor Yellow
            break
        }
    }
}

# --- Step 6: 接続情報の表示 ---
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " デプロイ完了" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "接続情報:" -ForegroundColor White
Write-Host "  FQDN        : $fqdn"
Write-Host "  IP Address   : $ip"
Write-Host "  Port         : 1521"
Write-Host "  Service      : XEPDB1"
Write-Host "  JDBC URL     : $jdbcUrl"
Write-Host "  App User     : $AppDbUsername"
Write-Host "  App Password : $AppDbPassword"
Write-Host "  SYS Password : $OraclePassword"
Write-Host ""
Write-Host "SQL*Plus 接続:" -ForegroundColor White
Write-Host "  sqlplus ${AppDbUsername}/${AppDbPassword}@//${fqdn}:1521/XEPDB1"
Write-Host ""
Write-Host "application.yml:" -ForegroundColor White
Write-Host "  spring:"
Write-Host "    datasource:"
Write-Host "      url: $jdbcUrl"
Write-Host "      username: $AppDbUsername"
Write-Host "      password: $AppDbPassword"
Write-Host ""
Write-Host "ログ確認:" -ForegroundColor White
Write-Host "  az container logs -g $ResourceGroup -n $containerName"
Write-Host ""
Write-Host "注意: privileged モード + Preview API (2024-05-01-preview) を使用" -ForegroundColor Yellow
Write-Host "  /dev/shm を 2GB tmpfs として再マウントするために必要です" -ForegroundColor Yellow
