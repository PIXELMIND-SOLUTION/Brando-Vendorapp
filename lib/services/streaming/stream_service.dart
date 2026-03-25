import 'dart:convert';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/streaming_model.dart';
import 'package:http/http.dart' as http;

class CameraStreamingService {
  // ── Shared headers ──────────────────────────────────────────────────────────
  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<StartStreamingResponseModel> startStreaming({
    required String hostelId,
    required String cameraId,
    String? token,
  }) async {
    final url = Uri.parse(ApiConstant.startStreaming(hostelId, cameraId));

    try {
      final response = await http.post(
        url,
        headers: _headers(token: token),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StartStreamingResponseModel.fromJson(json);
      } else {
        throw Exception(
          json['message'] ?? 'Failed to start streaming (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Start streaming error: $e');
    }
  }


  Future<StopStreamingResponseModel> stopStreaming({
    required String hostelId,
    required String cameraId,
    String? token,
  }) async {
    final url = Uri.parse(ApiConstant.stopStreaming(hostelId, cameraId));

    try {
      final response = await http.post(
        url,
        headers: _headers(token: token),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StopStreamingResponseModel.fromJson(json);
      } else {
        throw Exception(
          json['message'] ?? 'Failed to stop streaming (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Stop streaming error: $e');
    }
  }


  Future<LiveStreamModel> getLiveStream({
    required String hostelId,
    required String cameraId,
    String? token,
  }) async {
    final url = Uri.parse(ApiConstant.getLiveStream(hostelId, cameraId));

    try {
      final response = await http.get(
        url,
        headers: _headers(token: token),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LiveStreamModel.fromJson(json);
      } else {
        throw Exception(
          json['message'] ?? 'Failed to get live stream (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Get live stream error: $e');
    }
  }


  Future<UnknownVisitorsResponseModel> getUnknownVisitors({
    required String hostelId,
    String? token,
  }) async {
    final url = Uri.parse(ApiConstant.getUnknownVisitors(hostelId));

    try {
      final response = await http.get(
        url,
        headers: _headers(token: token),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return UnknownVisitorsResponseModel.fromJson(json);
      } else {
        throw Exception(
          json['message'] ??
              'Failed to get unknown visitors (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Get unknown visitors error: $e');
    }
  }
}