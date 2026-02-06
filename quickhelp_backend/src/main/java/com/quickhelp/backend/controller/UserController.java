package com.quickhelp.backend.controller;

import com.quickhelp.backend.model.User;
import com.quickhelp.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/search")
    public List<User> searchUsers(@RequestParam String query) {
        return userRepository.searchUsers(query);
    }
}
