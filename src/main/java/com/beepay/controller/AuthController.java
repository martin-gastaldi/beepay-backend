package com.beepay.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class AuthController {

    @GetMapping("/public/hello")
    public String publicHello() {
        return "¡Hola, mundo! Esta ruta es pública.";
    }

    @GetMapping("/secure/hello")
    public String secureHello() {
        return "¡Hola, usuario autenticado!";
    }
}
