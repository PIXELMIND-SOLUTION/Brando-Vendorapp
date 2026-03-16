class VendorModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String email;
  final String hostelImage;

  VendorModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.hostelImage,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      hostelImage: json['hostelImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'hostelImage': hostelImage,
    };
  }
}

class LoginResponseModel {
  final bool success;
  final String message;
  final String mobileNumber;
  final String token;
  final String otp;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.mobileNumber,
    required this.token,
    required this.otp,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      token: json['token'] ?? '',
      otp: json['otp'] ?? '',
    );
  }
}

class VerifyOtpResponseModel {
  final bool success;
  final String message;
  final String vendorId;
  final String mobileNumber;

  VerifyOtpResponseModel({
    required this.success,
    required this.message,
    required this.vendorId,
    required this.mobileNumber,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      vendorId: json['vendorId'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
    );
  }
}