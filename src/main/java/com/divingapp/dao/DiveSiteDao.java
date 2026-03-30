package com.divingapp.dao;

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

import oracle.jdbc.OracleTypes;

@Repository
public class DiveSiteDao {

    private final DataSource dataSource;

    public DiveSiteDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<DiveSiteDto> SITE_ROW_MAPPER = (rs, rowNum) -> {
        DiveSiteDto dto = new DiveSiteDto();
        dto.setSiteId(rs.getLong("SITE_ID"));
        dto.setSiteName(rs.getString("SITE_NAME"));
        dto.setArea(rs.getString("AREA"));
        dto.setDescription(rs.getString("DESCRIPTION"));
        dto.setMaxDepth(rs.getBigDecimal("MAX_DEPTH"));
        dto.setWaterTemperatureMin(rs.getBigDecimal("WATER_TEMPERATURE_MIN"));
        dto.setWaterTemperatureMax(rs.getBigDecimal("WATER_TEMPERATURE_MAX"));
        dto.setDifficulty(rs.getString("DIFFICULTY"));
        dto.setMarineLife(rs.getString("MARINE_LIFE"));
        dto.setAccessInfo(rs.getString("ACCESS_INFO"));
        dto.setStatus(rs.getString("STATUS"));
        return dto;
    };

    private static final RowMapper<TourDto> TOUR_ROW_MAPPER = (rs, rowNum) -> {
        TourDto dto = new TourDto();
        dto.setTourId(rs.getLong("TOUR_ID"));
        dto.setTourName(rs.getString("TOUR_NAME"));
        dto.setArea(rs.getString("AREA"));
        dto.setBasePrice(rs.getBigDecimal("BASE_PRICE"));
        dto.setDifficulty(rs.getString("DIFFICULTY"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public List<DiveSiteDto> getDiveSites(String area, String difficulty) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_DIVE_SITE")
            .withProcedureName("GET_DIVE_SITES")
            .declareParameters(
                new SqlParameter("p_area", java.sql.Types.VARCHAR),
                new SqlParameter("p_difficulty", java.sql.Types.VARCHAR),
                new SqlOutParameter("o_sites", OracleTypes.CURSOR, SITE_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_area", area)
            .addValue("p_difficulty", difficulty);

        Map<String, Object> result = call.execute(params);
        return (List<DiveSiteDto>) result.get("o_sites");
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getDiveSiteDetail(Long siteId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_DIVE_SITE")
            .withProcedureName("GET_DIVE_SITE_DETAIL")
            .declareParameters(
                new SqlParameter("p_site_id", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_site", OracleTypes.CURSOR, SITE_ROW_MAPPER),
                new SqlOutParameter("o_related_tours", OracleTypes.CURSOR, TOUR_ROW_MAPPER)
            );

        return call.execute(new MapSqlParameterSource("p_site_id", siteId));
    }
}
