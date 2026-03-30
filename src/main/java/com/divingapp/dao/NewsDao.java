package com.divingapp.dao;

import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.divingapp.dto.NewsDto;

import oracle.jdbc.OracleTypes;

@Repository
public class NewsDao {

    private final DataSource dataSource;

    public NewsDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<NewsDto> NEWS_ROW_MAPPER = (rs, rowNum) -> {
        NewsDto dto = new NewsDto();
        dto.setNewsId(rs.getLong("NEWS_ID"));
        dto.setTitle(rs.getString("TITLE"));
        dto.setContent(rs.getString("CONTENT"));
        dto.setCategory(rs.getString("CATEGORY"));
        dto.setPublishDate(rs.getDate("PUBLISH_DATE"));
        dto.setStatus(rs.getString("STATUS"));
        dto.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public List<NewsDto> getLatestNews(int limit, String category) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_NEWS")
            .withProcedureName("GET_LATEST_NEWS")
            .declareParameters(
                new SqlParameter("p_limit", java.sql.Types.NUMERIC),
                new SqlParameter("p_category", java.sql.Types.VARCHAR),
                new SqlOutParameter("o_news", OracleTypes.CURSOR, NEWS_ROW_MAPPER)
            );

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_limit", limit)
            .addValue("p_category", category);

        Map<String, Object> result = call.execute(params);
        return (List<NewsDto>) result.get("o_news");
    }

    public Map<String, Object> saveNews(Long newsId, String title, String content,
            String category, Date publishDate, String status) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withCatalogName("PKG_NEWS")
            .withProcedureName("SAVE_NEWS");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_news_id", newsId)
            .addValue("p_title", title)
            .addValue("p_content", content)
            .addValue("p_category", category)
            .addValue("p_publish_date", publishDate)
            .addValue("p_status", status);

        return call.execute(params);
    }
}
