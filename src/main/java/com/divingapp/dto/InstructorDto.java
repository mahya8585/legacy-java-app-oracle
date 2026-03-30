package com.divingapp.dto;

import java.sql.Timestamp;
import java.util.List;

public class InstructorDto {
    private Long instructorId;
    private String lastName;
    private String firstName;
    private String certification;
    private Integer experienceYears;
    private String specialty;
    private String profile;
    private String photoUrl;
    private String status;
    private Timestamp createdAt;
    private String role;
    private List<TourDto> tours;

    public String getFullName() { return lastName + " " + firstName; }

    public Long getInstructorId() { return instructorId; }
    public void setInstructorId(Long instructorId) { this.instructorId = instructorId; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }
    public Integer getExperienceYears() { return experienceYears; }
    public void setExperienceYears(Integer experienceYears) { this.experienceYears = experienceYears; }
    public String getSpecialty() { return specialty; }
    public void setSpecialty(String specialty) { this.specialty = specialty; }
    public String getProfile() { return profile; }
    public void setProfile(String profile) { this.profile = profile; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public List<TourDto> getTours() { return tours; }
    public void setTours(List<TourDto> tours) { this.tours = tours; }
}
