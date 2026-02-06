package com.quickhelp.backend.controller;

import com.quickhelp.backend.model.Message;
import com.quickhelp.backend.model.User;
import com.quickhelp.backend.repository.MessageRepository;
import com.quickhelp.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/messages")
@CrossOrigin(origins = "*")
public class MessageController {

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private UserRepository userRepository;

    // Send a message
    @PostMapping
    public Message sendMessage(@RequestBody Message message) {
        message.setTimestamp(LocalDateTime.now());
        return messageRepository.save(message);
    }

    // Get chat history between two users
    @GetMapping("/{user1}/{user2}")
    public List<Message> getChatHistory(@PathVariable Long user1, @PathVariable Long user2) {
        return messageRepository.findChatHistory(user1, user2);
    }

    // Get list of users the current user has chatted with
    @GetMapping("/recent/{userId}")
    public List<Map<String, Object>> getRecentChats(@PathVariable Long userId) {
        List<Message> messages = messageRepository.findRecentMessages(userId);
        
        Set<Long> chattedUserIds = new HashSet<>();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Message m : messages) {
            Long otherId = m.getSenderId().equals(userId) ? m.getReceiverId() : m.getSenderId();
            if (!chattedUserIds.contains(otherId)) {
                chattedUserIds.add(otherId);
                
                // Fetch user details
                Optional<User> userOpt = userRepository.findById(otherId);
                if (userOpt.isPresent()) {
                    User u = userOpt.get();
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", u.getId());
                    map.put("fullName", u.getFullName());
                    map.put("username", u.getUsername());
                    map.put("lastMessage", m.getContent());
                    map.put("timestamp", m.getTimestamp());
                    result.add(map);
                } else {
                    System.out.println("⚠️ Found chat message with orphan User ID: " + otherId + " (User does not exist)");
                }
            }
        }
        return result;
    }
}
