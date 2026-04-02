# Ocean Dive Tours - レガシーダイビングツアー管理アプリケーション

Java 8 / Spring Boot 2.7 / Oracle 19c / Thymeleaf によるレガシーアーキテクチャのダイビングツアー予約管理システム。

## 技術スタック

| レイヤー | 技術 |
|---|---|
| 言語 | Java 8 |
| フレームワーク | Spring Boot 2.7.18 |
| テンプレート | Thymeleaf + Layout Dialect 3.1.0 |
| データベース | Oracle 19c XE |
| データアクセス | JdbcTemplate + SimpleJdbcCall（JPA不使用） |
| ビジネスロジック | Oracle PL/SQL パッケージ |
| 認証 | Spring Security 5（セッションベース） |
| パスワード | DBMS_CRYPTO SHA-256（PL/SQL側） |
| コンテナ | Docker + Docker Compose |

## アーキテクチャ

```
Controller → Service (@Transactional) → DAO (SimpleJdbcCall) → Oracle PL/SQL Package
```

- **Java側はデータの受け渡しのみ** — ビジネスロジックはすべてPL/SQLパッケージ内に実装
- **ORM不使用** — JdbcTemplateとSimpleJdbcCallでPL/SQLプロシージャを直接呼び出し
- PL/SQLはSYS_REFCURSORでカーソルを返し、Java側でRowMapperによりDTOにマッピング

## ディレクトリ構成

```
├── docker/
│   └── oracle/
│       ├── Dockerfile              # Oracle 19c XEイメージ
│       └── init-scripts/
│           └── 01_create_user.sql  # スキーマユーザー作成
├── db/
│   ├── migration/
│   │   ├── V001__create_tables.sql # テーブル・シーケンス・インデックス
│   │   ├── V002__create_packages.sql
│   │   ├── V003__insert_master_data.sql
│   │   └── V004__create_dashboard_tables.sql # ダッシュボードレポート用テーブル
│   ├── packages/                   # PL/SQLパッケージ（8パッケージ×spec/body）
│   └── seed/
│       └── sample_data.sql
├── src/main/java/com/divingapp/
│   ├── config/                     # DataSource, Security, Auth
│   ├── controller/                 # 公開・顧客画面コントローラ
│   │   └── admin/                  # 管理者画面コントローラ
│   ├── dao/                        # DAOクラス（SimpleJdbcCall）
│   ├── dto/                        # DTOクラス
│   ├── form/                       # フォームクラス
│   └── service/                    # サービスクラス（@Transactional）
├── src/main/resources/
│   ├── templates/                  # Thymeleafテンプレート
│   ├── static/css/                 # CSS
│   ├── static/js/                  # JavaScript
│   ├── application.yml             # アプリケーション設定
│   └── messages.properties         # メッセージ定義
├── docker-compose.yml
├── Dockerfile                      # アプリケーションDockerイメージ
└── pom.xml
```

## PL/SQLパッケージ一覧

| パッケージ | 機能 |
|---|---|
| PKG_TOUR | ツアー検索・詳細・おすすめ・保存・削除 |
| PKG_RESERVATION | 予約作成（楽観ロック）・キャンセル（返金計算）・一覧 |
| PKG_CUSTOMER | 認証（SHA-256）・会員登録・プロフィール更新 |
| PKG_DIVE_SITE | ダイブサイト一覧・詳細 |
| PKG_INSTRUCTOR | インストラクター一覧・詳細 |
| PKG_DIVING_LOG | ダイビングログ一覧・保存 |
| PKG_REPORT | 月次売上・ツアー人気（RANK）・稼働率・総合ダッシュボードレポート生成 |
| PKG_NEWS | ニュース一覧・保存 |

## セットアップ

### 前提条件

- Docker & Docker Compose
- Java 8 JDK（ローカル開発時）
- Maven 3.8+（ローカル開発時）

### Docker Compose で起動

```bash
# 環境変数ファイルをコピー
cp .env.example .env
# 必要に応じて .env を編集

# 起動（Oracle DB初回起動は数分かかります）
docker-compose up -d

# ログ確認
docker-compose logs -f app
```

### ローカル開発（パッケージ管理ツールから直接起動）

```bash
# Oracle DBのみDockerで起動
docker-compose up -d oracle-db

# DBスキーマ・PL/SQLパッケージを手動投入
# Oracle SQL*Plus や SQLcl で db/migration/ と db/packages/ のSQLを実行

# アプリケーション起動
mvn spring-boot:run
```

### アクセス

| URL | 説明 |
|---|---|
| http://localhost:8080 | トップページ |
| http://localhost:8080/tours | ツアー一覧 |
| http://localhost:8080/customer/login | ログイン |
| http://localhost:8080/admin | 管理者ダッシュボード |

### テストアカウント（sample_data.sql投入後）

| 種別 | Email | Password |
|---|---|---|
| 顧客 | tanaka@example.com | test1234 |
| 顧客 | suzuki@example.com | test1234 |

## 設計上の意図

このアプリケーションは**意図的にレガシーアーキテクチャ**で構築されています：

- **Java 8** — 最新のJavaバージョン（17/21）を使わない
- **Spring Boot 2.7** — Spring Boot 3.x（Jakarta EE）を使わない
- **JPA不使用** — JdbcTemplate + SimpleJdbcCall で直接PL/SQL呼び出し
- **PL/SQLにビジネスロジック集中** — Java側は薄いレイヤーのみ
- **DBMS_CRYPTO** — Spring Security のBCrypt を使わず、Oracle側でパスワードハッシュ
- **サーバーサイドレンダリング** — SPA/REST APIではなくThymeleafによるMVCパターン

これはモダナイゼーション演習やマイグレーション評価の素材として設計されています。
