package com.divingapp.dao;

import java.sql.Types;
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
        dto.setTourId(rs.getLong("tour_id"));
        dto.setTourName(rs.getString("tour_name"));
        dto.setDescription(rs.getString("description"));
        dto.setArea(rs.getString("area"));
        dto.setDifficulty(rs.getString("difficulty"));
        dto.setMaxParticipants(rs.getInt("max_participants"));
        dto.setBasePrice(rs.getBigDecimal("base_price"));
        dto.setDurationDays(rs.getInt("duration_days"));
        dto.setMinDiveCount(rs.getInt("min_dive_count"));
        dto.setFeaturedFlag(rs.getString("featured_flag"));
        dto.setStatus(rs.getString("status"));
        return dto;
    };

    private static final RowMapper<DiveSiteDto> SITE_ROW_MAPPER = (rs, rowNum) -> {
        DiveSiteDto dto = new DiveSiteDto();
        dto.setSiteId(rs.getLong("site_id"));
        dto.setSiteName(rs.getString("site_name"));
        dto.setArea(rs.getString("area"));
        dto.setMaxDepth(rs.getBigDecimal("max_depth"));
        dto.setDifficulty(rs.getString("difficulty"));
        return dto;
    };

    private static final RowMapper<InstructorDto> INSTRUCTOR_ROW_MAPPER = (rs, rowNum) -> {
        InstructorDto dto = new InstructorDto();
        dto.setInstructorId(rs.getLong("instructor_id"));
        dto.setLastName(rs.getString("last_name"));
        dto.setFirstName(rs.getString("first_name"));
        dto.setCertification(rs.getString("certification"));
        dto.setRole(rs.getString("role"));
        return dto;
    };

    private static final RowMapper<TourScheduleDto> SCHEDULE_ROW_MAPPER = (rs, rowNum) -> {
        TourScheduleDto dto = new TourScheduleDto();
        dto.setScheduleId(rs.getLong("schedule_id"));
        dto.setTourId(rs.getLong("tour_id"));
        dto.setTourDate(rs.getDate("tour_date"));
        dto.setStartTime(rs.getString("start_time"));
        dto.setRemainingSeats(rs.getInt("remaining_seats"));
        dto.setStatus(rs.getString("status"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public Map<String, Object> searchTours(TourSearchCondition condition) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("search_tours")
            .declareParameters(
                new SqlParameter("p_area", Types.VARCHAR),
                new SqlParameter("p_difficulty", Types.VARCHAR),
                new SqlParameter("p_date_from", Types.DATE),
                new SqlParameter("p_date_to", Types.DATE),
                new SqlParameter("p_price_min", Types.NUMERIC),
                new SqlParameter("p_price_max", Types.NUMERIC),
                new SqlParameter("p_duration_days", Types.NUMERIC),
                new SqlParameter("p_keyword", Types.VARCHAR),
                new SqlParameter("p_page", Types.NUMERIC),
                new SqlParameter("p_page_size", Types.NUMERIC),
                new SqlOutParameter("o_tours", Types.REF_CURSOR, TOUR_ROW_MAPPER),
                new SqlOutParameter("o_total_count", Types.NUMERIC)
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
            .withSchemaName("divingapp")
            .withProcedureName("get_tour_detail")
            .declareParameters(
                new SqlParameter("p_tour_id", Types.NUMERIC),
                new SqlOutParameter("o_tour", Types.REF_CURSOR, TOUR_ROW_MAPPER),
                new SqlOutParameter("o_sites", Types.REF_CURSOR, SITE_ROW_MAPPER),
                new SqlOutParameter("o_instructors", Types.REF_CURSOR, INSTRUCTOR_ROW_MAPPER),
                new SqlOutParameter("o_schedules", Types.REF_CURSOR, SCHEDULE_ROW_MAPPER)
            );

        return call.execute(new MapSqlParameterSource("p_tour_id", tourId));
    }

    @SuppressWarnings("unchecked")
    public List<TourDto> getFeaturedTours(int limit) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_featured_tours")
            .declareParameters(
                new SqlParameter("p_limit", Types.NUMERIC),
                new SqlOutParameter("o_tours", Types.REF_CURSOR, TOUR_ROW_MAPPER)
            );

        Map<String, Object> result = call.execute(new MapSqlParameterSource("p_limit", limit));
        return (List<TourDto>) result.get("o_tours");
    }

    public Map<String, Object> saveTour(Long tourId, String tourName, String description,
            String area, String difficulty, int maxParticipants, int basePrice,
            int durationDays, int minDiveCount, String featuredFlag) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("save_tour");

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
            .withSchemaName("divingapp")
            .withProcedureName("delete_tour");

        return call.execute(new MapSqlParameterSource("p_tour_id", tourId));
    }
}
