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
        dto.setOptionId(rs.getLong("option_id"));
        dto.setOptionName(rs.getString("option_name"));
        dto.setOptionCategory(rs.getString("option_category"));
        dto.setDescription(rs.getString("description"));
        dto.setUnitPrice(rs.getBigDecimal("unit_price"));
        dto.setStatus(rs.getString("status"));
        return dto;
    };

    public List<OptionMasterDto> findAllActive() {
        return jdbcTemplate.query(
            "SELECT option_id, option_name, option_category, description, unit_price, status " +
            "FROM divingapp.options_master WHERE status = 'ACTIVE' ORDER BY option_category, option_name",
            OPTION_ROW_MAPPER
        );
    }
}
