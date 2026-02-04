import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    // Always use live server for now
    return 'https://quickhelp-48a5.onrender.com/api';
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
      final response = await http.get(Uri.parse('$baseUrl/bookings'));
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
      final response = await http.get(Uri.parse('$baseUrl/providers?serviceType=$serviceType'));
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
}
