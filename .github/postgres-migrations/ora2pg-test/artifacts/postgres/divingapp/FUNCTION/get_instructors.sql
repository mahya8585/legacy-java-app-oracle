-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_INSTRUCTOR.sql
-- Generated at: 2026-04-03T15:26:04.291814

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_INSTRUCTOR.sql
CREATE OR REPLACE FUNCTION divingapp.get_instructors()
RETURNS refcursor
LANGUAGE plpgsql
AS $$
DECLARE
	o_instructors refcursor;
BEGIN
	OPEN o_instructors FOR
		SELECT instructor_id,
			   last_name,
			   first_name,
			   certification,
			   experience_years,
			   specialty,
			   profile,
			   photo_url,
			   status,
			   created_at,
			   updated_at
		  FROM divingapp.instructors
		 WHERE status = 'ACTIVE'
		 ORDER BY experience_years DESC;

	RETURN o_instructors;
END;
$$;