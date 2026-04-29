import 'dart:convert';
import 'dart:io';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/vendor_model.dart';
import 'package:http/http.dart' as http;

class VendorService {
  Future<RegisterResponseModel?> registerVendor({
    required String name,
    required String mobileNumber,
    required String email,
    required File hostelImage,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.register),
      );

      request.fields['name'] = name;
      request.fields['mobileNumber'] = mobileNumber;
      request.fields['email'] = email;

      request.files.add(
        await http.MultipartFile.fromPath('hostelImage', hostelImage.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Register status: ${response.statusCode}');
      print('Register body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return RegisterResponseModel.fromJson(json);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VERIFY REGISTRATION OTP  →  POST /verify-registration-otp
  // Body: { token, otp }
  // ─────────────────────────────────────────────────────────────
  Future<VerifyRegistrationOtpResponseModel?> verifyRegistrationOtp({
    required String token,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.verifyRegistrationOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'otp': otp}),
      );

      print('Verify Registration OTP status: ${response.statusCode}');
      print('Verify Registration OTP body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return VerifyRegistrationOtpResponseModel.fromJson(json);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Registration OTP verification failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // RESEND REGISTRATION OTP  →  POST /resend-registration-otp
  // Body: { mobileNumber }
  // ─────────────────────────────────────────────────────────────
  Future<ResendOtpResponseModel?> resendRegistrationOtp({
    required String mobileNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.resendRegistrationOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      print('Resend Registration OTP status: ${response.statusCode}');
      print('Resend Registration OTP body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return ResendOtpResponseModel.fromJson(json);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Resend registration OTP failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN  →  POST /login
  // Body: { mobileNumber }  — sends login OTP
  // ─────────────────────────────────────────────────────────────
  // Future<LoginResponseModel?> login(String mobileNumber) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(ApiConstant.login),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'mobileNumber': mobileNumber}),
  //     );

  //     print('Login status: ${response.statusCode}');
  //     print('Login body: ${response.body}');

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final json = jsonDecode(response.body);
  //       if (json['success'] == true) {
  //         return LoginResponseModel.fromJson(json);
  //       }
  //     }
  //     return null;
  //   } catch (e) {
  //     throw Exception('Login failed: $e');
  //   }
  // }

  // In VendorService.dart - Update the login method

  Future<LoginResponseModel?> login(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      print('Login status: ${response.statusCode}');
      print('Login body: ${response.body}');

      // Try to parse the response regardless of status code
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 403) {
        // Add 403 as acceptable status
        final json = jsonDecode(response.body);
        return LoginResponseModel.fromJson(json);
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VERIFY LOGIN OTP  →  POST /verify-otp
  // Body: { mobileNumber, token, otp }
  // ─────────────────────────────────────────────────────────────
  Future<VerifyOtpResponseModel?> verifyOtp({
    required String mobileNumber,
    required String token,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
          'token': token,
          'otp': otp,
        }),
      );

      print('Verify OTP status: ${response.statusCode}');
      print('Verify OTP body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return VerifyOtpResponseModel.fromJson(json);
        }
      }
      return null;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // RESEND LOGIN OTP  →  POST /resend-otp
  // Body: { mobileNumber }
  // ─────────────────────────────────────────────────────────────
  Future<ResendOtpResponseModel?> resendOtp({
    required String mobileNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.resendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      print('Resend OTP status: ${response.statusCode}');
      print('Resend OTP body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return ResendOtpResponseModel.fromJson(json);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Resend OTP failed: $e');
    }
  }
}
