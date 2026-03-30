package com.divingapp.controller;

import com.divingapp.dto.DiveSiteDto;
import com.divingapp.service.DiveSiteService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@Controller
public class DiveSiteController {

    private final DiveSiteService diveSiteService;

    public DiveSiteController(DiveSiteService diveSiteService) {
        this.diveSiteService = diveSiteService;
    }

    @GetMapping("/divesites")
    public String list(@RequestParam(required = false) String area,
                       @RequestParam(required = false) String difficulty,
                       Model model) {
        model.addAttribute("sites", diveSiteService.getDiveSites(area, difficulty));
        model.addAttribute("area", area);
        model.addAttribute("difficulty", difficulty);
        return "divesite/list";
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/divesites/{id}")
    public String detail(@PathVariable Long id, Model model) {
        Map<String, Object> result = diveSiteService.getDiveSiteDetail(id);
        List<DiveSiteDto> siteList = (List<DiveSiteDto>) result.get("O_SITE");

        model.addAttribute("site", siteList != null && !siteList.isEmpty() ? siteList.get(0) : null);
        model.addAttribute("relatedTours", result.get("O_RELATED_TOURS"));
        return "divesite/detail";
    }
}
