# 開発環境構築手順

Ocean Dive Tours アプリケーションのローカル開発環境をセットアップする手順です。

---

## 目次

1. [前提条件](#前提条件)
2. [リポジトリの取得](#リポジトリの取得)
3. [方法A: Docker Compose で一括起動](#方法a-docker-compose-で一括起動)
4. [方法B: Oracle のみ Docker + ローカル Maven 起動](#方法b-oracle-のみ-docker--ローカル-maven-起動)
5. [データベースの初期セットアップ](#データベースの初期セットアップ)
6. [動作確認](#動作確認)
7. [よくあるトラブルと対処法](#よくあるトラブルと対処法)

---

## 前提条件

### 必須ソフトウェア

| ソフトウェア | バージョン | 備考 |
|---|---|---|
| Docker Desktop | 4.x 以上 | WSL2 バックエンド推奨 (Windows) |
| Docker Compose | V2 以上 | Docker Desktop に同梱 |

### ローカル Maven 起動時のみ追加で必要

| ソフトウェア | バージョン | 備考 |
|---|---|---|
| Java JDK | **8** (1.8) | OpenJDK 8 / Amazon Corretto 8 等 |
| Apache Maven | 3.8 以上 | |

### ハードウェア要件

- **メモリ**: 8GB 以上推奨（Oracle 19c XE は約 2GB 使用）
- **ディスク**: 10GB 以上の空き容量（Oracle イメージ + データ）

---

## リポジトリの取得

```bash
git clone <repository-url>
cd legacy-java-app-oracle
```

---

## 方法A: Docker Compose で一括起動

アプリケーションと Oracle DB の両方を Docker コンテナで起動します。最も簡単な方法です。

### 1. 環境変数ファイルの準備

```bash
cp .env.example .env
```

必要に応じて `.env` のパスワード等を変更してください（デフォルト値のままでも動作します）。

```properties
# .env
ORACLE_PASSWORD=oracle123      # Oracle SYS/SYSTEM パスワード
APP_DB_USERNAME=DIVINGAPP      # アプリ用スキーマユーザー名
APP_DB_PASSWORD=divingapp123   # アプリ用スキーマパスワード
```

### 2. コンテナ起動

```bash
docker-compose up -d
```

> **初回起動時の注意:** Oracle 19c XE の初期化に **3〜5分** かかります。`oracle-db` コンテナのヘルスチェックが `healthy` になるまでアプリコンテナは待機します。

### 3. 起動状況の確認

```bash
# コンテナ状態を確認
docker-compose ps

# Oracle DBのヘルスチェック状態を確認
docker inspect --format='{{.State.Health.Status}}' diving-oracle-db

# アプリケーションのログを確認
docker-compose logs -f app
```

`app` コンテナのログに `Started DivingAppApplication` が出力されれば起動完了です。

### 4. 停止・再起動

```bash
# 停止
docker-compose down

# 停止（データボリュームも削除 → DB初期化からやり直し）
docker-compose down -v

# 再起動（ソースコード変更後のリビルド含む）
docker-compose up -d --build app
```

---

## 方法B: Oracle のみ Docker + ローカル Maven 起動

開発中のホットリロードを活用したい場合はこちらの方法がおすすめです。

### 1. 環境変数ファイルの準備

```bash
cp .env.example .env
```

### 2. Oracle DB コンテナの起動

```bash
docker-compose up -d oracle-db
```

ヘルスチェックが `healthy` になるまで待ちます:

```bash
# 状態を繰り返し確認
docker inspect --format='{{.State.Health.Status}}' diving-oracle-db
```

### 3. Java / Maven のバージョン確認

```bash
java -version
# java version "1.8.0_xxx" が表示されること

mvn -version
# Apache Maven 3.8.x が表示されること
```

> **JAVA_HOME** が JDK 8 を指していることを確認してください。

### 4. アプリケーションの起動

```bash
mvn spring-boot:run
```

デフォルトプロファイル（`localhost:1521/XEPDB1`）で Oracle DB に接続します。

> **ホットリロード**: `spring-boot-devtools` が含まれているため、Java ソースやテンプレートの変更時に自動リスタートします。

---

## データベースの初期セットアップ

### Docker Compose の場合（方法A）

Docker イメージビルド時に `docker/oracle/init-scripts/01_create_user.sql` が自動実行され、`DIVINGAPP` ユーザーが作成されます。

ただし、テーブル・PL/SQL パッケージ・データの投入は別途実行が必要です。

### SQL の手動実行

Oracle DB コンテナに接続して SQL を実行します:

```bash
# コンテナ内で SQL*Plus を起動
docker exec -it diving-oracle-db sqlplus DIVINGAPP/divingapp123@//localhost:1521/XEPDB1
```

以下の順序で SQL ファイルを実行してください:

#### Step 1: テーブル作成

```sql
@/opt/oracle/scripts/migration/V001__create_tables.sql
```

#### Step 2: PL/SQL パッケージ作成

パッケージは **仕様部 → 本体** の順に実行する必要があります。

```sql
-- 仕様部（全パッケージ）
@/opt/oracle/scripts/packages/pkg_tour_spec.sql
@/opt/oracle/scripts/packages/pkg_reservation_spec.sql
@/opt/oracle/scripts/packages/pkg_customer_spec.sql
@/opt/oracle/scripts/packages/pkg_dive_site_spec.sql
@/opt/oracle/scripts/packages/pkg_instructor_spec.sql
@/opt/oracle/scripts/packages/pkg_diving_log_spec.sql
@/opt/oracle/scripts/packages/pkg_report_spec.sql
@/opt/oracle/scripts/packages/pkg_news_spec.sql

-- 本体（全パッケージ）
@/opt/oracle/scripts/packages/pkg_tour_body.sql
@/opt/oracle/scripts/packages/pkg_reservation_body.sql
@/opt/oracle/scripts/packages/pkg_customer_body.sql
@/opt/oracle/scripts/packages/pkg_dive_site_body.sql
@/opt/oracle/scripts/packages/pkg_instructor_body.sql
@/opt/oracle/scripts/packages/pkg_diving_log_body.sql
@/opt/oracle/scripts/packages/pkg_report_body.sql
@/opt/oracle/scripts/packages/pkg_news_body.sql
```

#### Step 3: マスタデータ投入

```sql
@/opt/oracle/scripts/migration/V003__insert_master_data.sql
```

#### Step 4: サンプルデータ投入（任意）

```sql
@/opt/oracle/scripts/seed/sample_data.sql
```

#### Step 5: パッケージ状態の検証

```sql
-- INVALID なパッケージがないことを確認
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY object_name, object_type;
```

全パッケージの STATUS が `VALID` であれば正常です。

---

## 動作確認

### アクセスURL

| URL | 画面 |
|---|---|
| http://localhost:8080 | トップページ |
| http://localhost:8080/tours | ツアー一覧 |
| http://localhost:8080/divesites | ダイブサイト一覧 |
| http://localhost:8080/instructors | インストラクター一覧 |
| http://localhost:8080/customer/login | ログイン |
| http://localhost:8080/admin | 管理者ダッシュボード |

### テストアカウント（sample_data.sql 投入後）

| 種別 | Email | Password |
|---|---|---|
| 顧客 | tanaka@example.com | test1234 |
| 顧客 | suzuki@example.com | test1234 |

### 確認チェックリスト

- [ ] トップページが表示される
- [ ] おすすめツアーのカードが表示される
- [ ] ツアー一覧ページで検索できる
- [ ] ツアー詳細ページでスケジュール一覧が表示される
- [ ] テストアカウントでログインできる
- [ ] マイページが表示される

---

## よくあるトラブルと対処法

### Oracle DB コンテナが起動しない / healthy にならない

```bash
# ログを確認
docker-compose logs oracle-db

# コンテナを再作成（データボリューム削除）
docker-compose down -v
docker-compose up -d oracle-db
```

- **メモリ不足**: Docker Desktop の設定で割り当てメモリを 4GB 以上に増やしてください
- **ポート競合**: 1521 ポートが他のプロセスで使用されていないか確認してください

### ORA-01017: invalid username/password

`DIVINGAPP` ユーザーが作成されていない可能性があります。

```bash
# SYSユーザーで接続してユーザーを手動作成
docker exec -it diving-oracle-db sqlplus sys/oracle123@//localhost:1521/XEPDB1 as sysdba
```

```sql
@/container-entrypoint-initdb.d/01_create_user.sql
```

### PL/SQL パッケージが INVALID

```sql
-- 再コンパイル
ALTER PACKAGE PKG_TOUR COMPILE;
ALTER PACKAGE PKG_TOUR COMPILE BODY;
-- 他のパッケージも同様に

-- または全オブジェクトを一括再コンパイル
EXEC DBMS_UTILITY.COMPILE_SCHEMA(schema => 'DIVINGAPP');
```

### アプリ起動時に接続エラー

- Oracle DB コンテナが `healthy` 状態か確認
- `application.yml` の接続先 (`localhost:1521/XEPDB1`) が正しいか確認
- ファイアウォールが 1521 ポートをブロックしていないか確認

### Maven ビルドエラー（Java バージョン）

```
[ERROR] Failed to execute goal ... source release 8 requires target release 8
```

`JAVA_HOME` が JDK 8 を指しているか確認してください:

```bash
echo %JAVA_HOME%        # Windows
echo $JAVA_HOME         # macOS/Linux
```

### docker-compose up --build 後にアプリの変更が反映されない

Maven キャッシュが残っている可能性があります:

```bash
mvn clean
docker-compose up -d --build app
```

---

## 補足: DB接続情報まとめ

| 項目 | 値 |
|---|---|
| ホスト | `localhost` (ローカル) / `oracle-db` (Docker内) |
| ポート | `1521` |
| サービス名 | `XEPDB1` |
| JDBC URL | `jdbc:oracle:thin:@localhost:1521/XEPDB1` |
| スキーマユーザー | `DIVINGAPP` |
| パスワード | `divingapp123` |
| SYSパスワード | `oracle123` |

### SQL*Plus / SQLcl 接続コマンド

```bash
# コンテナ内から
docker exec -it diving-oracle-db sqlplus DIVINGAPP/divingapp123@//localhost:1521/XEPDB1

# ホストマシンから（SQL*Plus インストール済みの場合）
sqlplus DIVINGAPP/divingapp123@//localhost:1521/XEPDB1

# SQLcl の場合
sql DIVINGAPP/divingapp123@//localhost:1521/XEPDB1
```
