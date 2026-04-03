# Azure Container Instances (ACI) - Oracle 21c XE 開発 DB セットアップ

## 概要

ダイビングツアー予約システム (Ocean Dive Tours) の開発用 Oracle 21c XE データベースを
Azure Container Instances (ACI) にデプロイする構成です。

### アーキテクチャ

```
┌─────────────────────────────────────────────────┐
│ Resource Group: rg-divingapp-dev (japaneast)     │
│                                                   │
│  ┌──────────────────────┐                        │
│  │ ACR: acrdivingapp7659│  ← Docker イメージ格納  │
│  │ (Basic SKU)          │     gvenzl/oracle-xe    │
│  └──────────┬───────────┘     :21-slim ベース     │
│             │ pull                                │
│  ┌──────────▼───────────────────────────────────┐│
│  │ ACI: aci-divingapp-oracledb                  ││
│  │ ┌─────────────────────────────────────────┐  ││
│  │ │  Oracle 21c XE (privileged mode)        │  ││
│  │ │  /dev/shm: 2GB tmpfs (mount at start)   │  ││
│  │ │  CPU: 2 cores, Memory: 4GB              │  ││
│  │ │  Port: 1521 (Public IP)                 │  ││
│  │ │  PDB: XEPDB1                            │  ││
│  │ │  App User: DIVINGAPP                    │  ││
│  │ └─────────────────────────────────────────┘  ││
│  └──────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

## 前提条件

- Azure CLI (`az`) ログイン済み
- Azure サブスクリプションに Contributor 以上の権限
- Docker Desktop は **不要**（ACR Tasks でリモートビルド）

## クイックスタート

```powershell
# 1. デプロイスクリプトを実行（全自動）
.\scripts\deploy-aci.ps1

# 2. または手動で Bicep デプロイ
az deployment group create \
  --resource-group rg-divingapp-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json
```

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `infra/main.bicep` | ACI リソース定義（Bicep テンプレート） |
| `infra/main.parameters.json` | パラメータファイル |
| `docker/oracle/Dockerfile.aci` | ACI 用 Oracle イメージ定義 |
| `docker/oracle/init-scripts/01_create_user.sql` | アプリ用ユーザー権限付与 |
| `docker/oracle/init-scripts/02_setup_schema.sh` | スキーマ一括セットアップ |
| `scripts/deploy-aci.ps1` | ワンクリックデプロイスクリプト |

## 技術的な詳細

### /dev/shm 制約とワークアラウンド

ACI の `/dev/shm` はデフォルト 64MB ですが、Oracle XE の SGA は最低 1GB 必要です。
この制約に対処するため、以下の構成を採用しています:

1. **ACI Preview API** (`2024-05-01-preview`) で `privileged: true` を設定
2. コンテナ起動時に `mount -t tmpfs -o size=2g tmpfs /dev/shm` を実行
3. `Dockerfile.aci` に `util-linux` をインストール（slim イメージには `mount` コマンドがない）
4. `runuser -u oracle` で Oracle プロセスを oracle ユーザーとして実行

### Dockerfile.aci の構成

```dockerfile
FROM ${ACR}.azurecr.io/gvenzl/oracle-xe:21-slim
# SQL スクリプトをイメージにベイク
COPY docker/oracle/init-scripts/ /container-entrypoint-initdb.d/
COPY db/migration/ /opt/oracle/scripts/migration/
COPY db/packages/ /opt/oracle/scripts/packages/
COPY db/seed/ /opt/oracle/scripts/seed/
USER root
RUN microdnf install -y util-linux && microdnf clean all
RUN ln -sf /opt/oracle/container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
```

### データベース初期化の順序

`02_setup_schema.sh` が以下の順序でスキーマを構築します:

1. `V001__create_tables.sql` — テーブル・シーケンス・インデックス
2. `V004__create_dashboard_tables.sql` — ダッシュボード用テーブル
3. PL/SQL パッケージ仕様部 (8 パッケージ)
4. PL/SQL パッケージ本体 (8 パッケージ)
5. `V003__insert_master_data.sql` — マスタデータ
6. `sample_data.sql` — テスト用サンプルデータ
7. コンパイル状態確認

### Bicep パラメータ

| パラメータ | デフォルト | 説明 |
|-----------|-----------|------|
| `location` | `japaneast` | リージョン |
| `projectName` | `divingapp` | 名前プレフィックス |
| `acrName` | — | 既存 ACR のリソース名 |
| `oraclePassword` | — | Oracle SYS/SYSTEM パスワード |
| `appDbUsername` | `DIVINGAPP` | アプリ用 DB ユーザー名 |
| `appDbPassword` | — | アプリ用 DB パスワード |
| `containerCpuCores` | `2` | CPU コア数 |
| `containerMemoryGb` | `4` | メモリ (GB) |

## 接続情報

```
Host     : <FQDN> (デプロイ後に表示)
Port     : 1521
Service  : XEPDB1
User     : DIVINGAPP
Password : divingapp123 (デフォルト)
```

### Spring Boot (application.yml)

```yaml
spring:
  datasource:
    url: jdbc:oracle:thin:@<FQDN>:1521/XEPDB1
    username: DIVINGAPP
    password: divingapp123
    driver-class-name: oracle.jdbc.OracleDriver
```

### SQL*Plus

```bash
sqlplus DIVINGAPP/divingapp123@//<FQDN>:1521/XEPDB1
```

## 運用

### ログ確認

```powershell
az container logs -g rg-divingapp-dev -n aci-divingapp-oracledb
```

### コンテナ再起動（DB 再初期化）

```powershell
# コンテナを削除して再デプロイ（DB はゼロから再構築）
az container delete -g rg-divingapp-dev -n aci-divingapp-oracledb --yes
az deployment group create -g rg-divingapp-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json
```

### リソース削除

```powershell
# リソースグループごと削除
az group delete --name rg-divingapp-dev --yes --no-wait
```

## トラブルシューティング

| 現象 | 原因 | 対処 |
|------|------|------|
| ExitCode 153/216 | `/dev/shm` が 64MB | `privileged: true` + `mount tmpfs` を確認 |
| Listener permission denied | root で Oracle 起動 | `runuser -u oracle` を確認 |
| `mount` command not found | slim イメージ | Dockerfile で `util-linux` インストール確認 |
| ORA-06553: PLS-221 | SQL 内で PL/SQL 定数を使用 | INSERT では数値定数 `4` を使う |
| ORA-12899: value too large | カラムサイズ不足 | VARCHAR2 のバイト数を確認 |
| CrashLoopBackOff | 初期化エラーで exit != 0 | `az container logs` でエラー内容を確認 |

## 制約事項

- **開発専用**: 本構成は開発・テスト用です。本番環境では使用しないでください
- **永続化なし**: コンテナ再作成時にデータは失われます（init スクリプトで再構築）
- **Preview API**: `2024-05-01-preview` API を使用（privileged mode のため）
- **パブリック IP**: ポート 1521 がインターネットに公開されます
