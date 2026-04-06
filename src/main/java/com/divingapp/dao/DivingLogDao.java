package com.divingapp.dao;

import java.math.BigDecimal;
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

import com.divingapp.dto.DivingLogDto;

@Repository
public class DivingLogDao {

    private final DataSource dataSource;

    public DivingLogDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<DivingLogDto> LOG_ROW_MAPPER = (rs, rowNum) -> {
        DivingLogDto dto = new DivingLogDto();
        dto.setLogId(rs.getLong("log_id"));
        dto.setCustomerId(rs.getLong("customer_id"));
        dto.setSiteId(rs.getLong("site_id"));
        dto.setDiveDate(rs.getDate("dive_date"));
        dto.setMaxDepth(rs.getBigDecimal("max_depth"));
        dto.setDiveTime(rs.getInt("dive_time"));
        dto.setWaterTemp(rs.getBigDecimal("water_temp"));
        dto.setVisibility(rs.getBigDecimal("visibility"));
        dto.setWeather(rs.getString("weather"));
        dto.setBuddy(rs.getString("buddy"));
        dto.setNotes(rs.getString("notes"));
        try { dto.setSiteName(rs.getString("site_name")); } catch (Exception e) { }
        return dto;
    };

    public Map<String, Object> getCustomerLogs(Long customerId, int page, int pageSize) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_customer_logs")
            .declareParameters(
                new SqlParameter("p_customer_id", Types.NUMERIC),
                new SqlParameter("p_page", Types.NUMERIC),
                new SqlParameter("p_page_size", Types.NUMERIC),
                new SqlOutParameter("o_logs", Types.REF_CURSOR, LOG_ROW_MAPPER),
                new SqlOutParameter("o_total_count", Types.NUMERIC)
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
            .withSchemaName("divingapp")
            .withProcedureName("save_diving_log");

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
