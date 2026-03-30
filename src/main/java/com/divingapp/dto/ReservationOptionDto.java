package com.divingapp.dto;

import java.math.BigDecimal;

public class ReservationOptionDto {
    private Long resOptionId;
    private Long reservationId;
    private Long optionId;
    private String optionName;
    private String optionCategory;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal subtotal;

    public Long getResOptionId() { return resOptionId; }
    public void setResOptionId(Long resOptionId) { this.resOptionId = resOptionId; }
    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }
    public Long getOptionId() { return optionId; }
    public void setOptionId(Long optionId) { this.optionId = optionId; }
    public String getOptionName() { return optionName; }
    public void setOptionName(String optionName) { this.optionName = optionName; }
    public String getOptionCategory() { return optionCategory; }
    public void setOptionCategory(String optionCategory) { this.optionCategory = optionCategory; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
}
