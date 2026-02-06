package com.quickhelp.backend.repository;

import com.quickhelp.backend.model.Provider;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProviderRepository extends JpaRepository<Provider, Long> {
    List<Provider> findByServiceTypeIgnoreCase(String serviceType);
    long countByServiceTypeIgnoreCase(String serviceType);
}
