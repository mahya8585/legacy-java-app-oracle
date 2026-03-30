package com.divingapp.dto;

import java.math.BigDecimal;

public class OptionMasterDto {
    private Long optionId;
    private String optionName;
    private String optionCategory;
    private BigDecimal unitPrice;
    private String description;
    private String status;

    public Long getOptionId() { return optionId; }
    public void setOptionId(Long optionId) { this.optionId = optionId; }
    public String getOptionName() { return optionName; }
    public void setOptionName(String optionName) { this.optionName = optionName; }
    public String getOptionCategory() { return optionCategory; }
    public void setOptionCategory(String optionCategory) { this.optionCategory = optionCategory; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
