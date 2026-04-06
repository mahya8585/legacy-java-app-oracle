package com.divingapp.dao;

import java.math.BigDecimal;
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

import com.divingapp.dto.ReservationDto;
import com.divingapp.dto.ReservationOptionDto;

@Repository
public class ReservationDao {

    private final DataSource dataSource;

    public ReservationDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<ReservationDto> RESERVATION_ROW_MAPPER = (rs, rowNum) -> {
        ReservationDto dto = new ReservationDto();
        dto.setReservationId(rs.getLong("reservation_id"));
        dto.setCustomerId(rs.getLong("customer_id"));
        dto.setScheduleId(rs.getLong("schedule_id"));
        dto.setNumParticipants(rs.getInt("num_participants"));
        dto.setTotalPrice(rs.getBigDecimal("total_price"));
        dto.setStatus(rs.getString("status"));
        dto.setCancelReason(rs.getString("cancel_reason"));
        dto.setRefundAmount(rs.getBigDecimal("refund_amount"));
        dto.setNotes(rs.getString("notes"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        try { dto.setTourName(rs.getString("tour_name")); } catch (Exception e) { /* column may not exist */ }
        try { dto.setArea(rs.getString("area")); } catch (Exception e) { }
        try { dto.setTourDate(rs.getDate("tour_date")); } catch (Exception e) { }
        try { dto.setStartTime(rs.getString("start_time")); } catch (Exception e) { }
        try { dto.setCustomerName(rs.getString("customer_name")); } catch (Exception e) { }
        return dto;
    };

    private static final RowMapper<ReservationOptionDto> OPTION_ROW_MAPPER = (rs, rowNum) -> {
        ReservationOptionDto dto = new ReservationOptionDto();
        dto.setResOptionId(rs.getLong("res_option_id"));
        dto.setReservationId(rs.getLong("reservation_id"));
        dto.setOptionId(rs.getLong("option_id"));
        dto.setOptionName(rs.getString("option_name"));
        dto.setOptionCategory(rs.getString("option_category"));
        dto.setQuantity(rs.getInt("quantity"));
        dto.setUnitPrice(rs.getBigDecimal("unit_price"));
        dto.setSubtotal(rs.getBigDecimal("subtotal"));
        return dto;
    };

    public Map<String, Object> createReservation(Long customerId, Long scheduleId,
            int numParticipants, String optionIds, String optionQuantities, String notes) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("create_reservation");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_customer_id", customerId)
            .addValue("p_schedule_id", scheduleId)
            .addValue("p_num_participants", numParticipants)
            .addValue("p_option_ids", optionIds)
            .addValue("p_option_quantities", optionQuantities)
            .addValue("p_notes", notes);

        return call.execute(params);
    }

    public Map<String, Object> cancelReservation(Long reservationId, Long customerId, String cancelReason) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("cancel_reservation");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_reservation_id", reservationId)
            .addValue("p_customer_id", customerId)
            .addValue("p_cancel_reason", cancelReason);

        return call.execute(params);
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getReservationDetail(Long reservationId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_reservation_detail")
            .declareParameters(
                new SqlParameter("p_reservation_id", Types.NUMERIC),
                new SqlOutParameter("o_reservation", Types.REF_CURSOR, RESERVATION_ROW_MAPPER),
                new SqlOutParameter("o_options", Types.REF_CURSOR, OPTION_ROW_MAPPER)
            );

        return call.execute(new MapSqlParameterSource("p_reservation_id", reservationId));
    }

    @SuppressWarnings("unchecked")
    public List<ReservationDto> getCustomerReservations(Long customerId, String status) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_customer_reservations")
            .declareParameters(
                new SqlParameter("p_customer_id", Types.NUMERIC),
                new SqlParameter("p_status", Types.VARCHAR),
                new SqlOutParameter("o_reservations", Types.REF_CURSOR, RESERVATION_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_customer_id", customerId)
            .addValue("p_status", status);

        Map<String, Object> result = call.execute(params);
        return (List<ReservationDto>) result.get("o_reservations");
    }

    public BigDecimal calcTotalPrice(Long scheduleId, int numParticipants,
            String optionIds, String optionQuantities) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withFunctionName("calc_total_price");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_schedule_id", scheduleId)
            .addValue("p_num_participants", numParticipants)
            .addValue("p_option_ids", optionIds)
            .addValue("p_option_quantities", optionQuantities);

        return call.executeFunction(BigDecimal.class, params);
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getAllReservations(String status, Date dateFrom, Date dateTo,
            int page, int pageSize) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("get_all_reservations")
            .declareParameters(
                new SqlParameter("p_status", Types.VARCHAR),
                new SqlParameter("p_date_from", Types.DATE),
                new SqlParameter("p_date_to", Types.DATE),
                new SqlParameter("p_page", Types.NUMERIC),
                new SqlParameter("p_page_size", Types.NUMERIC),
                new SqlOutParameter("o_reservations", Types.REF_CURSOR, RESERVATION_ROW_MAPPER),
                new SqlOutParameter("o_total_count", Types.NUMERIC)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_status", status)
            .addValue("p_date_from", dateFrom)
            .addValue("p_date_to", dateTo)
            .addValue("p_page", page)
            .addValue("p_page_size", pageSize);

        return call.execute(params);
    }
}
