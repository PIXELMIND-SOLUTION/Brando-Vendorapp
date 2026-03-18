import 'dart:convert';
import 'dart:io';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/vendor_model.dart';
import 'package:http/http.dart' as http;

class VendorService {
  Future<VendorModel?> registerVendor({
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

      print('Response status code vendor registration ${response.statusCode}');
      print(
        'Response bodyyyyyyyyyyyyyyyyyy vendor registration ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return VendorModel.fromJson(json['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login - Send OTP
  Future<LoginResponseModel?> login(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      print(
        'Response status code vendor loginnnnnnnnnnn ${response.statusCode}',
      );
      print(
        'Response bodyyyyyyyyyyyyyyyyyy vendor loginnnnnnnnnnnnnn ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return LoginResponseModel.fromJson(json);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Verify OTP
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

      print(
        'Response status code vendor verifyyyyyyyyyyyy otpppppppppppp ${response.statusCode}',
      );
      print(
        'Response bodyyyyyyyyyyyyyyyyyy vendor otppppppppppppp ${response.body}',
      );

      if (response.statusCode == 200) {
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
}
