package com.quickhelp.backend.controller;

import com.quickhelp.backend.model.Booking;
import com.quickhelp.backend.model.Provider;
import com.quickhelp.backend.model.Service;
import com.quickhelp.backend.repository.BookingRepository;
import com.quickhelp.backend.repository.ProviderRepository;
import com.quickhelp.backend.repository.ServiceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // Allow Flutter web/emulator to access
public class ApiController {

    @Autowired
    private ServiceRepository serviceRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private ProviderRepository providerRepository;

    @GetMapping("/services")
    public List<Service> getServices() {
        return serviceRepository.findAll();
    }

    @GetMapping("/bookings")
    public List<Booking> getBookings() {
        return bookingRepository.findAll();
    }

    @PostMapping("/bookings")
    public Booking createBooking(@RequestBody Booking booking) {
        return bookingRepository.save(booking);
    }

    @GetMapping("/providers")
    public List<Provider> getProviders(@RequestParam(required = false) String serviceType) {
        if (serviceType != null && !serviceType.isEmpty()) {
            return providerRepository.findByServiceTypeIgnoreCase(serviceType);
        }
        return providerRepository.findAll();
    }

    @PostMapping("/providers")
    public Provider createProvider(@RequestBody Provider provider) {
        return providerRepository.save(provider);
    }
}
