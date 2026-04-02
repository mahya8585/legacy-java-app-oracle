package com.divingapp.controller.admin;

import java.math.BigDecimal;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.divingapp.service.ReportService;

@Controller
@RequestMapping("/admin")
public class AdminDashboardController {

    private final ReportService reportService;

    public AdminDashboardController(ReportService reportService) {
        this.reportService = reportService;
    }

    @SuppressWarnings("unchecked")
    @GetMapping({"", "/dashboard"})
    public String dashboard(@RequestParam(required = false) Integer year,
                            @RequestParam(required = false) Integer month,
                            Model model) {
        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
        int targetYear = (year != null) ? year : currentYear;

        // 既存の月次売上レポート
        Map<String, Object> salesResult = reportService.getMonthlySales(targetYear, null);
        model.addAttribute("salesReport", salesResult.get("O_REPORT"));

        // 包括的ダッシュボードレポート
        Map<String, Object> dashboard = reportService.getDashboardReport(targetYear, month);
        model.addAttribute("salesTrend", dashboard.get("O_SALES_TREND"));
        model.addAttribute("areaMatrix", dashboard.get("O_AREA_MATRIX"));
        model.addAttribute("instructorKpi", dashboard.get("O_INSTRUCTOR_KPI"));
        model.addAttribute("customerSegment", dashboard.get("O_CUSTOMER_SEGMENT"));
        model.addAttribute("cancelAnalysis", dashboard.get("O_CANCEL_ANALYSIS"));
        model.addAttribute("anomalyAlerts", dashboard.get("O_ANOMALY_ALERTS"));

        model.addAttribute("year", targetYear);
        model.addAttribute("month", month);
        return "admin/dashboard";
    }
}
