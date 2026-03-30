package com.divingapp.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.InstructorDao;
import com.divingapp.dto.InstructorDto;

@Service
@Transactional(readOnly = true)
public class InstructorService {

    private final InstructorDao instructorDao;

    public InstructorService(InstructorDao instructorDao) {
        this.instructorDao = instructorDao;
    }

    public List<InstructorDto> getInstructors() {
        return instructorDao.getInstructors();
    }

    public Map<String, Object> getInstructorDetail(Long instructorId) {
        return instructorDao.getInstructorDetail(instructorId);
    }
}
