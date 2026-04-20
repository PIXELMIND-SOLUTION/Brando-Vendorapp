class HostelBookingUser {
  final String id;
  final int mobileNumber;
  final String name;

  HostelBookingUser({
    required this.id,
    required this.mobileNumber,
    required this.name,
  });

  factory HostelBookingUser.fromJson(Map<String, dynamic> json) {
    return HostelBookingUser(
      id: json['_id'] ?? '',
      mobileNumber: json['mobileNumber'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class HostelBookingHostel {
  final String id;
  final String name;
  final double rating;
  final String address;
  final List<String> images;

  HostelBookingHostel({
    required this.id,
    required this.name,
    required this.rating,
    required this.address,
    required this.images,
  });

  factory HostelBookingHostel.fromJson(Map<String, dynamic> json) {
    return HostelBookingHostel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

class HostelBooking {
  final String id;
  final HostelBookingUser user;
  final HostelBookingHostel hostel;
  final String vendorId;
  final String shareType;
  final String roomType;
  final String roomNo;
  final String name;
  final String mobileNumber;
  final String email;
  final String aadharCardImage;
  final String panCardImage;
  final String profileImage;
  final String paymentStatus;
  final double price;
  final String? assignedDate;
  final String status;
  final String createdAt;
  final String updatedAt;

  HostelBooking({
    required this.id,
    required this.user,
    required this.hostel,
    required this.vendorId,
    required this.shareType,
    required this.roomType,
    required this.roomNo,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.aadharCardImage,
    required this.panCardImage,
    required this.profileImage,
    required this.paymentStatus,
    required this.price,
    this.assignedDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HostelBooking.fromJson(Map<String, dynamic> json) {
    return HostelBooking(
      id: json['_id'] ?? '',
      user: HostelBookingUser.fromJson(json['userId'] ?? {}),
      hostel: HostelBookingHostel.fromJson(json['hostelId'] ?? {}),
      vendorId: json['vendorId'] ?? '',
      shareType: json['shareType'] ?? '',
      roomType: json['roomType'] ?? '',
      roomNo: json['roomNo'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      email: json['email'] ?? '',
      aadharCardImage: json['aadharCardImage'] ?? '',
      panCardImage: json['panCardImage'] ?? '',
      profileImage: json['profileImage'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      assignedDate: json['assignedDate'],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class UpdateBookingRequest {
  final String status;
  final String paymentStatus;
  final double price;
  final String assignedDate;

  UpdateBookingRequest({
    required this.status,
    required this.paymentStatus,
    required this.price,
    required this.assignedDate,
  });

  Map<String, dynamic> toJson() => {
        'status': status,
        'paymentStatus': paymentStatus,
        'price': price,
        'assignedDate': assignedDate,
      };
}