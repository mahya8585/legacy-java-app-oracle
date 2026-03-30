package com.divingapp.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

    private final CustomAuthenticationProvider authenticationProvider;

    public WebSecurityConfig(CustomAuthenticationProvider authenticationProvider) {
        this.authenticationProvider = authenticationProvider;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.authenticationProvider(authenticationProvider);
        http
            .authorizeHttpRequests(auth -> auth
                .antMatchers("/", "/tours/**", "/divesites/**", "/instructors/**",
                             "/news/**", "/css/**", "/js/**", "/images/**").permitAll()
                .antMatchers("/customer/register", "/customer/login").permitAll()
                .antMatchers("/admin/**").hasRole("ADMIN")
                .antMatchers("/customer/**", "/reservations/**", "/divinglogs/**").hasRole("CUSTOMER")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/customer/login")
                .loginProcessingUrl("/customer/login")
                .defaultSuccessUrl("/customer/mypage", true)
                .failureUrl("/customer/login?error=true")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutUrl("/customer/logout")
                .logoutSuccessUrl("/")
                .permitAll()
            )
            .csrf().and()
            .headers().frameOptions().sameOrigin();

        return http.build();
    }
}
