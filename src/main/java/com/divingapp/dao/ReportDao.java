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
}
