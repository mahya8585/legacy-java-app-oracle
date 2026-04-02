package com.divingapp.dao;

import java.util.Date;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.divingapp.dto.DashboardReportDto;
import com.divingapp.dto.ReportDto;

import oracle.jdbc.OracleTypes;

@Repository
public class ReportDao {

    private final DataSource dataSource;

    public ReportDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<ReportDto> REPORT_ROW_MAPPER = (rs, rowNum) -> {
        ReportDto dto = new ReportDto();
        try { dto.setYear(rs.getInt("YEAR")); } catch (Exception e) { }
        try { dto.setMonth(rs.getInt("MONTH")); } catch (Exception e) { }
        try { dto.setTotalReservations(rs.getInt("TOTAL_RESERVATIONS")); } catch (Exception e) { }
        try { dto.setTotalRevenue(rs.getBigDecimal("TOTAL_REVENUE")); } catch (Exception e) { }
        try { dto.setCancelledCount(rs.getInt("CANCELLED_COUNT")); } catch (Exception e) { }
        try { dto.setTourName(rs.getString("TOUR_NAME")); } catch (Exception e) { }
        try { dto.setArea(rs.getString("AREA")); } catch (Exception e) { }
        try { dto.setReservationCount(rs.getInt("RESERVATION_COUNT")); } catch (Exception e) { }
        try { dto.setAvgParticipants(rs.getBigDecimal("AVG_PARTICIPANTS")); } catch (Exception e) { }
        try { dto.setTotalCapacity(rs.getInt("TOTAL_CAPACITY")); } catch (Exception e) { }
        try { dto.setTotalBooked(rs.getInt("TOTAL_BOOKED")); } catch (Exception e) { }
        try { dto.setOccupancyRate(rs.getBigDecimal("OCCUPANCY_RATE")); } catch (Exception e) { }
        return dto;
    };

    public Map<String, Object> getMonthlySales(int year, Integer month) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_REPORT")
            .withProcedureName("GET_MONTHLY_SALES")
            .declareParameters(
                new SqlParameter("p_year", java.sql.Types.NUMERIC),
                new SqlParameter("p_month", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_report", OracleTypes.CURSOR, REPORT_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_year", year)
            .addValue("p_month", month);

        return call.execute(params);
    }

    public Map<String, Object> getTourPopularity(Date dateFrom, Date dateTo, int limit) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_REPORT")
            .withProcedureName("GET_TOUR_POPULARITY")
            .declareParameters(
                new SqlParameter("p_date_from", java.sql.Types.DATE),
                new SqlParameter("p_date_to", java.sql.Types.DATE),
                new SqlParameter("p_limit", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_report", OracleTypes.CURSOR, REPORT_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_date_from", dateFrom)
            .addValue("p_date_to", dateTo)
            .addValue("p_limit", limit);

        return call.execute(params);
    }

    public Map<String, Object> getOccupancyRate(int year, Integer month) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_REPORT")
            .withProcedureName("GET_OCCUPANCY_RATE")
            .declareParameters(
                new SqlParameter("p_year", java.sql.Types.NUMERIC),
                new SqlParameter("p_month", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_report", OracleTypes.CURSOR, REPORT_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_year", year)
            .addValue("p_month", month);

        return call.execute(params);
    }

    // =========================================================
    // ダッシュボードレポート用 RowMapper
    // =========================================================

    private static final RowMapper<DashboardReportDto.SalesTrendRow> SALES_TREND_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.SalesTrendRow row = new DashboardReportDto.SalesTrendRow();
        try { row.setMonth(rs.getInt("REPORT_MONTH")); } catch (Exception e) { }
        try { row.setReservationCount(rs.getInt("RESERVATION_COUNT")); } catch (Exception e) { }
        try { row.setRevenue(rs.getBigDecimal("REVENUE")); } catch (Exception e) { }
        try { row.setParticipants(rs.getInt("PARTICIPANTS")); } catch (Exception e) { }
        try { row.setCancelCount(rs.getInt("CANCEL_COUNT")); } catch (Exception e) { }
        try { row.setPrevMonthRevenue(rs.getBigDecimal("PREV_MONTH_REVENUE")); } catch (Exception e) { }
        try { row.setMomChangeRate(rs.getBigDecimal("MOM_CHANGE_RATE")); } catch (Exception e) { }
        try { row.setYoyRevenue(rs.getBigDecimal("YOY_REVENUE")); } catch (Exception e) { }
        try { row.setYoyChangeRate(rs.getBigDecimal("YOY_CHANGE_RATE")); } catch (Exception e) { }
        try { row.setCumulativeRevenue(rs.getBigDecimal("CUMULATIVE_REVENUE")); } catch (Exception e) { }
        try { row.setSharePct(rs.getBigDecimal("SHARE_PCT")); } catch (Exception e) { }
        try { row.setTrend(rs.getString("TREND")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.AreaMatrixRow> AREA_MATRIX_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.AreaMatrixRow row = new DashboardReportDto.AreaMatrixRow();
        try { row.setArea(rs.getString("AREA")); } catch (Exception e) { }
        try { row.setDifficulty(rs.getString("DIFFICULTY")); } catch (Exception e) { }
        try { row.setGroupingLevel(rs.getInt("GROUPING_LEVEL")); } catch (Exception e) { }
        try { row.setReservationCount(rs.getInt("RESERVATION_COUNT")); } catch (Exception e) { }
        try { row.setTotalRevenue(rs.getBigDecimal("TOTAL_REVENUE")); } catch (Exception e) { }
        try { row.setAvgParticipants(rs.getBigDecimal("AVG_PARTICIPANTS")); } catch (Exception e) { }
        try { row.setBeginnerCount(rs.getInt("BEGINNER_COUNT")); } catch (Exception e) { }
        try { row.setIntermediateCount(rs.getInt("INTERMEDIATE_COUNT")); } catch (Exception e) { }
        try { row.setAdvancedCount(rs.getInt("ADVANCED_COUNT")); } catch (Exception e) { }
        try { row.setExpertCount(rs.getInt("EXPERT_COUNT")); } catch (Exception e) { }
        try { row.setBeginnerRevPct(rs.getBigDecimal("BEGINNER_REV_PCT")); } catch (Exception e) { }
        try { row.setAdvancedRevPct(rs.getBigDecimal("ADVANCED_REV_PCT")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.InstructorKpiRow> INSTRUCTOR_KPI_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.InstructorKpiRow row = new DashboardReportDto.InstructorKpiRow();
        try { row.setInstructorName(rs.getString("INSTRUCTOR_NAME")); } catch (Exception e) { }
        try { row.setCertification(rs.getString("CERTIFICATION")); } catch (Exception e) { }
        try { row.setExperienceYears(rs.getInt("EXPERIENCE_YEARS")); } catch (Exception e) { }
        try { row.setScheduleCount(rs.getInt("SCHEDULE_COUNT")); } catch (Exception e) { }
        try { row.setReservationCount(rs.getInt("RESERVATION_COUNT")); } catch (Exception e) { }
        try { row.setUniqueCustomers(rs.getInt("UNIQUE_CUSTOMERS")); } catch (Exception e) { }
        try { row.setTotalRevenue(rs.getBigDecimal("TOTAL_REVENUE")); } catch (Exception e) { }
        try { row.setTotalParticipants(rs.getInt("TOTAL_PARTICIPANTS")); } catch (Exception e) { }
        try { row.setAvgParticipants(rs.getBigDecimal("AVG_PARTICIPANTS")); } catch (Exception e) { }
        try { row.setRevenueRank(rs.getInt("REVENUE_RANK")); } catch (Exception e) { }
        try { row.setParticipantPercentile(rs.getBigDecimal("PARTICIPANT_PERCENTILE")); } catch (Exception e) { }
        try { row.setRevenueSharePct(rs.getBigDecimal("REVENUE_SHARE_PCT")); } catch (Exception e) { }
        try { row.setAreaList(rs.getString("AREA_LIST")); } catch (Exception e) { }
        try { row.setRepeatRate(rs.getBigDecimal("REPEAT_RATE")); } catch (Exception e) { }
        try { row.setRecentActiveDays(rs.getInt("RECENT_ACTIVE_DAYS")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.CustomerSegmentRow> CUSTOMER_SEGMENT_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.CustomerSegmentRow row = new DashboardReportDto.CustomerSegmentRow();
        try { row.setSegment(rs.getString("SEGMENT")); } catch (Exception e) { }
        try { row.setSegmentOrder(rs.getInt("SEGMENT_ORDER")); } catch (Exception e) { }
        try { row.setCustomerCount(rs.getInt("CUSTOMER_COUNT")); } catch (Exception e) { }
        try { row.setSharePct(rs.getBigDecimal("SHARE_PCT")); } catch (Exception e) { }
        try { row.setAvgLtv(rs.getBigDecimal("AVG_LTV")); } catch (Exception e) { }
        try { row.setAvgDiveCount(rs.getInt("AVG_DIVE_COUNT")); } catch (Exception e) { }
        try { row.setAvgFrequency(rs.getBigDecimal("AVG_FREQUENCY")); } catch (Exception e) { }
        try { row.setAvgCancelRate(rs.getBigDecimal("AVG_CANCEL_RATE")); } catch (Exception e) { }
        try { row.setTotalRevenue(rs.getBigDecimal("TOTAL_REVENUE")); } catch (Exception e) { }
        try { row.setAvgRecencyMonths(rs.getBigDecimal("AVG_RECENCY_MONTHS")); } catch (Exception e) { }
        try { row.setPrevSegmentCount(rs.getInt("PREV_SEGMENT_COUNT")); } catch (Exception e) { }
        try { row.setCountDiff(rs.getInt("COUNT_DIFF")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.CancelAnalysisRow> CANCEL_ANALYSIS_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.CancelAnalysisRow row = new DashboardReportDto.CancelAnalysisRow();
        try { row.setAnalysisType(rs.getString("ANALYSIS_TYPE")); } catch (Exception e) { }
        try { row.setSortKey(rs.getInt("SORT_KEY")); } catch (Exception e) { }
        try { row.setDimension(rs.getString("DIMENSION")); } catch (Exception e) { }
        try { row.setCancelCount(rs.getInt("CANCEL_COUNT")); } catch (Exception e) { }
        try { row.setLossAmount(rs.getBigDecimal("LOSS_AMOUNT")); } catch (Exception e) { }
        try { row.setRefundAmount(rs.getBigDecimal("REFUND_AMOUNT")); } catch (Exception e) { }
        try { row.setNetRevenue(rs.getBigDecimal("NET_REVENUE")); } catch (Exception e) { }
        try { row.setMomChange(rs.getBigDecimal("MOM_CHANGE")); } catch (Exception e) { }
        try { row.setMovingAvg(rs.getBigDecimal("MOVING_AVG")); } catch (Exception e) { }
        try { row.setMovingStddev(rs.getBigDecimal("MOVING_STDDEV")); } catch (Exception e) { }
        try { row.setAlertFlag(rs.getString("ALERT_FLAG")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.AnomalyAlertRow> ANOMALY_ALERT_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.AnomalyAlertRow row = new DashboardReportDto.AnomalyAlertRow();
        try { row.setAlertId(rs.getLong("ALERT_ID")); } catch (Exception e) { }
        try { row.setAlertType(rs.getString("ALERT_TYPE")); } catch (Exception e) { }
        try { row.setSeverity(rs.getString("SEVERITY")); } catch (Exception e) { }
        try { row.setMetricName(rs.getString("METRIC_NAME")); } catch (Exception e) { }
        try { row.setCurrentValue(rs.getBigDecimal("CURRENT_VALUE")); } catch (Exception e) { }
        try { row.setThresholdValue(rs.getBigDecimal("THRESHOLD_VALUE")); } catch (Exception e) { }
        try { row.setDeviation(rs.getBigDecimal("DEVIATION")); } catch (Exception e) { }
        try { row.setMessage(rs.getString("MESSAGE")); } catch (Exception e) { }
        try { row.setDetectedAt(rs.getTimestamp("DETECTED_AT")); } catch (Exception e) { }
        try { row.setStatus(rs.getString("STATUS")); } catch (Exception e) { }
        try { row.setAlertRank(rs.getInt("ALERT_RANK")); } catch (Exception e) { }
        try { row.setTotalAlerts(rs.getInt("TOTAL_ALERTS")); } catch (Exception e) { }
        try { row.setSeverityCount(rs.getInt("SEVERITY_COUNT")); } catch (Exception e) { }
        try { row.setSeverityDistPct(rs.getBigDecimal("SEVERITY_DIST_PCT")); } catch (Exception e) { }
        return row;
    };

    public Map<String, Object> getDashboardReport(int year, Integer month) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_REPORT")
            .withProcedureName("GENERATE_DASHBOARD_REPORT")
            .declareParameters(
                new SqlParameter("p_year", java.sql.Types.NUMERIC),
                new SqlParameter("p_month", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_sales_trend", OracleTypes.CURSOR, SALES_TREND_ROW_MAPPER),
                new SqlOutParameter("o_area_matrix", OracleTypes.CURSOR, AREA_MATRIX_ROW_MAPPER),
                new SqlOutParameter("o_instructor_kpi", OracleTypes.CURSOR, INSTRUCTOR_KPI_ROW_MAPPER),
                new SqlOutParameter("o_customer_segment", OracleTypes.CURSOR, CUSTOMER_SEGMENT_ROW_MAPPER),
                new SqlOutParameter("o_cancel_analysis", OracleTypes.CURSOR, CANCEL_ANALYSIS_ROW_MAPPER),
                new SqlOutParameter("o_anomaly_alerts", OracleTypes.CURSOR, ANOMALY_ALERT_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_year", year)
            .addValue("p_month", month);

        return call.execute(params);
    }
}
