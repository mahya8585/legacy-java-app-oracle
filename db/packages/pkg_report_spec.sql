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
END PKG_REPORT;
/
