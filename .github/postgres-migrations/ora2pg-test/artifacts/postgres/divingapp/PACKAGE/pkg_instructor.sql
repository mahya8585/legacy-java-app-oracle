-- PostgreSQL DDL for divingapp.pkg_instructor (PACKAGE)
-- Generated from Oracle → PostgreSQL migration
-- Oracle source: DIVINGAPP/PACKAGE/PKG_INSTRUCTOR.sql
-- Generated at: 2026-04-03

-- =========================================================
-- インストラクター一覧取得
-- ACTIVE なインストラクターを経験年数の降順で返す
-- Oracle: PROCEDURE GET_INSTRUCTORS with SYS_REFCURSOR OUT
-- =========================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_instructor_get_instructors()
RETURNS TABLE(
    instructor_id BIGINT,
    last_name VARCHAR,
    first_name VARCHAR,
    certification VARCHAR,
    experience_years BIGINT,
    specialty TEXT,
    profile TEXT,
    photo_url VARCHAR,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT i.instructor_id,
           i.last_name,
           i.first_name,
           i.certification,
           i.experience_years,
           i.specialty,
           i.profile,
           i.photo_url,
           i.status,
           i.created_at,
           i.updated_at
      FROM divingapp.instructors i
     WHERE i.status = 'ACTIVE'
     ORDER BY i.experience_years DESC;
END;
$$;

-- =========================================================
-- インストラクター詳細取得
-- Oracle: PROCEDURE GET_INSTRUCTOR_DETAIL (o_instructor OUT SYS_REFCURSOR)
-- PostgreSQL: Split into separate function for instructor details
-- =========================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_instructor_get_instructor_detail(
    p_instructor_id BIGINT
)
RETURNS TABLE(
    instructor_id BIGINT,
    last_name VARCHAR,
    first_name VARCHAR,
    certification VARCHAR,
    experience_years BIGINT,
    specialty TEXT,
    profile TEXT,
    photo_url VARCHAR,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT i.instructor_id,
           i.last_name,
           i.first_name,
           i.certification,
           i.experience_years,
           i.specialty,
           i.profile,
           i.photo_url,
           i.status,
           i.created_at,
           i.updated_at
      FROM divingapp.instructors i
     WHERE i.instructor_id = p_instructor_id;
END;
$$;

-- =========================================================
-- インストラクター担当ツアー取得
-- Oracle: PROCEDURE GET_INSTRUCTOR_DETAIL (o_tours OUT SYS_REFCURSOR)
-- PostgreSQL: Split into separate function for instructor's tours
-- ACTIVE かつ将来のスケジュールが存在するツアーを返す
-- =========================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_instructor_get_instructor_tours(
    p_instructor_id BIGINT
)
RETURNS TABLE(
    tour_id BIGINT,
    tour_name VARCHAR,
    area VARCHAR,
    difficulty VARCHAR,
    max_participants BIGINT,
    base_price NUMERIC,
    duration_days BIGINT,
    role VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
           t.tour_id,
           t.tour_name,
           t.area,
           t.difficulty,
           t.max_participants,
           t.base_price,
           t.duration_days,
           ti.role
      FROM divingapp.tour_instructors ti
      JOIN divingapp.tours t
        ON t.tour_id = ti.tour_id
     WHERE ti.instructor_id = p_instructor_id
       AND t.status = 'ACTIVE'
       AND EXISTS (
           SELECT 1
             FROM divingapp.tour_schedules ts
            WHERE ts.tour_id = t.tour_id
              AND ts.tour_date >= CURRENT_DATE
              AND ts.status IN ('OPEN', 'FULL')
       )
     ORDER BY t.tour_name;
END;
$$;
