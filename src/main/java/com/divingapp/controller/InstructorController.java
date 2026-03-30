package com.divingapp.controller;

import com.divingapp.dto.InstructorDto;
import com.divingapp.service.InstructorService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.Map;

@Controller
public class InstructorController {

    private final InstructorService instructorService;

    public InstructorController(InstructorService instructorService) {
        this.instructorService = instructorService;
    }

    @GetMapping("/instructors")
    public String list(Model model) {
        model.addAttribute("instructors", instructorService.getInstructors());
        return "instructor/list";
    }

    @SuppressWarnings("unchecked")
    @GetMapping("/instructors/{id}")
    public String detail(@PathVariable Long id, Model model) {
        Map<String, Object> result = instructorService.getInstructorDetail(id);
        List<InstructorDto> instructorList = (List<InstructorDto>) result.get("O_INSTRUCTOR");

        model.addAttribute("instructor", instructorList != null && !instructorList.isEmpty() ? instructorList.get(0) : null);
        model.addAttribute("tours", result.get("O_TOURS"));
        return "instructor/detail";
    }
}
