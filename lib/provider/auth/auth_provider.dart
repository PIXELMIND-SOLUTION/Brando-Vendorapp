// // import 'dart:io';
// // import 'package:brando_vendor/helper/shared_preference.dart';
// // import 'package:brando_vendor/model/vendor_model.dart';
// // import 'package:brando_vendor/services/auth/auth_service.dart';
// // import 'package:flutter/material.dart';


// // enum AuthStatus { idle, loading, success, error }

// // class VendorProvider extends ChangeNotifier {
// //   final VendorService _service = VendorService();

// //   AuthStatus _status = AuthStatus.idle;
// //   String _errorMessage = '';
// //   String _successMessage = '';

// //   bool? _isVendorExists;

// // bool? get isVendorExists => _isVendorExists;  
  

// //   VendorModel? _vendorData;
  
// //   String? _loginToken;
// //   String? _mobileNumber;

// //   // Getters
// //   AuthStatus get status => _status;
// //   String get errorMessage => _errorMessage;
// //   String get successMessage => _successMessage;
// //   VendorModel? get vendorData => _vendorData;
// //   bool get isLoading => _status == AuthStatus.loading;

// //   // Register Vendor
// //   Future<bool> registerVendor({
// //     required String name,
// //     required String mobileNumber,
// //     required String email,
// //     required File hostelImage,
// //   }) async {
// //     _setLoading();
// //     try {
// //       final vendor = await _service.registerVendor(
// //         name: name,
// //         mobileNumber: mobileNumber,
// //         email: email,
// //         hostelImage: hostelImage,
// //       );

// //       if (vendor != null) {
// //         _vendorData = vendor;
// //         await SharedPreferenceHelper.saveVendorData(vendor);
// //         _setSuccess('Vendor registered successfully');
// //         return true;
// //       } else {
// //         _setError('Registration failed. Please try again.');
// //         return false;
// //       }
// //     } catch (e) {
// //       _setError(e.toString());
// //       return false;
// //     }
// //   }
  

// //   // Login - Request OTP
// //   // Future<bool> login(String mobileNumber) async {
// //   //   _setLoading();
// //   //   try {
// //   //     final response = await _service.login(mobileNumber);

// //   //     if (response != null) {
// //   //       _loginToken = response.token;
// //   //       _mobileNumber = response.mobileNumber;
// //   //       await SharedPreferenceHelper.saveMobileNumber(mobileNumber);
// //   //       await SharedPreferenceHelper.saveToken(response.token);
// //   //       _setSuccess(response.message);
// //   //       return true;
// //   //     } else {
// //   //       _setError('Login failed. Please try again.');
// //   //       return false;
// //   //     }
// //   //   } catch (e) {
// //   //     _setError(e.toString());
// //   //     return false;
// //   //   }
// //   // }


// //   Future<bool> login(String mobileNumber) async {
// //   _setLoading();
// //   try {
// //     final response = await _service.login(mobileNumber);

// //     if (response != null) {
// //       _isVendorExists = response.isExists;  // ADD THIS

// //       if (!response.isExists) {
// //         // Vendor not registered — stop here, redirect to registration
// //         _setError(response.message); // "Vendor not registered"
// //         return false;
// //       }

// //       // Vendor exists — proceed with OTP flow
// //       _loginToken = response.token;
// //       _mobileNumber = response.mobileNumber;
// //       await SharedPreferenceHelper.saveMobileNumber(mobileNumber);
// //       await SharedPreferenceHelper.saveToken(response.token);
// //       _setSuccess(response.message);
// //       return true;
// //     } else {
// //       _setError('Login failed. Please try again.');
// //       return false;
// //     }
// //   } catch (e) {
// //     _setError(e.toString());
// //     return false;
// //   }
// // }

// //   // Verify OTP
// //   Future<bool> verifyOtp(String otp) async {
// //     if (_mobileNumber == null || _loginToken == null) {
// //       _setError('Session expired. Please login again.');
// //       return false;
// //     }

// //     _setLoading();
// //     try {
// //       final response = await _service.verifyOtp(
// //         mobileNumber: _mobileNumber!,
// //         token: _loginToken!,
// //         otp: otp,
// //       );

// //       if (response != null) {
// //         await SharedPreferenceHelper.saveVendorId(response.vendorId);
// //         await SharedPreferenceHelper.setLoggedIn(true);
// //         _setSuccess(response.message);
// //         return true;
// //       } else {
// //         _setError('Invalid OTP. Please try again.');
// //         return false;
// //       }
// //     } catch (e) {
// //       _setError(e.toString());
// //       return false;
// //     }
// //   }

// //   // Logout
// //   Future<void> logout() async {
// //     await SharedPreferenceHelper.clearAll();
// //     _vendorData = null;
// //     _loginToken = null;
// //     _mobileNumber = null;
// //     _status = AuthStatus.idle;
// //     notifyListeners();
// //   }

// //   // Load saved vendor on app start
// //   Future<void> loadSavedVendor() async {
// //     _vendorData = await SharedPreferenceHelper.getVendorData();
// //     notifyListeners();
// //   }

// //   // Private helpers
// //   void _setLoading() {
// //     _status = AuthStatus.loading;
// //     _errorMessage = '';
// //     notifyListeners();
// //   }

// //   void _setSuccess(String message) {
// //     _status = AuthStatus.success;
// //     _successMessage = message;
// //     notifyListeners();
// //   }

// //   void _setError(String message) {
// //     _status = AuthStatus.error;
// //     _errorMessage = message;
// //     notifyListeners();
// //   }

// //   void resetStatus() {
// //     _status = AuthStatus.idle;
// //     _errorMessage = '';
// //     _successMessage = '';
// //     notifyListeners();
// //   }
// // }























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

//   // Getters
//   AuthStatus get status => _status;
//   String get errorMessage => _errorMessage;
//   String get successMessage => _successMessage;
//   VendorModel? get vendorData => _vendorData;
//   bool get isLoading => _status == AuthStatus.loading;
//   bool? get isVendorExists => _isVendorExists;

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


  

  bool? _isVendorExists;

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
  String? get registrationApprovalStatus => _registrationApprovalStatus; 

  // ─────────────────────────────────────────────────────────────
  // REGISTER  →  POST /register
  // On success: saves token for registration OTP step
  // Returns true so UI can navigate to registration OTP screen
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

  // ─────────────────────────────────────────────────────────────
  // VERIFY REGISTRATION OTP  →  POST /verify-registration-otp
  // Body: { token, otp }
  // On success: saves auth token + vendorId, marks as logged in
  // ─────────────────────────────────────────────────────────────
  Future<bool> verifyRegistrationOtp(String otp) async {


    
    if (_registrationToken == null) {
      _setError('Session expired. Please register again.');
      return false;
    }

    _setLoading();
    try {
      final response = await _service.verifyRegistrationOtp(
        token: _registrationToken!,
        otp: otp,
      );

      if (response != null && response.success) {
          _registrationApprovalStatus = response.approvalStatus; 
        await SharedPreferenceHelper.saveVendorId(response.vendorId);
        await SharedPreferenceHelper.saveToken(response.token);
        await SharedPreferenceHelper.setLoggedIn(true);
        _registrationToken = null; // clear after use
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

  // ─────────────────────────────────────────────────────────────
  // RESEND REGISTRATION OTP  →  POST /resend-registration-otp
  // Body: { mobileNumber }
  // Updates _registrationToken with the freshly issued token
  // ─────────────────────────────────────────────────────────────
  Future<bool> resendRegistrationOtp() async {
    if (_mobileNumber == null) {
      _setError('Mobile number not found. Please register again.');
      return false;
    }

    _setLoading();
    try {
      final response = await _service.resendRegistrationOtp(
        mobileNumber: _mobileNumber!,
      );

      if (response != null && response.success) {
        _registrationToken = response.token; // refresh token
        _setSuccess(response.message);
        return true;
      } else {
        _setError('Failed to resend OTP. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN  →  POST /login
  // Body: { mobileNumber }
  // On success: saves token for login OTP step
  // If vendor does not exist → returns false so UI can redirect
  // ─────────────────────────────────────────────────────────────
  Future<bool> login(String mobileNumber) async {
    _setLoading();
    try {
      final response = await _service.login(mobileNumber);

      if (response != null) {
        _isVendorExists = response.isExists;

        if (!response.isExists) {
          // Vendor not registered — stop, let UI redirect to register
          _setError(response.message);
          return false;
        }

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

  // ─────────────────────────────────────────────────────────────
  // VERIFY LOGIN OTP  →  POST /verify-otp
  // Body: { mobileNumber, token, otp }
  // ─────────────────────────────────────────────────────────────
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

      if (response != null && response.success) {
        await SharedPreferenceHelper.saveVendorId(response.vendorId);
        await SharedPreferenceHelper.setLoggedIn(true);
        _loginToken = null; // clear after use
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

  // ─────────────────────────────────────────────────────────────
  // RESEND LOGIN OTP  →  POST /resend-otp
  // Body: { mobileNumber }
  // Updates _loginToken with the freshly issued token
  // ─────────────────────────────────────────────────────────────
  Future<bool> resendOtp() async {
    if (_mobileNumber == null) {
      _setError('Mobile number not found. Please login again.');
      return false;
    }

    _setLoading();
    try {
      final response = await _service.resendOtp(
        mobileNumber: _mobileNumber!,
      );

      if (response != null && response.success) {
        _loginToken = response.token; // refresh token
        _setSuccess(response.message);
        return true;
      } else {
        _setError('Failed to resend OTP. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

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
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // Load saved vendor on app start
  Future<void> loadSavedVendor() async {
    _vendorData = await SharedPreferenceHelper.getVendorData();
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