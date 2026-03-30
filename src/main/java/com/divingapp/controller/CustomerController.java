package com.divingapp.controller;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.validation.Valid;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import com.divingapp.config.CustomUserDetails;
import com.divingapp.dto.CustomerDto;
import com.divingapp.dto.ReservationDto;
import com.divingapp.form.CustomerRegistrationForm;
import com.divingapp.service.CustomerService;
import com.divingapp.service.ReservationService;

@Controller
public class CustomerController {

    private final CustomerService customerService;
    private final ReservationService reservationService;

    public CustomerController(CustomerService customerService, ReservationService reservationService) {
        this.customerService = customerService;
        this.reservationService = reservationService;
    }

    @GetMapping("/customer/login")
    public String login() {
        return "customer/login";
    }

    @GetMapping("/customer/register")
    public String registerForm(Model model) {
        model.addAttribute("form", new CustomerRegistrationForm());
        return "customer/register";
    }

    @PostMapping("/customer/register")
    public String register(@Valid @ModelAttribute("form") CustomerRegistrationForm form,
                           BindingResult result, Model model) {
        if (!form.getPassword().equals(form.getPasswordConfirm())) {
            result.addError(new FieldError("form", "passwordConfirm", "パスワードが一致しません"));
        }
        if (result.hasErrors()) {
            return "customer/register";
        }

        try {
            Date birthDate = null;
            if (form.getBirthDate() != null && !form.getBirthDate().isEmpty()) {
                birthDate = new SimpleDateFormat("yyyy-MM-dd").parse(form.getBirthDate());
            }
            customerService.registerCustomer(
                    form.getEmail(), form.getPassword(),
                    form.getLastName(), form.getFirstName(),
                    form.getLastNameKana(), form.getFirstNameKana(),
                    form.getPhone(), birthDate, form.getLicenseLevel());
            return "redirect:/customer/login?registered=true";
        } catch (RuntimeException e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("-20")) {
                result.addError(new FieldError("form", "email", "このメールアドレスは既に登録されています"));
            } else {
                result.addError(new FieldError("form", "email", "登録に失敗しました: " + msg));
            }
            return "customer/register";
        } catch (ParseException e) {
            result.addError(new FieldError("form", "birthDate", "生年月日の形式が不正です"));
            return "customer/register";
        }
    }

    @GetMapping("/customer/mypage")
    public String mypage(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {
        Long customerId = userDetails.getUserId();
        CustomerDto customer = customerService.getCustomerInfo(customerId);
        List<ReservationDto> reservations = reservationService.getCustomerReservations(customerId, null);

        model.addAttribute("customer", customer);
        model.addAttribute("reservations", reservations);
        return "customer/mypage";
    }

    @GetMapping("/customer/profile")
    public String profileForm(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {
        Long customerId = userDetails.getUserId();
        CustomerDto customer = customerService.getCustomerInfo(customerId);

        CustomerRegistrationForm form = new CustomerRegistrationForm();
        form.setEmail(customer.getEmail());
        form.setLastName(customer.getLastName());
        form.setFirstName(customer.getFirstName());
        form.setLastNameKana(customer.getLastNameKana());
        form.setFirstNameKana(customer.getFirstNameKana());
        form.setPhone(customer.getPhone());
        if (customer.getBirthDate() != null) {
            form.setBirthDate(new SimpleDateFormat("yyyy-MM-dd").format(customer.getBirthDate()));
        }
        form.setLicenseLevel(customer.getLicenseLevel());

        model.addAttribute("form", form);
        model.addAttribute("customer", customer);
        return "customer/profile";
    }

    @PostMapping("/customer/profile")
    public String updateProfile(@AuthenticationPrincipal CustomUserDetails userDetails,
                                @ModelAttribute("form") CustomerRegistrationForm form,
                                BindingResult result, Model model) {
        if (result.hasErrors()) {
            return "customer/profile";
        }

        try {
            Long customerId = userDetails.getUserId();
            Date birthDate = null;
            if (form.getBirthDate() != null && !form.getBirthDate().isEmpty()) {
                birthDate = new SimpleDateFormat("yyyy-MM-dd").parse(form.getBirthDate());
            }
            customerService.updateProfile(customerId,
                    form.getLastName(), form.getFirstName(),
                    form.getLastNameKana(), form.getFirstNameKana(),
                    form.getPhone(), birthDate, form.getLicenseLevel(), null);
            return "redirect:/customer/mypage";
        } catch (ParseException e) {
            result.addError(new FieldError("form", "birthDate", "生年月日の形式が不正です"));
            return "customer/profile";
        } catch (RuntimeException e) {
            model.addAttribute("errorMessage", "更新に失敗しました: " + e.getMessage());
            return "customer/profile";
        }
    }
}
