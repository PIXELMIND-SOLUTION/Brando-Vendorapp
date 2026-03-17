import 'dart:convert';
import 'dart:io';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/create_hostel_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class HostelService {
  Future<CreateHostelResponse> createHostel(HostelRequest request) async {
    final uri = Uri.parse(ApiConstant.createHostel);
    final multipartRequest = http.MultipartRequest('POST', uri);

    multipartRequest.fields.addAll(request.toFormFields());

    await _attachImages(multipartRequest, request.imagePaths);

    final streamedResponse = await multipartRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    _assertSuccess(response, 'createHostel');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CreateHostelResponse.fromJson(json);
  }

  // ── Update Hostel ──────────────────────────────────────────────────────
  Future<CreateHostelResponse> updateHostel({
    required String hostelId,
    required HostelRequest request,
  }) async {
    final uri = Uri.parse(ApiConstant.updateHostel(hostelId));
    final multipartRequest = http.MultipartRequest('PUT', uri);

    multipartRequest.fields.addAll(request.toFormFields());

    await _attachImages(multipartRequest, request.imagePaths);

    final streamedResponse = await multipartRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    _assertSuccess(response, 'updateHostel');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CreateHostelResponse.fromJson(json);
  }

  // ── Get Hostels by Vendor ──────────────────────────────────────────────
  Future<GetHostelsByVendorResponse> getHostelsByVendor(String vendorId) async {
    final uri = Uri.parse(ApiConstant.gethostelbyvendor(vendorId));
    final response = await http.get(uri, headers: _jsonHeaders());

    _assertSuccess(response, 'getHostelsByVendor');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GetHostelsByVendorResponse.fromJson(json);
  }

  // ── Private Helpers ────────────────────────────────────────────────────

  /// Attaches image files to a multipart request.
  Future<void> _attachImages(
    http.MultipartRequest request,
    List<String> imagePaths,
  ) async {
    for (final path in imagePaths) {
      final file = File(path);
      if (!await file.exists()) continue;

      final mimeType = _mimeTypeFromPath(path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }
  }

  Map<String, String> _jsonHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  void _assertSuccess(http.Response response, String caller) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['message'] as String? ?? message;
      } catch (_) {}
      throw HostelServiceException(
        message: '[$caller] $message',
        statusCode: response.statusCode,
      );
    }
  }

  String _mimeTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'avif': 'image/avif',
      'webp': 'image/webp',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}

// ── Custom exception ───────────────────────────────────────────────────────
class HostelServiceException implements Exception {
  final String message;
  final int statusCode;

  const HostelServiceException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'HostelServiceException($statusCode): $message';
}