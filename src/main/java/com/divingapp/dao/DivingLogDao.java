package com.divingapp.dao;

import java.math.BigDecimal;
import java.util.Date;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.divingapp.dto.DivingLogDto;

import oracle.jdbc.OracleTypes;

@Repository
public class DivingLogDao {

    private final DataSource dataSource;

    public DivingLogDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<DivingLogDto> LOG_ROW_MAPPER = (rs, rowNum) -> {
        DivingLogDto dto = new DivingLogDto();
        dto.setLogId(rs.getLong("LOG_ID"));
        dto.setCustomerId(rs.getLong("CUSTOMER_ID"));
        dto.setSiteId(rs.getLong("SITE_ID"));
        dto.setDiveDate(rs.getDate("DIVE_DATE"));
        dto.setMaxDepth(rs.getBigDecimal("MAX_DEPTH"));
        dto.setDiveTime(rs.getInt("DIVE_TIME"));
        dto.setWaterTemp(rs.getBigDecimal("WATER_TEMP"));
        dto.setVisibility(rs.getBigDecimal("VISIBILITY"));
        dto.setWeather(rs.getString("WEATHER"));
        dto.setBuddy(rs.getString("BUDDY"));
        dto.setNotes(rs.getString("NOTES"));
        try { dto.setSiteName(rs.getString("SITE_NAME")); } catch (Exception e) { }
        return dto;
    };

    public Map<String, Object> getCustomerLogs(Long customerId, int page, int pageSize) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_DIVING_LOG")
            .withProcedureName("GET_CUSTOMER_LOGS")
            .declareParameters(
                new SqlParameter("p_customer_id", java.sql.Types.NUMERIC),
                new SqlParameter("p_page", java.sql.Types.NUMERIC),
                new SqlParameter("p_page_size", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_logs", OracleTypes.CURSOR, LOG_ROW_MAPPER),
                new SqlOutParameter("o_total_count", java.sql.Types.NUMERIC)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_customer_id", customerId)
            .addValue("p_page", page)
            .addValue("p_page_size", pageSize);

        return call.execute(params);
    }

    public Map<String, Object> saveDivingLog(Long logId, Long customerId, Long siteId,
            Long reservationId, Date diveDate, BigDecimal maxDepth, Integer diveTime,
            BigDecimal waterTemp, BigDecimal visibility, String weather,
            String buddy, String notes) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_DIVING_LOG")
            .withProcedureName("SAVE_DIVING_LOG");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_log_id", logId)
            .addValue("p_customer_id", customerId)
            .addValue("p_site_id", siteId)
            .addValue("p_reservation_id", reservationId)
            .addValue("p_dive_date", diveDate)
            .addValue("p_max_depth", maxDepth)
            .addValue("p_dive_time", diveTime)
            .addValue("p_water_temp", waterTemp)
            .addValue("p_visibility", visibility)
            .addValue("p_weather", weather)
            .addValue("p_buddy", buddy)
            .addValue("p_notes", notes);

        return call.execute(params);
    }
}
