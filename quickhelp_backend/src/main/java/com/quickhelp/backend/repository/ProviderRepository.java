package com.quickhelp.backend.repository;

import com.quickhelp.backend.model.Provider;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProviderRepository extends JpaRepository<Provider, Long> {
    List<Provider> findByServiceTypeIgnoreCase(String serviceType);
    long countByServiceTypeIgnoreCase(String serviceType);

    @org.springframework.data.jpa.repository.Query("SELECT p FROM Provider p WHERE (6371 * acos(cos(radians(:lat)) * cos(radians(p.lat)) * cos(radians(p.lng) - radians(:lng)) + sin(radians(:lat)) * sin(radians(p.lat)))) < :radius")
    List<Provider> findNearbyProviders(double lat, double lng, double radius);
}
