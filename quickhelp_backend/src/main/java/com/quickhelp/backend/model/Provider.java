package com.quickhelp.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Provider {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String serviceType;
    private String price;
    private String gender;
    private String phone;
    private Double rating;
    private Double lat;
    private Double lng;
    private String image;
    @jakarta.persistence.Column(length = 10485760)
    private byte[] photoData;

    public Provider() {
    }

    public Provider(Long id, String name, String serviceType, String price, String gender, String phone, Double rating, Double lat, Double lng, String image, byte[] photoData) {
        this.id = id;
        this.name = name;
        this.serviceType = serviceType;
        this.price = price;
        this.gender = gender;
        this.phone = phone;
        this.rating = rating;
        this.lat = lat;
        this.lng = lng;
        this.image = image;
        this.photoData = photoData;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public String getPrice() { return price; }
    public void setPrice(String price) { this.price = price; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }

    public Double getLat() { return lat; }
    public void setLat(Double lat) { this.lat = lat; }

    public Double getLng() { return lng; }
    public void setLng(Double lng) { this.lng = lng; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public byte[] getPhotoData() { return photoData; }
    public void setPhotoData(byte[] photoData) { this.photoData = photoData; }
}
