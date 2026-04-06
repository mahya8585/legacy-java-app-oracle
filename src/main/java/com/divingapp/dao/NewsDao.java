package com.divingapp.dao;

import java.sql.Types;
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

@Repository
public class NewsDao {

    private final DataSource dataSource;

    public NewsDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private static final RowMapper<NewsDto> NEWS_ROW_MAPPER = (rs, rowNum) -> {
        NewsDto dto = new NewsDto();
        dto.setNewsId(rs.getLong("news_id"));
        dto.setTitle(rs.getString("title"));
        dto.setContent(rs.getString("content"));
        dto.setCategory(rs.getString("category"));
        dto.setPublishDate(rs.getDate("publish_date"));
        dto.setStatus(rs.getString("status"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        return dto;
    };

    @SuppressWarnings("unchecked")
    public List<NewsDto> getLatestNews(int limit, String category) {
        SimpleJdbcCall call = new SimpleJdbcCall(dataSource)
            .withSchemaName("divingapp")
            .withProcedureName("pkg_news_get_latest_news")
            .declareParameters(
                new SqlParameter("p_limit", Types.NUMERIC),
                new SqlParameter("p_category", Types.VARCHAR),
                new SqlOutParameter("o_news", Types.REF_CURSOR, NEWS_ROW_MAPPER)
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
            .withSchemaName("divingapp")
            .withProcedureName("pkg_news_save_news");

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
