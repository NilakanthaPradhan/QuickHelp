package com.quickhelp.backend.repository;

import com.quickhelp.backend.model.ProviderRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProviderRequestRepository extends JpaRepository<ProviderRequest, Long> {
    List<ProviderRequest> findByStatus(ProviderRequest.RequestStatus status);
}
