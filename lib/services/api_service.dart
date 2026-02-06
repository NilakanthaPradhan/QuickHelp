import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';


class ApiService {
  static String get baseUrl {
    // LAN IP for physical device connection
    return 'http://172.23.72.126:8080/api';
  }

  static Future<List<dynamic>> getServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    }
    return [];
  }

  static Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      if (currentUser != null && currentUser!.id != -1) {
        bookingData['userId'] = currentUser!.id;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error creating booking: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getBookings() async {
    try {
      String url = '$baseUrl/bookings';
      if (currentUser != null && currentUser!.id != -1 && currentUser!.role != 'ADMIN') {
        url += '?userId=${currentUser!.id}';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getProviders(String serviceType) async {
    try {
      final uri = Uri.parse('$baseUrl/providers').replace(queryParameters: {'serviceType': serviceType});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching providers: $e');
    }
    return [];
  }

  static Future<bool> createProvider(Map<String, dynamic> provider) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/providers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(provider),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error creating provider: $e');
      return false;
    }
  }

  static Future<bool> submitProviderRequest(
      Map<String, String> fields, var imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/provider-requests'),
      );
      request.fields.addAll(fields);
      if (imageFile != null) {
        if (imageFile is File) {
            request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
        } else if (imageFile is Uint8List) {
             request.files.add(http.MultipartFile.fromBytes('file', imageFile, filename: 'photo.jpg'));
        }
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error submitting provider request: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getProviderRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/provider-requests'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching provider requests: $e');
    }
    return [];
  }

  static Future<bool> approveRequest(int id) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/provider-requests/$id/approve'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error approving request: $e');
      return false;
    }
  }

  static Future<bool> rejectRequest(int id) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/provider-requests/$id/reject'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      return false;
    }
  }

  static Future<bool> adminLogin(String username, String password) async {
    try {
      debugPrint('🔐 Admin login attempt for username: $username');
      // Reuse standard login to authenticate against DB
      final user = await login(username, password);
      debugPrint('🔐 Login result - User: ${user?.username}, Role: ${user?.role}, FullName: ${user?.fullName}');
      if (user != null && user.role == 'ADMIN') {
        currentUser = user; // Set current user with full DB details
        debugPrint('✅ Admin login successful! Current user set to: ${currentUser?.username}');
        return true;
      } else if (user != null) {
        // Logged in but not admin
        debugPrint('❌ Login successful but user is not ADMIN. Role: ${user.role}');
        currentUser = null; // Clear if strict about admin session
        return false;
      }
      debugPrint('❌ Admin login failed - no user returned');
      return false;
    } catch (e) {
      debugPrint('❌ Error logging in admin: $e');
      return false;
    }
  }

  // --- User Auth ---
  
  static User? currentUser;

  static Future<User?> login(String username, String password) async {
    try {
      debugPrint('👤 Login attempt for username: $username');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      debugPrint('👤 Login response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('👤 Login response data: $jsonData');
        currentUser = User.fromJson(jsonData);
        debugPrint('✅ Login successful! Set currentUser - Username: ${currentUser?.username}, FullName: ${currentUser?.fullName}, Role: ${currentUser?.role}');
        return currentUser;
      } else {
        debugPrint('❌ Login failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
    }
    return null;
  }
  static Future<bool> register(Map<String, String> data, var imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/register'));
      request.fields.addAll(data);
      
      if (imageFile != null) {
         if (imageFile is File) {
            request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
         } else if (imageFile is Uint8List) {
            request.files.add(http.MultipartFile.fromBytes('file', imageFile, filename: 'profile.jpg'));
         }
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      debugPrint('Register status: ${response.statusCode}');
      debugPrint('Register response: $respStr');
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  static Future<List<User>> getAllUsers() async {
    try {
      debugPrint('Fetching users from: $baseUrl/admin/users');
      final response = await http.get(Uri.parse('$baseUrl/admin/users'));
      debugPrint('GetUsers status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        debugPrint('Users found: ${list.length}');
        return list.map((e) => User.fromJson(e)).toList();
      } else {
        debugPrint('GetUsers failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
    return [];
  }

  static Future<bool> updateProfile(User user, var imageFile) async {
    try {
      debugPrint('Updating profile for user: ${user.id}');
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/auth/profile/${user.id}'));
      request.fields['fullName'] = user.fullName;
      request.fields['phone'] = user.phone;
      request.fields['email'] = user.email;
      request.fields['address'] = user.address;
      
      if (imageFile != null) {
         if (imageFile is File) {
            request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
         } else if (imageFile is Uint8List) {
            request.files.add(http.MultipartFile.fromBytes('file', imageFile, filename: 'profile.jpg'));
         }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('UpdateProfile status: ${response.statusCode}');
      debugPrint('UpdateProfile response: ${response.body}');
      
      if (response.statusCode == 200) {
        currentUser = User.fromJson(jsonDecode(response.body));
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
    return false;
  }
}
