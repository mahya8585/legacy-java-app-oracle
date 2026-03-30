package com.divingapp.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.TourDao;
import com.divingapp.dto.TourDto;
import com.divingapp.dto.TourSearchCondition;

@Service
@Transactional(readOnly = true)
public class TourService {

    private final TourDao tourDao;

    public TourService(TourDao tourDao) {
        this.tourDao = tourDao;
    }

    public Map<String, Object> searchTours(TourSearchCondition condition) {
        return tourDao.searchTours(condition);
    }

    public Map<String, Object> getTourDetail(Long tourId) {
        return tourDao.getTourDetail(tourId);
    }

    public List<TourDto> getFeaturedTours(int limit) {
        return tourDao.getFeaturedTours(limit);
    }

    @Transactional
    public Map<String, Object> saveTour(Long tourId, String tourName, String description,
            String area, String difficulty, int maxParticipants, int basePrice,
            int durationDays, int minDiveCount, String featuredFlag) {
        return tourDao.saveTour(tourId, tourName, description, area, difficulty,
                maxParticipants, basePrice, durationDays, minDiveCount, featuredFlag);
    }

    @Transactional
    public Map<String, Object> deleteTour(Long tourId) {
        return tourDao.deleteTour(tourId);
    }
}
