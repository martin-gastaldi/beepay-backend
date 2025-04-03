package com.beepay;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"com.beepay", "com.beepay.config"})
public class BeePayApplication {
    public static void main(String[] args) {
        SpringApplication.run(BeePayApplication.class, args);
    }
}

