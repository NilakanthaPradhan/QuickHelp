package com.quickhelp.backend.model;

import jakarta.persistence.*;

@Entity
public class ProviderRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    private String serviceType;
    private String description;
    private String location;
    private Double lat;
    private Double lng;
    private String phoneNumber;
    
    @Column(length = 10485760)
    private byte[] photoData;
    
    @Enumerated(EnumType.STRING)
    private RequestStatus status;
    
    public enum RequestStatus {
        PENDING,
        APPROVED,
        REJECTED
    }

    public ProviderRequest() {}

    public ProviderRequest(Long id, String name, String serviceType, String description, String location, String phoneNumber, byte[] photoData, RequestStatus status) {
        this.id = id;
        this.name = name;
        this.serviceType = serviceType;
        this.description = description;
        this.location = location;
        this.phoneNumber = phoneNumber;
        this.photoData = photoData;
        this.status = status;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Double getLat() { return lat; }
    public void setLat(Double lat) { this.lat = lat; }

    public Double getLng() { return lng; }
    public void setLng(Double lng) { this.lng = lng; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public byte[] getPhotoData() { return photoData; }
    public void setPhotoData(byte[] photoData) { this.photoData = photoData; }

    public RequestStatus getStatus() { return status; }
    public void setStatus(RequestStatus status) { this.status = status; }
}
