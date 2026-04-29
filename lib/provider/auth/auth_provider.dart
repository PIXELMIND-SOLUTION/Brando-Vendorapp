// import 'dart:io';
// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/model/vendor_model.dart';
// import 'package:brando_vendor/services/auth/auth_service.dart';
// import 'package:flutter/material.dart';

// enum AuthStatus { idle, loading, success, error }

// class VendorProvider extends ChangeNotifier {
//   final VendorService _service = VendorService();

//   AuthStatus _status = AuthStatus.idle;
//   String _errorMessage = '';
//   String _successMessage = '';

//   bool? _isVendorExists;

//   VendorModel? _vendorData;

//   // Shared across login & registration OTP flows
//   String? _loginToken;
//   String? _mobileNumber;

//   // Holds token returned after /register — used by verifyRegistrationOtp
//   String? _registrationToken;

//   String? _registrationApprovalStatus;

//   // Getters
//   AuthStatus get status => _status;
//   String get errorMessage => _errorMessage;
//   String get successMessage => _successMessage;
//   VendorModel? get vendorData => _vendorData;
//   bool get isLoading => _status == AuthStatus.loading;
//   bool? get isVendorExists => _isVendorExists;
//   String? get registrationApprovalStatus => _registrationApprovalStatus;

//   // ─────────────────────────────────────────────────────────────
//   // REGISTER  →  POST /register
//   // On success: saves token for registration OTP step
//   // Returns true so UI can navigate to registration OTP screen
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> registerVendor({
//     required String name,
//     required String mobileNumber,
//     required String email,
//     required File hostelImage,
//   }) async {
//     _setLoading();
//     try {
//       final response = await _service.registerVendor(
//         name: name,
//         mobileNumber: mobileNumber,
//         email: email,
//         hostelImage: hostelImage,
//       );

//       if (response != null && response.success) {
//         _registrationToken = response.token;
//         _mobileNumber = response.mobileNumber;
//         await SharedPreferenceHelper.saveMobileNumber(response.mobileNumber);
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Registration failed. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // VERIFY REGISTRATION OTP  →  POST /verify-registration-otp
//   // Body: { token, otp }
//   // On success: saves auth token + vendorId, marks as logged in
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> verifyRegistrationOtp(String otp) async {

//     if (_registrationToken == null) {
//       _setError('Session expired. Please register again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.verifyRegistrationOtp(
//         token: _registrationToken!,
//         otp: otp,
//       );

//       if (response != null && response.success) {
//           _registrationApprovalStatus = response.approvalStatus;
//         await SharedPreferenceHelper.saveVendorId(response.vendorId);
//         await SharedPreferenceHelper.saveToken(response.token);
//         await SharedPreferenceHelper.setLoggedIn(true);
//         _registrationToken = null; // clear after use
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Invalid OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // RESEND REGISTRATION OTP  →  POST /resend-registration-otp
//   // Body: { mobileNumber }
//   // Updates _registrationToken with the freshly issued token
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> resendRegistrationOtp() async {
//     if (_mobileNumber == null) {
//       _setError('Mobile number not found. Please register again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.resendRegistrationOtp(
//         mobileNumber: _mobileNumber!,
//       );

//       if (response != null && response.success) {
//         _registrationToken = response.token; // refresh token
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Failed to resend OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // LOGIN  →  POST /login
//   // Body: { mobileNumber }
//   // On success: saves token for login OTP step
//   // If vendor does not exist → returns false so UI can redirect
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> login(String mobileNumber) async {
//     _setLoading();
//     try {
//       final response = await _service.login(mobileNumber);

//       if (response != null) {
//         _isVendorExists = response.isExists;

//         if (!response.isExists) {
//           // Vendor not registered — stop, let UI redirect to register
//           _setError(response.message);
//           return false;
//         }

//         _loginToken = response.token;
//         _mobileNumber = response.mobileNumber;
//         await SharedPreferenceHelper.saveMobileNumber(mobileNumber);
//         await SharedPreferenceHelper.saveToken(response.token);
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Login failed. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // VERIFY LOGIN OTP  →  POST /verify-otp
//   // Body: { mobileNumber, token, otp }
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> verifyOtp(String otp) async {
//     if (_mobileNumber == null || _loginToken == null) {
//       _setError('Session expired. Please login again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.verifyOtp(
//         mobileNumber: _mobileNumber!,
//         token: _loginToken!,
//         otp: otp,
//       );

//       if (response != null && response.success) {
//         await SharedPreferenceHelper.saveVendorId(response.vendorId);
//         await SharedPreferenceHelper.setLoggedIn(true);
//         _loginToken = null; // clear after use
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Invalid OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // RESEND LOGIN OTP  →  POST /resend-otp
//   // Body: { mobileNumber }
//   // Updates _loginToken with the freshly issued token
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> resendOtp() async {
//     if (_mobileNumber == null) {
//       _setError('Mobile number not found. Please login again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.resendOtp(
//         mobileNumber: _mobileNumber!,
//       );

//       if (response != null && response.success) {
//         _loginToken = response.token; // refresh token
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Failed to resend OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // LOGOUT
//   // ─────────────────────────────────────────────────────────────
//   Future<void> logout() async {
//     await SharedPreferenceHelper.clearAll();
//     _vendorData = null;
//     _loginToken = null;
//     _registrationToken = null;
//      _registrationApprovalStatus = null;
//     _mobileNumber = null;
//     _isVendorExists = null;
//     _status = AuthStatus.idle;
//     notifyListeners();
//   }

//   // Load saved vendor on app start
//   Future<void> loadSavedVendor() async {
//     _vendorData = await SharedPreferenceHelper.getVendorData();
//     notifyListeners();
//   }

//   // ─────────────────────────────────────────────────────────────
//   // Private helpers
//   // ─────────────────────────────────────────────────────────────
//   void _setLoading() {
//     _status = AuthStatus.loading;
//     _errorMessage = '';
//     notifyListeners();
//   }

//   void _setSuccess(String message) {
//     _status = AuthStatus.success;
//     _successMessage = message;
//     notifyListeners();
//   }

//   void _setError(String message) {
//     _status = AuthStatus.error;
//     _errorMessage = message;
//     notifyListeners();
//   }

//   void resetStatus() {
//     _status = AuthStatus.idle;
//     _errorMessage = '';
//     _successMessage = '';
//     notifyListeners();
//   }
// }

// import 'dart:io';
// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/model/vendor_model.dart';
// import 'package:brando_vendor/services/auth/auth_service.dart';
// import 'package:flutter/material.dart';

// enum AuthStatus { idle, loading, success, error }

// class VendorProvider extends ChangeNotifier {
//   final VendorService _service = VendorService();

//   AuthStatus _status = AuthStatus.idle;
//   String _errorMessage = '';
//   String _successMessage = '';

//   bool? _isVendorExists;
//   bool? _adminApproved;
//   String? _loginApprovalStatus;

//   VendorModel? _vendorData;

//   // Shared across login & registration OTP flows
//   String? _loginToken;
//   String? _mobileNumber;

//   // Holds token returned after /register — used by verifyRegistrationOtp
//   String? _registrationToken;

//   String? _registrationApprovalStatus;

//   // Getters
//   AuthStatus get status => _status;
//   String get errorMessage => _errorMessage;
//   String get successMessage => _successMessage;
//   VendorModel? get vendorData => _vendorData;
//   bool get isLoading => _status == AuthStatus.loading;
//   bool? get isVendorExists => _isVendorExists;
//   bool? get adminApproved => _adminApproved;
//   String? get loginApprovalStatus => _loginApprovalStatus;
//   String? get registrationApprovalStatus => _registrationApprovalStatus;

//   // ─────────────────────────────────────────────────────────────
//   // REGISTER  →  POST /register
//   // On success: saves token for registration OTP step
//   // Returns true so UI can navigate to registration OTP screen
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> registerVendor({
//     required String name,
//     required String mobileNumber,
//     required String email,
//     required File hostelImage,
//   }) async {
//     _setLoading();
//     try {
//       final response = await _service.registerVendor(
//         name: name,
//         mobileNumber: mobileNumber,
//         email: email,
//         hostelImage: hostelImage,
//       );

//       if (response != null && response.success) {
//         _registrationToken = response.token;
//         _mobileNumber = response.mobileNumber;
//         await SharedPreferenceHelper.saveMobileNumber(response.mobileNumber);
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Registration failed. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // VERIFY REGISTRATION OTP  →  POST /verify-registration-otp
//   // Body: { token, otp }
//   // On success: saves auth token + vendorId, marks as logged in
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> verifyRegistrationOtp(String otp) async {
//     if (_registrationToken == null) {
//       _setError('Session expired. Please register again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.verifyRegistrationOtp(
//         token: _registrationToken!,
//         otp: otp,
//       );

//       if (response != null && response.success) {
//         _registrationApprovalStatus = response.approvalStatus;
//         await SharedPreferenceHelper.saveVendorId(response.vendorId);
//         await SharedPreferenceHelper.saveToken(response.token);
//         await SharedPreferenceHelper.setLoggedIn(true);
//         _registrationToken = null; // clear after use
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Invalid OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // RESEND REGISTRATION OTP  →  POST /resend-registration-otp
//   // Body: { mobileNumber }
//   // Updates _registrationToken with the freshly issued token
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> resendRegistrationOtp() async {
//     if (_mobileNumber == null) {
//       _setError('Mobile number not found. Please register again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.resendRegistrationOtp(
//         mobileNumber: _mobileNumber!,
//       );

//       if (response != null && response.success) {
//         _registrationToken = response.token; // refresh token
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Failed to resend OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // LOGIN  →  POST /login
//   // Body: { mobileNumber }
//   // On success: saves token for login OTP step
//   // Handles three cases:
//   // 1. Vendor does not exist → returns false (UI shows registration)
//   // 2. Vendor exists but not admin approved → returns false with error message
//   // 3. Vendor exists and approved → returns true (proceed to OTP)
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> login(String mobileNumber) async {
//     _setLoading();
//     try {
//       final response = await _service.login(mobileNumber);

//       if (response != null) {
//         _isVendorExists = response.isExists;
//         _adminApproved = response.adminApproved;
//         _loginApprovalStatus = response.approvalStatus;

//         // Case 1: Vendor doesn't exist
//         if (!response.isExists) {
//           _setError(response.message);
//           return false;
//         }

//         // Case 2: Vendor exists but not approved by admin
//         if (!response.adminApproved) {
//           _setError(response.message);
//           return false;
//         }

//         // Case 3: Vendor exists and is approved
//         _loginToken = response.token;
//         _mobileNumber = response.mobileNumber;
//         await SharedPreferenceHelper.saveMobileNumber(mobileNumber);
//         await SharedPreferenceHelper.saveToken(response.token);
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Login failed. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // VERIFY LOGIN OTP  →  POST /verify-otp
//   // Body: { mobileNumber, token, otp }
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> verifyOtp(String otp) async {
//     if (_mobileNumber == null || _loginToken == null) {
//       _setError('Session expired. Please login again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.verifyOtp(
//         mobileNumber: _mobileNumber!,
//         token: _loginToken!,
//         otp: otp,
//       );

//       if (response != null && response.success) {
//         await SharedPreferenceHelper.saveVendorId(response.vendorId);
//         await SharedPreferenceHelper.setLoggedIn(true);
//         _loginToken = null; // clear after use
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Invalid OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // RESEND LOGIN OTP  →  POST /resend-otp
//   // Body: { mobileNumber }
//   // Updates _loginToken with the freshly issued token
//   // ─────────────────────────────────────────────────────────────
//   Future<bool> resendOtp() async {
//     if (_mobileNumber == null) {
//       _setError('Mobile number not found. Please login again.');
//       return false;
//     }

//     _setLoading();
//     try {
//       final response = await _service.resendOtp(mobileNumber: _mobileNumber!);

//       if (response != null && response.success) {
//         _loginToken = response.token; // refresh token
//         _setSuccess(response.message);
//         return true;
//       } else {
//         _setError('Failed to resend OTP. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // CHECK APPROVAL STATUS
//   // Used for polling when vendor is pending approval
//   // ─────────────────────────────────────────────────────────────
//   // Future<String?> checkApprovalStatus(String vendorId) async {
//   //   try {
//   //     final response = await _service.getApprovalStatus(vendorId);
//   //     if (response != null && response['success'] == true) {
//   //       return response['data']['approvalStatus'];
//   //     }
//   //     return null;
//   //   } catch (e) {
//   //     return null;
//   //   }
//   // }

//   // ─────────────────────────────────────────────────────────────
//   // LOGOUT
//   // ─────────────────────────────────────────────────────────────
//   Future<void> logout() async {
//     await SharedPreferenceHelper.clearAll();
//     _vendorData = null;
//     _loginToken = null;
//     _registrationToken = null;
//     _registrationApprovalStatus = null;
//     _mobileNumber = null;
//     _isVendorExists = null;
//     _adminApproved = null;
//     _loginApprovalStatus = null;
//     _status = AuthStatus.idle;
//     notifyListeners();
//   }

//   // Load saved vendor on app start
//   Future<void> loadSavedVendor() async {
//     _vendorData = await SharedPreferenceHelper.getVendorData();
//     notifyListeners();
//   }

//   // Reset login approval status (called after showing error)
//   void resetLoginApprovalStatus() {
//     _adminApproved = null;
//     _loginApprovalStatus = null;
//     notifyListeners();
//   }

//   // ─────────────────────────────────────────────────────────────
//   // Private helpers
//   // ─────────────────────────────────────────────────────────────
//   void _setLoading() {
//     _status = AuthStatus.loading;
//     _errorMessage = '';
//     notifyListeners();
//   }

//   void _setSuccess(String message) {
//     _status = AuthStatus.success;
//     _successMessage = message;
//     notifyListeners();
//   }

//   void _setError(String message) {
//     _status = AuthStatus.error;
//     _errorMessage = message;
//     notifyListeners();
//   }

//   void resetStatus() {
//     _status = AuthStatus.idle;
//     _errorMessage = '';
//     _successMessage = '';
//     notifyListeners();
//   }
// }

import 'dart:io';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/vendor_model.dart';
import 'package:brando_vendor/services/auth/auth_service.dart';
import 'package:brando_vendor/services/toast_service.dart';
import 'package:flutter/material.dart';

enum AuthStatus { idle, loading, success, error }

class VendorProvider extends ChangeNotifier {
  final VendorService _service = VendorService();

  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';
  String _successMessage = '';

  bool? _isVendorExists;
  bool? _adminApproved;
  String? _loginApprovalStatus;

  VendorModel? _vendorData;

  // Shared across login & registration OTP flows
  String? _loginToken;
  String? _mobileNumber;

  // Holds token returned after /register — used by verifyRegistrationOtp
  String? _registrationToken;

  String? _registrationApprovalStatus;

  // Getters
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  VendorModel? get vendorData => _vendorData;
  bool get isLoading => _status == AuthStatus.loading;
  bool? get isVendorExists => _isVendorExists;
  bool? get adminApproved => _adminApproved;
  String? get loginApprovalStatus => _loginApprovalStatus;
  String? get registrationApprovalStatus => _registrationApprovalStatus;

  // ─────────────────────────────────────────────────────────────
  // REGISTER  →  POST /register
  // ─────────────────────────────────────────────────────────────
  Future<bool> registerVendor({
    required String name,
    required String mobileNumber,
    required String email,
    required File hostelImage,
  }) async {
    _setLoading();
    try {
      final response = await _service.registerVendor(
        name: name,
        mobileNumber: mobileNumber,
        email: email,
        hostelImage: hostelImage,
      );

      if (response != null && response.success) {
        _registrationToken = response.token;
        _mobileNumber = response.mobileNumber;
        await SharedPreferenceHelper.saveMobileNumber(response.mobileNumber);
        _setSuccess(response.message);
        ToastService.showSuccess(response.message);
        return true;
      } else {
        final errorMsg = 'Registration failed. Please try again.';
        _setError(errorMsg);
        ToastService.showError(errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VERIFY REGISTRATION OTP  →  POST /verify-registration-otp
  // ─────────────────────────────────────────────────────────────
  Future<bool> verifyRegistrationOtp(String otp) async {
    if (_registrationToken == null) {
      final errorMsg = 'Session expired. Please register again.';
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }

    _setLoading();
    try {
      final response = await _service.verifyRegistrationOtp(
        token: _registrationToken!,
        otp: otp,
      );

      print("lllllllllllllllllllllllllllllllllll${response?.vendorId}");

      if (response != null && response.success) {
        print("lllllllllllllllllllllllllllllllllll${response?.vendorId}");

        _registrationApprovalStatus = response.approvalStatus;
        await SharedPreferenceHelper.saveVendorId(response.vendorId);
        await SharedPreferenceHelper.saveToken(response.token);
        await SharedPreferenceHelper.setLoggedIn(true);
        _registrationToken = null;
        _setSuccess(response.message);

        if (response.approvalStatus == 'approved') {
          ToastService.showSuccess('Registration successful! Welcome aboard!');
        } else {
          ToastService.showInfo(response.message);
        }
        return true;
      } else {
        final errorMsg = 'Invalid OTP. Please try again.';
        _setError(errorMsg);
        ToastService.showError(errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // RESEND REGISTRATION OTP  →  POST /resend-registration-otp
  // ─────────────────────────────────────────────────────────────
  Future<bool> resendRegistrationOtp() async {
    if (_mobileNumber == null) {
      final errorMsg = 'Mobile number not found. Please register again.';
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }

    _setLoading();
    try {
      final response = await _service.resendRegistrationOtp(
        mobileNumber: _mobileNumber!,
      );

      if (response != null && response.success) {
        _registrationToken = response.token;
        _setSuccess(response.message);
        ToastService.showSuccess('OTP resent successfully');
        return true;
      } else {
        final errorMsg = 'Failed to resend OTP. Please try again.';
        _setError(errorMsg);
        ToastService.showError(errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN  →  POST /login
  // ─────────────────────────────────────────────────────────────
  // Future<bool> login(String mobileNumber) async {
  //   _setLoading();
  //   try {
  //     final response = await _service.login(mobileNumber);

  //     if (response != null) {
  //       _isVendorExists = response.isExists;
  //       _adminApproved = response.adminApproved;
  //       _loginApprovalStatus = response.approvalStatus;

  //       // Case 1: Vendor doesn't exist
  //       if (!response.isExists) {
  //         _setError(response.message);
  //         ToastService.showError(response.message);
  //         return false;
  //       }

  //       // Case 2: Vendor exists but not approved by admin
  //       if (!response.adminApproved) {
  //         _setError(response.message);
  //         ToastService.showError(response.message);
  //         return false;
  //       }

  //       // Case 3: Vendor exists and is approved
  //       _loginToken = response.token;
  //       _mobileNumber = response.mobileNumber;
  //       await SharedPreferenceHelper.saveMobileNumber(mobileNumber);
  //       await SharedPreferenceHelper.saveToken(response.token);
  //       _setSuccess(response.message);
  //       ToastService.showSuccess('OTP sent successfully!');
  //       return true;
  //     } else {
  //       final errorMsg = 'Login failed. Please try again.';
  //       _setError(errorMsg);
  //       ToastService.showError(errorMsg);
  //       return false;
  //     }
  //   } catch (e) {
  //     final errorMsg = e.toString();
  //     _setError(errorMsg);
  //     ToastService.showError(errorMsg);
  //     return false;
  //   }
  // }

  Future<bool> login(String mobileNumber) async {
    _setLoading();
    try {
      final response = await _service.login(mobileNumber);

      if (response != null) {
        _isVendorExists = response.isExists;
        _adminApproved = response.adminApproved;
        _loginApprovalStatus = response.approvalStatus;

        // Case 1: Vendor doesn't exist
        if (!response.isExists) {
          _setError(response.message);
          ToastService.showError(response.message);
          return false;
        }

        // Case 2: Vendor exists but not approved by admin
        if (!response.adminApproved) {
          // Save userId for polling even if not approved
          if (response.userId != null) {
            await SharedPreferenceHelper.saveVendorId(
              response.userId.toString(),
            );
            print(
              'Saved vendorId for polling: ${response.userId}',
            ); // Debug log
          }
          _setError(response.message);
          ToastService.showError(response.message);
          return false;
        }

        // Case 3: Vendor exists and is approved
        _loginToken = response.token;
        _mobileNumber = response.mobileNumber;
        await SharedPreferenceHelper.saveMobileNumber(mobileNumber);
        await SharedPreferenceHelper.saveToken(response.token);
        if (response.userId != null) {
          await SharedPreferenceHelper.saveVendorId(response.userId.toString());
        }
        _setSuccess(response.message);
        ToastService.showSuccess('OTP sent successfully!');
        return true;
      } else {
        final errorMsg = 'Login failed. Please try again.';
        _setError(errorMsg);
        ToastService.showError(errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VERIFY LOGIN OTP  →  POST /verify-otp
  // ─────────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String otp) async {
    if (_mobileNumber == null || _loginToken == null) {
      final errorMsg = 'Session expired. Please login again.';
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }

    _setLoading();
    try {
      final response = await _service.verifyOtp(
        mobileNumber: _mobileNumber!,
        token: _loginToken!,
        otp: otp,
      );

      if (response != null && response.success) {
        await SharedPreferenceHelper.saveVendorId(response.vendorId);
        await SharedPreferenceHelper.setLoggedIn(true);
        _loginToken = null;
        _setSuccess(response.message);
        ToastService.showSuccess('Login successful!');
        return true;
      } else {
        final errorMsg = 'Invalid OTP. Please try again.';
        _setError(errorMsg);
        ToastService.showError(errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // RESEND LOGIN OTP  →  POST /resend-otp
  // ─────────────────────────────────────────────────────────────
  Future<bool> resendOtp() async {
    if (_mobileNumber == null) {
      final errorMsg = 'Mobile number not found. Please login again.';
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }

    _setLoading();
    try {
      final response = await _service.resendOtp(mobileNumber: _mobileNumber!);

      if (response != null && response.success) {
        _loginToken = response.token;
        _setSuccess(response.message);
        ToastService.showSuccess('OTP resent successfully');
        return true;
      } else {
        final errorMsg = 'Failed to resend OTP. Please try again.';
        _setError(errorMsg);
        ToastService.showError(errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      ToastService.showError(errorMsg);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // CHECK APPROVAL STATUS
  // ─────────────────────────────────────────────────────────────
  // Future<String?> checkApprovalStatus(String vendorId) async {
  //   try {
  //     final response = await _service.getApprovalStatus(vendorId);
  //     if (response != null && response['success'] == true) {
  //       return response['data']['approvalStatus'];
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await SharedPreferenceHelper.clearAll();
    _vendorData = null;
    _loginToken = null;
    _registrationToken = null;
    _registrationApprovalStatus = null;
    _mobileNumber = null;
    _isVendorExists = null;
    _adminApproved = null;
    _loginApprovalStatus = null;
    _status = AuthStatus.idle;
    ToastService.showInfo('Logged out successfully');
    notifyListeners();
  }

  // Load saved vendor on app start
  Future<void> loadSavedVendor() async {
    _vendorData = await SharedPreferenceHelper.getVendorData();
    notifyListeners();
  }

  // Reset login approval status
  void resetLoginApprovalStatus() {
    _adminApproved = null;
    _loginApprovalStatus = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────
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
