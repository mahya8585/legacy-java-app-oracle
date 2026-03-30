package com.divingapp.controller.admin;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import javax.validation.Valid;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.divingapp.dto.TourDto;
import com.divingapp.dto.TourSearchCondition;
import com.divingapp.form.TourForm;
import com.divingapp.service.TourService;

@Controller
@RequestMapping("/admin/tours")
public class AdminTourController {

    private final TourService tourService;

    public AdminTourController(TourService tourService) {
        this.tourService = tourService;
    }

    @SuppressWarnings("unchecked")
    @GetMapping
    public String list(Model model) {
        TourSearchCondition condition = new TourSearchCondition();
        condition.setPage(1);
        condition.setPageSize(20);

        Map<String, Object> result = tourService.searchTours(condition);
        List<TourDto> tours = (List<TourDto>) result.get("O_TOURS");
        BigDecimal totalCount = (BigDecimal) result.get("O_TOTAL_COUNT");

        model.addAttribute("tours", tours);
        model.addAttribute("totalCount", totalCount != null ? totalCount.intValue() : 0);
        return "admin/tour/list";
    }

    @GetMapping("/new")
    public String newForm(Model model) {
        model.addAttribute("form", new TourForm());
        model.addAttribute("isNew", true);
        return "admin/tour/form";
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        Map<String, Object> result = tourService.getTourDetail(id);
        List<TourDto> tourList = (List<TourDto>) result.get("O_TOUR");
        TourDto tour = (tourList != null && !tourList.isEmpty()) ? tourList.get(0) : null;

        TourForm form = new TourForm();
        if (tour != null) {
            form.setTourId(tour.getTourId());
            form.setTourName(tour.getTourName());
            form.setDescription(tour.getDescription());
            form.setArea(tour.getArea());
            form.setDifficulty(tour.getDifficulty());
            form.setMaxParticipants(tour.getMaxParticipants());
            form.setBasePrice(tour.getBasePrice() != null ? tour.getBasePrice().intValue() : null);
            form.setDurationDays(tour.getDurationDays());
            form.setMinDiveCount(tour.getMinDiveCount());
            form.setFeaturedFlag(tour.getFeaturedFlag());
        }

        model.addAttribute("form", form);
        model.addAttribute("isNew", false);
        return "admin/tour/form";
    }

    @PostMapping("/save")
    public String save(@Valid @ModelAttribute("form") TourForm form,
                       BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("isNew", form.getTourId() == null);
            return "admin/tour/form";
        }

        tourService.saveTour(
                form.getTourId(),
                form.getTourName(),
                form.getDescription(),
                form.getArea(),
                form.getDifficulty(),
                form.getMaxParticipants() != null ? form.getMaxParticipants() : 0,
                form.getBasePrice() != null ? form.getBasePrice() : 0,
                form.getDurationDays() != null ? form.getDurationDays() : 1,
                form.getMinDiveCount() != null ? form.getMinDiveCount() : 0,
                form.getFeaturedFlag() != null ? form.getFeaturedFlag() : "N"
        );

        return "redirect:/admin/tours";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        tourService.deleteTour(id);
        return "redirect:/admin/tours";
    }
}
