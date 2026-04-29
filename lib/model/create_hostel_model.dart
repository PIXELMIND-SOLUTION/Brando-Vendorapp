import 'dart:convert';

class SharingOption {
  final String shareType;
  final String? type;

  final double? monthlyPrice;
  final double? dailyPrice;

  final double? acMonthlyPrice;
  final double? acDailyPrice;
  final double? nonAcMonthlyPrice;
  final double? nonAcDailyPrice;

  const SharingOption({
    required this.shareType,
    this.type,
    this.monthlyPrice,
    this.dailyPrice,
    this.acMonthlyPrice,
    this.acDailyPrice,
    this.nonAcMonthlyPrice,
    this.nonAcDailyPrice,
  });

  factory SharingOption.fromJson(Map<String, dynamic> json) {
    return SharingOption(
      shareType: json['shareType'] as String? ?? '',
      type: json['type'] as String?,
      monthlyPrice: _toDouble(json['monthlyPrice']),
      dailyPrice: _toDouble(json['dailyPrice']),
      acMonthlyPrice: _toDouble(json['acMonthlyPrice']),
      acDailyPrice: _toDouble(json['acDailyPrice']),
      nonAcMonthlyPrice: _toDouble(json['nonAcMonthlyPrice']),
      nonAcDailyPrice: _toDouble(json['nonAcDailyPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      'shareType': shareType,
      if (monthlyPrice != null) 'monthlyPrice': monthlyPrice,
      if (dailyPrice != null) 'dailyPrice': dailyPrice,
      if (acMonthlyPrice != null) 'acMonthlyPrice': acMonthlyPrice,
      if (acDailyPrice != null) 'acDailyPrice': acDailyPrice,
      if (nonAcMonthlyPrice != null) 'nonAcMonthlyPrice': nonAcMonthlyPrice,
      if (nonAcDailyPrice != null) 'nonAcDailyPrice': nonAcDailyPrice,
    };
  }
}

// ── Rooms wrapper ──────────────────────────────────────────────────────────
class HostelRooms {
  final List<SharingOption> ac;
  final List<SharingOption> nonAc;

  const HostelRooms({required this.ac, required this.nonAc});

  factory HostelRooms.fromJson(Map<String, dynamic> json) {
    return HostelRooms(
      ac: _parseSharings(json['ac']),
      nonAc: _parseSharings(json['nonAc']),
    );
  }

  Map<String, dynamic> toJson() => {
    'ac': ac.map((e) => e.toJson()).toList(),
    'nonAc': nonAc.map((e) => e.toJson()).toList(),
  };
}

// ── Main Hostel model ──────────────────────────────────────────────────────
class Hostel {
  final String id;
  final String? categoryId;
  final String? adminId;
  final String? vendorId;
  final String name;
  final double rating;
  final String address;
  final double monthlyAdvance;
  final double latitude;
  final double longitude;
  final List<String> type;
  final List<SharingOption> sharings;
  final HostelRooms? rooms;
  final List<String> images;
  final DateTime? createdAt;
  final String? qrUrl; // ← ADDED: from API response "qrUrl" field
  final String? categoryName;

  const Hostel({
    required this.id,
    this.categoryId,
    this.adminId,
    this.vendorId,
    required this.name,
    required this.rating,
    required this.address,
    required this.monthlyAdvance,
    required this.latitude,
    required this.longitude,
    this.type = const [],
    this.sharings = const [],
    this.rooms,
    this.images = const [],
    this.createdAt,
    this.qrUrl, // ← ADDED
    this.categoryName,
  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    return Hostel(
      id: json['_id'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      adminId: json['adminId'] as String?,
      vendorId: json['vendorId'] as String?,
      name: json['name'] as String? ?? '',
      rating: _toDouble(json['rating']) ?? 0.0,
      address: json['address'] as String? ?? '',
      monthlyAdvance: _toDouble(json['monthlyAdvance']) ?? 0.0,
      latitude: _toDouble(json['latitude']) ?? 0.0,
      longitude: _toDouble(json['longitude']) ?? 0.0,
      type: _parseStringList(json['type']),
      sharings: _parseSharings(json['sharings']),
      rooms: json['rooms'] != null
          ? HostelRooms.fromJson(json['rooms'] as Map<String, dynamic>)
          : null,
      images: _parseStringList(json['images']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      qrUrl: json['qrUrl'] as String?, // ← ADDED
      categoryName: json['categoryName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    if (categoryId != null) 'categoryId': categoryId,
    if (adminId != null) 'adminId': adminId,
    if (vendorId != null) 'vendorId': vendorId,
    'name': name,
    'rating': rating,
    'address': address,
    'monthlyAdvance': monthlyAdvance,
    'latitude': latitude,
    'longitude': longitude,
    if (type.isNotEmpty) 'type': type,
    if (sharings.isNotEmpty)
      'sharings': sharings.map((e) => e.toJson()).toList(),
    if (rooms != null) 'rooms': rooms!.toJson(),
    'images': images,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (qrUrl != null) 'qrUrl': qrUrl, // ← ADDED
  };

  Hostel copyWith({
    String? id,
    String? categoryId,
    String? adminId,
    String? vendorId,
    String? name,
    double? rating,
    String? address,
    double? monthlyAdvance,
    double? latitude,
    double? longitude,
    List<String>? type,
    List<SharingOption>? sharings,
    HostelRooms? rooms,
    List<String>? images,
    DateTime? createdAt,
    String? qrUrl, // ← ADDED
  }) {
    return Hostel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      adminId: adminId ?? this.adminId,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      address: address ?? this.address,
      monthlyAdvance: monthlyAdvance ?? this.monthlyAdvance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      sharings: sharings ?? this.sharings,
      rooms: rooms ?? this.rooms,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      qrUrl: qrUrl ?? this.qrUrl, // ← ADDED
    );
  }
}

// ── Request model ──────────────────────────────────────────────────────────
class HostelRequest {
  final String categoryId;
  final String? vendorId;
  final String name;
  final double rating;
  final String address;
  final double monthlyAdvance;
  final double latitude;
  final double longitude;
  final bool isAc;
  final List<SharingOption> sharings;
  final List<String> imagePaths;

  const HostelRequest({
    required this.categoryId,
    this.vendorId,
    required this.name,
    required this.rating,
    required this.address,
    required this.monthlyAdvance,
    required this.latitude,
    required this.longitude,
    required this.isAc,
    required this.sharings,
    this.imagePaths = const [],
  });

  Map<String, String> toFormFields() {
    final typeValue = isAc ? 'AC' : 'Non-AC';

    return {
      if (categoryId != null) 'categoryId': categoryId!,
      if (vendorId != null) 'vendorId': vendorId!,
      'name': name,
      'rating': rating.toString(),
      'address': address,
      'monthlyAdvance': monthlyAdvance.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'type': jsonEncode([typeValue]),
      'sharings': _sharingListToJsonString(sharings),
    };
  }
}

// ── Response wrappers ──────────────────────────────────────────────────────
class CreateHostelResponse {
  final bool success;
  final String message;
  final Hostel hostel;

  const CreateHostelResponse({
    required this.success,
    required this.message,
    required this.hostel,
  });

  factory CreateHostelResponse.fromJson(Map<String, dynamic> json) {
    return CreateHostelResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      hostel: Hostel.fromJson(json['hostel'] as Map<String, dynamic>),
    );
  }
}

class GetHostelsByVendorResponse {
  final bool success;
  final int count;
  final List<Hostel> hostels;

  const GetHostelsByVendorResponse({
    required this.success,
    required this.count,
    required this.hostels,
  });

  factory GetHostelsByVendorResponse.fromJson(Map<String, dynamic> json) {
    return GetHostelsByVendorResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      hostels: _parseHostelList(json['hostels']),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

List<SharingOption> _parseSharings(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map((e) => SharingOption.fromJson(e))
        .toList();
  }
  return [];
}

List<Hostel> _parseHostelList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map((e) => Hostel.fromJson(e))
        .toList();
  }
  return [];
}

String _sharingListToJsonString(List<SharingOption> sharings) {
  final list = sharings.map((s) {
    final map = <String, dynamic>{};

    if (s.type != null) map['type'] = s.type;
    map['shareType'] = s.shareType;

    if (s.monthlyPrice != null) map['monthlyPrice'] = s.monthlyPrice;
    if (s.dailyPrice != null) map['dailyPrice'] = s.dailyPrice;

    if (s.acMonthlyPrice != null) map['acMonthlyPrice'] = s.acMonthlyPrice;
    if (s.acDailyPrice != null) map['acDailyPrice'] = s.acDailyPrice;
    if (s.nonAcMonthlyPrice != null)
      map['nonAcMonthlyPrice'] = s.nonAcMonthlyPrice;
    if (s.nonAcDailyPrice != null) map['nonAcDailyPrice'] = s.nonAcDailyPrice;

    return map;
  }).toList();

  return jsonEncode(list);
}
