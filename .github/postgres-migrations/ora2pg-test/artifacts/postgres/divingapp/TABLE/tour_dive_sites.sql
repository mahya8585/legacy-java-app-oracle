-- PostgreSQL DDL for divingapp.tour_dive_sites (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/TOUR_DIVE_SITES.sql
-- Generated at: 2026-04-03T15:26:03.873474

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOUR_DIVE_SITES.sql
CREATE TABLE IF NOT EXISTS divingapp.tour_dive_sites (
    tour_id BIGINT NOT NULL,
    site_id BIGINT NOT NULL,
    dive_order BIGINT DEFAULT 1,
    CONSTRAINT pk_tour_dive_sites PRIMARY KEY (tour_id, site_id),
    CONSTRAINT fk_tds_tour FOREIGN KEY (tour_id)
        REFERENCES divingapp.tours (tour_id),
    CONSTRAINT fk_tds_site FOREIGN KEY (site_id)
        REFERENCES divingapp.dive_sites (site_id)
);