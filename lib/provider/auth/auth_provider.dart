import 'dart:io';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/vendor_model.dart';
import 'package:brando_vendor/services/auth/auth_service.dart';
import 'package:flutter/material.dart';


enum AuthStatus { idle, loading, success, error }

class VendorProvider extends ChangeNotifier {
  final VendorService _service = VendorService();

  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';
  String _successMessage = '';
  

  VendorModel? _vendorData;
  String? _loginToken;
  String? _mobileNumber;

  // Getters
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  VendorModel? get vendorData => _vendorData;
  bool get isLoading => _status == AuthStatus.loading;

  // Register Vendor
  Future<bool> registerVendor({
    required String name,
    required String mobileNumber,
    required String email,
    required File hostelImage,
  }) async {
    _setLoading();
    try {
      final vendor = await _service.registerVendor(
        name: name,
        mobileNumber: mobileNumber,
        email: email,
        hostelImage: hostelImage,
      );

      if (vendor != null) {
        _vendorData = vendor;
        await SharedPreferenceHelper.saveVendorData(vendor);
        _setSuccess('Vendor registered successfully');
        return true;
      } else {
        _setError('Registration failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  

  // Login - Request OTP
  Future<bool> login(String mobileNumber) async {
    _setLoading();
    try {
      final response = await _service.login(mobileNumber);

      if (response != null) {
        _loginToken = response.token;
        _mobileNumber = response.mobileNumber;
        await SharedPreferenceHelper.saveMobileNumber(mobileNumber);
        await SharedPreferenceHelper.saveToken(response.token);
        _setSuccess(response.message);
        return true;
      } else {
        _setError('Login failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (_mobileNumber == null || _loginToken == null) {
      _setError('Session expired. Please login again.');
      return false;
    }

    _setLoading();
    try {
      final response = await _service.verifyOtp(
        mobileNumber: _mobileNumber!,
        token: _loginToken!,
        otp: otp,
      );

      if (response != null) {
        await SharedPreferenceHelper.saveVendorId(response.vendorId);
        await SharedPreferenceHelper.setLoggedIn(true);
        _setSuccess(response.message);
        return true;
      } else {
        _setError('Invalid OTP. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await SharedPreferenceHelper.clearAll();
    _vendorData = null;
    _loginToken = null;
    _mobileNumber = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // Load saved vendor on app start
  Future<void> loadSavedVendor() async {
    _vendorData = await SharedPreferenceHelper.getVendorData();
    notifyListeners();
  }

  // Private helpers
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setSuccess(String message) {
    _status = AuthStatus.success;
    _successMessage = message;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}