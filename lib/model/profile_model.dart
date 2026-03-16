class VendorProfileModel {
  final String vendorId;
  final String name;
  final String mobileNumber;
  final String email;
  final String? hostelImage;

  VendorProfileModel({
    required this.vendorId,
    required this.name,
    required this.mobileNumber,
    required this.email,
    this.hostelImage,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      hostelImage: json['hostelImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'hostelImage': hostelImage,
    };
  }

  VendorProfileModel copyWith({
    String? vendorId,
    String? name,
    String? mobileNumber,
    String? email,
    String? hostelImage,
  }) {
    return VendorProfileModel(
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      hostelImage: hostelImage ?? this.hostelImage,
    );
  }
}