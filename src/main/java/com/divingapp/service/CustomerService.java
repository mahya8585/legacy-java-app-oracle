package com.divingapp.service;

import java.util.Date;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.CustomerDao;
import com.divingapp.dto.CustomerDto;

@Service
@Transactional(readOnly = true)
public class CustomerService {

    private final CustomerDao customerDao;

    public CustomerService(CustomerDao customerDao) {
        this.customerDao = customerDao;
    }

    @Transactional
    public Map<String, Object> registerCustomer(String email, String password,
            String lastName, String firstName, String lastNameKana, String firstNameKana,
            String phone, Date birthDate, String licenseLevel) {
        return customerDao.registerCustomer(email, password, lastName, firstName,
                lastNameKana, firstNameKana, phone, birthDate, licenseLevel);
    }

    @Transactional
    public Map<String, Object> updateProfile(Long customerId, String lastName, String firstName,
            String lastNameKana, String firstNameKana, String phone, Date birthDate,
            String licenseLevel, String emergencyContact) {
        return customerDao.updateProfile(customerId, lastName, firstName,
                lastNameKana, firstNameKana, phone, birthDate, licenseLevel, emergencyContact);
    }

    public CustomerDto getCustomerInfo(Long customerId) {
        return customerDao.getCustomerInfo(customerId);
    }

    public Map<String, Object> getAllCustomers(String keyword, String status, int page, int pageSize) {
        return customerDao.getAllCustomers(keyword, status, page, pageSize);
    }
}
