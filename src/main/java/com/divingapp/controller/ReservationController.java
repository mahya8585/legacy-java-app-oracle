package com.divingapp.controller;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import javax.validation.Valid;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.divingapp.config.CustomUserDetails;
import com.divingapp.dao.OptionMasterDao;
import com.divingapp.dto.OptionMasterDto;
import com.divingapp.dto.ReservationDto;
import com.divingapp.dto.TourDto;
import com.divingapp.form.ReservationForm;
import com.divingapp.service.ReservationService;
import com.divingapp.service.TourService;

@Controller
public class ReservationController {

    private final ReservationService reservationService;
    private final TourService tourService;
    private final OptionMasterDao optionMasterDao;

    public ReservationController(ReservationService reservationService,
                                 TourService tourService,
                                 OptionMasterDao optionMasterDao) {
        this.reservationService = reservationService;
        this.tourService = tourService;
        this.optionMasterDao = optionMasterDao;
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/reservations/new")
    public String newForm(@RequestParam Long tourId,
                          @RequestParam Long scheduleId,
                          Model model) {
        Map<String, Object> result = tourService.getTourDetail(tourId);
        List<TourDto> tourList = (List<TourDto>) result.get("O_TOUR");
        TourDto tour = (tourList != null && !tourList.isEmpty()) ? tourList.get(0) : null;

        List<OptionMasterDto> options = optionMasterDao.findAllActive();

        ReservationForm form = new ReservationForm();
        form.setScheduleId(scheduleId);

        model.addAttribute("tour", tour);
        model.addAttribute("schedules", result.get("O_SCHEDULES"));
        model.addAttribute("scheduleId", scheduleId);
        model.addAttribute("options", options);
        model.addAttribute("form", form);
        return "reservation/form";
    }

    @PostMapping("/reservations/new")
    public String create(@Valid @ModelAttribute("form") ReservationForm form,
                         BindingResult result,
                         @AuthenticationPrincipal CustomUserDetails userDetails,
                         Model model) {
        if (result.hasErrors()) {
            return "reservation/form";
        }

        String optionIds = form.getOptionIds() != null ? form.getOptionIds() : "";
        String optionQuantities = form.getOptionQuantities() != null ? form.getOptionQuantities() : "";

        Map<String, Object> res = reservationService.createReservation(
                userDetails.getUserId(),
                form.getScheduleId(),
                form.getNumParticipants(),
                optionIds,
                optionQuantities,
                form.getNotes());

        BigDecimal reservationId = (BigDecimal) res.get("O_RESERVATION_ID");
        return "redirect:/reservations/complete?id=" + reservationId.longValue();
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/reservations/complete")
    public String complete(@RequestParam Long id, Model model) {
        Map<String, Object> result = reservationService.getReservationDetail(id);
        List<ReservationDto> resList = (List<ReservationDto>) result.get("O_RESERVATION");
        ReservationDto reservation = (resList != null && !resList.isEmpty()) ? resList.get(0) : null;

        model.addAttribute("reservation", reservation);
        model.addAttribute("options", result.get("O_OPTIONS"));
        return "reservation/complete";
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/reservations/{id}")
    public String detail(@PathVariable Long id,
                         @AuthenticationPrincipal CustomUserDetails userDetails,
                         Model model) {
        Map<String, Object> result = reservationService.getReservationDetail(id);
        List<ReservationDto> resList = (List<ReservationDto>) result.get("O_RESERVATION");
        ReservationDto reservation = (resList != null && !resList.isEmpty()) ? resList.get(0) : null;

        if (reservation != null && !reservation.getCustomerId().equals(userDetails.getUserId())) {
            return "redirect:/customer/mypage";
        }

        model.addAttribute("reservation", reservation);
        model.addAttribute("options", result.get("O_OPTIONS"));
        return "reservation/detail";
    }

    @PostMapping("/reservations/{id}/cancel")
    public String cancel(@PathVariable Long id,
                         @RequestParam String cancelReason,
                         @AuthenticationPrincipal CustomUserDetails userDetails) {
        reservationService.cancelReservation(id, userDetails.getUserId(), cancelReason);
        return "redirect:/customer/mypage";
    }
}
