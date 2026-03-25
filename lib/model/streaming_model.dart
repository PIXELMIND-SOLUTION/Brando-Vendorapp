// ─────────────────────────────────────────────
// camera_info_model.dart
// ─────────────────────────────────────────────

class CameraInfo {
  final String id;
  final String name;

  CameraInfo({required this.id, required this.name});

  factory CameraInfo.fromJson(Map<String, dynamic> json) {
    return CameraInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

// ─────────────────────────────────────────────
// start_streaming_response_model.dart
// ─────────────────────────────────────────────

class StartStreamingResponseModel {
  final bool success;
  final String message;
  final CameraInfo camera;
  final String streamUrl;
  final String mode;
  final String note;

  StartStreamingResponseModel({
    required this.success,
    required this.message,
    required this.camera,
    required this.streamUrl,
    required this.mode,
    required this.note,
  });

  factory StartStreamingResponseModel.fromJson(Map<String, dynamic> json) {
    return StartStreamingResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      camera: CameraInfo.fromJson(json['camera'] ?? {}),
      streamUrl: json['streamUrl'] ?? '',
      mode: json['mode'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'camera': camera.toJson(),
        'streamUrl': streamUrl,
        'mode': mode,
        'note': note,
      };
}

// ─────────────────────────────────────────────
// stop_streaming_response_model.dart
// ─────────────────────────────────────────────

class StopStreamingResponseModel {
  final bool success;
  final String message;

  StopStreamingResponseModel({
    required this.success,
    required this.message,
  });

  factory StopStreamingResponseModel.fromJson(Map<String, dynamic> json) {
    return StopStreamingResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
      };
}

// ─────────────────────────────────────────────
// live_stream_model.dart
// ─────────────────────────────────────────────

class LiveStreamModel {
  final bool success;
  final String streamUrl;
  final String status;
  final String cameraId;
  final String hostelId;

  LiveStreamModel({
    required this.success,
    required this.streamUrl,
    required this.status,
    required this.cameraId,
    required this.hostelId,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      success: json['success'] ?? false,
      streamUrl: json['streamUrl'] ?? '',
      status: json['status'] ?? '',
      cameraId: json['cameraId'] ?? '',
      hostelId: json['hostelId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'streamUrl': streamUrl,
        'status': status,
        'cameraId': cameraId,
        'hostelId': hostelId,
      };
}

// ─────────────────────────────────────────────
// unknown_visitor_model.dart
// ─────────────────────────────────────────────

class UnknownVisitor {
  final String id;
  final String hostelId;
  final String cameraId;
  final String imageUrl;
  final String detectedAt;
  final String status;

  UnknownVisitor({
    required this.id,
    required this.hostelId,
    required this.cameraId,
    required this.imageUrl,
    required this.detectedAt,
    required this.status,
  });

  factory UnknownVisitor.fromJson(Map<String, dynamic> json) {
    return UnknownVisitor(
      id: json['_id'] ?? json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      cameraId: json['cameraId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      detectedAt: json['detectedAt'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hostelId': hostelId,
        'cameraId': cameraId,
        'imageUrl': imageUrl,
        'detectedAt': detectedAt,
        'status': status,
      };
}

class UnknownVisitorsResponseModel {
  final bool success;
  final List<UnknownVisitor> visitors;
  final int total;

  UnknownVisitorsResponseModel({
    required this.success,
    required this.visitors,
    required this.total,
  });

  factory UnknownVisitorsResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['visitors'] ?? json['data'] ?? [];
    return UnknownVisitorsResponseModel(
      success: json['success'] ?? false,
      visitors: rawList.map((e) => UnknownVisitor.fromJson(e)).toList(),
      total: json['total'] ?? rawList.length,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'visitors': visitors.map((v) => v.toJson()).toList(),
        'total': total,
      };
}