package com.divingapp.dao;

import java.sql.Types;
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

@Repository
public class ReportDao {

    private final DataSource dataSource;

    public ReportDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<ReportDto> REPORT_ROW_MAPPER = (rs, rowNum) -> {
        ReportDto dto = new ReportDto();
        try { dto.setYear(rs.getInt("year")); } catch (Exception e) { }
        try { dto.setMonth(rs.getInt("month")); } catch (Exception e) { }
        try { dto.setTotalReservations(rs.getInt("total_reservations")); } catch (Exception e) { }
        try { dto.setTotalRevenue(rs.getBigDecimal("total_revenue")); } catch (Exception e) { }
        try { dto.setCancelledCount(rs.getInt("cancelled_count")); } catch (Exception e) { }
        try { dto.setTourName(rs.getString("tour_name")); } catch (Exception e) { }
        try { dto.setArea(rs.getString("area")); } catch (Exception e) { }
        try { dto.setReservationCount(rs.getInt("reservation_count")); } catch (Exception e) { }
        try { dto.setAvgParticipants(rs.getBigDecimal("avg_participants")); } catch (Exception e) { }
        try { dto.setTotalCapacity(rs.getInt("total_capacity")); } catch (Exception e) { }
        try { dto.setTotalBooked(rs.getInt("total_booked")); } catch (Exception e) { }
        try { dto.setOccupancyRate(rs.getBigDecimal("occupancy_rate")); } catch (Exception e) { }
        return dto;
    };

    public Map<String, Object> getMonthlySales(int year, Integer month) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_monthly_sales")
            .declareParameters(
                new SqlParameter("p_year", Types.NUMERIC),
                new SqlParameter("p_month", Types.NUMERIC),
                new SqlOutParameter("o_report", Types.REF_CURSOR, REPORT_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_year", year)
            .addValue("p_month", month);

        return call.execute(params);
    }

    public Map<String, Object> getTourPopularity(Date dateFrom, Date dateTo, int limit) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_tour_popularity")
            .declareParameters(
                new SqlParameter("p_date_from", Types.DATE),
                new SqlParameter("p_date_to", Types.DATE),
                new SqlParameter("p_limit", Types.NUMERIC),
                new SqlOutParameter("o_report", Types.REF_CURSOR, REPORT_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_date_from", dateFrom)
            .addValue("p_date_to", dateTo)
            .addValue("p_limit", limit);

        return call.execute(params);
    }

    public Map<String, Object> getOccupancyRate(int year, Integer month) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_occupancy_rate")
            .declareParameters(
                new SqlParameter("p_year", Types.NUMERIC),
                new SqlParameter("p_month", Types.NUMERIC),
                new SqlOutParameter("o_report", Types.REF_CURSOR, REPORT_ROW_MAPPER)
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
        try { row.setMonth(rs.getInt("report_month")); } catch (Exception e) { }
        try { row.setReservationCount(rs.getInt("reservation_count")); } catch (Exception e) { }
        try { row.setRevenue(rs.getBigDecimal("revenue")); } catch (Exception e) { }
        try { row.setParticipants(rs.getInt("participants")); } catch (Exception e) { }
        try { row.setCancelCount(rs.getInt("cancel_count")); } catch (Exception e) { }
        try { row.setPrevMonthRevenue(rs.getBigDecimal("prev_month_revenue")); } catch (Exception e) { }
        try { row.setMomChangeRate(rs.getBigDecimal("mom_change_rate")); } catch (Exception e) { }
        try { row.setYoyRevenue(rs.getBigDecimal("yoy_revenue")); } catch (Exception e) { }
        try { row.setYoyChangeRate(rs.getBigDecimal("yoy_change_rate")); } catch (Exception e) { }
        try { row.setCumulativeRevenue(rs.getBigDecimal("cumulative_revenue")); } catch (Exception e) { }
        try { row.setSharePct(rs.getBigDecimal("share_pct")); } catch (Exception e) { }
        try { row.setTrend(rs.getString("trend")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.AreaMatrixRow> AREA_MATRIX_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.AreaMatrixRow row = new DashboardReportDto.AreaMatrixRow();
        try { row.setArea(rs.getString("area")); } catch (Exception e) { }
        try { row.setDifficulty(rs.getString("difficulty")); } catch (Exception e) { }
        try { row.setGroupingLevel(rs.getInt("grouping_level")); } catch (Exception e) { }
        try { row.setReservationCount(rs.getInt("reservation_count")); } catch (Exception e) { }
        try { row.setTotalRevenue(rs.getBigDecimal("total_revenue")); } catch (Exception e) { }
        try { row.setAvgParticipants(rs.getBigDecimal("avg_participants")); } catch (Exception e) { }
        try { row.setBeginnerCount(rs.getInt("beginner_count")); } catch (Exception e) { }
        try { row.setIntermediateCount(rs.getInt("intermediate_count")); } catch (Exception e) { }
        try { row.setAdvancedCount(rs.getInt("advanced_count")); } catch (Exception e) { }
        try { row.setExpertCount(rs.getInt("expert_count")); } catch (Exception e) { }
        try { row.setBeginnerRevPct(rs.getBigDecimal("beginner_rev_pct")); } catch (Exception e) { }
        try { row.setAdvancedRevPct(rs.getBigDecimal("advanced_rev_pct")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.InstructorKpiRow> INSTRUCTOR_KPI_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.InstructorKpiRow row = new DashboardReportDto.InstructorKpiRow();
        try { row.setInstructorName(rs.getString("instructor_name")); } catch (Exception e) { }
        try { row.setCertification(rs.getString("certification")); } catch (Exception e) { }
        try { row.setExperienceYears(rs.getInt("experience_years")); } catch (Exception e) { }
        try { row.setScheduleCount(rs.getInt("schedule_count")); } catch (Exception e) { }
        try { row.setReservationCount(rs.getInt("reservation_count")); } catch (Exception e) { }
        try { row.setUniqueCustomers(rs.getInt("unique_customers")); } catch (Exception e) { }
        try { row.setTotalRevenue(rs.getBigDecimal("total_revenue")); } catch (Exception e) { }
        try { row.setTotalParticipants(rs.getInt("total_participants")); } catch (Exception e) { }
        try { row.setAvgParticipants(rs.getBigDecimal("avg_participants")); } catch (Exception e) { }
        try { row.setRevenueRank(rs.getInt("revenue_rank")); } catch (Exception e) { }
        try { row.setParticipantPercentile(rs.getBigDecimal("participant_percentile")); } catch (Exception e) { }
        try { row.setRevenueSharePct(rs.getBigDecimal("revenue_share_pct")); } catch (Exception e) { }
        try { row.setAreaList(rs.getString("area_list")); } catch (Exception e) { }
        try { row.setRepeatRate(rs.getBigDecimal("repeat_rate")); } catch (Exception e) { }
        try { row.setRecentActiveDays(rs.getInt("recent_active_days")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.CustomerSegmentRow> CUSTOMER_SEGMENT_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.CustomerSegmentRow row = new DashboardReportDto.CustomerSegmentRow();
        try { row.setSegment(rs.getString("segment")); } catch (Exception e) { }
        try { row.setSegmentOrder(rs.getInt("segment_order")); } catch (Exception e) { }
        try { row.setCustomerCount(rs.getInt("customer_count")); } catch (Exception e) { }
        try { row.setSharePct(rs.getBigDecimal("share_pct")); } catch (Exception e) { }
        try { row.setAvgLtv(rs.getBigDecimal("avg_ltv")); } catch (Exception e) { }
        try { row.setAvgDiveCount(rs.getInt("avg_dive_count")); } catch (Exception e) { }
        try { row.setAvgFrequency(rs.getBigDecimal("avg_frequency")); } catch (Exception e) { }
        try { row.setAvgCancelRate(rs.getBigDecimal("avg_cancel_rate")); } catch (Exception e) { }
        try { row.setTotalRevenue(rs.getBigDecimal("total_revenue")); } catch (Exception e) { }
        try { row.setAvgRecencyMonths(rs.getBigDecimal("avg_recency_months")); } catch (Exception e) { }
        try { row.setPrevSegmentCount(rs.getInt("prev_segment_count")); } catch (Exception e) { }
        try { row.setCountDiff(rs.getInt("count_diff")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.CancelAnalysisRow> CANCEL_ANALYSIS_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.CancelAnalysisRow row = new DashboardReportDto.CancelAnalysisRow();
        try { row.setAnalysisType(rs.getString("analysis_type")); } catch (Exception e) { }
        try { row.setSortKey(rs.getInt("sort_key")); } catch (Exception e) { }
        try { row.setDimension(rs.getString("dimension")); } catch (Exception e) { }
        try { row.setCancelCount(rs.getInt("cancel_count")); } catch (Exception e) { }
        try { row.setLossAmount(rs.getBigDecimal("loss_amount")); } catch (Exception e) { }
        try { row.setRefundAmount(rs.getBigDecimal("refund_amount")); } catch (Exception e) { }
        try { row.setNetRevenue(rs.getBigDecimal("net_revenue")); } catch (Exception e) { }
        try { row.setMomChange(rs.getBigDecimal("mom_change")); } catch (Exception e) { }
        try { row.setMovingAvg(rs.getBigDecimal("moving_avg")); } catch (Exception e) { }
        try { row.setMovingStddev(rs.getBigDecimal("moving_stddev")); } catch (Exception e) { }
        try { row.setAlertFlag(rs.getString("alert_flag")); } catch (Exception e) { }
        return row;
    };

    private static final RowMapper<DashboardReportDto.AnomalyAlertRow> ANOMALY_ALERT_ROW_MAPPER = (rs, rowNum) -> {
        DashboardReportDto.AnomalyAlertRow row = new DashboardReportDto.AnomalyAlertRow();
        try { row.setAlertId(rs.getLong("alert_id")); } catch (Exception e) { }
        try { row.setAlertType(rs.getString("alert_type")); } catch (Exception e) { }
        try { row.setSeverity(rs.getString("severity")); } catch (Exception e) { }
        try { row.setMetricName(rs.getString("metric_name")); } catch (Exception e) { }
        try { row.setCurrentValue(rs.getBigDecimal("current_value")); } catch (Exception e) { }
        try { row.setThresholdValue(rs.getBigDecimal("threshold_value")); } catch (Exception e) { }
        try { row.setDeviation(rs.getBigDecimal("deviation")); } catch (Exception e) { }
        try { row.setMessage(rs.getString("message")); } catch (Exception e) { }
        try { row.setDetectedAt(rs.getTimestamp("detected_at")); } catch (Exception e) { }
        try { row.setStatus(rs.getString("status")); } catch (Exception e) { }
        try { row.setAlertRank(rs.getInt("alert_rank")); } catch (Exception e) { }
        try { row.setTotalAlerts(rs.getInt("total_alerts")); } catch (Exception e) { }
        try { row.setSeverityCount(rs.getInt("severity_count")); } catch (Exception e) { }
        try { row.setSeverityDistPct(rs.getBigDecimal("severity_dist_pct")); } catch (Exception e) { }
        return row;
    };

    public Map<String, Object> getDashboardReport(int year, Integer month) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("generate_dashboard_report")
            .declareParameters(
                new SqlParameter("p_year", Types.NUMERIC),
                new SqlParameter("p_month", Types.NUMERIC),
                new SqlOutParameter("o_sales_trend", Types.REF_CURSOR, SALES_TREND_ROW_MAPPER),
                new SqlOutParameter("o_area_matrix", Types.REF_CURSOR, AREA_MATRIX_ROW_MAPPER),
                new SqlOutParameter("o_instructor_kpi", Types.REF_CURSOR, INSTRUCTOR_KPI_ROW_MAPPER),
                new SqlOutParameter("o_customer_segment", Types.REF_CURSOR, CUSTOMER_SEGMENT_ROW_MAPPER),
                new SqlOutParameter("o_cancel_analysis", Types.REF_CURSOR, CANCEL_ANALYSIS_ROW_MAPPER),
                new SqlOutParameter("o_anomaly_alerts", Types.REF_CURSOR, ANOMALY_ALERT_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_year", year)
            .addValue("p_month", month);

        return call.execute(params);
    }
}
