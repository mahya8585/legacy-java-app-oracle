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

import com.divingapp.dto.InstructorDto;
import com.divingapp.dto.TourDto;

@Repository
public class InstructorDao {

    private final DataSource dataSource;

    public InstructorDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<InstructorDto> INSTRUCTOR_ROW_MAPPER = (rs, rowNum) -> {
        InstructorDto dto = new InstructorDto();
        dto.setInstructorId(rs.getLong("instructor_id"));
        dto.setLastName(rs.getString("last_name"));
        dto.setFirstName(rs.getString("first_name"));
        dto.setCertification(rs.getString("certification"));
        dto.setExperienceYears(rs.getInt("experience_years"));
        dto.setSpecialty(rs.getString("specialty"));
        dto.setProfile(rs.getString("profile"));
        dto.setPhotoUrl(rs.getString("photo_url"));
        dto.setStatus(rs.getString("status"));
        return dto;
    };

    private static final RowMapper<TourDto> TOUR_ROW_MAPPER = (rs, rowNum) -> {
        TourDto dto = new TourDto();
        dto.setTourId(rs.getLong("tour_id"));
        dto.setTourName(rs.getString("tour_name"));
        dto.setArea(rs.getString("area"));
        dto.setBasePrice(rs.getBigDecimal("base_price"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public List<InstructorDto> getInstructors() {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_instructors")
            .declareParameters(
                new SqlOutParameter("o_instructors", Types.REF_CURSOR, INSTRUCTOR_ROW_MAPPER)
            );

        Map<String, Object> result = call.execute(new MapSqlParameterSource());
        return (List<InstructorDto>) result.get("o_instructors");
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getInstructorDetail(Long instructorId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_instructor_detail")
            .declareParameters(
                new SqlParameter("p_instructor_id", Types.NUMERIC),
                new SqlOutParameter("o_instructor", Types.REF_CURSOR, INSTRUCTOR_ROW_MAPPER),
                new SqlOutParameter("o_tours", Types.REF_CURSOR, TOUR_ROW_MAPPER)
            );

        return call.execute(new MapSqlParameterSource("p_instructor_id", instructorId));
    }
}
