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

import com.divingapp.dto.InstructorDto;
import com.divingapp.dto.TourDto;

import oracle.jdbc.OracleTypes;

@Repository
public class InstructorDao {

    private final DataSource dataSource;

    public InstructorDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<InstructorDto> INSTRUCTOR_ROW_MAPPER = (rs, rowNum) -> {
        InstructorDto dto = new InstructorDto();
        dto.setInstructorId(rs.getLong("INSTRUCTOR_ID"));
        dto.setLastName(rs.getString("LAST_NAME"));
        dto.setFirstName(rs.getString("FIRST_NAME"));
        dto.setCertification(rs.getString("CERTIFICATION"));
        dto.setExperienceYears(rs.getInt("EXPERIENCE_YEARS"));
        dto.setSpecialty(rs.getString("SPECIALTY"));
        dto.setProfile(rs.getString("PROFILE"));
        dto.setPhotoUrl(rs.getString("PHOTO_URL"));
        dto.setStatus(rs.getString("STATUS"));
        return dto;
    };

    private static final RowMapper<TourDto> TOUR_ROW_MAPPER = (rs, rowNum) -> {
        TourDto dto = new TourDto();
        dto.setTourId(rs.getLong("TOUR_ID"));
        dto.setTourName(rs.getString("TOUR_NAME"));
        dto.setArea(rs.getString("AREA"));
        dto.setBasePrice(rs.getBigDecimal("BASE_PRICE"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public List<InstructorDto> getInstructors() {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_INSTRUCTOR")
            .withProcedureName("GET_INSTRUCTORS")
            .declareParameters(
                new SqlOutParameter("o_instructors", OracleTypes.CURSOR, INSTRUCTOR_ROW_MAPPER)
            );

        Map<String, Object> result = call.execute(new MapSqlParameterSource());
        return (List<InstructorDto>) result.get("o_instructors");
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getInstructorDetail(Long instructorId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_INSTRUCTOR")
            .withProcedureName("GET_INSTRUCTOR_DETAIL")
            .declareParameters(
                new SqlParameter("p_instructor_id", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_instructor", OracleTypes.CURSOR, INSTRUCTOR_ROW_MAPPER),
                new SqlOutParameter("o_tours", OracleTypes.CURSOR, TOUR_ROW_MAPPER)
            );

        return call.execute(new MapSqlParameterSource("p_instructor_id", instructorId));
    }
}
