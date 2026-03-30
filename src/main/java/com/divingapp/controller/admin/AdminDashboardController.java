package com.divingapp.controller.admin;

import java.math.BigDecimal;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

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
    public String dashboard(Model model) {
        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
        Map<String, Object> result = reportService.getMonthlySales(currentYear, null);
        model.addAttribute("salesReport", result.get("O_REPORT"));
        model.addAttribute("year", currentYear);
        return "admin/dashboard";
    }
}
