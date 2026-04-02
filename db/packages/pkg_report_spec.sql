CREATE OR REPLACE PACKAGE PKG_REPORT AS
    -- 月別売上集計レポート
    PROCEDURE GET_MONTHLY_SALES(
        p_year          IN  NUMBER,
        p_month         IN  NUMBER DEFAULT NULL,
        o_report        OUT SYS_REFCURSOR
    );

    -- ツアー別人気ランキング
    PROCEDURE GET_TOUR_POPULARITY(
        p_date_from     IN  DATE DEFAULT NULL,
        p_date_to       IN  DATE DEFAULT NULL,
        p_limit         IN  NUMBER DEFAULT 10,
        o_report        OUT SYS_REFCURSOR
    );

    -- 稼働率レポート
    PROCEDURE GET_OCCUPANCY_RATE(
        p_year          IN  NUMBER,
        p_month         IN  NUMBER DEFAULT NULL,
        o_report        OUT SYS_REFCURSOR
    );

    -- 包括的ダッシュボードレポート生成
    -- 売上推移・エリア×難易度クロス集計・インストラクターKPI・
    -- 顧客セグメント・キャンセル傾向・異常検知アラートを一括生成
    PROCEDURE GENERATE_DASHBOARD_REPORT(
        p_year              IN  NUMBER,
        p_month             IN  NUMBER DEFAULT NULL,
        o_sales_trend       OUT SYS_REFCURSOR,
        o_area_matrix       OUT SYS_REFCURSOR,
        o_instructor_kpi    OUT SYS_REFCURSOR,
        o_customer_segment  OUT SYS_REFCURSOR,
        o_cancel_analysis   OUT SYS_REFCURSOR,
        o_anomaly_alerts    OUT SYS_REFCURSOR
    );
END PKG_REPORT;
/
