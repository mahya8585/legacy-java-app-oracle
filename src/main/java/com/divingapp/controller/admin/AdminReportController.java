package com.divingapp.controller.admin;

import java.util.Calendar;
import java.util.Date;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.divingapp.service.ReportService;

@Controller
@RequestMapping("/admin/reports")
public class AdminReportController {

    private final ReportService reportService;

    public AdminReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping
    public String index(@RequestParam(defaultValue = "sales") String type,
                        @RequestParam(required = false) Integer year,
                        @RequestParam(required = false) Integer month,
                        Model model) {
        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
        int targetYear = (year != null) ? year : currentYear;

        Map<String, Object> result;
        switch (type) {
            case "popularity":
                Calendar calFrom = Calendar.getInstance();
                calFrom.set(targetYear, (month != null ? month - 1 : 0), 1, 0, 0, 0);
                Calendar calTo = Calendar.getInstance();
                if (month != null) {
                    calTo.set(targetYear, month - 1, calTo.getActualMaximum(Calendar.DAY_OF_MONTH), 23, 59, 59);
                } else {
                    calTo.set(targetYear, 11, 31, 23, 59, 59);
                }
                result = reportService.getTourPopularity(calFrom.getTime(), calTo.getTime(), 20);
                model.addAttribute("reportData", result.get("O_REPORT"));
                break;
            case "occupancy":
                result = reportService.getOccupancyRate(targetYear, month);
                model.addAttribute("reportData", result.get("O_REPORT"));
                break;
            case "sales":
            default:
                result = reportService.getMonthlySales(targetYear, month);
                model.addAttribute("reportData", result.get("O_REPORT"));
                break;
        }

        model.addAttribute("reportType", type);
        model.addAttribute("year", targetYear);
        model.addAttribute("month", month);
        return "admin/report/index";
    }
}
