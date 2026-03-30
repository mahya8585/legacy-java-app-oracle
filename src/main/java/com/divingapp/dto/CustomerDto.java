package com.divingapp.dto;

import java.sql.Timestamp;
import java.util.Date;

public class CustomerDto {
    private Long customerId;
    private String email;
    private String lastName;
    private String firstName;
    private String lastNameKana;
    private String firstNameKana;
    private String phone;
    private Date birthDate;
    private String licenseLevel;
    private Integer diveCount;
    private String emergencyContact;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public String getFullName() { return lastName + " " + firstName; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastNameKana() { return lastNameKana; }
    public void setLastNameKana(String lastNameKana) { this.lastNameKana = lastNameKana; }
    public String getFirstNameKana() { return firstNameKana; }
    public void setFirstNameKana(String firstNameKana) { this.firstNameKana = firstNameKana; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public Date getBirthDate() { return birthDate; }
    public void setBirthDate(Date birthDate) { this.birthDate = birthDate; }
    public String getLicenseLevel() { return licenseLevel; }
    public void setLicenseLevel(String licenseLevel) { this.licenseLevel = licenseLevel; }
    public Integer getDiveCount() { return diveCount; }
    public void setDiveCount(Integer diveCount) { this.diveCount = diveCount; }
    public String getEmergencyContact() { return emergencyContact; }
    public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
