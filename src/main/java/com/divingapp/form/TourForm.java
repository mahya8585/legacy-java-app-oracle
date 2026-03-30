package com.divingapp.form;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

public class TourForm {
    private Long tourId;

    @NotBlank
    private String tourName;

    private String description;

    @NotBlank
    private String area;

    @NotBlank
    private String difficulty;

    @NotNull
    @Min(1)
    private Integer maxParticipants;

    @NotNull
    @Min(0)
    private Integer basePrice;

    @NotNull
    @Min(1)
    private Integer durationDays;

    private Integer minDiveCount;
    private String featuredFlag;

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
    public Integer getBasePrice() { return basePrice; }
    public void setBasePrice(Integer basePrice) { this.basePrice = basePrice; }
    public Integer getDurationDays() { return durationDays; }
    public void setDurationDays(Integer durationDays) { this.durationDays = durationDays; }
    public Integer getMinDiveCount() { return minDiveCount; }
    public void setMinDiveCount(Integer minDiveCount) { this.minDiveCount = minDiveCount; }
    public String getFeaturedFlag() { return featuredFlag; }
    public void setFeaturedFlag(String featuredFlag) { this.featuredFlag = featuredFlag; }
}
