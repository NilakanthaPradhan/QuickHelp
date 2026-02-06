package com.quickhelp.backend.repository;

import com.quickhelp.backend.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    java.util.List<Booking> findByUserId(Long userId);
}
