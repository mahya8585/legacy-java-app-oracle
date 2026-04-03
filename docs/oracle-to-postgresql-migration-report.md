# Oracle → PostgreSQL マイグレーション セッションレポート

**作成日:** 2026年4月3日  
**対象システム:** Diving Tour Booking Application (legacy-java-app-oracle)

---

## 1. 実施した作業一覧

| # | 作業内容 | 対象 | 結果 |
|---|---------|------|------|
| 1 | **PostgreSQL データベース作成** | `diving-postgre.postgres.database.azure.com` に `divingapp` DB を作成 | 成功 |
| 2 | **Oracle スキーマ抽出** | Oracle XE 21c (`DIVINGAPP` スキーマ) から57オブジェクト抽出 | 成功 (100%) |
| 3 | **DDL変換 (20チャンク)** | 全56オブジェクトを PostgreSQL DDL に変換 | 成功 (100%) |

---

## 2. 変換されたオブジェクトの内訳

| オブジェクト種別 | 個数 | Oracle → PostgreSQL 主な変換内容 |
|----------|------|-------------------------------|
| **Schema** | 1 | `DIVINGAPP` → `divingapp` (小文字化) |
| **Sequence** | 13 | `MAXVALUE` 省略 (Oracle28桁 > BIGINT範囲), `NOCACHE`/`NOORDER` 削除 |
| **Table** | 15 | `NUMBER` → `BIGINT`, `VARCHAR2` → `VARCHAR`, `CLOB` → `TEXT`, `DATE` → `TIMESTAMP`, `RAW(64)` → `BYTEA`, `SYSTIMESTAMP` → `CURRENT_TIMESTAMP`, Oracle storage句すべて削除 |
| **Index** | 19 | スキーマ修飾削除, `PCTFREE`/`TABLESPACE`等の物理属性削除 |
| **Package** | 8 | 個別関数/プロシージャに分解 (次項で詳述) |

---

## 3. PL/SQL パッケージ変換の詳細

| パッケージ | 変換ポイント |
|-----------|-------------|
| **PKG_CUSTOMER** | `DBMS_CRYPTO.HASH` + `UTL_I18N.STRING_TO_RAW` → `pgcrypto` の `digest(convert_to(...,'UTF8'),'sha256')`, `SYS_REFCURSOR` → `RETURNS TABLE`, `COMMIT`/`ROLLBACK` 削除 |
| **PKG_DIVE_SITE** | `SYS_REFCURSOR OUT` → set-returning function, `RAISE_APPLICATION_ERROR` 削除 |
| **PKG_INSTRUCTOR** | `SYS_REFCURSOR` → `REFCURSOR` INOUT パラメータ |
| **PKG_TOUR** | 5プロシージャに分解, `DBMS_LOB.INSTR` → `POSITION()`, `NVL` → `COALESCE`, `DUAL` 削除 |
| **PKG_REPORT** | 4プロシージャに分解, `CONNECT BY` → `WITH RECURSIVE`, `LISTAGG` → `string_agg`, `MERGE` → `INSERT ... ON CONFLICT`, `ADD_MONTHS` → interval演算 |
| **PKG_DIVING_LOG** | `REF CURSOR` + `OUT` パラメータ → set-returning function, `RAISE_APPLICATION_ERROR` → `RAISE EXCEPTION` |
| **PKG_RESERVATION** | `NEXTVAL`/`DUAL` → `nextval('schema.seq')`, `REGEXP_COUNT`/`REGEXP_SUBSTR` → `regexp_split_to_array` |
| **PKG_NEWS** | `SYS_REFCURSOR` → `SETOF divingapp.news`, `TRUNC(SYSDATE)` → `date_trunc('day', CURRENT_TIMESTAMP)` |

---

## 4. 生成されたアーティファクト

```
.github/postgres-migrations/ora2pg-test/artifacts/
├── chunks/
│   ├── oracle_json/     … chunk-000 ~ 019 (Oracle DDL JSON)
│   ├── postgres_json/   … chunk-000 ~ 019 (PostgreSQL DDL JSON)
│   └── postgres/        … chunk-000.sql ~ 019.sql (実行可能SQL)
├── object_trackers/     … chunk-000 ~ 019_tracker.json (変換追跡)
├── oracle/              … 抽出済みOracle DDL + deps.json + export_index.csv
└── migration.yaml       … レビュータスク一覧
```

---

## 5. 未解決のレビュータスク (`migration.yaml`)

| 対象テーブル/パッケージ | 種別 | 優先度 | チェック観点 |
|-------------------|------|--------|------------|
| `DIVE_SITES` | performance_concern | low | LOBカラム、テーブル圧縮、21カラム |
| `OPTIONS_MASTER` | performance_concern | low | テーブル圧縮 |
| `INSTRUCTORS` | performance_concern | low | LOBカラム、テーブル圧縮 |
| `REPORT_CACHE` | performance_concern | low | テーブル圧縮 |
| `NEWS` | performance_concern | low | LOBカラム、テーブル圧縮 |
| `PKG_NEWS` | complex_object_conversion | medium | パッケージ変換の正確性 |

---

## 6. Oracle → PostgreSQL 変換チェックリスト (再利用向け)

今回の変換で適用されたルールを、今後同じバグを踏まないためのチェックリストとして整理:

### データ型マッピング
- [ ] `NUMBER` (精度/スケールなし) → `BIGINT`
- [ ] `NUMBER(p,s)` → `NUMERIC(p,s)`
- [ ] `VARCHAR2(n)` → `VARCHAR(n)`
- [ ] `CLOB` → `TEXT`
- [ ] `DATE` → `TIMESTAMP` (**Oracle DATEは時刻を含む**)
- [ ] `RAW(n)` → `BYTEA`
- [ ] `TIMESTAMP(6)` → `TIMESTAMP(6)` (そのまま)

### シーケンス
- [ ] Oracle `MAXVALUE 9999999999999999999999999999` → **省略** (PostgreSQL BIGINTの範囲超過)
- [ ] `NOCACHE` → `CACHE 1` または省略
- [ ] `NOORDER` / `NOKEEP` / `NOSCALE` / `GLOBAL` → **削除** (PG該当なし)
- [ ] `SEQ_XXX.NEXTVAL` → `nextval('divingapp.seq_xxx')` (スキーマ修飾+小文字)
- [ ] `SELECT ... FROM DUAL` → **DUAL削除** (PGでは不要)

### テーブル
- [ ] `SYSTIMESTAMP` → `CURRENT_TIMESTAMP`
- [ ] `SYSDATE` → `CURRENT_TIMESTAMP` / `current_date`
- [ ] `TRUNC(SYSDATE)` → `date_trunc('day', CURRENT_TIMESTAMP)`
- [ ] Oracle storage句 (`PCTFREE`, `INITRANS`, `MAXTRANS`, `TABLESPACE`, `STORAGE`, `SEGMENT`, `COMPRESS`) → **全削除**
- [ ] `SecureFile LOB` 句 → **削除**
- [ ] `ENABLE`/`USING INDEX` 句 → **削除**

### インデックス
- [ ] スキーマ修飾 (`DIVINGAPP.IDX_XXX`) → スキーマ名除去 (`idx_xxx`)
- [ ] `COMPUTE STATISTICS` → **削除** (PGでは `ANALYZE` で別途実行)
- [ ] 物理属性 (`PCTFREE`/`TABLESPACE`等) → **全削除**

### PL/SQL → PL/pgSQL パッケージ変換
- [ ] Oracle `PACKAGE` → **個別の `FUNCTION` / `PROCEDURE` に分解**
- [ ] `SYS_REFCURSOR OUT` → `RETURNS TABLE(...)` (set-returning function) **または** `REFCURSOR INOUT`
- [ ] `COMMIT` / `ROLLBACK` → **削除** (PG関数内でトランザクション制御不可、呼び出し側に委譲)
- [ ] `NVL(a, b)` → `COALESCE(a, b)`
- [ ] `DBMS_CRYPTO.HASH` + `UTL_I18N.STRING_TO_RAW` → **`pgcrypto` 拡張 + `digest(convert_to(text,'UTF8'),'sha256')`**
- [ ] `DBMS_LOB.INSTR` → `POSITION()`
- [ ] `RAISE_APPLICATION_ERROR(-nnnnn, msg)` → `RAISE EXCEPTION 'msg' USING ERRCODE = 'P0001'`
- [ ] `CONNECT BY` 階層クエリ → `WITH RECURSIVE`
- [ ] `LISTAGG(col, sep)` → `string_agg(col, sep)`
- [ ] `ADD_MONTHS(date, n)` → `date + INTERVAL 'n months'`
- [ ] `MERGE INTO` → `INSERT ... ON CONFLICT ... DO UPDATE`
- [ ] `REGEXP_COUNT` / `REGEXP_SUBSTR` → `regexp_split_to_array`

### 前提条件
- [ ] マイグレーション先DBに **`CREATE EXTENSION IF NOT EXISTS pgcrypto;`** を実行済みであること (PKG_CUSTOMER のハッシュ関数が依存)
- [ ] `REPORT_CACHE` に `(report_key, section, metric_name)` のユニーク制約があること (PKG_REPORT の `ON CONFLICT` が依存)

---

## 7. 次のステップ

1. **生成SQL の適用** — `chunk-000.sql` ～ `chunk-019.sql` を順番に `divingapp` DBへ実行
2. **pgcrypto 拡張の有効化** — `CREATE EXTENSION IF NOT EXISTS pgcrypto;`
3. **レビュータスク消化** — `migration.yaml` の medium 優先度 (`PKG_NEWS`) を優先確認
4. **サンプルデータ投入** — `db/seed/sample_data.sql` の Oracle→PG 変換と投入
5. **アプリケーション側の接続設定変更** — `src/main/resources/application.yml` の JDBC URL / DAO層 の Oracle依存コード修正
