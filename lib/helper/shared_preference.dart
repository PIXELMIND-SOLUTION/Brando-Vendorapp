import 'dart:convert';
import 'package:brando_vendor/model/vendor_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String _keyVendorId = 'vendor_id';
  static const String _keyMobileNumber = 'mobile_number';
  static const String _keyToken = 'auth_token';
  static const String _keyVendorData = 'vendor_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Save login token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Save vendor ID
  static Future<void> saveVendorId(String vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVendorId, vendorId);
  }

  static Future<String?> getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVendorId);
  }

  // Save mobile number
  static Future<void> saveMobileNumber(String mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMobileNumber, mobileNumber);
  }

  static Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMobileNumber);
  }

  // Save full vendor data
  static Future<void> saveVendorData(VendorModel vendor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVendorData, jsonEncode(vendor.toJson()));
  }

  static Future<VendorModel?> getVendorData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyVendorData);
    if (jsonString != null) {
      return VendorModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // Login state
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear all data on logout
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
}