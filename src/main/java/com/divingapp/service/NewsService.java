package com.divingapp.service;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.divingapp.dao.NewsDao;
import com.divingapp.dto.NewsDto;

@Service
@Transactional(readOnly = true)
public class NewsService {

    private final NewsDao newsDao;

    public NewsService(NewsDao newsDao) {
        this.newsDao = newsDao;
    }

    public List<NewsDto> getLatestNews(int limit, String category) {
        return newsDao.getLatestNews(limit, category);
    }

    @Transactional
    public Map<String, Object> saveNews(Long newsId, String title, String content,
            String category, Date publishDate, String status) {
        return newsDao.saveNews(newsId, title, content, category, publishDate, status);
    }
}
