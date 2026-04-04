
class UnknownUserDetection {
  final bool enabled;
  final String detectionInterval;
  final DateTime? lastDetection;
  final bool hasUnknownUser;
  final int unknownCount;
  final List<dynamic> unknownUsers;
  final int registeredUsersCount;
  final String voiceMessage;
  final String statusText;

  UnknownUserDetection({
    required this.enabled,
    required this.detectionInterval,
    this.lastDetection,
    required this.hasUnknownUser,
    required this.unknownCount,
    required this.unknownUsers,
    required this.registeredUsersCount,
    required this.voiceMessage,
    required this.statusText,
  });

  factory UnknownUserDetection.fromJson(Map<String, dynamic> json) {
    return UnknownUserDetection(
      enabled: json['enabled'] ?? false,
      detectionInterval: json['detectionInterval'] ?? '',
      lastDetection: json['lastDetection'] != null
          ? DateTime.tryParse(json['lastDetection'])
          : null,
      hasUnknownUser: json['hasUnknownUser'] ?? false,
      unknownCount: json['unknownCount'] ?? 0,
      unknownUsers: json['unknownUsers'] ?? [],
      registeredUsersCount: json['registeredUsersCount'] ?? 0,
      voiceMessage: json['voiceMessage'] ?? '',
      statusText: json['statusText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'detectionInterval': detectionInterval,
      'lastDetection': lastDetection?.toIso8601String(),
      'hasUnknownUser': hasUnknownUser,
      'unknownCount': unknownCount,
      'unknownUsers': unknownUsers,
      'registeredUsersCount': registeredUsersCount,
      'voiceMessage': voiceMessage,
      'statusText': statusText,
    };
  }
}

class LiveStreamModel {
  final bool success;
  final bool isStreaming;
  final String cameraStatus;
  final String liveStreamUrl;
  final String message;
  final String channel;
  final UnknownUserDetection unknownUserDetection;

  LiveStreamModel({
    required this.success,
    required this.isStreaming,
    required this.cameraStatus,
    required this.liveStreamUrl,
    required this.message,
    required this.channel,
    required this.unknownUserDetection,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      success: json['success'] ?? false,
      isStreaming: json['isStreaming'] ?? false,
      cameraStatus: json['cameraStatus'] ?? '',
      liveStreamUrl: json['liveStreamUrl'] ?? '',
      message: json['message'] ?? '',
      channel: json['channel']?.toString() ?? '',
      unknownUserDetection: UnknownUserDetection.fromJson(
        json['unknownUserDetection'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'isStreaming': isStreaming,
      'cameraStatus': cameraStatus,
      'liveStreamUrl': liveStreamUrl,
      'message': message,
      'channel': channel,
      'unknownUserDetection': unknownUserDetection.toJson(),
    };
  }

  /// Replaces localhost URL with the actual server IP for device access
  String get resolvedStreamUrl {
    return liveStreamUrl.replaceAll(
      'http://localhost:2003',
      'http://31.97.206.144:2003',
    );
  }

  bool get isCameraActive => cameraStatus == 'active';
}

class StreamToggleModel {
  final bool success;
  final String message;

  StreamToggleModel({
    required this.success,
    required this.message,
  });

  factory StreamToggleModel.fromJson(Map<String, dynamic> json) {
    return StreamToggleModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}