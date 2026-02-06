package com.quickhelp.backend;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendApplication {
	public static void main(String[] args) {
		SpringApplication.run(BackendApplication.class, args);
	}

	@org.springframework.context.annotation.Bean
	public org.springframework.boot.CommandLineRunner demo(
			com.quickhelp.backend.repository.ServiceRepository serviceInfo, 
			com.quickhelp.backend.repository.ProviderRepository providerInfo,
			com.quickhelp.backend.repository.UserRepository userRepository,
			@Value("${admin.username}") String adminUsername,
			@Value("${admin.password}") String adminPassword) {
		return (args) -> {
            // Seed Services and Providers
            if (serviceInfo.count() == 0) {
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "AC Repair", "ac_unit", "Fix your AC", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Cleaner", "cleaning_services", "Home cleaning", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Plumber", "plumbing", "Fix leaks", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Electrician", "electrical_services", "Wiring help", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Maid", "cleaning_services", "Daily chores helper", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Painter", "format_paint", "House painting", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Carpenter", "handyman", "Woodwork & furniture", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Gardener", "grass", "Garden maintenance", 0L));
                serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Pest Control", "bug_report", "Remove pests", 0L));
                
                // Seed Providers
                providerInfo.save(new com.quickhelp.backend.model.Provider(null, "Asha", "Maid", "₹300/hr", "Female", "+91 90000 00001", 4.5, 12.9716, 77.5946, "https://i.pravatar.cc/150?img=1", null));
                providerInfo.save(new com.quickhelp.backend.model.Provider(null, "Raju", "Plumber", "₹350/hr", "Male", "+91 90000 00002", 4.7, 12.9716, 77.5946, "https://i.pravatar.cc/150?img=2", null));

                System.out.println("Data Seeding Completed!");
            } else {
                System.out.println("Data already exists. Skipping seeding.");
            }

            // Create/Update Admin User from properties
            var adminUserOpt = userRepository.findByUsername(adminUsername);
            if (adminUserOpt.isEmpty()) {
                // Create new admin user
                com.quickhelp.backend.model.User adminUser = new com.quickhelp.backend.model.User();
                adminUser.setUsername(adminUsername);
                adminUser.setPassword(adminPassword);
                adminUser.setFullName("Administrator");
                adminUser.setEmail("admin@quickhelp.com");
                adminUser.setPhone("0000000000");
                adminUser.setAddress("QuickHelp HQ");
                adminUser.setRole("ADMIN");
                userRepository.save(adminUser);
                System.out.println("✅ Admin user created: " + adminUsername);
            } else {
                // Update existing user to ensure they have admin role
                com.quickhelp.backend.model.User existingUser = adminUserOpt.get();
                if (!"ADMIN".equals(existingUser.getRole())) {
                    existingUser.setRole("ADMIN");
                    userRepository.save(existingUser);
                    System.out.println("✅ User '" + adminUsername + "' promoted to ADMIN");
                } else {
                    System.out.println("✅ Admin user already exists: " + adminUsername);
                }
            }
		};
	}
}
