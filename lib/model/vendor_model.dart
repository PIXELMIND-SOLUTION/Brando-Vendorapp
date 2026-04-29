// class VendorModel {
//   final String id;
//   final String name;
//   final String mobileNumber;
//   final String email;
//   final String hostelImage;

//   VendorModel({
//     required this.id,
//     required this.name,
//     required this.mobileNumber,
//     required this.email,
//     required this.hostelImage,
//   });

//   factory VendorModel.fromJson(Map<String, dynamic> json) {
//     return VendorModel(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       mobileNumber: json['mobileNumber'] ?? '',
//       email: json['email'] ?? '',
//       hostelImage: json['hostelImage'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'mobileNumber': mobileNumber,
//       'email': email,
//       'hostelImage': hostelImage,
//     };
//   }
// }

// class LoginResponseModel {
//   final bool success;
//   final String message;
//   final String mobileNumber;
//   final String token;
//   final String otp;
//   final bool isExists;

//   LoginResponseModel({
//     required this.success,
//     required this.message,
//     required this.mobileNumber,
//     required this.token,
//     required this.otp,
//     required this.isExists,
//   });

//   factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
//     return LoginResponseModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       mobileNumber: json['mobileNumber'] ?? '',
//       token: json['token'] ?? '',
//       otp: json['otp'] ?? '',
//       isExists: json['isExists'] ?? false,
//     );
//   }
// }

// class VerifyOtpResponseModel {
//   final bool success;
//   final String message;
//   final String vendorId;
//   final String mobileNumber;

//   VerifyOtpResponseModel({
//     required this.success,
//     required this.message,
//     required this.vendorId,
//     required this.mobileNumber,
//   });

//   factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
//     return VerifyOtpResponseModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       vendorId: json['vendorId'] ?? '',
//       mobileNumber: json['mobileNumber'] ?? '',
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────
// Register Response Model
// POST /register
// Returns vendorId, name, mobileNumber, token, otp, approvalStatus
// ─────────────────────────────────────────────────────────────
class RegisterResponseModel {
  final bool success;
  final String message;
  final String vendorId;
  final String name;
  final String mobileNumber;
  final String token;
  final String otp;
  final String approvalStatus;

  RegisterResponseModel({
    required this.success,
    required this.message,
    required this.vendorId,
    required this.name,
    required this.mobileNumber,
    required this.token,
    required this.otp,
    required this.approvalStatus,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return RegisterResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      vendorId: data['vendorId'] ?? '',
      name: data['name'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      token: data['token'] ?? '',
      otp: data['otp'] ?? '',
      approvalStatus: data['approvalStatus'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Verify Registration OTP Response Model
// POST /verify-registration-otp
// Returns vendorId, name, mobileNumber, email, token, approvalStatus
// ─────────────────────────────────────────────────────────────
class VerifyRegistrationOtpResponseModel {
  final bool success;
  final String message;
  final String vendorId;
  final String name;
  final String mobileNumber;
  final String email;
  final String token;
  final String approvalStatus;

  VerifyRegistrationOtpResponseModel({
    required this.success,
    required this.message,
    required this.vendorId,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.token,
    required this.approvalStatus,
  });

  factory VerifyRegistrationOtpResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return VerifyRegistrationOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      vendorId: data['vendorId'] ?? '',
      name: data['name'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      email: data['email'] ?? '',
      token: data['token'] ?? '',
      approvalStatus: data['approvalStatus'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Login Response Model
// POST /login  →  sends OTP
// ─────────────────────────────────────────────────────────────
// class LoginResponseModel {
//   final bool success;
//   final String message;
//   final String mobileNumber;
//   final String token;
//   final String otp;
//   final bool isExists;

//   LoginResponseModel({
//     required this.success,
//     required this.message,
//     required this.mobileNumber,
//     required this.token,
//     required this.otp,
//     required this.isExists,
//   });

//   factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
//     return LoginResponseModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       mobileNumber: json['mobileNumber'] ?? '',
//       token: json['token'] ?? '',
//       otp: json['otp'] ?? '',
//       isExists: json['isExists'] ?? false,
//     );
//   }
// }

class LoginResponseModel {
  final bool success;
  final bool isExists;
  final bool adminApproved;
  final String approvalStatus;
  final String token;
  final String mobileNumber;
  final String message;
  final String? userId;

  LoginResponseModel({
    required this.success,
    required this.isExists,
    required this.adminApproved,
    required this.approvalStatus,
    required this.token,
    required this.mobileNumber,
    required this.message,
    this.userId, // Add this
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      isExists: json['isExists'] ?? false,
      adminApproved: json['adminApproved'] ?? false,
      approvalStatus: json['approvalStatus'] ?? '',
      token: json['token'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      message: json['message'] ?? '',
      userId: json['userId']?.toString(), // Capture userId from response
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Verify Login OTP Response Model
// POST /verify-otp
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// Resend OTP Response Model
// POST /resend-registration-otp  |  POST /resend-otp
// ─────────────────────────────────────────────────────────────
class ResendOtpResponseModel {
  final bool success;
  final String message;
  final String token;
  final String otp;

  ResendOtpResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.otp,
  });

  factory ResendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ResendOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: data['token'] ?? '',
      otp: data['otp'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Vendor Profile Model  (used by GET /profile, PUT /update-profile)
// ─────────────────────────────────────────────────────────────
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
