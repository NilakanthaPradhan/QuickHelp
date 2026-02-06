package com.quickhelp.backend.controller;

import com.quickhelp.backend.model.User;
import com.quickhelp.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "phone", required = false) String phone,
            @RequestParam(value = "fullName", required = false) String fullName,
            @RequestParam(value = "address", required = false) String address,
            @RequestParam(value = "file", required = false) org.springframework.web.multipart.MultipartFile file) {
        
        if (userRepository.findByUsername(username).isPresent()) {
            return ResponseEntity.badRequest().body("Username already exists");
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setEmail(email);
        user.setPhone(phone);
        user.setFullName(fullName != null && !fullName.isEmpty() ? fullName : username);
        user.setAddress(address);
        user.setRole("USER");

        try {
            if (file != null && !file.isEmpty()) {
                user.setPhotoData(file.getBytes());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        User savedUser = userRepository.save(user);
        return ResponseEntity.ok(savedUser);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> creds) {
        String username = creds.get("username");
        String password = creds.get("password");

        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getPassword().equals(password)) {
                System.out.println("✅ Login Success for: " + username);
                return ResponseEntity.ok(user);
            } else {
                System.out.println("❌ Login Failed: Password mismatch for " + username);
            }
        } else {
            System.out.println("❌ Login Failed: User not found: " + username);
        }
        return ResponseEntity.status(401).body("Invalid Credentials");
    }

    @PutMapping("/profile/{id}")
    public ResponseEntity<?> updateProfile(
            @PathVariable Long id, 
            @RequestParam(value = "file", required = false) org.springframework.web.multipart.MultipartFile file,
            @RequestParam(value = "fullName", required = false) String fullName,
            @RequestParam(value = "phone", required = false) String phone,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "address", required = false) String address
            ) {
        return userRepository.findById(id).map(user -> {
            if (fullName != null) user.setFullName(fullName);
            if (phone != null) user.setPhone(phone);
            if (email != null) user.setEmail(email);
            if (address != null) user.setAddress(address);
            
            try {
                if (file != null && !file.isEmpty()) {
                    user.setPhotoData(file.getBytes());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            userRepository.save(user);
            return ResponseEntity.ok(user);
        }).orElse(ResponseEntity.notFound().build());
    }
}
