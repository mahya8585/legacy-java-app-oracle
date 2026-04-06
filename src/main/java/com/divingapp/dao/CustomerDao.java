package com.divingapp.dao;

import java.sql.Types;
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

@Repository
public class CustomerDao {

    private final DataSource dataSource;

    public CustomerDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<CustomerDto> CUSTOMER_ROW_MAPPER = (rs, rowNum) -> {
        CustomerDto dto = new CustomerDto();
        dto.setCustomerId(rs.getLong("customer_id"));
        dto.setEmail(rs.getString("email"));
        dto.setLastName(rs.getString("last_name"));
        dto.setFirstName(rs.getString("first_name"));
        dto.setLastNameKana(rs.getString("last_name_kana"));
        dto.setFirstNameKana(rs.getString("first_name_kana"));
        dto.setPhone(rs.getString("phone"));
        dto.setBirthDate(rs.getDate("birth_date"));
        dto.setLicenseLevel(rs.getString("license_level"));
        dto.setDiveCount(rs.getInt("dive_count"));
        dto.setEmergencyContact(rs.getString("emergency_contact"));
        dto.setStatus(rs.getString("status"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        return dto;
    };

    public Map<String, Object> authenticate(String email, String password) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("pkg_customer_authenticate");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_email", email)
            .addValue("p_password", password);

        return call.execute(params);
    }

    public Map<String, Object> registerCustomer(String email, String password,
            String lastName, String firstName, String lastNameKana, String firstNameKana,
            String phone, Date birthDate, String licenseLevel) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("pkg_customer_register_customer");

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
            .withSchemaName("divingapp")
            .withProcedureName("pkg_customer_update_profile");

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
            .withSchemaName("divingapp")
            .withProcedureName("pkg_customer_get_customer_info")
            .declareParameters(
                new SqlParameter("p_customer_id", Types.NUMERIC),
                new SqlOutParameter("o_customer", Types.REF_CURSOR, CUSTOMER_ROW_MAPPER)
            );

        Map<String, Object> result = call.execute(new MapSqlParameterSource("p_customer_id", customerId));
        List<CustomerDto> list = (List<CustomerDto>) result.get("o_customer");
        return list != null && !list.isEmpty() ? list.get(0) : null;
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getAllCustomers(String keyword, String status, int page, int pageSize) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("pkg_customer_get_all_customers")
            .declareParameters(
                new SqlParameter("p_keyword", Types.VARCHAR),
                new SqlParameter("p_status", Types.VARCHAR),
                new SqlParameter("p_page", Types.NUMERIC),
                new SqlParameter("p_page_size", Types.NUMERIC),
                new SqlOutParameter("o_customers", Types.REF_CURSOR, CUSTOMER_ROW_MAPPER),
                new SqlOutParameter("o_total_count", Types.NUMERIC)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_keyword", keyword)
            .addValue("p_status", status)
            .addValue("p_page", page)
            .addValue("p_page_size", pageSize);

        return call.execute(params);
    }
}
