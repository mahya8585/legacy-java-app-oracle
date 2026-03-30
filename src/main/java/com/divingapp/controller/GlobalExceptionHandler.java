package com.divingapp.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(DataAccessException.class)
    public String handleDataAccessException(DataAccessException ex, Model model) {
        logger.error("Database error occurred", ex);

        String message = ex.getMostSpecificCause().getMessage();
        if (message != null && message.contains("ORA-20")) {
            // PL/SQL business error
            String userMessage = extractOracleMessage(message);
            model.addAttribute("errorMessage", userMessage);
        } else {
            model.addAttribute("errorMessage", "データベースエラーが発生しました。しばらく経ってから再度お試しください。");
        }
        return "error/general";
    }

    @ExceptionHandler(Exception.class)
    public String handleException(Exception ex, Model model) {
        logger.error("Unexpected error occurred", ex);
        model.addAttribute("errorMessage", "予期しないエラーが発生しました。しばらく経ってから再度お試しください。");
        return "error/general";
    }

    private String extractOracleMessage(String message) {
        if (message == null) return "エラーが発生しました。";
        int idx = message.indexOf("ORA-20");
        if (idx >= 0) {
            String sub = message.substring(idx);
            int end = sub.indexOf('\n');
            if (end > 0) {
                return sub.substring(sub.indexOf(':') + 2, end).trim();
            }
            int colonIdx = sub.indexOf(':');
            if (colonIdx > 0) {
                return sub.substring(colonIdx + 2).trim();
            }
        }
        return "処理中にエラーが発生しました。";
    }
}
