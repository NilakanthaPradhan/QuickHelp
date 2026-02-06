class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String role; // USER, ADMIN, GUEST
  final String fullName;
  final String address;
  final String? photoData; // Base64 encoded or raw bytes handled elsewhere

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.fullName,
    required this.address,
    this.photoData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'USER',
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      photoData: json['photoData'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'fullName': fullName,
      'address': address,
      'photoData': photoData, // Backend expects this or multipart
    };
  }

  // Helper for guest user
  factory User.guest() {
    return User(
      id: -1,
      username: 'Guest',
      email: '',
      phone: '',
      role: 'GUEST',
      fullName: 'Guest User',
      address: '',
      photoData: null,
    );
  }
}
