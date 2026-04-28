// class BookingUserModel {
//   final String id;
//   final int mobileNumber;
//   final String name;

//   BookingUserModel({
//     required this.id,
//     required this.mobileNumber,
//     required this.name,
//   });

//   // factory BookingUserModel.fromJson(Map<String, dynamic> json) {
//   //   return BookingUserModel(
//   //     id: json['_id'] ?? '',
//   //     mobileNumber: json['mobileNumber'] ?? 0,
//   //     name: json['name'] ?? '',
//   //   );
//   // }


//   factory BookingUserModel.fromJson(Map<String, dynamic> json) {
//   return BookingUserModel(
//     id: json['_id'] ?? '',
//     mobileNumber: json['mobileNumber'] ?? 0,
//     name: json['name'] ?? 'Unknown User',  // API doesn't return name
//   );
// }

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
//     return BookingRequestModel(
//       id: json['_id'] ?? '',
//       user: BookingUserModel.fromJson(json['userId'] ?? {}),
//       hostel: BookingHostelModel.fromJson(json['hostelId'] ?? {}),
//       status: json['status'] ?? '',
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//     );
//   }

//   BookingRequestModel copyWith({String? status}) {
//     return BookingRequestModel(
//       id: id,
//       user: user,
//       hostel: hostel,
//       status: status ?? this.status,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//     );
//   }
// }



















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

  BookingHostelModel({
    required this.id,
    required this.name,
    required this.address,
  });

  factory BookingHostelModel.fromJson(Map<String, dynamic> json) {
    return BookingHostelModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'address': address,
      };
}

class BookingRequestModel {
  final String id;
  final BookingUserModel user;
  final BookingHostelModel hostel;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingRequestModel({
    required this.id,
    required this.user,
    required this.hostel,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    // userId can be a populated object (on fetch) or a plain string (after update)
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

    // hostelId can be a populated object or a plain string
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
      hostel: hostel,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  BookingRequestModel copyWith({
    String? id,
    BookingUserModel? user,
    BookingHostelModel? hostel,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      user: user ?? this.user,
      hostel: hostel ?? this.hostel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': user.toJson(),
        'hostelId': hostel.toJson(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}