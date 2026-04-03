# Azure Deployment Plan — Oracle Dev DB on ACI

## Status: Deployed ✅

## Overview

ダイビングツアー予約システム (Ocean Dive Tours) の開発用 Oracle 21c XE データベースを
Azure Container Instances (ACI) にデプロイ。開発チームが共有できるリモート開発 DB 環境。

---

## Architecture

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
│  │  Oracle 21c XE (privileged mode)             ││
│  │  /dev/shm: 2GB tmpfs (mount at start)        ││
│  │  CPU: 2 cores, Memory: 4GB                   ││
│  │  Port: 1521 (Public IP)                       ││
│  │  PDB: XEPDB1, User: DIVINGAPP               ││
│  └──────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

## Azure Resources

| リソース | SKU/Tier | 用途 |
|---|---|---|
| Resource Group (`rg-divingapp-dev`) | — | 全リソースの格納先 |
| ACR (`acrdivingapp7659`) | Basic | カスタム Oracle イメージのホスティング |
| ACI (`aci-divingapp-oracledb`) | 2 vCPU / 4 GB RAM | Oracle 21c XE コンテナ実行 |

> **注**: Storage Account / File Share は不使用（サブスクリプションポリシー制約のため）。
> データは永続化されず、コンテナ再作成時に init スクリプトから再構築。

## Key Technical Decisions

### /dev/shm ワークアラウンド

ACI のデフォルト `/dev/shm` は 64MB だが Oracle XE の SGA は最低 1GB 必要。
ACI Preview API (`2024-05-01-preview`) の `privileged: true` を使用し、
コンテナ起動時に `mount -t tmpfs -o size=2g tmpfs /dev/shm` で再マウント。

### Docker イメージ構成

`gvenzl/oracle-xe:21-slim` をベースに以下を追加:
- `util-linux` — slim イメージに `mount` コマンドがないためインストール
- `container-entrypoint.sh` のシンボリックリンク — root PATH 対応
- 全 SQL スクリプトをイメージにベイク（ボリュームマウント不要）

### IaC

Bicep テンプレート (`infra/main.bicep`) で ACI を定義。
ACR は既存リソースとして参照。

## Files

| ファイル | 説明 |
|---|---|
| `infra/main.bicep` | Bicep テンプレート (ACI 定義) |
| `infra/main.parameters.json` | パラメータファイル |
| `docker/oracle/Dockerfile.aci` | ACI 用 Dockerfile |
| `docker/oracle/init-scripts/01_create_user.sql` | ユーザー権限付与 |
| `docker/oracle/init-scripts/02_setup_schema.sh` | スキーマ一括セットアップ |
| `scripts/deploy-aci.ps1` | ワンクリックデプロイスクリプト |
| `docs/azure-aci-setup.md` | セットアップ・運用ドキュメント |

## Cost Estimate (月額概算)

| リソース | 概算コスト |
|---|---|
| ACR Basic | ~$5/月 |
| ACI (2 vCPU, 4 GB, 常時起動) | ~$95/月 |
| **合計** | **~$100/月** |

> 使わない時は ACI を削除すれば課金は ACR の $5/月のみ。

## Deployment Log

- 2026-04-03: 初回デプロイ成功。全8パッケージ VALID、マスタデータ・サンプルデータ投入完了。
