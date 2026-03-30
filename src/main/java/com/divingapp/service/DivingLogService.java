package com.divingapp.service;

import java.math.BigDecimal;
import java.util.Date;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.DivingLogDao;

@Service
@Transactional(readOnly = true)
public class DivingLogService {

    private final DivingLogDao divingLogDao;

    public DivingLogService(DivingLogDao divingLogDao) {
        this.divingLogDao = divingLogDao;
    }

    public Map<String, Object> getCustomerLogs(Long customerId, int page, int pageSize) {
        return divingLogDao.getCustomerLogs(customerId, page, pageSize);
    }

    @Transactional
    public Map<String, Object> saveDivingLog(Long logId, Long customerId, Long siteId,
            Long reservationId, Date diveDate, BigDecimal maxDepth, Integer diveTime,
            BigDecimal waterTemp, BigDecimal visibility, String weather,
            String buddy, String notes) {
        return divingLogDao.saveDivingLog(logId, customerId, siteId, reservationId,
                diveDate, maxDepth, diveTime, waterTemp, visibility, weather, buddy, notes);
    }
}
