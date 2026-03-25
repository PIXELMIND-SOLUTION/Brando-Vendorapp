class CameraModel {
  final String cameraId;
  final String name;
  final String ipAddress;
  final int port;
  final String username;
  final String password;
  final String location;
  final String streamUrl;
  final String status;
  final String id;
  final DateTime createdAt;

  CameraModel({
    required this.cameraId,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.username,
    required this.password,
    required this.location,
    required this.streamUrl,
    required this.status,
    required this.id,
    required this.createdAt,
  });

  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(
      cameraId: json['cameraId'] ?? '',
      name: json['name'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      port: json['port'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      location: json['location'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
      status: json['status'] ?? 'inactive',
      id: json['_id'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'username': username,
      'password': password,
      'location': location,
    };
  }

  CameraModel copyWith({
    String? cameraId,
    String? name,
    String? ipAddress,
    int? port,
    String? username,
    String? password,
    String? location,
    String? streamUrl,
    String? status,
    String? id,
    DateTime? createdAt,
  }) {
    return CameraModel(
      cameraId: cameraId ?? this.cameraId,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      location: location ?? this.location,
      streamUrl: streamUrl ?? this.streamUrl,
      status: status ?? this.status,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Request payload model
class CameraPayload {
  final String name;
  final String ipAddress;
  final int port;
  final String username;
  final String password;
  final String location;

  CameraPayload({
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.username,
    required this.password,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'username': username,
      'password': password,
      'location': location,
    };
  }
}

// API response wrapper
class CameraResponse {
  final bool success;
  final String message;
  final CameraModel? camera;

  CameraResponse({
    required this.success,
    required this.message,
    this.camera,
  });

  factory CameraResponse.fromJson(Map<String, dynamic> json) {
    return CameraResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      camera: json['camera'] != null
          ? CameraModel.fromJson(json['camera'])
          : null,
    );
  }
}