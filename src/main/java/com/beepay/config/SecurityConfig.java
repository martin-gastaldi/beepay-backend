package com.beepay.config;

import com.beepay.security.FirebaseAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    private final FirebaseAuthenticationFilter firebaseAuthenticationFilter;

    public SecurityConfig(FirebaseAuthenticationFilter firebaseAuthenticationFilter) {
        this.firebaseAuthenticationFilter = firebaseAuthenticationFilter;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Desactiva CSRF para APIs sin estado
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // No usa sesiones
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll() // Acceso libre a rutas públicas
                .requestMatchers("/api/secure/**").authenticated() // Permitir acceso solo a usuarios autenticados
                .anyRequest().denyAll() // Bloquear cualquier otra ruta no especificada
            )

            .addFilterBefore(firebaseAuthenticationFilter, UsernamePasswordAuthenticationFilter.class); // Agrega el filtro de Firebase

        return http.build();
    }

    // Evita que Spring Security use autenticación por defecto (desactiva el usuario/password generados)
    @Bean
    public UserDetailsService userDetailsService() {
        return username -> {
            throw new UsernameNotFoundException("No se usa autenticación por defecto");
        };
    }
}


/* 📌 ¿Qué hace esta configuración?
✅ Permite acceso libre a /api/publico/** (para endpoints sin autenticación).
✅ Protege todos los demás endpoints, obligando a que envíen un idToken válido.

 */
