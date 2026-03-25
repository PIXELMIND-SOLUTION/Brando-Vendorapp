import 'dart:convert';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/camera_model.dart';
import 'package:http/http.dart' as http;

class CameraService {
  Future<CameraResponse> addCamera({
    required String hostelId,
    required CameraPayload payload,
  }) async {
    try {
      final uri = Uri.parse(ApiConstant.addCamera(hostelId));
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload.toJson()),
      );

      print('Status Code for adding camera: ${response.statusCode}');

      // ✅ Print response body
      print('Response Body for adding cameraaaaaaaaaaa: ${response.body}');

      return _handleCameraResponse(response);
    } catch (e) {
      throw Exception('Failed to add camera: $e');
    }
  }

  // Get All Hostel Cameras
  Future<List<CameraModel>> getAllHostelCameras(String hostelId) async {
    try {
      final uri = Uri.parse(ApiConstant.getAllHostelCameras(hostelId));
      final response = await http.get(uri, headers: _headers());

      print(
        'Response status code for get alll camerassssssss ${response.statusCode}',
      );
      print(
        'Response bodddddddyyyyyyyyyyyy for get alll camerassssssss ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List cameras = data['cameras'] ?? data['data'] ?? [];
        return cameras.map((e) => CameraModel.fromJson(e)).toList();
      } else {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch cameras: $e');
    }
  }

  // Get Single Camera
  Future<CameraModel> getSingleCamera({
    required String hostelId,
    required String cameraId,
  }) async {
    try {
      final uri = Uri.parse(ApiConstant.getSingleCamera(hostelId, cameraId));
      final response = await http.get(uri, headers: _headers());

      print(
        'Response status code for get singleeeeeeeeeeeeeee camerassssssss ${response.statusCode}',
      );
      print(
        'Response bodddddddyyyyyyyyyyyy for get singleeeeeeeeeeee camerassssssss ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CameraModel.fromJson(data['camera'] ?? data);
      } else {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch camera: $e');
    }
  }

  // Update Camera
  Future<CameraResponse> updateCamera({
    required String hostelId,
    required String cameraId,
    required CameraPayload payload,
  }) async {
    try {
      final uri = Uri.parse(ApiConstant.updateCamera(hostelId, cameraId));
      final response = await http.put(
        uri,
        headers: _headers(),
        body: jsonEncode(payload.toJson()),
      );

      print(
        'Response status code for update camera details ${response.statusCode}',
      );
      print(
        'Response bodyyyyyyyyyyyy for update camera details ${response.body}',
      );

      return _handleCameraResponse(response);
    } catch (e) {
      throw Exception('Failed to update camera: $e');
    }
  }

  // Delete Camera
  Future<bool> deleteCamera({
    required String hostelId,
    required String cameraId,
  }) async {
    try {
      final uri = Uri.parse(ApiConstant.deleteCamera(hostelId, cameraId));
      final response = await http.delete(uri, headers: _headers());

      print(
        'Response status code for deleteeeeeeeeeeeeeee camerassssssss ${response.statusCode}',
      );
      print(
        'Response bodddddddyyyyyyyyyyyy for deeeeeeeeeeeeeeeeeeeelete  camerassssssss ${response.body}',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('Failed to delete camera: $e');
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  CameraResponse _handleCameraResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CameraResponse.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }

  String _extractError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Error ${response.statusCode}';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }
}
