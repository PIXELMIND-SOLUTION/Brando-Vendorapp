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
      name: json['name'] ?? '',
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
    return BookingRequestModel(
      id: json['_id'] ?? '',
      user: BookingUserModel.fromJson(json['userId'] ?? {}),
      hostel: BookingHostelModel.fromJson(json['hostelId'] ?? {}),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  BookingRequestModel copyWith({String? status}) {
    return BookingRequestModel(
      id: id,
      user: user,
      hostel: hostel,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}