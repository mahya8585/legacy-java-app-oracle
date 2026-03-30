package com.divingapp.dto;

import java.util.Date;

public class TourSearchCondition {
    private String area;
    private String difficulty;
    private Date dateFrom;
    private Date dateTo;
    private Integer priceMin;
    private Integer priceMax;
    private String keyword;
    private int page = 1;
    private int pageSize = 10;

    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    public Date getDateFrom() { return dateFrom; }
    public void setDateFrom(Date dateFrom) { this.dateFrom = dateFrom; }
    public Date getDateTo() { return dateTo; }
    public void setDateTo(Date dateTo) { this.dateTo = dateTo; }
    public Integer getPriceMin() { return priceMin; }
    public void setPriceMin(Integer priceMin) { this.priceMin = priceMin; }
    public Integer getPriceMax() { return priceMax; }
    public void setPriceMax(Integer priceMax) { this.priceMax = priceMax; }
    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }
    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }
    public int getPageSize() { return pageSize; }
    public void setPageSize(int pageSize) { this.pageSize = pageSize; }
}
