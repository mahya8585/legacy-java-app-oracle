package com.divingapp.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

public class DivingLogDto {
    private Long logId;
    private Long customerId;
    private Long siteId;
    private Long reservationId;
    private Date diveDate;
    private BigDecimal maxDepth;
    private Integer diveTime;
    private BigDecimal waterTemp;
    private BigDecimal visibility;
    private String weather;
    private String buddy;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String siteName;

    public Long getLogId() { return logId; }
    public void setLogId(Long logId) { this.logId = logId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getSiteId() { return siteId; }
    public void setSiteId(Long siteId) { this.siteId = siteId; }
    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }
    public Date getDiveDate() { return diveDate; }
    public void setDiveDate(Date diveDate) { this.diveDate = diveDate; }
    public BigDecimal getMaxDepth() { return maxDepth; }
    public void setMaxDepth(BigDecimal maxDepth) { this.maxDepth = maxDepth; }
    public Integer getDiveTime() { return diveTime; }
    public void setDiveTime(Integer diveTime) { this.diveTime = diveTime; }
    public BigDecimal getWaterTemp() { return waterTemp; }
    public void setWaterTemp(BigDecimal waterTemp) { this.waterTemp = waterTemp; }
    public BigDecimal getVisibility() { return visibility; }
    public void setVisibility(BigDecimal visibility) { this.visibility = visibility; }
    public String getWeather() { return weather; }
    public void setWeather(String weather) { this.weather = weather; }
    public String getBuddy() { return buddy; }
    public void setBuddy(String buddy) { this.buddy = buddy; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public String getSiteName() { return siteName; }
    public void setSiteName(String siteName) { this.siteName = siteName; }
}
