package com.quickhelp.backend.controller;

import com.quickhelp.backend.model.User;
import com.quickhelp.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> creds) {
        String username = creds.get("username");
        String password = creds.get("password");

        // Hardcoded admin for now or check DB with role 'ADMIN'
        if ("chintu".equals(username) && "chintu".equals(password)) {
             User adminUser = new User();
             adminUser.setId(0L);
             adminUser.setUsername("admin");
             adminUser.setRole("ADMIN");
             adminUser.setFullName("System Admin");
             return ResponseEntity.ok(adminUser);
        }
        
        // Also check DB for users with ADMIN role
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getPassword().equals(password) && "ADMIN".equalsIgnoreCase(user.getRole())) {
                return ResponseEntity.ok(user);
            }
        }
        
        return ResponseEntity.status(401).body("Invalid Admin Credentials");
    }
}
