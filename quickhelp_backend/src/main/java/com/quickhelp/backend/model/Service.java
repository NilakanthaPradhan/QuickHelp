package com.quickhelp.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Service {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String icon;
    private String description;
    
    @jakarta.persistence.Transient
    private long providerCount;

    public Service() {}

    public Service(Long id, String name, String icon, String description, long providerCount) {
        this.id = id;
        this.name = name;
        this.icon = icon;
        this.description = description;
        this.providerCount = providerCount;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public long getProviderCount() { return providerCount; }
    public void setProviderCount(long providerCount) { this.providerCount = providerCount; }
}
