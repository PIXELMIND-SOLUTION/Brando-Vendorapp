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

  SharingOption({
    required this.shareType,
    this.type,
    this.monthlyPrice,
    this.dailyPrice,
    this.acMonthlyPrice,
    this.acDailyPrice,
    this.nonAcMonthlyPrice,
    this.nonAcDailyPrice,
  });

  // Add fromJson if needed
  factory SharingOption.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String? ?? '').toUpperCase();
    final monthlyPrice = (json['monthlyPrice'] ?? 0).toDouble();
    final dailyPrice = (json['dailyPrice'] ?? 0).toDouble();
    final shareType = json['shareType'] ?? '';

    // Determine if this entry is AC or Non-AC
    final isAc = type == 'AC';
    final isNonAc = type == 'NON-AC';

    return SharingOption(
      shareType: shareType,
      type: type,
      monthlyPrice: monthlyPrice,
      dailyPrice: dailyPrice,
      // Set AC prices only if this is an AC entry
      acMonthlyPrice: isAc ? monthlyPrice : 0,
      acDailyPrice: isAc ? dailyPrice : 0,
      // Set Non-AC prices only if this is a Non-AC entry
      nonAcMonthlyPrice: isNonAc ? monthlyPrice : 0,
      nonAcDailyPrice: isNonAc ? dailyPrice : 0,
    );
  }

  // Add toJson if needed
  Map<String, dynamic> toJson() {
    return {
      'shareType': shareType,
      'type': type,
      'monthlyPrice': monthlyPrice?.toInt(),
      'dailyPrice': dailyPrice?.toInt(),
      'acMonthlyPrice': acMonthlyPrice?.toInt(),
      'acDailyPrice': acDailyPrice?.toInt(),
      'nonAcMonthlyPrice': nonAcMonthlyPrice?.toInt(),
      'nonAcDailyPrice': nonAcDailyPrice?.toInt(),
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

class Hostel {
  final String id;
  final String name;
  final double rating;
  final String address;
  final double monthlyAdvance;
  final double latitude;
  final double longitude;
  final List<SharingOption> sharings;
  final List<String> images;
  final String categoryId;
  final String? categoryName;
  final List<String> type;
  final List<String> features; // Add this
  final String furnishing; // Add this
  final String qrUrl; // Add if not present
  final HostelRooms? rooms;
  final List<String> roomNumbers;

  Hostel({
    required this.id,
    required this.name,
    required this.rating,
    required this.address,
    required this.monthlyAdvance,
    required this.latitude,
    required this.longitude,
    required this.sharings,
    required this.images,
    required this.categoryId,
    this.categoryName,
    this.type = const [],
    this.features = const [], // Default empty list
    this.furnishing = '', // Default empty string
    this.qrUrl = '',
    this.rooms,
    this.roomNumbers = const [], // Default empty list
  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    // Parse sharings
    final sharingsList = <SharingOption>[];
    if (json['sharings'] != null) {
      final rawSharings = json['sharings'] as List;
      for (final item in rawSharings) {
        sharingsList.add(SharingOption.fromJson(item));
      }
    }

    // Parse type (could be String or List)
    List<String> typeList = [];
    if (json['type'] != null) {
      if (json['type'] is String) {
        typeList = [json['type']];
      } else if (json['type'] is List) {
        typeList = List<String>.from(json['type']);
      }
    }

    // Parse roomNumbers
    List<String> roomNumbersList = [];
    if (json['roomNumbers'] != null) {
      if (json['roomNumbers'] is List) {
        roomNumbersList = List<String>.from(json['roomNumbers']);
      }
    }

    return Hostel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      monthlyAdvance: (json['monthlyAdvance'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      sharings: sharingsList,
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['categoryId'] ?? json['category']?['_id'] ?? '',
      categoryName: json['category']?['name'] ?? json['categoryName'],
      type: typeList,
      features: List<String>.from(json['features'] ?? []),
      furnishing: json['furnishing'] ?? '',
      qrUrl: json['qrUrl'] ?? '',
      rooms: json['rooms'] != null
          ? HostelRooms.fromJson(json['rooms'] as Map<String, dynamic>)
          : null,
      roomNumbers: roomNumbersList, // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'rating': rating,
      'address': address,
      'monthlyAdvance': monthlyAdvance,
      'latitude': latitude,
      'longitude': longitude,
      'sharings': sharings.map((s) => s.toJson()).toList(),
      'images': images,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'type': type,
      'features': features,
      'furnishing': furnishing,
      'qrUrl': qrUrl,
      'rooms': rooms,
    };
  }
}

// ── Request model ──────────────────────────────────────────────────────────
// class HostelRequest {
//   final String categoryId;
//   final String? vendorId;
//   final String name;
//   final double rating;
//   final String address;
//   final double monthlyAdvance;
//   final double latitude;
//   final double longitude;
//   final bool isAc;
//   final List<SharingOption> sharings;
//   final List<String> imagePaths;

//   const HostelRequest({
//     required this.categoryId,
//     this.vendorId,
//     required this.name,
//     required this.rating,
//     required this.address,
//     required this.monthlyAdvance,
//     required this.latitude,
//     required this.longitude,
//     required this.isAc,
//     required this.sharings,
//     this.imagePaths = const [],
//   });

//   Map<String, String> toFormFields() {
//     final typeValue = isAc ? 'AC' : 'Non-AC';

//     return {
//       if (categoryId != null) 'categoryId': categoryId!,
//       if (vendorId != null) 'vendorId': vendorId!,
//       'name': name,
//       'rating': rating.toString(),
//       'address': address,
//       'monthlyAdvance': monthlyAdvance.toString(),
//       'latitude': latitude.toString(),
//       'longitude': longitude.toString(),
//       'type': jsonEncode([typeValue]),
//       'sharings': _sharingListToJsonString(sharings),
//     };
//   }
// }

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
  final List<String> features;
  final String furnishing;
  final List<String> roomNumbers;

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
    this.features = const [],
    this.furnishing = '',
    this.roomNumbers = const [],
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
      'features': jsonEncode(features),
      'furnishing': furnishing,
      'roomNumbers': jsonEncode(roomNumbers), // Add this line
    };
  }

  String _sharingListToJsonString(List<SharingOption> sharings) {
    final List<Map<String, dynamic>> sharingMaps = [];

    for (final sharing in sharings) {
      sharingMaps.add({
        'shareType': sharing.shareType,
        'type': sharing.type,
        'monthlyPrice': sharing.monthlyPrice?.toInt() ?? 0,
        'dailyPrice': sharing.dailyPrice?.toInt() ?? 0,
        'acMonthlyPrice': sharing.acMonthlyPrice?.toInt() ?? 0,
        'acDailyPrice': sharing.acDailyPrice?.toInt() ?? 0,
        'nonAcMonthlyPrice': sharing.nonAcMonthlyPrice?.toInt() ?? 0,
        'nonAcDailyPrice': sharing.nonAcDailyPrice?.toInt() ?? 0,
      });
    }

    return jsonEncode(sharingMaps);
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
