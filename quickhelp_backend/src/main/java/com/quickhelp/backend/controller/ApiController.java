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

    @Autowired
    private com.quickhelp.backend.repository.ProviderRequestRepository providerRequestRepository;



    @Autowired
    private com.quickhelp.backend.repository.UserRepository userRepository;

    @GetMapping("/services")
    public List<Service> getServices() {
        List<Service> services = serviceRepository.findAll();
        for (Service s : services) {
            s.setProviderCount(providerRepository.countByServiceTypeIgnoreCase(s.getName()));
        }
        return services;
    }

    @GetMapping("/bookings")
    public List<Booking> getBookings(@RequestParam(name = "userId", required = false) Long userId) {
        if (userId != null) {
            return bookingRepository.findByUserId(userId);
        }
        return bookingRepository.findAll();
    }

    @PostMapping("/bookings")
    public Booking createBooking(@RequestBody Booking booking) {
        return bookingRepository.save(booking);
    }
    
    @GetMapping("/admin/users")
    public List<com.quickhelp.backend.model.User> getAllUsers() {
        return userRepository.findAll();
    }

    // Temporary endpoint to promote user to admin (for development)
    @PostMapping("/admin/promote/{username}")
    public org.springframework.http.ResponseEntity<?> promoteToAdmin(@PathVariable String username) {
        return userRepository.findByUsername(username).map(user -> {
            user.setRole("ADMIN");
            userRepository.save(user);
            return org.springframework.http.ResponseEntity.ok("User promoted to ADMIN");
        }).orElse(org.springframework.http.ResponseEntity.notFound().build());
    }

    @GetMapping("/providers")
    public List<Provider> getProviders(@RequestParam(name = "serviceType", required = false) String serviceType) {
        if (serviceType != null && !serviceType.isEmpty()) {
            return providerRepository.findByServiceTypeIgnoreCase(serviceType);
        }
        return providerRepository.findAll();
    }

    @PostMapping("/providers")
    public Provider createProvider(@RequestBody Provider provider) {
        return providerRepository.save(provider);
    }

    @PostMapping("/provider-requests")
    public org.springframework.http.ResponseEntity<String> submitProviderRequest(
            @RequestParam("name") String name,
            @RequestParam("serviceType") String serviceType,
            @RequestParam("description") String description,
            @RequestParam("location") String location,
            @RequestParam("phoneNumber") String phoneNumber,
            @RequestParam("file") org.springframework.web.multipart.MultipartFile file) {
        try {
            com.quickhelp.backend.model.ProviderRequest request = new com.quickhelp.backend.model.ProviderRequest();
            request.setName(name);
            request.setServiceType(serviceType);
            request.setDescription(description);
            request.setLocation(location);
            request.setPhoneNumber(phoneNumber);
            if (file != null && !file.isEmpty()) {
                request.setPhotoData(file.getBytes());
            }
            request.setStatus(com.quickhelp.backend.model.ProviderRequest.RequestStatus.PENDING);
            providerRequestRepository.save(request);
            return org.springframework.http.ResponseEntity.ok("Request submitted successfully");
        } catch (Exception e) {
            e.printStackTrace();
            return org.springframework.http.ResponseEntity.status(500).body("Error submitting request: " + e.getMessage());
        }
    }

    @GetMapping("/provider-requests")
    public List<com.quickhelp.backend.model.ProviderRequest> getProviderRequests() {
        return providerRequestRepository.findByStatus(com.quickhelp.backend.model.ProviderRequest.RequestStatus.PENDING);
    }

    @PostMapping("/provider-requests/{id}/approve")
    public org.springframework.http.ResponseEntity<String> approveProviderRequest(@PathVariable("id") Long id) {
        try {
            return providerRequestRepository.findById(id).map(request -> {
                // Move to Provider
                Provider provider = new Provider();
                provider.setName(request.getName());
                provider.setServiceType(request.getServiceType());
                provider.setPhone(request.getPhoneNumber());
                provider.setPhotoData(request.getPhotoData());
                provider.setRating(0.0); // New provider default rating
                provider.setPrice("₹200/hr"); // Default price or ask user?
                
                // Assuming location is just a string in request, but Provider needs lat/lng. 
                // For now, we'll default to some value or 0.0, 0.0
                provider.setLat(12.9716); // Default to Bangalore center for now
                provider.setLng(77.5946);
                
                providerRepository.save(provider);
                
                request.setStatus(com.quickhelp.backend.model.ProviderRequest.RequestStatus.APPROVED);
                providerRequestRepository.save(request);
                
                return org.springframework.http.ResponseEntity.ok("Request approved and Provider created");
            }).orElse(org.springframework.http.ResponseEntity.notFound().build());
        } catch (Exception e) {
            e.printStackTrace();
            return org.springframework.http.ResponseEntity.status(500).body("Error approving request: " + e.getMessage());
        }
    }

    @PostMapping("/provider-requests/{id}/reject")
    public org.springframework.http.ResponseEntity<String> rejectProviderRequest(@PathVariable("id") Long id) {
        return providerRequestRepository.findById(id).map(request -> {
            request.setStatus(com.quickhelp.backend.model.ProviderRequest.RequestStatus.REJECTED);
            providerRequestRepository.save(request);
            return org.springframework.http.ResponseEntity.ok("Request rejected");
        }).orElse(org.springframework.http.ResponseEntity.notFound().build());
    }
}
