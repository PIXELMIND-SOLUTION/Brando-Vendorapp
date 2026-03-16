import 'dart:convert';
import 'dart:io';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/profile_model.dart';
import 'package:http/http.dart' as http;

class VendorProfileService {
  // GET vendor profile by vendorId
  Future<VendorProfileModel> getVendorProfile(String vendorId) async {
    try {
      final uri = Uri.parse('${ApiConstant.profile}/$vendorId');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      print('Response status code for get profile ${response.statusCode}');
      print('Response status bodyyyyyyyyyyy for get profile ${response.body}');

      if (response.statusCode == 200 && responseBody['success'] == true) {
        return VendorProfileModel.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to fetch profile');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<VendorProfileModel> updateVendorProfile({
    required String vendorId,
    required String name,
    required String email,
    File? hostelImage,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstant.updateProfile}/$vendorId');

      final request = http.MultipartRequest('PUT', uri);

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;

      if (hostelImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('hostelImage', hostelImage.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      print(
        'Response status code for updateeeeeeeeeeee profile ${response.statusCode}',
      );
      print(
        'Response status bodyyyyyyyyyyy for updaaaaaaaaaaaaaaateeeeeeeeee profile ${response.body}',
      );

      if (response.statusCode == 200 && responseBody['success'] == true) {
        return VendorProfileModel.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to update profile');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
