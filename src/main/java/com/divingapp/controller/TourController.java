package com.divingapp.controller;

import com.divingapp.dto.TourDto;
import com.divingapp.dto.TourSearchCondition;
import com.divingapp.service.TourService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Controller
public class TourController {

    private final TourService tourService;

    public TourController(TourService tourService) {
        this.tourService = tourService;
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/tours")
    public String list(@ModelAttribute TourSearchCondition condition, Model model) {
        if (condition.getPage() == null || condition.getPage() == 0) {
            condition.setPage(1);
        }
        if (condition.getPageSize() == null || condition.getPageSize() == 0) {
            condition.setPageSize(9);
        }

        Map<String, Object> result = tourService.searchTours(condition);
        List<TourDto> tours = (List<TourDto>) result.get("O_TOURS");
        BigDecimal totalCount = (BigDecimal) result.get("O_TOTAL_COUNT");

        int total = totalCount != null ? totalCount.intValue() : 0;
        int totalPages = (total + condition.getPageSize() - 1) / condition.getPageSize();

        model.addAttribute("tours", tours);
        model.addAttribute("totalCount", total);
        model.addAttribute("condition", condition);
        model.addAttribute("totalPages", totalPages);
        return "tour/list";
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/tours/{id}")
    public String detail(@PathVariable Long id, Model model) {
        Map<String, Object> result = tourService.getTourDetail(id);
        List<TourDto> tourList = (List<TourDto>) result.get("O_TOUR");

        model.addAttribute("tour", tourList != null && !tourList.isEmpty() ? tourList.get(0) : null);
        model.addAttribute("sites", result.get("O_SITES"));
        model.addAttribute("instructors", result.get("O_INSTRUCTORS"));
        model.addAttribute("schedules", result.get("O_SCHEDULES"));
        return "tour/detail";
    }
}
