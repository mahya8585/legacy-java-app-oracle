package com.divingapp.dao;

import java.math.BigDecimal;
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

import oracle.jdbc.OracleTypes;

@Repository
public class ReservationDao {

    private final DataSource dataSource;

    public ReservationDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<ReservationDto> RESERVATION_ROW_MAPPER = (rs, rowNum) -> {
        ReservationDto dto = new ReservationDto();
        dto.setReservationId(rs.getLong("RESERVATION_ID"));
        dto.setCustomerId(rs.getLong("CUSTOMER_ID"));
        dto.setScheduleId(rs.getLong("SCHEDULE_ID"));
        dto.setNumParticipants(rs.getInt("NUM_PARTICIPANTS"));
        dto.setTotalPrice(rs.getBigDecimal("TOTAL_PRICE"));
        dto.setStatus(rs.getString("STATUS"));
        dto.setCancelReason(rs.getString("CANCEL_REASON"));
        dto.setRefundAmount(rs.getBigDecimal("REFUND_AMOUNT"));
        dto.setNotes(rs.getString("NOTES"));
        dto.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        try { dto.setTourName(rs.getString("TOUR_NAME")); } catch (Exception e) { /* column may not exist */ }
        try { dto.setArea(rs.getString("AREA")); } catch (Exception e) { }
        try { dto.setTourDate(rs.getDate("TOUR_DATE")); } catch (Exception e) { }
        try { dto.setStartTime(rs.getString("START_TIME")); } catch (Exception e) { }
        try { dto.setCustomerName(rs.getString("CUSTOMER_NAME")); } catch (Exception e) { }
        return dto;
    };

    private static final RowMapper<ReservationOptionDto> OPTION_ROW_MAPPER = (rs, rowNum) -> {
        ReservationOptionDto dto = new ReservationOptionDto();
        dto.setResOptionId(rs.getLong("RES_OPTION_ID"));
        dto.setReservationId(rs.getLong("RESERVATION_ID"));
        dto.setOptionId(rs.getLong("OPTION_ID"));
        dto.setOptionName(rs.getString("OPTION_NAME"));
        dto.setOptionCategory(rs.getString("OPTION_CATEGORY"));
        dto.setQuantity(rs.getInt("QUANTITY"));
        dto.setUnitPrice(rs.getBigDecimal("UNIT_PRICE"));
        dto.setSubtotal(rs.getBigDecimal("SUBTOTAL"));
        return dto;
    };

    public Map<String, Object> createReservation(Long customerId, Long scheduleId,
            int numParticipants, String optionIds, String optionQuantities, String notes) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_RESERVATION")
            .withProcedureName("CREATE_RESERVATION");

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
            .withCatalogName("PKG_RESERVATION")
            .withProcedureName("CANCEL_RESERVATION");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_reservation_id", reservationId)
            .addValue("p_customer_id", customerId)
            .addValue("p_cancel_reason", cancelReason);

        return call.execute(params);
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getReservationDetail(Long reservationId) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_RESERVATION")
            .withProcedureName("GET_RESERVATION_DETAIL")
            .declareParameters(
                new SqlParameter("p_reservation_id", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_reservation", OracleTypes.CURSOR, RESERVATION_ROW_MAPPER),
                new SqlOutParameter("o_options", OracleTypes.CURSOR, OPTION_ROW_MAPPER)
            );

        return call.execute(new MapSqlParameterSource("p_reservation_id", reservationId));
    }

    @SuppressWarnings("unchecked")
    public List<ReservationDto> getCustomerReservations(Long customerId, String status) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_RESERVATION")
            .withProcedureName("GET_CUSTOMER_RESERVATIONS")
            .declareParameters(
                new SqlParameter("p_customer_id", java.sql.Types.NUMERIC),
                new SqlParameter("p_status", java.sql.Types.VARCHAR),
                new SqlOutParameter("o_reservations", OracleTypes.CURSOR, RESERVATION_ROW_MAPPER)
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
            .withCatalogName("PKG_RESERVATION")
            .withFunctionName("CALC_TOTAL_PRICE");

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
            .withCatalogName("PKG_RESERVATION")
            .withProcedureName("GET_ALL_RESERVATIONS")
            .declareParameters(
                new SqlParameter("p_status", java.sql.Types.VARCHAR),
                new SqlParameter("p_date_from", java.sql.Types.DATE),
                new SqlParameter("p_date_to", java.sql.Types.DATE),
                new SqlParameter("p_page", java.sql.Types.NUMERIC),
                new SqlParameter("p_page_size", java.sql.Types.NUMERIC),
                new SqlOutParameter("o_reservations", OracleTypes.CURSOR, RESERVATION_ROW_MAPPER),
                new SqlOutParameter("o_total_count", java.sql.Types.NUMERIC)
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
