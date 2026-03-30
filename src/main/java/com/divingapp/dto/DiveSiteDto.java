package com.divingapp.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class DiveSiteDto {
    private Long siteId;
    private String siteName;
    private String area;
    private String description;
    private BigDecimal maxDepth;
    private BigDecimal waterTemperatureMin;
    private BigDecimal waterTemperatureMax;
    private String difficulty;
    private String marineLife;
    private String accessInfo;
    private String status;
    private Timestamp createdAt;
    private Integer diveOrder;

    public Long getSiteId() { return siteId; }
    public void setSiteId(Long siteId) { this.siteId = siteId; }
    public String getSiteName() { return siteName; }
    public void setSiteName(String siteName) { this.siteName = siteName; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getMaxDepth() { return maxDepth; }
    public void setMaxDepth(BigDecimal maxDepth) { this.maxDepth = maxDepth; }
    public BigDecimal getWaterTemperatureMin() { return waterTemperatureMin; }
    public void setWaterTemperatureMin(BigDecimal waterTemperatureMin) { this.waterTemperatureMin = waterTemperatureMin; }
    public BigDecimal getWaterTemperatureMax() { return waterTemperatureMax; }
    public void setWaterTemperatureMax(BigDecimal waterTemperatureMax) { this.waterTemperatureMax = waterTemperatureMax; }
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    public String getMarineLife() { return marineLife; }
    public void setMarineLife(String marineLife) { this.marineLife = marineLife; }
    public String getAccessInfo() { return accessInfo; }
    public void setAccessInfo(String accessInfo) { this.accessInfo = accessInfo; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Integer getDiveOrder() { return diveOrder; }
    public void setDiveOrder(Integer diveOrder) { this.diveOrder = diveOrder; }
}
