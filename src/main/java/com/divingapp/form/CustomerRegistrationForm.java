package com.divingapp.form;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

public class CustomerRegistrationForm {
    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Size(min = 6, max = 100)
    private String password;

    @NotBlank
    private String passwordConfirm;

    @NotBlank
    private String lastName;

    @NotBlank
    private String firstName;

    private String lastNameKana;
    private String firstNameKana;
    private String phone;
    private String birthDate;
    private String licenseLevel;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPasswordConfirm() { return passwordConfirm; }
    public void setPasswordConfirm(String passwordConfirm) { this.passwordConfirm = passwordConfirm; }
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
    public String getBirthDate() { return birthDate; }
    public void setBirthDate(String birthDate) { this.birthDate = birthDate; }
    public String getLicenseLevel() { return licenseLevel; }
    public void setLicenseLevel(String licenseLevel) { this.licenseLevel = licenseLevel; }
}
