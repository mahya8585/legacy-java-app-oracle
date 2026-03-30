package com.divingapp.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

public class TourDto {
    private Long tourId;
    private String tourName;
    private String description;
    private String area;
    private String difficulty;
    private Integer maxParticipants;
    private BigDecimal basePrice;
    private Integer durationDays;
    private Integer minDiveCount;
    private String featuredFlag;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // 検索結果用の追加フィールド
    private Date nearestDate;
    private Integer remainingSeats;

    // 詳細表示用
    private List<DiveSiteDto> diveSites;
    private List<InstructorDto> instructors;
    private List<TourScheduleDto> schedules;

    public Long getTourId() { return tourId; }
    public void setTourId(Long tourId) { this.tourId = tourId; }
    public String getTourName() { return tourName; }
    public void setTourName(String tourName) { this.tourName = tourName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    public Integer getMaxParticipants() { return maxParticipants; }
    public void setMaxParticipants(Integer maxParticipants) { this.maxParticipants = maxParticipants; }
    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
    public Integer getDurationDays() { return durationDays; }
    public void setDurationDays(Integer durationDays) { this.durationDays = durationDays; }
    public Integer getMinDiveCount() { return minDiveCount; }
    public void setMinDiveCount(Integer minDiveCount) { this.minDiveCount = minDiveCount; }
    public String getFeaturedFlag() { return featuredFlag; }
    public void setFeaturedFlag(String featuredFlag) { this.featuredFlag = featuredFlag; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public Date getNearestDate() { return nearestDate; }
    public void setNearestDate(Date nearestDate) { this.nearestDate = nearestDate; }
    public Integer getRemainingSeats() { return remainingSeats; }
    public void setRemainingSeats(Integer remainingSeats) { this.remainingSeats = remainingSeats; }
    public List<DiveSiteDto> getDiveSites() { return diveSites; }
    public void setDiveSites(List<DiveSiteDto> diveSites) { this.diveSites = diveSites; }
    public List<InstructorDto> getInstructors() { return instructors; }
    public void setInstructors(List<InstructorDto> instructors) { this.instructors = instructors; }
    public List<TourScheduleDto> getSchedules() { return schedules; }
    public void setSchedules(List<TourScheduleDto> schedules) { this.schedules = schedules; }
}
