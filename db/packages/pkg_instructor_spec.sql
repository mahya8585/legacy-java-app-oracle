CREATE OR REPLACE PACKAGE PKG_INSTRUCTOR AS
    -- インストラクター一覧
    PROCEDURE GET_INSTRUCTORS(
        o_instructors   OUT SYS_REFCURSOR
    );

    -- インストラクター詳細+担当ツアー
    PROCEDURE GET_INSTRUCTOR_DETAIL(
        p_instructor_id IN  NUMBER,
        o_instructor    OUT SYS_REFCURSOR,
        o_tours         OUT SYS_REFCURSOR
    );
END PKG_INSTRUCTOR;
/
