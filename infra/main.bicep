// =============================================================
// main.bicep
// Oracle 21c XE 開発 DB を Azure Container Instances にデプロイ
// リソース: ACI (ACR は事前に作成済み)
// 特権モード: /dev/shm を 2GB tmpfs として再マウント（Oracle XE 要件）
// =============================================================

@description('リソースのデプロイ先リージョン')
param location string = resourceGroup().location

@description('プロジェクト名（リソース名のプレフィックス）')
param projectName string = 'divingapp'

@description('既存 ACR のリソース名')
param acrName string

@description('Oracle SYS/SYSTEM パスワード')
@secure()
param oraclePassword string

@description('アプリ用DBユーザー名')
param appDbUsername string = 'DIVINGAPP'

@description('アプリ用DBパスワード')
@secure()
param appDbPassword string

@description('ACI の CPU コア数')
param containerCpuCores int = 2

@description('ACI のメモリ (GB)')
param containerMemoryGb int = 4

// --- 命名規則 ---
var uniqueSuffix = uniqueString(resourceGroup().id)
var containerGroupName = 'aci-${projectName}-oracledb'
var imageName = '${projectName}/oracle-dev:latest'

// =============================================================
// 既存の ACR を参照
// =============================================================
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

// =============================================================
// Azure Container Instance (Oracle 21c XE)
// =============================================================
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2024-05-01-preview' = {
  name: containerGroupName
  location: location
  properties: {
    osType: 'Linux'
    restartPolicy: 'OnFailure'
    imageRegistryCredentials: [
      {
        server: acr.properties.loginServer
        username: acr.listCredentials().username
        password: acr.listCredentials().passwords[0].value
      }
    ]
    containers: [
      {
        name: 'oracle-dev'
        properties: {
          image: '${acr.properties.loginServer}/${imageName}'
          // ACI の /dev/shm は 64MB（Oracle XE は >= 1GB 必要）
          // 特権モードで tmpfs を再マウントしてから oracle ユーザーでエントリポイント実行
          command: [
            '/bin/bash'
            '-c'
            'mount -t tmpfs -o size=2g tmpfs /dev/shm && exec runuser -u oracle -- container-entrypoint.sh'
          ]
          ports: [
            {
              port: 1521
              protocol: 'TCP'
            }
          ]
          environmentVariables: [
            {
              name: 'ORACLE_PASSWORD'
              secureValue: oraclePassword
            }
            {
              name: 'APP_USER'
              value: appDbUsername
            }
            {
              name: 'APP_USER_PASSWORD'
              secureValue: appDbPassword
            }
          ]
          resources: {
            requests: {
              cpu: containerCpuCores
              memoryInGB: containerMemoryGb
            }
          }
          securityContext: {
            privileged: true
          }
        }
      }
    ]
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 1521
          protocol: 'TCP'
        }
      ]
      dnsNameLabel: '${projectName}-oracledb-${uniqueSuffix}'
    }
  }
}

// =============================================================
// Outputs
// =============================================================
output acrLoginServer string = acr.properties.loginServer
output acrName string = acrName
output containerGroupName string = containerGroup.name
output containerFqdn string = containerGroup.properties.ipAddress.fqdn
output containerIpAddress string = containerGroup.properties.ipAddress.ip
output jdbcUrl string = 'jdbc:oracle:thin:@${containerGroup.properties.ipAddress.fqdn}:1521/XEPDB1'
