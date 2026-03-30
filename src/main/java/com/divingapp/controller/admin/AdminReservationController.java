package com.divingapp.controller.admin;

import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.divingapp.dto.ReservationDto;
import com.divingapp.service.ReservationService;

@Controller
@RequestMapping("/admin/reservations")
public class AdminReservationController {

    private final ReservationService reservationService;

    public AdminReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    @SuppressWarnings("unchecked")
    @GetMapping
    public String list(@RequestParam(required = false) String status,
                       @RequestParam(required = false) String dateFrom,
                       @RequestParam(required = false) String dateTo,
                       @RequestParam(defaultValue = "1") int page,
                       Model model) {
        int pageSize = 20;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date from = null;
        Date to = null;
        try {
            if (dateFrom != null && !dateFrom.isEmpty()) {
                from = sdf.parse(dateFrom);
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                to = sdf.parse(dateTo);
            }
        } catch (ParseException e) {
            // 日付パースエラーは無視
        }

        Map<String, Object> result = reservationService.getAllReservations(status, from, to, page, pageSize);
        List<ReservationDto> reservations = (List<ReservationDto>) result.get("O_RESERVATIONS");
        BigDecimal totalCount = (BigDecimal) result.get("O_TOTAL_COUNT");

        int total = totalCount != null ? totalCount.intValue() : 0;
        int totalPages = (total + pageSize - 1) / pageSize;

        model.addAttribute("reservations", reservations);
        model.addAttribute("totalCount", total);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("status", status);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo", dateTo);
        model.addAttribute("page", page);
        return "admin/reservation/list";
    }
}
