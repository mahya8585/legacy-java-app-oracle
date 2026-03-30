package com.divingapp.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.divingapp.dto.TourDto;
import com.divingapp.dto.TourSearchCondition;
import com.divingapp.dto.DiveSiteDto;
import com.divingapp.dto.InstructorDto;
import com.divingapp.dto.TourScheduleDto;

import oracle.jdbc.OracleTypes;

@Repository
public class TourDao {

    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;

    public TourDao(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.dataSource = dataSource;
    }

    private static final RowMapper<TourDto> TOUR_ROW_MAPPER = (rs, rowNum) -> {
        TourDto dto = new TourDto();
        dto.setTourId(rs.getLong("TOUR_ID"));
        dto.setTourName(rs.getString("TOUR_NAME"));
        dto.setDescription(rs.getString("DESCRIPTION"));
        dto.setArea(rs.getString("AREA"));
        dto.setDifficulty(rs.getString("DIFFICULTY"));
        dto.setMaxParticipants(rs.getInt("MAX_PARTICIPANTS"));
        dto.setBasePrice(rs.getBigDecimal("BASE_PRICE"));
        dto.setDurationDays(rs.getInt("DURATION_DAYS"));
        dto.setMinDiveCount(rs.getInt("MIN_DIVE_COUNT"));
        dto.setFeaturedFlag(rs.getString("FEATURED_FLAG"));
        dto.setStatus(rs.getString("STATUS"));
        return dto;
    };

    private static final RowMapper<DiveSiteDto> SITE_ROW_MAPPER = (rs, rowNum) -> {
        DiveSiteDto dto = new DiveSiteDto();
        dto.setSiteId(rs.getLong("SITE_ID"));
        dto.setSiteName(rs.getString("SITE_NAME"));
        dto.setArea(rs.getString("AREA"));
        dto.setMaxDepth(rs.getBigDecimal("MAX_DEPTH"));
        dto.setDifficulty(rs.getString("DIFFICULTY"));
        return dto;
    };

    private static final RowMapper<InstructorDto> INSTRUCTOR_ROW_MAPPER = (rs, rowNum) -> {
        InstructorDto dto = new InstructorDto();
        dto.setInstructorId(rs.getLong("INSTRUCTOR_ID"));
        dto.setLastName(rs.getString("LAST_NAME"));
        dto.setFirstName(rs.getString("FIRST_NAME"));
        dto.setCertification(rs.getString("CERTIFICATION"));
        dto.setRole(rs.getString("ROLE"));
        return dto;
    };

    private static final RowMapper<TourScheduleDto> SCHEDULE_ROW_MAPPER = (rs, rowNum) -> {
        TourScheduleDto dto = new TourScheduleDto();
        dto.setScheduleId(rs.getLong("SCHEDULE_ID"));
        dto.setTourId(rs.getLong("TOUR_ID"));
        dto.setTourDate(rs.getDate("TOUR_DATE"));
        dto.setStartTime(rs.getString("START_TIME"));
        dto.setRemainingSeats(rs.getInt("REMAINING_SEATS"));
        dto.setStatus(rs.getString("STATUS"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public Map<String, Object> searchTours(TourSearchCondition condition) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_TOUR")
            .withProcedureName("SEARCH_TOURS")
            .declareParameters(
                new SqlParameter("p_area", java.sql.Types.VARCHAR),
                new SqlParameter("p_difficulty", java.sql.Types.VARCHAR),
                new SqlParameter("p_date_from", java.sql.Types.DATE),
                new SqlParameter("p_date_to", java.sql.Types.DATE),
                new SqlParameter("p_price_min", java.sql.Types.NUMERIC),
                new SqlParameter("p_price_max", java.sql.Types.NUMERIC),
                new SqlParameter("p_duration_days", java.sql.Types.NUMERIC),
                new SqlParameter("p_keyword", java.sql.Types.VARCHAR),
                new SqlParameter("p_page", java.sql.Types.NUMERIC),
                new SqlParameter("p_page_size", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_tours", OracleTypes.CURSOR, TOUR_ROW_MAPPER),
                new SqlOutParameter("o_total_count", java.sql.Types.NUMERIC)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_area", condition.getArea())
            .addValue("p_difficulty", condition.getDifficulty())
            .addValue("p_date_from", condition.getDateFrom())
            .addValue("p_date_to", condition.getDateTo())
            .addValue("p_price_min", condition.getPriceMin())
            .addValue("p_price_max", condition.getPriceMax())
            .addValue("p_duration_days", condition.getDurationDays())
            .addValue("p_keyword", condition.getKeyword())
            .addValue("p_page", condition.getPage())
            .addValue("p_page_size", condition.getPageSize());

        return call.execute(params);
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getTourDetail(Long tourId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_TOUR")
            .withProcedureName("GET_TOUR_DETAIL")
            .declareParameters(
                new SqlParameter("p_tour_id", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_tour", OracleTypes.CURSOR, TOUR_ROW_MAPPER),
                new SqlOutParameter("o_sites", OracleTypes.CURSOR, SITE_ROW_MAPPER),
                new SqlOutParameter("o_instructors", OracleTypes.CURSOR, INSTRUCTOR_ROW_MAPPER),
                new SqlOutParameter("o_schedules", OracleTypes.CURSOR, SCHEDULE_ROW_MAPPER)
            );

        return call.execute(new MapSqlParameterSource("p_tour_id", tourId));
    }

    @SuppressWarnings("unchecked")
    public List<TourDto> getFeaturedTours(int limit) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_TOUR")
            .withProcedureName("GET_FEATURED_TOURS")
            .declareParameters(
                new SqlParameter("p_limit", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_tours", OracleTypes.CURSOR, TOUR_ROW_MAPPER)
            );

        Map<String, Object> result = call.execute(new MapSqlParameterSource("p_limit", limit));
        return (List<TourDto>) result.get("o_tours");
    }

    public Map<String, Object> saveTour(Long tourId, String tourName, String description,
            String area, String difficulty, int maxParticipants, int basePrice,
            int durationDays, int minDiveCount, String featuredFlag) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_TOUR")
            .withProcedureName("SAVE_TOUR");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_tour_id", tourId)
            .addValue("p_tour_name", tourName)
            .addValue("p_description", description)
            .addValue("p_area", area)
            .addValue("p_difficulty", difficulty)
            .addValue("p_max_participants", maxParticipants)
            .addValue("p_base_price", basePrice)
            .addValue("p_duration_days", durationDays)
            .addValue("p_min_dive_count", minDiveCount)
            .addValue("p_featured_flag", featuredFlag);

        return call.execute(params);
    }

    public Map<String, Object> deleteTour(Long tourId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_TOUR")
            .withProcedureName("DELETE_TOUR");

        return call.execute(new MapSqlParameterSource("p_tour_id", tourId));
    }
}
