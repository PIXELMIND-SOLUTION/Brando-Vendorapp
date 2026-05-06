// // lib/model/history_model.dart

// class HistoryResponse {
//   final bool success;
//   final int totalRooms;
//   final List<RoomBookingData> data;

//   HistoryResponse({
//     required this.success,
//     required this.totalRooms,
//     required this.data,
//   });

//   factory HistoryResponse.fromJson(Map<String, dynamic> json) {
//     return HistoryResponse(
//       success: json['success'] ?? false,
//       totalRooms: json['totalRooms'] ?? 0,
//       data:
//           (json['data'] as List?)
//               ?.map((e) => RoomBookingData.fromJson(e))
//               .toList() ??
//           [],
//     );
//   }
// }

// class RoomBookingData {
//   final String roomNo;
//   final int totalBookings;
//   final List<Booking> bookings;

//   RoomBookingData({
//     required this.roomNo,
//     required this.totalBookings,
//     required this.bookings,
//   });

//   factory RoomBookingData.fromJson(Map<String, dynamic> json) {
//     return RoomBookingData(
//       roomNo: json['roomNo'] ?? '',
//       totalBookings: json['totalBookings'] ?? 0,
//       bookings:
//           (json['bookings'] as List?)
//               ?.map((e) => Booking.fromJson(e))
//               .toList() ??
//           [],
//     );
//   }
// }

// class Booking {
//   final String id;
//   final HostelInfo? hostelId;
//   final UserInfo? userId;
//   final String roomType;
//   final String shareType;
//   final String isTrue;
//   final String roomNo;
//   final String bookingType;
//   final DateTime startDate;
//   final int totalAmount;
//   final int monthlyAdvance;
//   final String status;
//   final String bookingReference;
//   final String vendorId;
//   final List<dynamic> paymentHistory;
//   final List<dynamic> statusHistory;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Booking({
//     required this.id,
//     this.hostelId,
//     this.userId,
//     required this.roomType,
//     required this.shareType,
//     required this.isTrue,
//     required this.roomNo,
//     required this.bookingType,
//     required this.startDate,
//     required this.totalAmount,
//     required this.monthlyAdvance,
//     required this.status,
//     required this.bookingReference,
//     required this.vendorId,
//     required this.paymentHistory,
//     required this.statusHistory,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Booking.fromJson(Map<String, dynamic> json) {
//     return Booking(
//       id: json['_id'] ?? '',
//       hostelId: json['hostelId'] != null
//           ? HostelInfo.fromJson(json['hostelId'])
//           : null,
//       userId: json['userId'] != null ? UserInfo.fromJson(json['userId']) : null,
//       roomType: json['roomType'] ?? '',
//       shareType: json['shareType'] ?? '',
//       isTrue: json['isTrue'] ?? '',
//       roomNo: json['roomNo'] ?? '',
//       bookingType: json['bookingType'] ?? '',
//       startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
//       totalAmount: json['totalAmount'] ?? 0,
//       monthlyAdvance: json['monthlyAdvance'] ?? 0,
//       status: json['status'] ?? '',
//       bookingReference: json['bookingReference'] ?? '',
//       vendorId: json['vendorId'] ?? '',
//       paymentHistory: json['paymentHistory'] ?? [],
//       statusHistory: json['statusHistory'] ?? [],
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//     );
//   }
// }

// class HostelInfo {
//   final String id;
//   final String name;
//   final String address;

//   HostelInfo({required this.id, required this.name, required this.address});

//   factory HostelInfo.fromJson(Map<String, dynamic> json) {
//     return HostelInfo(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       address: json['address'] ?? '',
//     );
//   }
// }

// class UserInfo {
//   final String id;
//   final int mobileNumber;
//   final String name;

//   UserInfo({required this.id, required this.mobileNumber, required this.name});

//   factory UserInfo.fromJson(Map<String, dynamic> json) {
//     return UserInfo(
//       id: json['_id'] ?? '',
//       mobileNumber: json['mobileNumber'] ?? 0,
//       name: json['name'] ?? '',
//     );
//   }
// }

// lib/model/history_model.dart

class HistoryResponse {
  final bool success;
  final int totalRooms;
  final List<RoomBookingData> data;

  HistoryResponse({
    required this.success,
    required this.totalRooms,
    required this.data,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      success: json['success'] ?? false,
      totalRooms: json['totalRooms'] ?? 0,
      data:
          (json['data'] as List?)
              ?.map((e) => RoomBookingData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RoomBookingData {
  final String roomNo;
  final int totalBookings;
  final List<Booking> bookings;

  RoomBookingData({
    required this.roomNo,
    required this.totalBookings,
    required this.bookings,
  });

  factory RoomBookingData.fromJson(Map<String, dynamic> json) {
    return RoomBookingData(
      roomNo: json['roomNo'] ?? '',
      totalBookings: json['totalBookings'] ?? 0,
      bookings:
          (json['bookings'] as List?)
              ?.map((e) => Booking.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Booking {
  final String id;
  final HostelInfo? hostelId;
  final UserInfo? userId;
  final String roomType;
  final String shareType;
  final String isTrue;
  final String roomNo;
  final String bookingType;
  final DateTime startDate;
  final DateTime endDate; // Added endDate
  final int totalAmount;
  final int monthlyAdvance;
  final String status;
  final String bookingReference;
  final String vendorId;
  final List<PaymentHistory> paymentHistory; // Changed from List<dynamic>
  final List<dynamic> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String currentMonthPaymentStatus;

  Booking({
    required this.id,
    this.hostelId,
    this.userId,
    required this.roomType,
    required this.shareType,
    required this.isTrue,
    required this.roomNo,
    required this.bookingType,
    required this.startDate,
    required this.endDate, // Added
    required this.totalAmount,
    required this.monthlyAdvance,
    required this.status,
    required this.bookingReference,
    required this.vendorId,
    required this.paymentHistory,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
    required this.currentMonthPaymentStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      hostelId: json['hostelId'] != null
          ? HostelInfo.fromJson(json['hostelId'])
          : null,
      userId: json['userId'] != null ? UserInfo.fromJson(json['userId']) : null,
      roomType: json['roomType'] ?? '',
      shareType: json['shareType'] ?? '',
      isTrue: json['isTrue'] ?? '',
      roomNo: json['roomNo'] ?? '',
      bookingType: json['bookingType'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate']) ?? DateTime.now()
          : DateTime.now(), // Added
      totalAmount: json['totalAmount'] ?? 0,
      monthlyAdvance: json['monthlyAdvance'] ?? 0,
      status: json['status'] ?? '',
      bookingReference: json['bookingReference'] ?? '',
      vendorId: json['vendorId'] ?? '',
      paymentHistory:
          (json['paymentHistory'] as List?)
              ?.map((e) => PaymentHistory.fromJson(e))
              .toList() ??
          [],
      statusHistory: json['statusHistory'] ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      currentMonthPaymentStatus: json['currentMonthPaymentStatus'] ?? 'pending',
    );
  }
}

class HostelInfo {
  final String id;
  final String name;
  final String address;

  HostelInfo({required this.id, required this.name, required this.address});

  factory HostelInfo.fromJson(Map<String, dynamic> json) {
    return HostelInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class UserInfo {
  final String id;
  final int mobileNumber;
  final String name;

  UserInfo({required this.id, required this.mobileNumber, required this.name});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      mobileNumber: json['mobileNumber'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// Add PaymentHistory model
class PaymentHistory {
  final String id;
  final String date;
  final int amount;
  final String status;
  final dynamic remainingAmount;

  PaymentHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.remainingAmount,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['_id'] ?? '',
      date: json['date'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
      remainingAmount: json['remainingAmount'] ?? 0,
    );
  }
}
