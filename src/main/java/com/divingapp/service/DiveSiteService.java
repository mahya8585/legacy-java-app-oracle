package com.divingapp.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.DiveSiteDao;
import com.divingapp.dto.DiveSiteDto;

@Service
@Transactional(readOnly = true)
public class DiveSiteService {

    private final DiveSiteDao diveSiteDao;

    public DiveSiteService(DiveSiteDao diveSiteDao) {
        this.diveSiteDao = diveSiteDao;
    }

    public List<DiveSiteDto> getDiveSites(String area, String difficulty) {
        return diveSiteDao.getDiveSites(area, difficulty);
    }

    public Map<String, Object> getDiveSiteDetail(Long siteId) {
        return diveSiteDao.getDiveSiteDetail(siteId);
    }
}
