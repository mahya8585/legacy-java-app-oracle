package com.divingapp.dao;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.divingapp.dto.OptionMasterDto;

@Repository
public class OptionMasterDao {

    private final JdbcTemplate jdbcTemplate;

    public OptionMasterDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final RowMapper<OptionMasterDto> OPTION_ROW_MAPPER = (rs, rowNum) -> {
        OptionMasterDto dto = new OptionMasterDto();
        dto.setOptionId(rs.getLong("OPTION_ID"));
        dto.setOptionName(rs.getString("OPTION_NAME"));
        dto.setOptionCategory(rs.getString("OPTION_CATEGORY"));
        dto.setDescription(rs.getString("DESCRIPTION"));
        dto.setUnitPrice(rs.getBigDecimal("UNIT_PRICE"));
        dto.setStatus(rs.getString("STATUS"));
        return dto;
    };

    public List<OptionMasterDto> findAllActive() {
        return jdbcTemplate.query(
            "SELECT OPTION_ID, OPTION_NAME, OPTION_CATEGORY, DESCRIPTION, UNIT_PRICE, STATUS " +
            "FROM OPTIONS_MASTER WHERE STATUS = 'ACTIVE' ORDER BY OPTION_CATEGORY, OPTION_NAME",
            OPTION_ROW_MAPPER
        );
    }
}
