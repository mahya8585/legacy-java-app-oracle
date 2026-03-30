package com.divingapp.controller;

import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.divingapp.config.CustomUserDetails;
import com.divingapp.dto.DiveSiteDto;
import com.divingapp.dto.DivingLogDto;
import com.divingapp.service.DiveSiteService;
import com.divingapp.service.DivingLogService;

@Controller
public class DivingLogController {

    private final DivingLogService divingLogService;
    private final DiveSiteService diveSiteService;

    public DivingLogController(DivingLogService divingLogService, DiveSiteService diveSiteService) {
        this.divingLogService = divingLogService;
        this.diveSiteService = diveSiteService;
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/divinglogs")
    public String list(@AuthenticationPrincipal CustomUserDetails userDetails,
                       @RequestParam(defaultValue = "1") int page,
                       Model model) {
        int pageSize = 10;
        Map<String, Object> result = divingLogService.getCustomerLogs(userDetails.getUserId(), page, pageSize);
        List<DivingLogDto> logs = (List<DivingLogDto>) result.get("O_LOGS");
        BigDecimal totalCount = (BigDecimal) result.get("O_TOTAL_COUNT");

        int total = totalCount != null ? totalCount.intValue() : 0;
        int totalPages = (total + pageSize - 1) / pageSize;

        model.addAttribute("logs", logs);
        model.addAttribute("totalCount", total);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        return "divinglog/list";
    }

    @GetMapping("/divinglogs/new")
    public String newForm(Model model) {
        List<DiveSiteDto> sites = diveSiteService.getDiveSites(null, null);
        model.addAttribute("sites", sites);
        return "divinglog/form";
    }

    @PostMapping("/divinglogs/save")
    public String save(@AuthenticationPrincipal CustomUserDetails userDetails,
                       @RequestParam(required = false) Long logId,
                       @RequestParam(required = false) Long siteId,
                       @RequestParam(required = false) Long reservationId,
                       @RequestParam(required = false) String diveDate,
                       @RequestParam(required = false) BigDecimal maxDepth,
                       @RequestParam(required = false) Integer diveTime,
                       @RequestParam(required = false) BigDecimal waterTemp,
                       @RequestParam(required = false) BigDecimal visibility,
                       @RequestParam(required = false) String weather,
                       @RequestParam(required = false) String buddy,
                       @RequestParam(required = false) String notes) {
        Date parsedDate = null;
        if (diveDate != null && !diveDate.isEmpty()) {
            try {
                parsedDate = new SimpleDateFormat("yyyy-MM-dd").parse(diveDate);
            } catch (ParseException e) {
                // invalid date, leave null
            }
        }

        divingLogService.saveDivingLog(logId, userDetails.getUserId(), siteId, reservationId,
                parsedDate, maxDepth, diveTime, waterTemp, visibility, weather, buddy, notes);
        return "redirect:/divinglogs";
    }
}
