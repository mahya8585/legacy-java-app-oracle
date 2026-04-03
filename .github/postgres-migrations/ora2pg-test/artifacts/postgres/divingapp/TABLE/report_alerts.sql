-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/REPORT_ALERTS.sql
-- Generated at: 2026-04-03T15:26:03.543057

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/REPORT_ALERTS.sql
CREATE TABLE IF NOT EXISTS divingapp.report_alerts (
    alert_id BIGINT NOT NULL,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(10) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    current_value NUMERIC(15,2),
    threshold_value NUMERIC(15,2),
    deviation NUMERIC(10,4),
    message VARCHAR(500),
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'NEW' NOT NULL,
    CONSTRAINT ck_ra_severity CHECK (severity IN ('HIGH', 'MEDIUM', 'LOW')),
    CONSTRAINT ck_ra_status CHECK (status IN ('NEW', 'ACKNOWLEDGED', 'RESOLVED')),
    CONSTRAINT pk_report_alerts PRIMARY KEY (alert_id)
);