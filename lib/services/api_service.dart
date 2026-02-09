import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';


import '../config.dart';

class ApiService {
  static String get baseUrl => Config.baseUrl;

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

  static Future<List<dynamic>> getProviders(String serviceType, {double? lat, double? lng, double? radius}) async {
    try {
      final params = {'serviceType': serviceType};
      if (lat != null) params['lat'] = lat.toString();
      if (lng != null) params['lng'] = lng.toString();
      if (radius != null) params['radius'] = radius.toString();

      final uri = Uri.parse('$baseUrl/providers').replace(queryParameters: params);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching providers: $e');
    }
    return [];
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

  // --- User Auth & Persistence ---
  
  static User? currentUser;
  static final ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);

  static Future<void> loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('user_data');
      if (userData != null) {
        currentUser = User.fromJson(jsonDecode(userData));
        userNotifier.value = currentUser; // Notify listeners
        debugPrint('✅ Restored user session: ${currentUser?.username}');
      }
    } catch (e) {
      debugPrint('❌ Error loading user from prefs: $e');
    }
  }

  static Future<void> saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson())); 
    } catch (e) {
      debugPrint('❌ Error saving user to prefs: $e');
    }
  }

  static Future<void> clearUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

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
        userNotifier.value = currentUser; // Notify listeners
        await saveUserToPrefs(currentUser!); 
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
  
  static Future<void> logout() async {
    currentUser = null;
    userNotifier.value = null; // Notify listeners
    await clearUserPrefs();
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
        userNotifier.value = currentUser; // Notify listeners
        await saveUserToPrefs(currentUser!); // Persist updated profile
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
    return false;
  }

  static Future<List<User>> searchUsers(String query) async {
    try {
      // Config.baseUrl usually includes /api but let's be safe
      final uri = Uri.parse('$baseUrl/users/search?query=$query');
      debugPrint('🔍 Search Request: $uri');
      
      final response = await http.get(uri);
      debugPrint('🔍 Search Response Code: ${response.statusCode}');
      debugPrint('🔍 Search Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error searching users: $e');
      rethrow; // Re-throw to show in UI
    }
    return [];
  }

  static Future<String?> sendMessage(int receiverId, String content) async {
    try {
      if (currentUser == null) return 'Not logged in';
      final uri = Uri.parse('$baseUrl/messages');
      debugPrint('🔍 Send Message Request: $uri');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': currentUser!.id,
          'receiverId': receiverId,
          'content': content
        }),
      );
      debugPrint('🔍 Send Message Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return null; // Success (no error)
      } else {
        return 'Server Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      return 'Network Error: $e';
    }
  }

  static Future<List<dynamic>?> getChatHistory(int otherUserId) async {
    try {
      if (currentUser == null) return [];
      final response = await http.get(Uri.parse('$baseUrl/messages/${currentUser!.id}/$otherUserId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
      return null; // Return null on error so UI knows not to clear list
    }
    return null; // Return null on non-200 status too
  }

  static Future<List<dynamic>> getRecentChats() async {
    try {
      if (currentUser == null) return [];
      final response = await http.get(Uri.parse('$baseUrl/messages/recent/${currentUser!.id}'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching recent chats: $e');
    }
    return [];
  }
  static Future<List<dynamic>> getRentals() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rentals'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching rentals: $e');
    }
    return [];
  }
}
