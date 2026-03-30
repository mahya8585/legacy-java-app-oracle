package com.divingapp.config;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.Map;

import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import com.divingapp.dao.CustomerDao;

@Component
public class CustomAuthenticationProvider implements AuthenticationProvider {

    private final CustomerDao customerDao;

    public CustomAuthenticationProvider(CustomerDao customerDao) {
        this.customerDao = customerDao;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String email = authentication.getName();
        String password = authentication.getCredentials().toString();

        try {
            Map<String, Object> result = customerDao.authenticate(email, password);
            BigDecimal customerId = (BigDecimal) result.get("O_CUSTOMER_ID");
            String status = (String) result.get("O_STATUS");

            if (customerId == null || customerId.longValue() <= 0) {
                throw new BadCredentialsException("メールアドレスまたはパスワードが正しくありません。");
            }

            if (!"ACTIVE".equals(status)) {
                throw new BadCredentialsException("このアカウントは無効です。");
            }

            CustomUserDetails userDetails = new CustomUserDetails(
                customerId.longValue(), email, password, "CUSTOMER"
            );

            return new UsernamePasswordAuthenticationToken(
                userDetails, password,
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_CUSTOMER"))
            );
        } catch (AuthenticationException e) {
            throw e;
        } catch (Exception e) {
            throw new BadCredentialsException("認証に失敗しました。", e);
        }
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication);
    }
}
