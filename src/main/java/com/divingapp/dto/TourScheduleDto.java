package com.divingapp.dto;

import java.util.Date;

public class TourScheduleDto {
    private Long scheduleId;
    private Long tourId;
    private Date tourDate;
    private String startTime;
    private Integer remainingSeats;
    private String status;

    public Long getScheduleId() { return scheduleId; }
    public void setScheduleId(Long scheduleId) { this.scheduleId = scheduleId; }
    public Long getTourId() { return tourId; }
    public void setTourId(Long tourId) { this.tourId = tourId; }
    public Date getTourDate() { return tourDate; }
    public void setTourDate(Date tourDate) { this.tourDate = tourDate; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public Integer getRemainingSeats() { return remainingSeats; }
    public void setRemainingSeats(Integer remainingSeats) { this.remainingSeats = remainingSeats; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
