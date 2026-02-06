class Config {
  // Toggle this for local vs production
  static const bool isProd = true;

  // Since we use 'adb reverse tcp:8080 tcp:8080', the device can access computer's localhost:8080
  // static const String localUrl = 'http://127.0.0.1:8080/api'; 
  // If USB (adb reverse) fails, use your LAN IP (phone & PC must be on same WiFi):
   static const String localUrl = 'http://172.23.72.126:8080/api'; 
  static const String prodUrl = 'https://quickhelp-48a5.onrender.com/api'; // Replace with actual URL

  static String get baseUrl => isProd ? prodUrl : localUrl;
}
