package com.beepay.security;

import com.beepay.service.FirebaseAuthService;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.GenericFilterBean;

import java.io.IOException;
import java.util.List;

@Component
public class FirebaseAuthenticationFilter extends GenericFilterBean {

    private final FirebaseAuthService firebaseAuthService;

    public FirebaseAuthenticationFilter(FirebaseAuthService firebaseAuthService) {
        this.firebaseAuthService = firebaseAuthService;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        throws IOException, ServletException {
        
      HttpServletRequest httpRequest = (HttpServletRequest) request;
      String token = httpRequest.getHeader("Authorization");

      if (token != null && token.startsWith("Bearer ")) {
        try {
            FirebaseToken decodedToken = firebaseAuthService.verifyIdToken(token.substring(7));
            System.out.println("Usuario autenticado: " + decodedToken.getUid()); // Imprime el UID del usuario

            // Asigna el rol "ROLE_USER" al usuario autenticado
            PreAuthenticatedAuthenticationToken authentication =
                new PreAuthenticatedAuthenticationToken(decodedToken, null, List.of(new SimpleGrantedAuthority("ROLE_USER")));

            SecurityContextHolder.getContext().setAuthentication(authentication);
        } catch (FirebaseAuthException e) {
            System.out.println("Error al verificar token: " + e.getMessage());
            SecurityContextHolder.clearContext();
        }
      } else {
        System.out.println("No se encontró token en la petición");
      }

      chain.doFilter(request, response);
    }
}



/*📌 ¿Qué hace este filtro?
✅ Toma el idToken del header de la solicitud.
✅ Lo verifica con Firebase para ver si es válido.
✅ Si es válido, deja pasar la solicitud.
✅ Si no es válido, devuelve un error 401 (No autorizado). */