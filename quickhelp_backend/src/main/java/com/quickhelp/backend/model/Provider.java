package com.quickhelp.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Provider {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String serviceType; // e.g. "Maid", "Plumber"
    private String price;       // e.g. "300/hr"
    private String gender;      // "Male" or "Female"
    private String phone;
    private Double rating;
    private Double lat;
    private Double lng;
    private String image;       // URL or local asset path
}
