package com.divingapp.controller;

import com.divingapp.service.NewsService;
import com.divingapp.service.TourService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final TourService tourService;
    private final NewsService newsService;

    public HomeController(TourService tourService, NewsService newsService) {
        this.tourService = tourService;
        this.newsService = newsService;
    }

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("featuredTours", tourService.getFeaturedTours(6));
        model.addAttribute("newsItems", newsService.getLatestNews(5, null));
        return "home";
    }
}
