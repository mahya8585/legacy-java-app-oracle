CREATE OR REPLACE PACKAGE PKG_DIVE_SITE AS
    -- ダイブサイト一覧（エリア条件付き）
    PROCEDURE GET_DIVE_SITES(
        p_area          IN  VARCHAR2 DEFAULT NULL,
        p_difficulty    IN  VARCHAR2 DEFAULT NULL,
        o_sites         OUT SYS_REFCURSOR
    );

    -- ダイブサイト詳細+関連ツアー
    PROCEDURE GET_DIVE_SITE_DETAIL(
        p_site_id       IN  NUMBER,
        o_site          OUT SYS_REFCURSOR,
        o_related_tours OUT SYS_REFCURSOR
    );
END PKG_DIVE_SITE;
/
