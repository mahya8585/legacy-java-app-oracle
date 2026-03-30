package com.divingapp.dto;

import java.math.BigDecimal;

public class ReportDto {
    private Integer year;
    private Integer month;
    private Integer totalReservations;
    private BigDecimal totalRevenue;
    private Integer cancelledCount;

    // ツアー人気ランキング
    private String tourName;
    private String area;
    private Integer reservationCount;
    private BigDecimal avgParticipants;

    // 稼働率
    private Integer totalCapacity;
    private Integer totalBooked;
    private BigDecimal occupancyRate;

    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }
    public Integer getMonth() { return month; }
    public void setMonth(Integer month) { this.month = month; }
    public Integer getTotalReservations() { return totalReservations; }
    public void setTotalReservations(Integer totalReservations) { this.totalReservations = totalReservations; }
    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    public Integer getCancelledCount() { return cancelledCount; }
    public void setCancelledCount(Integer cancelledCount) { this.cancelledCount = cancelledCount; }
    public String getTourName() { return tourName; }
    public void setTourName(String tourName) { this.tourName = tourName; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public Integer getReservationCount() { return reservationCount; }
    public void setReservationCount(Integer reservationCount) { this.reservationCount = reservationCount; }
    public BigDecimal getAvgParticipants() { return avgParticipants; }
    public void setAvgParticipants(BigDecimal avgParticipants) { this.avgParticipants = avgParticipants; }
    public Integer getTotalCapacity() { return totalCapacity; }
    public void setTotalCapacity(Integer totalCapacity) { this.totalCapacity = totalCapacity; }
    public Integer getTotalBooked() { return totalBooked; }
    public void setTotalBooked(Integer totalBooked) { this.totalBooked = totalBooked; }
    public BigDecimal getOccupancyRate() { return occupancyRate; }
    public void setOccupancyRate(BigDecimal occupancyRate) { this.occupancyRate = occupancyRate; }
}
