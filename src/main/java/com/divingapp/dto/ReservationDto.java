package com.divingapp.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

public class ReservationDto {
    private Long reservationId;
    private Long customerId;
    private Long scheduleId;
    private Integer numParticipants;
    private BigDecimal totalPrice;
    private String status;
    private String cancelReason;
    private BigDecimal refundAmount;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // 結合情報
    private String tourName;
    private String area;
    private Date tourDate;
    private String startTime;
    private String customerName;

    // オプション一覧
    private List<ReservationOptionDto> options;

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getScheduleId() { return scheduleId; }
    public void setScheduleId(Long scheduleId) { this.scheduleId = scheduleId; }
    public Integer getNumParticipants() { return numParticipants; }
    public void setNumParticipants(Integer numParticipants) { this.numParticipants = numParticipants; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCancelReason() { return cancelReason; }
    public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }
    public BigDecimal getRefundAmount() { return refundAmount; }
    public void setRefundAmount(BigDecimal refundAmount) { this.refundAmount = refundAmount; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public String getTourName() { return tourName; }
    public void setTourName(String tourName) { this.tourName = tourName; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public Date getTourDate() { return tourDate; }
    public void setTourDate(Date tourDate) { this.tourDate = tourDate; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public List<ReservationOptionDto> getOptions() { return options; }
    public void setOptions(List<ReservationOptionDto> options) { this.options = options; }
}
