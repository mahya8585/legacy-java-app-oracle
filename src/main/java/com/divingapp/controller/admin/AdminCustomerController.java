package com.divingapp.controller.admin;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.divingapp.dto.CustomerDto;
import com.divingapp.service.CustomerService;

@Controller
@RequestMapping("/admin/customers")
public class AdminCustomerController {

    private final CustomerService customerService;

    public AdminCustomerController(CustomerService customerService) {
        this.customerService = customerService;
    }

    @SuppressWarnings("unchecked")
    @GetMapping
    public String list(@RequestParam(required = false) String keyword,
                       @RequestParam(required = false) String status,
                       @RequestParam(defaultValue = "1") int page,
                       Model model) {
        int pageSize = 20;
        Map<String, Object> result = customerService.getAllCustomers(keyword, status, page, pageSize);
        List<CustomerDto> customers = (List<CustomerDto>) result.get("O_CUSTOMERS");
        BigDecimal totalCount = (BigDecimal) result.get("O_TOTAL_COUNT");

        int total = totalCount != null ? totalCount.intValue() : 0;
        int totalPages = (total + pageSize - 1) / pageSize;

        model.addAttribute("customers", customers);
        model.addAttribute("totalCount", total);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("keyword", keyword);
        model.addAttribute("status", status);
        model.addAttribute("page", page);
        return "admin/customer/list";
    }
}
