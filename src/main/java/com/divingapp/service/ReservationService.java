package com.divingapp.service;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.ReservationDao;
import com.divingapp.dto.ReservationDto;

@Service
@Transactional(readOnly = true)
public class ReservationService {

    private final ReservationDao reservationDao;

    public ReservationService(ReservationDao reservationDao) {
        this.reservationDao = reservationDao;
    }

    @Transactional
    public Map<String, Object> createReservation(Long customerId, Long scheduleId,
            int numParticipants, String optionIds, String optionQuantities, String notes) {
        return reservationDao.createReservation(customerId, scheduleId,
                numParticipants, optionIds, optionQuantities, notes);
    }

    @Transactional
    public Map<String, Object> cancelReservation(Long reservationId, Long customerId, String cancelReason) {
        return reservationDao.cancelReservation(reservationId, customerId, cancelReason);
    }

    public Map<String, Object> getReservationDetail(Long reservationId) {
        return reservationDao.getReservationDetail(reservationId);
    }

    public List<ReservationDto> getCustomerReservations(Long customerId, String status) {
        return reservationDao.getCustomerReservations(customerId, status);
    }

    public BigDecimal calcTotalPrice(Long scheduleId, int numParticipants,
            String optionIds, String optionQuantities) {
        return reservationDao.calcTotalPrice(scheduleId, numParticipants, optionIds, optionQuantities);
    }

    public Map<String, Object> getAllReservations(String status, Date dateFrom, Date dateTo,
            int page, int pageSize) {
        return reservationDao.getAllReservations(status, dateFrom, dateTo, page, pageSize);
    }
}
