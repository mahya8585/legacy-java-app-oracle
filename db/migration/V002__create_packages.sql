-- =============================================================
-- V002__create_packages.sql
-- 全PL/SQLパッケージの作成（仕様部 + 本体）
-- 実行順序: 仕様部を先に全て作成してから本体を作成
-- =============================================================

-- =====================
-- パッケージ仕様部
-- =====================

@@../packages/pkg_tour_spec.sql
@@../packages/pkg_reservation_spec.sql
@@../packages/pkg_customer_spec.sql
@@../packages/pkg_dive_site_spec.sql
@@../packages/pkg_instructor_spec.sql
@@../packages/pkg_diving_log_spec.sql
@@../packages/pkg_report_spec.sql
@@../packages/pkg_news_spec.sql

-- =====================
-- パッケージ本体
-- =====================

@@../packages/pkg_tour_body.sql
@@../packages/pkg_reservation_body.sql
@@../packages/pkg_customer_body.sql
@@../packages/pkg_dive_site_body.sql
@@../packages/pkg_instructor_body.sql
@@../packages/pkg_diving_log_body.sql
@@../packages/pkg_report_body.sql
@@../packages/pkg_news_body.sql

-- =====================
-- コンパイル状態確認
-- =====================
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY object_type, object_name;
