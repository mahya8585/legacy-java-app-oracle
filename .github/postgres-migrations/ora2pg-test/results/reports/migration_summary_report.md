# 🔄 Oracle to PostgreSQL Migration Report

## 📋 Migration Overview
This report describes the migration of Oracle schema objects to PostgreSQL. The migration was performed on **2026-04-03**
and includes all major Oracle object types converted to their PostgreSQL equivalents.

## 📈 Summary
| 📦 Total Objects | ✅ Successfully Converted | 📊 Percent |
|------------------|----------------------------|-------------|
| <div style="font-size:3rem; font-weight:bold;">61</div> | <div style="font-size:3rem; font-weight:bold;">61</div> | <div style="font-size:3rem; font-weight:bold;">100.0%</div> |

### 🔀 Objects by Category

| Category | Total | ✅ Converted | ❌ Failed | ⏭️ Skipped | Success Rate |
|----------|-------|--------------|-----------|------------|--------------|
| **🔧 Programmable Objects** | 12 | 12 | 0 | 0 | 100.0% |
| **📦 Non-Programmable Objects** | 49 | 49 | 0 | 0 | 100.0% |

#### 🔧 Programmable Objects Breakdown
Objects containing executable code or logic (functions, procedures, packages, triggers, etc.)

| Object Type | Count |
|-------------|-------|
| Package | 5 |
| Function | 7 |

#### 📦 Non-Programmable Objects Breakdown
Structural and data objects (tables, views, indexes, sequences, etc.)

| Object Type | Count |
|-------------|-------|
| Schema | 1 |
| Table | 15 |
| Sequence | 13 |
| Index | 20 |

## 🗄️ Database Target Environment
- **📊 Source**: Extracted Oracle Database Schema DDL
- **📅 Migration Date**: 2026-04-03
- **🐘 PostgreSQL Version**: 17.9
- **🗄️ Target PostgreSQL Database Name**: divingapp

## 🔧 Discovered Installed PostgreSQL Extensions

| Extension Discovered | Version |
|----------------------|---------|
| plpgsql  | (1.0) |
## 📦 Objects Migrated

### 1. Schemas
| Oracle Schema | PostgreSQL Schema | Status | Notes |
|---------------|---------------|---------------|---------------|
| DIVINGAPP | divingapp | ✅ Migrated | UPPERCASE Oracle schema name converted to lowercase PostgreSQL schema name |

Total Schemas Migrated: 1

### 2. Tables
| Oracle Schema | Oracle Table | PostgreSQL Table | Status | Notes |
|---------------|----------------------------------|--------------------------------------|--------|-------|
| DIVINGAPP | DIVE_SITES | dive_sites | ✅ Migrated | Oracle NUMBER mapped to BIGINT for site_id; Oracle VARCHAR2 mapped to VARCHAR; Oracle CLOB mapped to TEXT; Oracle SYSTIMESTAMP mapped to CURRENT_TIMESTAMP; Oracle storage/tablespace/lob clauses omitted (not applicable in PostgreSQL) |
| DIVINGAPP | OPTIONS_MASTER | options_master | ✅ Migrated | Oracle NUMBER mapped to BIGINT for integer columns (option_id, unit_price); Oracle VARCHAR2 mapped to VARCHAR; Oracle SYSTIMESTAMP mapped to CURRENT_TIMESTAMP; Oracle storage/tablespace clauses omitted (not applicable in PostgreSQL) |
| DIVINGAPP | INSTRUCTORS | instructors | ✅ Migrated | Oracle NUMBER mapped to BIGINT for integer columns (instructor_id, experience_years); Oracle VARCHAR2 mapped to VARCHAR; Oracle CLOB mapped to TEXT; Oracle SYSTIMESTAMP mapped to CURRENT_TIMESTAMP; Oracle storage/tablespace/lob clauses omitted (not applicable in PostgreSQL) |
| DIVINGAPP | REPORT_CACHE | report_cache | ✅ Migrated | Oracle NUMBER mapped to BIGINT for cache_id; Oracle NUMBER(p,s) mapped to NUMERIC(p,s) for metric_value; Oracle VARCHAR2 mapped to VARCHAR; Oracle DATE mapped to TIMESTAMP (Oracle DATE includes time); Oracle SYSTIMESTAMP mapped to CURRENT_TIMESTAMP; Oracle tablespace/segment clauses omitted (not applicable in PostgreSQL) |
| DIVINGAPP | CUSTOMERS | customers | ✅ Migrated | NUMBER converted to BIGINT for integer columns; RAW(64) converted to BYTEA; DATE converted to TIMESTAMP; SYSTIMESTAMP converted to CURRENT_TIMESTAMP |
| DIVINGAPP | REPORT_ALERTS | report_alerts | ✅ Migrated | NUMBER converted to BIGINT for integer columns; NUMBER(p,s) converted to NUMERIC(p,s); SYSTIMESTAMP converted to CURRENT_TIMESTAMP |
| DIVINGAPP | TOURS | tours | ✅ Migrated | NUMBER converted to BIGINT for integer columns; NUMBER(10,0) converted to BIGINT; CLOB converted to TEXT; SYSTIMESTAMP converted to CURRENT_TIMESTAMP; Oracle SecureFile LOB storage clauses dropped (not applicable in PostgreSQL) |
| DIVINGAPP | TOUR_INSTRUCTORS | tour_instructors | ✅ Migrated | NUMBER mapped to BIGINT; VARCHAR2 mapped to VARCHAR |
| DIVINGAPP | TOUR_DIVE_SITES | tour_dive_sites | ✅ Migrated | NUMBER mapped to BIGINT |
| DIVINGAPP | TOUR_SCHEDULES | tour_schedules | ✅ Migrated | Oracle DATE mapped to TIMESTAMP; SYSTIMESTAMP mapped to CURRENT_TIMESTAMP; NUMBER mapped to BIGINT; VARCHAR2 mapped to VARCHAR |
| DIVINGAPP | RESERVATIONS | reservations | ✅ Migrated | NUMBER converted to BIGINT for integer columns; TIMESTAMP(6) DEFAULT SYSTIMESTAMP converted to TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP; Oracle ENABLE/USING INDEX/TABLESPACE/STORAGE/segment attributes omitted (not applicable in PostgreSQL) |
| DIVINGAPP | DIVING_LOGS | diving_logs | ✅ Migrated | DATE column DIVE_DATE converted to TIMESTAMP; CLOB column NOTES converted to TEXT; NUMBER columns converted to BIGINT unless precision/scale specified |
| DIVINGAPP | RESERVATION_OPTIONS | reservation_options | ✅ Migrated | NUMBER columns converted to BIGINT unless precision/scale specified |
| DIVINGAPP | NEWS | news | ✅ Migrated | NUMBER converted to BIGINT; VARCHAR2 converted to VARCHAR; CLOB converted to TEXT; DATE converted to TIMESTAMP; SYSTIMESTAMP converted to CURRENT_TIMESTAMP |
| DIVINGAPP | ADMIN_USERS | admin_users | ✅ Migrated | NUMBER mapped to BIGINT (integer identifier); RAW(64) mapped to BYTEA; SYSTIMESTAMP mapped to CURRENT_TIMESTAMP; Dropped Oracle storage/tablespace/index physical attributes; handled by PostgreSQL |

Total Tables Migrated: 15

### 3. Sequences
| Oracle Schema | Oracle Sequence | PostgreSQL Sequence | Status | Notes |
|---------------|----------------------------------|--------------------------------------|--------|-------|
| DIVINGAPP | SEQ_DIVING_LOGS | seq_diving_logs | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint; MAXVALUE omitted; Oracle NOCACHE converted to CACHE 1; Oracle NOORDER ignored (PostgreSQL sequences are unordered by default) |
| DIVINGAPP | SEQ_RESERVATIONS | seq_reservations | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint; MAXVALUE omitted; Oracle NOCACHE converted to CACHE 1; Oracle NOORDER ignored (PostgreSQL sequences are unordered by default) |
| DIVINGAPP | SEQ_TOURS | seq_tours | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint; MAXVALUE omitted; Oracle NOCACHE converted to CACHE 1; Oracle NOORDER ignored (PostgreSQL sequences are unordered by default) |
| DIVINGAPP | SEQ_REPORT_ALERTS | seq_report_alerts | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint; MAXVALUE omitted; Oracle NOCACHE converted to CACHE 1; Oracle NOORDER ignored (PostgreSQL sequences are unordered by default) |
| DIVINGAPP | SEQ_CUSTOMERS | seq_customers | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint; MAXVALUE omitted; Oracle NOCACHE converted to CACHE 1; Oracle NOORDER ignored (PostgreSQL sequences are unordered by default) |
| DIVINGAPP | SEQ_REPORT_CACHE | seq_report_cache | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds bigint; omitted MAXVALUE in PostgreSQL; Oracle NOCACHE not specified to preserve semantics (PostgreSQL cache defaults apply); Oracle NOORDER ignored (PostgreSQL sequences are not order-guaranteed across sessions) |
| DIVINGAPP | SEQ_RESERVATION_OPTIONS | seq_reservation_options | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds bigint; omitted MAXVALUE in PostgreSQL; Oracle NOCACHE not specified to preserve semantics (PostgreSQL cache defaults apply); Oracle NOORDER ignored (PostgreSQL sequences are not order-guaranteed across sessions) |
| DIVINGAPP | SEQ_NEWS | seq_news | ✅ Migrated | Oracle MAXVALUE omitted (exceeded BIGINT range); Oracle NOCACHE/NOORDER/GLOBAL ignored (no direct PostgreSQL equivalents) |
| DIVINGAPP | SEQ_OPTIONS_MASTER | seq_options_master | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint range; MAXVALUE omitted.; Oracle NOCACHE/NOORDER/NOKEEP/NOSCALE/GLOBAL have no direct PostgreSQL sequence DDL equivalents (ignored). |
| DIVINGAPP | SEQ_DIVE_SITES | seq_dive_sites | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL BIGINT range; omitted MAXVALUE in PostgreSQL; Oracle NOCACHE not specified in PostgreSQL (PostgreSQL uses default CACHE 1); Oracle NOORDER has no direct PostgreSQL equivalent; Oracle GLOBAL ignored (Oracle RAC feature) |
| DIVINGAPP | SEQ_TOUR_SCHEDULES | seq_tour_schedules | ✅ Migrated | Oracle MAXVALUE (9999999999999999999999999999) exceeds PostgreSQL BIGINT limit; omitted MAXVALUE; Oracle NOCACHE omitted (PostgreSQL caches by default; explicit cache not set); Oracle NOORDER omitted (PostgreSQL sequences are unordered) |
| DIVINGAPP | SEQ_ADMIN_USERS | seq_admin_users | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint range; omitted MAXVALUE; Oracle NOCACHE/NOORDER/NOKEEP/NOSCALE/GLOBAL have no direct PostgreSQL equivalent; not applied |
| DIVINGAPP | SEQ_INSTRUCTORS | seq_instructors | ✅ Migrated | Oracle MAXVALUE 9999999999999999999999999999 exceeds PostgreSQL bigint; omitted MAXVALUE; Oracle NOCACHE/NOORDER/NOKEEP/NOSCALE/GLOBAL options omitted (no direct PostgreSQL equivalent) |

Total Sequences Migrated: 13

### 4. Indexes
| Oracle Schema | Oracle Index | PostgreSQL Index | Status | Notes |
|---------------|----------------------------------|--------------------------------------|--------|-------|
| DIVINGAPP | IDX_DS_AREA | idx_ds_area | ✅ Migrated | Removed Oracle storage/tablespace attributes (PCTFREE/INITRANS/MAXTRANS/STORAGE/TABLESPACE/COMPUTE STATISTICS) |
| DIVINGAPP | IDX_RC_GENERATED | idx_rc_generated | ✅ Migrated | Removed Oracle storage/tablespace attributes (PCTFREE/INITRANS/MAXTRANS/TABLESPACE/COMPUTE STATISTICS) |
| DIVINGAPP | IDX_RC_KEY_SECTION | idx_rc_key_section | ✅ Migrated | Removed Oracle storage/tablespace attributes (PCTFREE/INITRANS/MAXTRANS/TABLESPACE/COMPUTE STATISTICS) |
| DIVINGAPP | IDX_CUSTOMERS_STATUS | idx_customers_status | ✅ Migrated | Oracle storage/tablespace clauses omitted |
| DIVINGAPP | IDX_RA_DETECTED | idx_ra_detected | ✅ Migrated | Oracle tablespace clause omitted |
| DIVINGAPP | IDX_RA_SEVERITY | idx_ra_severity | ✅ Migrated | Oracle tablespace clause omitted |
| DIVINGAPP | IDX_TOURS_AREA | idx_tours_area | ✅ Migrated | Oracle storage/tablespace clauses omitted |
| DIVINGAPP | IDX_TOURS_DIFFICULTY | idx_tours_difficulty | ✅ Migrated | Oracle storage/tablespace clauses omitted |
| DIVINGAPP | IDX_TOURS_FEATURED | idx_tours_featured | ✅ Migrated | Oracle storage/tablespace clauses omitted |
| DIVINGAPP | IDX_TOURS_STATUS | idx_tours_status | ✅ Migrated | Oracle storage/tablespace clauses omitted |
| DIVINGAPP | IDX_TS_TOUR_DATE | idx_ts_tour_date | ✅ Migrated | Removed Oracle storage/tablespace attributes (not applicable in PostgreSQL); Removed schema-qualification from index name per PostgreSQL rules |
| DIVINGAPP | IDX_TS_TOUR_ID | idx_ts_tour_id | ✅ Migrated | Removed Oracle storage/tablespace attributes (not applicable in PostgreSQL); Removed schema-qualification from index name per PostgreSQL rules |
| DIVINGAPP | IDX_RESERVATIONS_STATUS | idx_reservations_status | ✅ Migrated | Removed schema qualification from index name (PostgreSQL restriction) |
| DIVINGAPP | IDX_RESERVATIONS_SCHEDULE | idx_reservations_schedule | ✅ Migrated | Removed schema qualification from index name (PostgreSQL restriction) |
| DIVINGAPP | IDX_TS_STATUS | idx_ts_status | ✅ Migrated | Removed schema qualification from index name (PostgreSQL restriction) |
| DIVINGAPP | IDX_DL_CUSTOMER | idx_dl_customer | ✅ Migrated | Oracle index storage/tablespace attributes (PCTFREE, INITRANS, MAXTRANS, COMPUTE STATISTICS, TABLESPACE) omitted/not applicable in PostgreSQL; Oracle UPPERCASE names converted to lowercase PostgreSQL names; PostgreSQL index name is unqualified (schema removed) per PostgreSQL syntax rules |
| DIVINGAPP | IDX_RESERVATIONS_CUSTOMER | idx_reservations_customer | ✅ Migrated | Oracle index storage/tablespace attributes (PCTFREE, INITRANS, MAXTRANS, COMPUTE STATISTICS, TABLESPACE) omitted/not applicable in PostgreSQL; Oracle UPPERCASE names converted to lowercase PostgreSQL names; PostgreSQL index name is unqualified (schema removed) per PostgreSQL syntax rules |
| DIVINGAPP | IDX_DL_DIVE_DATE | idx_dl_dive_date | ✅ Migrated | Oracle storage clauses (PCTFREE/INITRANS/MAXTRANS/TABLESPACE/COMPUTE STATISTICS) omitted as not applicable in PostgreSQL; Removed schema qualification from index name per PostgreSQL syntax rules |
| DIVINGAPP | IDX_RO_RESERVATION | idx_ro_reservation | ✅ Migrated | Oracle PCTFREE/INITRANS/MAXTRANS/COMPUTE STATISTICS/TABLESPACE clauses not applicable in PostgreSQL; omitted.; Removed schema qualification from index name (PostgreSQL creates index in same schema as target table). |
| DIVINGAPP | IDX_NEWS_PUBLISH | idx_news_publish | ✅ Migrated | Removed schema qualification from index name (PostgreSQL restriction) |

Total Indexes Migrated: 20

### 5. Packages
| Oracle Schema | Oracle Package | PostgreSQL Package | Status | Notes |
|---------------|----------------------------------|--------------------------------------|--------|-------|
| DIVINGAPP | PKG_CUSTOMER | pkg_customer | ✅ Migrated | Oracle PACKAGE decomposed into multiple PostgreSQL functions within the same chunk object for JSON slot compatibility; Oracle DBMS_CRYPTO.HASH + UTL_I18N.STRING_TO_RAW replaced with pgcrypto digest(convert_to(text,'UTF8'),'sha256') (requires extension pgcrypto); Oracle SYS_REFCURSOR OUT parameters converted to set-returning functions (RETURNS TABLE); Oracle SEQ_CUSTOMERS.NEXTVAL replaced with nextval('divingapp.seq_customers'); Oracle COMMIT/ROLLBACK removed (PostgreSQL functions cannot transaction-control); rely on caller transaction semantics |
| DIVINGAPP | PKG_TOUR | pkg_tour | ✅ Migrated | Oracle PACKAGE decomposed into standalone PostgreSQL PROCEDUREs: search_tours, get_tour_detail, get_featured_tours, save_tour, delete_tour.; SYS_REFCURSOR OUT parameters mapped to refcursor INOUT parameters; cursor names generated for deterministic OPEN behavior.; Oracle DBMS_LOB.INSTR used for keyword search converted to POSITION() over text; DESCRIPTION CLOB mapped to TEXT.; Oracle SYSTIMESTAMP/SYSDATE/TRUNC(SYSDATE) mapped to CURRENT_TIMESTAMP/date_trunc('day', CURRENT_TIMESTAMP).; Oracle SEQ_TOURS.NEXTVAL mapped to nextval('divingapp.seq_tours'); removed DUAL usage.; Oracle NVL mapped to COALESCE.; Oracle COMMIT/ROLLBACK removed; PostgreSQL procedures run within caller transaction.; Fixed PostgreSQL rule: parameters following a defaulted parameter must also have defaults; added defaults to refcursor INOUT/OUT parameters.; Fixed PostgreSQL default-parameter constraints: (1) no defaults allowed for OUT/INOUT, and (2) any parameter after a defaulted one must also be defaulted. Resolved by removing defaults from INPUT params and handling NULLs inside the body. |
| DIVINGAPP | PKG_REPORT | pkg_report | ✅ Migrated | Oracle PACKAGE decomposed into 4 PostgreSQL PROCEDURE definitions in a single chunk object due to JSON limitation.; Oracle SYS_REFCURSOR mapped to PostgreSQL refcursor INOUT parameters with OPEN FOR queries.; Oracle NVL converted to COALESCE; CONNECT BY converted to WITH RECURSIVE; LISTAGG converted to string_agg; ADD_MONTHS converted to interval arithmetic.; Oracle MERGE converted to INSERT ... ON CONFLICT, assuming report_cache has a unique constraint on (report_key, section, metric_name) and identity/defaults for ids.; Oracle RAISE_APPLICATION_ERROR converted to PL/pgSQL RAISE EXCEPTION with ERRCODE P0001. |
| DIVINGAPP | PKG_DIVING_LOG | pkg_diving_log | ✅ Migrated | Oracle package procedure GET_CUSTOMER_LOGS (REF CURSOR + total count OUT param) converted to set-returning function returning rows plus total_count column; Oracle RAISE_APPLICATION_ERROR converted to RAISE EXCEPTION |
| DIVINGAPP | PKG_RESERVATION | pkg_reservation | ✅ Migrated | Oracle PACKAGE converted into standalone PostgreSQL routines.; SYS_REFCURSOR outputs mapped to REFCURSOR INOUT parameters and OPEN ... FOR queries.; Oracle sequences NEXTVAL/DUAL converted to nextval('schema.sequence').; Oracle SYSTIMESTAMP/SYSDATE converted to CURRENT_TIMESTAMP/current_date.; Oracle REGEXP_COUNT/REGEXP_SUBSTR list parsing converted to regexp_split_to_array. |

Total Packages Migrated: 5

### 6. Functions
| Oracle Schema | Oracle Function | PostgreSQL Function | Status | Notes |
|---------------|----------------------------------|--------------------------------------|--------|-------|
| DIVINGAPP | PKG_DIVE_SITE | get_dive_sites | ✅ Migrated | Oracle package procedure GET_DIVE_SITES converted to set-returning function; SYS_REFCURSOR OUT converted to RETURNS TABLE result set; Oracle RAISE_APPLICATION_ERROR removed; callers should handle SQL errors/messages at application layer |
| DIVINGAPP | PKG_DIVE_SITE | get_dive_site_detail_site | ✅ Migrated | Oracle package procedure GET_DIVE_SITE_DETAIL (o_site cursor) converted to set-returning function; Oracle RAISE_APPLICATION_ERROR mapped to RAISE EXCEPTION with ERRCODE P0001 |
| DIVINGAPP | PKG_DIVE_SITE | get_dive_site_detail_related_tours | ✅ Migrated | Oracle package procedure GET_DIVE_SITE_DETAIL (o_related_tours cursor) converted to set-returning function; SYS_REFCURSOR OUT converted to RETURNS TABLE result set |
| DIVINGAPP | PKG_INSTRUCTOR | get_instructors | ✅ Migrated | Oracle PACKAGE procedure GET_INSTRUCTORS converted to PostgreSQL function returning refcursor |
| DIVINGAPP | PKG_INSTRUCTOR | get_instructor_detail | ✅ Migrated | Oracle PACKAGE procedure GET_INSTRUCTOR_DETAIL converted to PostgreSQL function with OUT refcursor parameters; Oracle TRUNC(SYSDATE) converted to date_trunc('day', CURRENT_TIMESTAMP) |
| DIVINGAPP | PKG_NEWS | pkg_news_get_latest_news | ✅ Migrated | Oracle package decomposed: GET_LATEST_NEWS procedure converted to set-returning function; SYS_REFCURSOR output converted to SETOF divingapp.news; NVL converted to COALESCE; TRUNC(SYSDATE) converted to date_trunc('day', CURRENT_TIMESTAMP) |
| DIVINGAPP | PKG_NEWS | pkg_news_save_news | ✅ Migrated | Oracle package decomposed: SAVE_NEWS procedure converted to function returning result code/message; CLOB parameter converted to TEXT; SEQ_NEWS.NEXTVAL converted to nextval('divingapp.seq_news'); SYSTIMESTAMP converted to CURRENT_TIMESTAMP; NVL converted to COALESCE; Fixed PostgreSQL limitation: replaced INOUT parameter with input parameter; returned updated p_news_id as first column in RETURNS TABLE; Resolved duplicate parameter name by renaming input parameter to p_news_id_in and assigning to output p_news_id |

Total Functions Migrated: 7

## 🔄 Key Changes and Considerations

### Data Type Mappings
- `NUMBER` → `SERIAL`
    -  **Note:** for auto-increment columns- `NUMBER(n,m)` → `NUMERIC(n,m)`
    - - `VARCHAR2(n)` → `VARCHAR(n)`
    - - `DATE` → `TIMESTAMP`
    -  **Note:** PostgreSQL includes time by default<br/>

### 📝 Function Conversion Notes
1. **Package State Variables**: Converted to PostgreSQL session variables using set_config() and current_setting()
2. **Exception Handling**: Oracle exception syntax converted to PostgreSQL exception blocks
## 🚀 Deployment Steps

### Prerequisites
1. Azure Database for PostgreSQL 17.9 or later
### Deployment Order
During the migration process, a scratch PostgreSQL database was created and populated with the converted DDL objects.
If you need to redeploy these objects or deploy them to another Azure Database for PostgreSQL server, you can use the following deployment file:

1. **/results/deploy.sql** - Create all converted objects
### Validation Steps
1. Verify all objects created successfully
2. Test functionality with sample data
3. Performance test with appropriate data volumes
## ⚠️ Known Limitations
Refer to https://aka.ms/schema-limitations for more details.

## 💡 Recommendations
1. **Testing**: Thoroughly test all converted objects
2. **Performance**: Monitor query performance and adjust as needed
3. **Error Handling**: Review error handling for PostgreSQL-specific behaviors
