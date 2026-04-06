package com.divingapp.dao;

import java.sql.Types;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.divingapp.dto.DiveSiteDto;
import com.divingapp.dto.TourDto;

@Repository
public class DiveSiteDao {

    private final DataSource dataSource;

    public DiveSiteDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<DiveSiteDto> SITE_ROW_MAPPER = (rs, rowNum) -> {
        DiveSiteDto dto = new DiveSiteDto();
        dto.setSiteId(rs.getLong("site_id"));
        dto.setSiteName(rs.getString("site_name"));
        dto.setArea(rs.getString("area"));
        dto.setDescription(rs.getString("description"));
        dto.setMaxDepth(rs.getBigDecimal("max_depth"));
        dto.setWaterTemperatureMin(rs.getBigDecimal("water_temperature_min"));
        dto.setWaterTemperatureMax(rs.getBigDecimal("water_temperature_max"));
        dto.setDifficulty(rs.getString("difficulty"));
        dto.setMarineLife(rs.getString("marine_life"));
        dto.setAccessInfo(rs.getString("access_info"));
        dto.setStatus(rs.getString("status"));
        return dto;
    };

    private static final RowMapper<TourDto> TOUR_ROW_MAPPER = (rs, rowNum) -> {
        TourDto dto = new TourDto();
        dto.setTourId(rs.getLong("tour_id"));
        dto.setTourName(rs.getString("tour_name"));
        dto.setArea(rs.getString("area"));
        dto.setBasePrice(rs.getBigDecimal("base_price"));
        dto.setDifficulty(rs.getString("difficulty"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public List<DiveSiteDto> getDiveSites(String area, String difficulty) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_dive_sites")
            .declareParameters(
                new SqlParameter("p_area", Types.VARCHAR),
                new SqlParameter("p_difficulty", Types.VARCHAR),
                new SqlOutParameter("o_sites", Types.REF_CURSOR, SITE_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_area", area)
            .addValue("p_difficulty", difficulty);

        Map<String, Object> result = call.execute(params);
        return (List<DiveSiteDto>) result.get("o_sites");
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getDiveSiteDetail(Long siteId) {
        // PostgreSQL uses separate functions for site and related tours
        SimpleJdbcCall siteCall = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_dive_site_detail_site")
            .declareParameters(
                new SqlParameter("p_site_id", Types.NUMERIC),
                new SqlOutParameter("o_site", Types.REF_CURSOR, SITE_ROW_MAPPER)
            );

        SimpleJdbcCall toursCall = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_dive_site_detail_related_tours")
            .declareParameters(
                new SqlParameter("p_site_id", Types.NUMERIC),
                new SqlOutParameter("o_related_tours", Types.REF_CURSOR, TOUR_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource("p_site_id", siteId);
        
        Map<String, Object> siteResult = siteCall.execute(params);
        Map<String, Object> toursResult = toursCall.execute(params);
        
        // Combine results
        siteResult.put("o_related_tours", toursResult.get("o_related_tours"));
        return siteResult;
    }
}
