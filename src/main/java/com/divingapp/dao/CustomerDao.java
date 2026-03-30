package com.divingapp.dao;

import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.divingapp.dto.CustomerDto;

import oracle.jdbc.OracleTypes;

@Repository
public class CustomerDao {

    private final DataSource dataSource;

    public CustomerDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<CustomerDto> CUSTOMER_ROW_MAPPER = (rs, rowNum) -> {
        CustomerDto dto = new CustomerDto();
        dto.setCustomerId(rs.getLong("CUSTOMER_ID"));
        dto.setEmail(rs.getString("EMAIL"));
        dto.setLastName(rs.getString("LAST_NAME"));
        dto.setFirstName(rs.getString("FIRST_NAME"));
        dto.setLastNameKana(rs.getString("LAST_NAME_KANA"));
        dto.setFirstNameKana(rs.getString("FIRST_NAME_KANA"));
        dto.setPhone(rs.getString("PHONE"));
        dto.setBirthDate(rs.getDate("BIRTH_DATE"));
        dto.setLicenseLevel(rs.getString("LICENSE_LEVEL"));
        dto.setDiveCount(rs.getInt("DIVE_COUNT"));
        dto.setEmergencyContact(rs.getString("EMERGENCY_CONTACT"));
        dto.setStatus(rs.getString("STATUS"));
        dto.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        return dto;
    };

    public Map<String, Object> authenticate(String email, String password) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_CUSTOMER")
            .withProcedureName("AUTHENTICATE");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_email", email)
            .addValue("p_password", password);

        return call.execute(params);
    }

    public Map<String, Object> registerCustomer(String email, String password,
            String lastName, String firstName, String lastNameKana, String firstNameKana,
            String phone, Date birthDate, String licenseLevel) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_CUSTOMER")
            .withProcedureName("REGISTER_CUSTOMER");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_email", email)
            .addValue("p_password", password)
            .addValue("p_last_name", lastName)
            .addValue("p_first_name", firstName)
            .addValue("p_last_name_kana", lastNameKana)
            .addValue("p_first_name_kana", firstNameKana)
            .addValue("p_phone", phone)
            .addValue("p_birth_date", birthDate)
            .addValue("p_license_level", licenseLevel);

        return call.execute(params);
    }

    public Map<String, Object> updateProfile(Long customerId, String lastName, String firstName,
            String lastNameKana, String firstNameKana, String phone, Date birthDate,
            String licenseLevel, String emergencyContact) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_CUSTOMER")
            .withProcedureName("UPDATE_PROFILE");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_customer_id", customerId)
            .addValue("p_last_name", lastName)
            .addValue("p_first_name", firstName)
            .addValue("p_last_name_kana", lastNameKana)
            .addValue("p_first_name_kana", firstNameKana)
            .addValue("p_phone", phone)
            .addValue("p_birth_date", birthDate)
            .addValue("p_license_level", licenseLevel)
            .addValue("p_emergency_contact", emergencyContact);

        return call.execute(params);
    }

    @SuppressWarnings("unchecked")
    public CustomerDto getCustomerInfo(Long customerId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_CUSTOMER")
            .withProcedureName("GET_CUSTOMER_INFO")
            .declareParameters(
                new SqlParameter("p_customer_id", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_customer", OracleTypes.CURSOR, CUSTOMER_ROW_MAPPER)
            );

        Map<String, Object> result = call.execute(new MapSqlParameterSource("p_customer_id", customerId));
        List<CustomerDto> list = (List<CustomerDto>) result.get("o_customer");
        return list != null && !list.isEmpty() ? list.get(0) : null;
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getAllCustomers(String keyword, String status, int page, int pageSize) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_CUSTOMER")
            .withProcedureName("GET_ALL_CUSTOMERS")
            .declareParameters(
                new SqlParameter("p_keyword", java.sql.Types.VARCHAR),
                new SqlParameter("p_status", java.sql.Types.VARCHAR),
                new SqlParameter("p_page", java.sql.Types.NUMERIC),
                new SqlParameter("p_page_size", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_customers", OracleTypes.CURSOR, CUSTOMER_ROW_MAPPER),
                new SqlOutParameter("o_total_count", java.sql.Types.NUMERIC)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_keyword", keyword)
            .addValue("p_status", status)
            .addValue("p_page", page)
            .addValue("p_page_size", pageSize);

        return call.execute(params);
    }
}
