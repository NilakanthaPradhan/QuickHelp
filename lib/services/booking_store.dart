import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookingStore {
  static const String _key = 'quickhelp_bookings';

  static Future<List<Map<String, dynamic>>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> dec = json.decode(raw);
    return dec.cast<Map<String, dynamic>>();
  }

  static Future<void> saveBooking(Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookings();
    list.insert(0, booking);
    await prefs.setString(_key, json.encode(list));
  }

  static Future<void> removeBookingAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookings();
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setString(_key, json.encode(list));
    }
  }
}
