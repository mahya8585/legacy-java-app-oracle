CREATE OR REPLACE PACKAGE PKG_NEWS AS
    -- 最新ニュース取得
    PROCEDURE GET_LATEST_NEWS(
        p_limit         IN  NUMBER DEFAULT 5,
        p_category      IN  VARCHAR2 DEFAULT NULL,
        o_news          OUT SYS_REFCURSOR
    );

    -- ニュース保存（登録・更新）
    PROCEDURE SAVE_NEWS(
        p_news_id       IN OUT NUMBER,
        p_title         IN  VARCHAR2,
        p_content       IN  CLOB,
        p_category      IN  VARCHAR2,
        p_publish_date  IN  DATE,
        p_status        IN  VARCHAR2,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );
END PKG_NEWS;
/
