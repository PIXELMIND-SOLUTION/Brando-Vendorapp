import 'dart:convert';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/streaming_model.dart';
import 'package:http/http.dart' as http;

class StreamService {
  Future<LiveStreamModel> getLiveStream({
    required String hostelId,
    required String cameraId,
    required String token,
  }) async {
    final url = ApiConstant.getLiveStream(hostelId, cameraId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _buildHeaders(token),
      );

      final data = jsonDecode(response.body);


      print('Response status code for get live streaming ${response.statusCode}');
            print('Response  bodyyyyyyyyy for get live streaming ${response.body}');


      if (response.statusCode == 200) {
        return LiveStreamModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch live stream');
      }
    } catch (e) {
      throw Exception('getLiveStream error: $e');
    }
  }

  /// Starts the stream for a specific camera.
  Future<StreamToggleModel> startStreaming({
    required String hostelId,
    required String cameraId,
    required String token,
  }) async {
    final url = ApiConstant.startStreaming(hostelId, cameraId);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _buildHeaders(token),
      );

      final data = jsonDecode(response.body);

        print('Response status code for starttttttttt streaming ${response.statusCode}');
            print('Response  bodyyyyyyyyy for starrttytyt live streaming ${response.body}');

      if (response.statusCode == 200) {
        return StreamToggleModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to start streaming');
      }
    } catch (e) {
      throw Exception('startStreaming error: $e');
    }
  }

  /// Stops the stream for a specific camera.
  Future<StreamToggleModel> stopStreaming({
    required String hostelId,
    required String cameraId,
    required String token,
  }) async {
    final url = ApiConstant.stopStreaming(hostelId, cameraId);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _buildHeaders(token),
      );

      final data = jsonDecode(response.body);


      print('Response status code for stooooooop streaming ${response.statusCode}');
            print('Response  bodyyyyyyyyy for stoooooop live streaming ${response.body}');

      if (response.statusCode == 200) {
        return StreamToggleModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to stop streaming');
      }
    } catch (e) {
      throw Exception('stopStreaming error: $e');
    }
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}