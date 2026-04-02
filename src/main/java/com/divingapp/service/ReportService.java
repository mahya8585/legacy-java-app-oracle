package com.divingapp.service;

import java.util.Date;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.ReportDao;

@Service
@Transactional(readOnly = true)
public class ReportService {

    private final ReportDao reportDao;

    public ReportService(ReportDao reportDao) {
        this.reportDao = reportDao;
    }

    public Map<String, Object> getMonthlySales(int year, Integer month) {
        return reportDao.getMonthlySales(year, month);
    }

    public Map<String, Object> getTourPopularity(Date dateFrom, Date dateTo, int limit) {
        return reportDao.getTourPopularity(dateFrom, dateTo, limit);
    }

    public Map<String, Object> getOccupancyRate(int year, Integer month) {
        return reportDao.getOccupancyRate(year, month);
    }

    public Map<String, Object> getDashboardReport(int year, Integer month) {
        return reportDao.getDashboardReport(year, month);
    }
}
