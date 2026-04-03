#!/bin/bash
# =============================================================
# 02_setup_schema.sh
# DIVINGAPPスキーマのセットアップ
# テーブル作成 → PL/SQLパッケージ → マスタデータ → サンプルデータ
# =============================================================

set -e

SCRIPTS_DIR="/opt/oracle/scripts"
CONN_STR="DIVINGAPP/divingapp123@localhost:1521/XEPDB1"

echo "=========================================="
echo " DIVINGAPPスキーマ セットアップ開始"
echo "=========================================="

# --- V001: テーブル・シーケンス・インデックス作成 ---
echo "[1/7] テーブル・シーケンス・インデックス作成..."
sqlplus -S "${CONN_STR}" <<'EOF'
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/opt/oracle/scripts/migration/V001__create_tables.sql
EOF

# --- V004: ダッシュボードレポート用テーブル ---
echo "[2/7] ダッシュボードレポート用テーブル作成..."
sqlplus -S "${CONN_STR}" <<'EOF'
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/opt/oracle/scripts/migration/V004__create_dashboard_tables.sql
EOF

# --- V002: PL/SQLパッケージ（仕様部） ---
echo "[3/7] PL/SQLパッケージ仕様部作成..."
for spec in \
    pkg_tour_spec.sql \
    pkg_reservation_spec.sql \
    pkg_customer_spec.sql \
    pkg_dive_site_spec.sql \
    pkg_instructor_spec.sql \
    pkg_diving_log_spec.sql \
    pkg_report_spec.sql \
    pkg_news_spec.sql
do
    echo "  - ${spec}"
    sqlplus -S "${CONN_STR}" <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/opt/oracle/scripts/packages/${spec}
EOF
done

# --- V002: PL/SQLパッケージ（本体） ---
echo "[4/7] PL/SQLパッケージ本体作成..."
for body in \
    pkg_tour_body.sql \
    pkg_reservation_body.sql \
    pkg_customer_body.sql \
    pkg_dive_site_body.sql \
    pkg_instructor_body.sql \
    pkg_diving_log_body.sql \
    pkg_report_body.sql \
    pkg_news_body.sql
do
    echo "  - ${body}"
    sqlplus -S "${CONN_STR}" <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/opt/oracle/scripts/packages/${body}
EOF
done

# --- V003: マスタデータ投入 ---
echo "[5/7] マスタデータ投入..."
sqlplus -S "${CONN_STR}" <<'EOF'
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/opt/oracle/scripts/migration/V003__insert_master_data.sql
EOF

# --- サンプルデータ投入 ---
echo "[6/7] サンプルデータ投入..."
sqlplus -S "${CONN_STR}" <<'EOF'
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/opt/oracle/scripts/seed/sample_data.sql
COMMIT;
EOF

# --- コンパイル状態確認 ---
echo ""
echo "[7/7] PL/SQLパッケージ コンパイル状態確認..."
sqlplus -S "${CONN_STR}" <<'EOF'
SET LINESIZE 120
SET PAGESIZE 50
COLUMN object_name FORMAT A30
COLUMN object_type FORMAT A20
COLUMN status FORMAT A10
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
 ORDER BY object_name, object_type;
EOF

echo ""
echo "=========================================="
echo " DIVINGAPPスキーマ セットアップ完了"
echo "=========================================="
