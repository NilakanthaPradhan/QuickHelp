package com.quickhelp.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendApplication {
	public static void main(String[] args) {
		SpringApplication.run(BackendApplication.class, args);
	}

	@org.springframework.context.annotation.Bean
	public org.springframework.boot.CommandLineRunner demo(com.quickhelp.backend.repository.ServiceRepository serviceInfo, com.quickhelp.backend.repository.ProviderRepository providerInfo) {
		return (args) -> {
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "AC Repair", "ac_unit", "Fix your AC"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Cleaner", "cleaning_services", "Home cleaning"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Plumber", "plumbing", "Fix leaks"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Electrician", "electrical_services", "Wiring help"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Maid", "cleaning_services", "Daily chores helper"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Painter", "format_paint", "House painting"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Carpenter", "handyman", "Woodwork & furniture"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Gardener", "grass", "Garden maintenance"));
			serviceInfo.save(new com.quickhelp.backend.model.Service(null, "Pest Control", "bug_report", "Remove pests"));
            
            // Seed Providers
            providerInfo.save(new com.quickhelp.backend.model.Provider(null, "Asha", "Maid", "₹300/hr", "Female", "+91 90000 00001", 4.5, 12.9716, 77.5946, "https://i.pravatar.cc/150?img=1"));
            providerInfo.save(new com.quickhelp.backend.model.Provider(null, "Raju", "Plumber", "₹350/hr", "Male", "+91 90000 00002", 4.7, 12.9716, 77.5946, "https://i.pravatar.cc/150?img=2"));

            System.out.println("Data Seeding Completed!");
		};
	}
}
