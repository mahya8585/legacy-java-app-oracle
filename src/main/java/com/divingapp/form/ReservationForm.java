package com.divingapp.form;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

public class ReservationForm {
    @NotNull
    private Long scheduleId;

    @NotNull
    @Min(1)
    private Integer numParticipants;

    private String optionIds;
    private String optionQuantities;
    private String notes;

    public Long getScheduleId() { return scheduleId; }
    public void setScheduleId(Long scheduleId) { this.scheduleId = scheduleId; }
    public Integer getNumParticipants() { return numParticipants; }
    public void setNumParticipants(Integer numParticipants) { this.numParticipants = numParticipants; }
    public String getOptionIds() { return optionIds; }
    public void setOptionIds(String optionIds) { this.optionIds = optionIds; }
    public String getOptionQuantities() { return optionQuantities; }
    public void setOptionQuantities(String optionQuantities) { this.optionQuantities = optionQuantities; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
