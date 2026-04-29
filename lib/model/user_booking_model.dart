// class BookingUserModel {
//   final String id;
//   final int mobileNumber;
//   final String name;

//   BookingUserModel({
//     required this.id,
//     required this.mobileNumber,
//     required this.name,
//   });

//   factory BookingUserModel.fromJson(Map<String, dynamic> json) {
//     return BookingUserModel(
//       id: json['_id'] ?? '',
//       mobileNumber: json['mobileNumber'] ?? 0,
//       name: json['name'] ?? 'Unknown User',
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'mobileNumber': mobileNumber,
//         'name': name,
//       };
// }

// class BookingHostelModel {
//   final String id;
//   final String name;
//   final String address;

//   BookingHostelModel({
//     required this.id,
//     required this.name,
//     required this.address,
//   });

//   factory BookingHostelModel.fromJson(Map<String, dynamic> json) {
//     return BookingHostelModel(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       address: json['address'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'name': name,
//         'address': address,
//       };
// }

// class BookingRequestModel {
//   final String id;
//   final BookingUserModel user;
//   final BookingHostelModel hostel;
//   final String status;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   BookingRequestModel({
//     required this.id,
//     required this.user,
//     required this.hostel,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
//     // userId can be a populated object (on fetch) or a plain string (after update)
//     BookingUserModel user;
//     final userId = json['userId'];
//     if (userId is Map<String, dynamic>) {
//       user = BookingUserModel.fromJson(userId);
//     } else {
//       user = BookingUserModel(
//         id: userId?.toString() ?? '',
//         mobileNumber: 0,
//         name: 'Unknown User',
//       );
//     }

//     // hostelId can be a populated object or a plain string
//     BookingHostelModel hostel;
//     final hostelId = json['hostelId'];
//     if (hostelId is Map<String, dynamic>) {
//       hostel = BookingHostelModel.fromJson(hostelId);
//     } else {
//       hostel = BookingHostelModel(
//         id: hostelId?.toString() ?? '',
//         name: '',
//         address: '',
//       );
//     }

//     return BookingRequestModel(
//       id: json['_id'] ?? '',
//       user: user,
//       hostel: hostel,
//       status: json['status'] ?? '',
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//     );
//   }

//   BookingRequestModel copyWith({
//     String? id,
//     BookingUserModel? user,
//     BookingHostelModel? hostel,
//     String? status,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return BookingRequestModel(
//       id: id ?? this.id,
//       user: user ?? this.user,
//       hostel: hostel ?? this.hostel,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'userId': user.toJson(),
//         'hostelId': hostel.toJson(),
//         'status': status,
//         'createdAt': createdAt.toIso8601String(),
//         'updatedAt': updatedAt.toIso8601String(),
//       };
// }

import 'dart:ui';

class BookingUserModel {
  final String id;
  final int mobileNumber;
  final String name;

  BookingUserModel({
    required this.id,
    required this.mobileNumber,
    required this.name,
  });

  factory BookingUserModel.fromJson(Map<String, dynamic> json) {
    return BookingUserModel(
      id: json['_id'] ?? '',
      mobileNumber: json['mobileNumber'] ?? 0,
      name: json['name'] ?? 'Unknown User',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'mobileNumber': mobileNumber,
    'name': name,
  };
}

class BookingHostelModel {
  final String id;
  final String name;
  final String address;
  final String? roomType;
  final String? shareType;

  BookingHostelModel({
    required this.id,
    required this.name,
    required this.address,
    this.roomType,
    this.shareType,
  });

  factory BookingHostelModel.fromJson(Map<String, dynamic> json) {
    return BookingHostelModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      roomType: json['roomType'],
      shareType: json['shareType'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'address': address,
    if (roomType != null) 'roomType': roomType,
    if (shareType != null) 'shareType': shareType,
  };
}

class BookingRequestModel {
  final String id;
  final BookingUserModel user;
  final BookingHostelModel hostel;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String bookingReference;
  final String roomType;
  final String? roomNo;
  final String shareType;
  final String bookingType;
  final DateTime startDate;
  final int totalAmount;
  final int monthlyAdvance;
  final String? isTrue;

  BookingRequestModel({
    required this.id,
    this.roomNo,
    required this.user,
    required this.hostel,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.bookingReference,
    required this.roomType,
    required this.shareType,
    required this.bookingType,
    required this.startDate,
    required this.totalAmount,
    required this.monthlyAdvance,
    this.isTrue,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle userId - can be a populated object or just an ID
    BookingUserModel user;
    final userId = json['userId'];
    if (userId is Map<String, dynamic>) {
      user = BookingUserModel.fromJson(userId);
    } else {
      user = BookingUserModel(
        id: userId?.toString() ?? '',
        mobileNumber: 0,
        name: 'Unknown User',
      );
    }

    // Handle hostelId - can be a populated object or just an ID
    BookingHostelModel hostel;
    final hostelId = json['hostelId'];
    if (hostelId is Map<String, dynamic>) {
      hostel = BookingHostelModel.fromJson(hostelId);
    } else {
      hostel = BookingHostelModel(
        id: hostelId?.toString() ?? '',
        name: '',
        address: '',
      );
    }

    return BookingRequestModel(
      id: json['_id'] ?? '',
      user: user,
      roomNo: json['roomNo'] ?? '',
      hostel: hostel,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      bookingReference: json['bookingReference'] ?? '',
      roomType: json['roomType'] ?? '',
      shareType: json['shareType'] ?? '',
      bookingType: json['bookingType'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      totalAmount: json['totalAmount'] ?? 0,
      monthlyAdvance: json['monthlyAdvance'] ?? 0,
      isTrue: json['isTrue'],
    );
  }

  BookingRequestModel copyWith({
    String? id,
    BookingUserModel? user,
    BookingHostelModel? hostel,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bookingReference,
    String? roomType,
    String? shareType,
    String? bookingType,
    DateTime? startDate,
    int? totalAmount,
    int? monthlyAdvance,
    String? isTrue,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      user: user ?? this.user,
      hostel: hostel ?? this.hostel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookingReference: bookingReference ?? this.bookingReference,
      roomType: roomType ?? this.roomType,
      shareType: shareType ?? this.shareType,
      bookingType: bookingType ?? this.bookingType,
      startDate: startDate ?? this.startDate,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlyAdvance: monthlyAdvance ?? this.monthlyAdvance,
      isTrue: isTrue ?? this.isTrue,
    );
  }

  // Helper method to get display-friendly status
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'running':
        return 'Running';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Helper method to get status color
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'running':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF8B5CF6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': user.toJson(),
    'hostelId': hostel.toJson(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'bookingReference': bookingReference,
    'roomType': roomType,
    'shareType': shareType,
    'bookingType': bookingType,
    'startDate': startDate.toIso8601String(),
    'totalAmount': totalAmount,
    'monthlyAdvance': monthlyAdvance,
    if (isTrue != null) 'isTrue': isTrue,
  };
}
