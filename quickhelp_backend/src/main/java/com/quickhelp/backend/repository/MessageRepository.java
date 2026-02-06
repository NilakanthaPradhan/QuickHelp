package com.quickhelp.backend.repository;

import com.quickhelp.backend.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    // Fetch chat history between two users
    @Query("SELECT m FROM Message m WHERE (m.senderId = :user1 AND m.receiverId = :user2) OR (m.senderId = :user2 AND m.receiverId = :user1) ORDER BY m.timestamp ASC")
    List<Message> findChatHistory(@Param("user1") Long user1, @Param("user2") Long user2);

    // Find recent messages involving a user (for chat list - simplistic approach)
    @Query("SELECT m FROM Message m WHERE m.senderId = :userId OR m.receiverId = :userId ORDER BY m.timestamp DESC")
    List<Message> findRecentMessages(@Param("userId") Long userId);
}
