CREATE OR REPLACE PACKAGE PKG_TOUR AS
    -- ツアー検索（条件付き動的WHERE）
    PROCEDURE SEARCH_TOURS(
        p_area          IN  VARCHAR2 DEFAULT NULL,
        p_difficulty    IN  VARCHAR2 DEFAULT NULL,
        p_date_from     IN  DATE     DEFAULT NULL,
        p_date_to       IN  DATE     DEFAULT NULL,
        p_price_min     IN  NUMBER   DEFAULT NULL,
        p_price_max     IN  NUMBER   DEFAULT NULL,
        p_duration_days IN  NUMBER   DEFAULT NULL,
        p_keyword       IN  VARCHAR2 DEFAULT NULL,
        p_page          IN  NUMBER   DEFAULT 1,
        p_page_size     IN  NUMBER   DEFAULT 10,
        o_tours         OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    );

    -- ツアー詳細取得
    PROCEDURE GET_TOUR_DETAIL(
        p_tour_id       IN  NUMBER,
        o_tour          OUT SYS_REFCURSOR,
        o_sites         OUT SYS_REFCURSOR,
        o_instructors   OUT SYS_REFCURSOR,
        o_schedules     OUT SYS_REFCURSOR
    );

    -- おすすめツアー取得
    PROCEDURE GET_FEATURED_TOURS(
        p_limit         IN  NUMBER DEFAULT 6,
        o_tours         OUT SYS_REFCURSOR
    );

    -- ツアー保存（登録・更新）
    PROCEDURE SAVE_TOUR(
        p_tour_id       IN OUT NUMBER,
        p_tour_name     IN  VARCHAR2,
        p_description   IN  CLOB,
        p_area          IN  VARCHAR2,
        p_difficulty    IN  VARCHAR2,
        p_max_participants IN NUMBER,
        p_base_price    IN  NUMBER,
        p_duration_days IN  NUMBER,
        p_min_dive_count IN NUMBER,
        p_featured_flag IN  CHAR,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );

    -- ツアー論理削除
    PROCEDURE DELETE_TOUR(
        p_tour_id       IN  NUMBER,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );
END PKG_TOUR;
/
