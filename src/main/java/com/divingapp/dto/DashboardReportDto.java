package com.divingapp.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class DashboardReportDto {

    // =========================================================
    // セクション1: 売上推移
    // =========================================================
    public static class SalesTrendRow {
        private Integer month;
        private Integer reservationCount;
        private BigDecimal revenue;
        private Integer participants;
        private Integer cancelCount;
        private BigDecimal prevMonthRevenue;
        private BigDecimal momChangeRate;
        private BigDecimal yoyRevenue;
        private BigDecimal yoyChangeRate;
        private BigDecimal cumulativeRevenue;
        private BigDecimal sharePct;
        private String trend;

        public Integer getMonth() { return month; }
        public void setMonth(Integer month) { this.month = month; }
        public Integer getReservationCount() { return reservationCount; }
        public void setReservationCount(Integer reservationCount) { this.reservationCount = reservationCount; }
        public BigDecimal getRevenue() { return revenue; }
        public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
        public Integer getParticipants() { return participants; }
        public void setParticipants(Integer participants) { this.participants = participants; }
        public Integer getCancelCount() { return cancelCount; }
        public void setCancelCount(Integer cancelCount) { this.cancelCount = cancelCount; }
        public BigDecimal getPrevMonthRevenue() { return prevMonthRevenue; }
        public void setPrevMonthRevenue(BigDecimal prevMonthRevenue) { this.prevMonthRevenue = prevMonthRevenue; }
        public BigDecimal getMomChangeRate() { return momChangeRate; }
        public void setMomChangeRate(BigDecimal momChangeRate) { this.momChangeRate = momChangeRate; }
        public BigDecimal getYoyRevenue() { return yoyRevenue; }
        public void setYoyRevenue(BigDecimal yoyRevenue) { this.yoyRevenue = yoyRevenue; }
        public BigDecimal getYoyChangeRate() { return yoyChangeRate; }
        public void setYoyChangeRate(BigDecimal yoyChangeRate) { this.yoyChangeRate = yoyChangeRate; }
        public BigDecimal getCumulativeRevenue() { return cumulativeRevenue; }
        public void setCumulativeRevenue(BigDecimal cumulativeRevenue) { this.cumulativeRevenue = cumulativeRevenue; }
        public BigDecimal getSharePct() { return sharePct; }
        public void setSharePct(BigDecimal sharePct) { this.sharePct = sharePct; }
        public String getTrend() { return trend; }
        public void setTrend(String trend) { this.trend = trend; }
    }

    // =========================================================
    // セクション2: エリア×難易度クロス集計
    // =========================================================
    public static class AreaMatrixRow {
        private String area;
        private String difficulty;
        private Integer groupingLevel;
        private Integer reservationCount;
        private BigDecimal totalRevenue;
        private BigDecimal avgParticipants;
        private Integer beginnerCount;
        private Integer intermediateCount;
        private Integer advancedCount;
        private Integer expertCount;
        private BigDecimal beginnerRevPct;
        private BigDecimal advancedRevPct;

        public String getArea() { return area; }
        public void setArea(String area) { this.area = area; }
        public String getDifficulty() { return difficulty; }
        public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
        public Integer getGroupingLevel() { return groupingLevel; }
        public void setGroupingLevel(Integer groupingLevel) { this.groupingLevel = groupingLevel; }
        public Integer getReservationCount() { return reservationCount; }
        public void setReservationCount(Integer reservationCount) { this.reservationCount = reservationCount; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
        public BigDecimal getAvgParticipants() { return avgParticipants; }
        public void setAvgParticipants(BigDecimal avgParticipants) { this.avgParticipants = avgParticipants; }
        public Integer getBeginnerCount() { return beginnerCount; }
        public void setBeginnerCount(Integer beginnerCount) { this.beginnerCount = beginnerCount; }
        public Integer getIntermediateCount() { return intermediateCount; }
        public void setIntermediateCount(Integer intermediateCount) { this.intermediateCount = intermediateCount; }
        public Integer getAdvancedCount() { return advancedCount; }
        public void setAdvancedCount(Integer advancedCount) { this.advancedCount = advancedCount; }
        public Integer getExpertCount() { return expertCount; }
        public void setExpertCount(Integer expertCount) { this.expertCount = expertCount; }
        public BigDecimal getBeginnerRevPct() { return beginnerRevPct; }
        public void setBeginnerRevPct(BigDecimal beginnerRevPct) { this.beginnerRevPct = beginnerRevPct; }
        public BigDecimal getAdvancedRevPct() { return advancedRevPct; }
        public void setAdvancedRevPct(BigDecimal advancedRevPct) { this.advancedRevPct = advancedRevPct; }
    }

    // =========================================================
    // セクション3: インストラクターKPI
    // =========================================================
    public static class InstructorKpiRow {
        private String instructorName;
        private String certification;
        private Integer experienceYears;
        private Integer scheduleCount;
        private Integer reservationCount;
        private Integer uniqueCustomers;
        private BigDecimal totalRevenue;
        private Integer totalParticipants;
        private BigDecimal avgParticipants;
        private Integer revenueRank;
        private BigDecimal participantPercentile;
        private BigDecimal revenueSharePct;
        private String areaList;
        private BigDecimal repeatRate;
        private Integer recentActiveDays;

        public String getInstructorName() { return instructorName; }
        public void setInstructorName(String instructorName) { this.instructorName = instructorName; }
        public String getCertification() { return certification; }
        public void setCertification(String certification) { this.certification = certification; }
        public Integer getExperienceYears() { return experienceYears; }
        public void setExperienceYears(Integer experienceYears) { this.experienceYears = experienceYears; }
        public Integer getScheduleCount() { return scheduleCount; }
        public void setScheduleCount(Integer scheduleCount) { this.scheduleCount = scheduleCount; }
        public Integer getReservationCount() { return reservationCount; }
        public void setReservationCount(Integer reservationCount) { this.reservationCount = reservationCount; }
        public Integer getUniqueCustomers() { return uniqueCustomers; }
        public void setUniqueCustomers(Integer uniqueCustomers) { this.uniqueCustomers = uniqueCustomers; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
        public Integer getTotalParticipants() { return totalParticipants; }
        public void setTotalParticipants(Integer totalParticipants) { this.totalParticipants = totalParticipants; }
        public BigDecimal getAvgParticipants() { return avgParticipants; }
        public void setAvgParticipants(BigDecimal avgParticipants) { this.avgParticipants = avgParticipants; }
        public Integer getRevenueRank() { return revenueRank; }
        public void setRevenueRank(Integer revenueRank) { this.revenueRank = revenueRank; }
        public BigDecimal getParticipantPercentile() { return participantPercentile; }
        public void setParticipantPercentile(BigDecimal participantPercentile) { this.participantPercentile = participantPercentile; }
        public BigDecimal getRevenueSharePct() { return revenueSharePct; }
        public void setRevenueSharePct(BigDecimal revenueSharePct) { this.revenueSharePct = revenueSharePct; }
        public String getAreaList() { return areaList; }
        public void setAreaList(String areaList) { this.areaList = areaList; }
        public BigDecimal getRepeatRate() { return repeatRate; }
        public void setRepeatRate(BigDecimal repeatRate) { this.repeatRate = repeatRate; }
        public Integer getRecentActiveDays() { return recentActiveDays; }
        public void setRecentActiveDays(Integer recentActiveDays) { this.recentActiveDays = recentActiveDays; }
    }

    // =========================================================
    // セクション4: 顧客セグメント
    // =========================================================
    public static class CustomerSegmentRow {
        private String segment;
        private Integer segmentOrder;
        private Integer customerCount;
        private BigDecimal sharePct;
        private BigDecimal avgLtv;
        private Integer avgDiveCount;
        private BigDecimal avgFrequency;
        private BigDecimal avgCancelRate;
        private BigDecimal totalRevenue;
        private BigDecimal avgRecencyMonths;
        private Integer prevSegmentCount;
        private Integer countDiff;

        public String getSegment() { return segment; }
        public void setSegment(String segment) { this.segment = segment; }
        public Integer getSegmentOrder() { return segmentOrder; }
        public void setSegmentOrder(Integer segmentOrder) { this.segmentOrder = segmentOrder; }
        public Integer getCustomerCount() { return customerCount; }
        public void setCustomerCount(Integer customerCount) { this.customerCount = customerCount; }
        public BigDecimal getSharePct() { return sharePct; }
        public void setSharePct(BigDecimal sharePct) { this.sharePct = sharePct; }
        public BigDecimal getAvgLtv() { return avgLtv; }
        public void setAvgLtv(BigDecimal avgLtv) { this.avgLtv = avgLtv; }
        public Integer getAvgDiveCount() { return avgDiveCount; }
        public void setAvgDiveCount(Integer avgDiveCount) { this.avgDiveCount = avgDiveCount; }
        public BigDecimal getAvgFrequency() { return avgFrequency; }
        public void setAvgFrequency(BigDecimal avgFrequency) { this.avgFrequency = avgFrequency; }
        public BigDecimal getAvgCancelRate() { return avgCancelRate; }
        public void setAvgCancelRate(BigDecimal avgCancelRate) { this.avgCancelRate = avgCancelRate; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
        public BigDecimal getAvgRecencyMonths() { return avgRecencyMonths; }
        public void setAvgRecencyMonths(BigDecimal avgRecencyMonths) { this.avgRecencyMonths = avgRecencyMonths; }
        public Integer getPrevSegmentCount() { return prevSegmentCount; }
        public void setPrevSegmentCount(Integer prevSegmentCount) { this.prevSegmentCount = prevSegmentCount; }
        public Integer getCountDiff() { return countDiff; }
        public void setCountDiff(Integer countDiff) { this.countDiff = countDiff; }
    }

    // =========================================================
    // セクション5: キャンセル傾向
    // =========================================================
    public static class CancelAnalysisRow {
        private String analysisType;
        private Integer sortKey;
        private String dimension;
        private Integer cancelCount;
        private BigDecimal lossAmount;
        private BigDecimal refundAmount;
        private BigDecimal netRevenue;
        private BigDecimal momChange;
        private BigDecimal movingAvg;
        private BigDecimal movingStddev;
        private String alertFlag;

        public String getAnalysisType() { return analysisType; }
        public void setAnalysisType(String analysisType) { this.analysisType = analysisType; }
        public Integer getSortKey() { return sortKey; }
        public void setSortKey(Integer sortKey) { this.sortKey = sortKey; }
        public String getDimension() { return dimension; }
        public void setDimension(String dimension) { this.dimension = dimension; }
        public Integer getCancelCount() { return cancelCount; }
        public void setCancelCount(Integer cancelCount) { this.cancelCount = cancelCount; }
        public BigDecimal getLossAmount() { return lossAmount; }
        public void setLossAmount(BigDecimal lossAmount) { this.lossAmount = lossAmount; }
        public BigDecimal getRefundAmount() { return refundAmount; }
        public void setRefundAmount(BigDecimal refundAmount) { this.refundAmount = refundAmount; }
        public BigDecimal getNetRevenue() { return netRevenue; }
        public void setNetRevenue(BigDecimal netRevenue) { this.netRevenue = netRevenue; }
        public BigDecimal getMomChange() { return momChange; }
        public void setMomChange(BigDecimal momChange) { this.momChange = momChange; }
        public BigDecimal getMovingAvg() { return movingAvg; }
        public void setMovingAvg(BigDecimal movingAvg) { this.movingAvg = movingAvg; }
        public BigDecimal getMovingStddev() { return movingStddev; }
        public void setMovingStddev(BigDecimal movingStddev) { this.movingStddev = movingStddev; }
        public String getAlertFlag() { return alertFlag; }
        public void setAlertFlag(String alertFlag) { this.alertFlag = alertFlag; }
    }

    // =========================================================
    // セクション6: 異常検知アラート
    // =========================================================
    public static class AnomalyAlertRow {
        private Long alertId;
        private String alertType;
        private String severity;
        private String metricName;
        private BigDecimal currentValue;
        private BigDecimal thresholdValue;
        private BigDecimal deviation;
        private String message;
        private Timestamp detectedAt;
        private String status;
        private Integer alertRank;
        private Integer totalAlerts;
        private Integer severityCount;
        private BigDecimal severityDistPct;

        public Long getAlertId() { return alertId; }
        public void setAlertId(Long alertId) { this.alertId = alertId; }
        public String getAlertType() { return alertType; }
        public void setAlertType(String alertType) { this.alertType = alertType; }
        public String getSeverity() { return severity; }
        public void setSeverity(String severity) { this.severity = severity; }
        public String getMetricName() { return metricName; }
        public void setMetricName(String metricName) { this.metricName = metricName; }
        public BigDecimal getCurrentValue() { return currentValue; }
        public void setCurrentValue(BigDecimal currentValue) { this.currentValue = currentValue; }
        public BigDecimal getThresholdValue() { return thresholdValue; }
        public void setThresholdValue(BigDecimal thresholdValue) { this.thresholdValue = thresholdValue; }
        public BigDecimal getDeviation() { return deviation; }
        public void setDeviation(BigDecimal deviation) { this.deviation = deviation; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public Timestamp getDetectedAt() { return detectedAt; }
        public void setDetectedAt(Timestamp detectedAt) { this.detectedAt = detectedAt; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public Integer getAlertRank() { return alertRank; }
        public void setAlertRank(Integer alertRank) { this.alertRank = alertRank; }
        public Integer getTotalAlerts() { return totalAlerts; }
        public void setTotalAlerts(Integer totalAlerts) { this.totalAlerts = totalAlerts; }
        public Integer getSeverityCount() { return severityCount; }
        public void setSeverityCount(Integer severityCount) { this.severityCount = severityCount; }
        public BigDecimal getSeverityDistPct() { return severityDistPct; }
        public void setSeverityDistPct(BigDecimal severityDistPct) { this.severityDistPct = severityDistPct; }
    }
}
