class FormDetailsResponse {
  final bool success;
  final int count;
  final String hostelId;
  final List<Submission> submissions;

  FormDetailsResponse({
    required this.success,
    required this.count,
    required this.hostelId,
    required this.submissions,
  });

  factory FormDetailsResponse.fromJson(Map<String, dynamic> json) {
    return FormDetailsResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      hostelId: json['hostelId'] ?? '',
      submissions: (json['submissions'] as List<dynamic>?)
              ?.map((e) => Submission.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Submission {
  final String id;
  final HostelInfo hostel;
  final GuestInfo guest;
  final StayDetails stayDetails;
  final Documents documents;
  final DateTime submittedAt;

  Submission({
    required this.id,
    required this.hostel,
    required this.guest,
    required this.stayDetails,
    required this.documents,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['_id'] ?? '',
      hostel: HostelInfo.fromJson(json['hostel'] ?? {}),
      guest: GuestInfo.fromJson(json['guest'] ?? {}),
      stayDetails: StayDetails.fromJson(json['stayDetails'] ?? {}),
      documents: Documents.fromJson(json['documents'] ?? {}),
      submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class HostelInfo {
  final String id;
  final String name;
  final String address;

  HostelInfo({
    required this.id,
    required this.name,
    required this.address,
  });

  factory HostelInfo.fromJson(Map<String, dynamic> json) {
    return HostelInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class GuestInfo {
  final String name;
  final String email;
  final String mobile;
  final String emergencyNumber;

  GuestInfo({
    required this.name,
    required this.email,
    required this.mobile,
    required this.emergencyNumber,
  });

  factory GuestInfo.fromJson(Map<String, dynamic> json) {
    return GuestInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      emergencyNumber: json['emergencyNumber'] ?? '',
    );
  }
}

class StayDetails {
  final String roomNo;
  final DateTime joiningDate;
  final String tenure;
  final String roomType;
  final num advance;

  StayDetails({
    required this.roomNo,
    required this.joiningDate,
    required this.tenure,
    required this.roomType,
    required this.advance,
  });

  factory StayDetails.fromJson(Map<String, dynamic> json) {
    return StayDetails(
      roomNo: json['roomNo'] ?? '',
      joiningDate: DateTime.tryParse(json['joiningDate'] ?? '') ?? DateTime.now(),
      tenure: json['tenure'] ?? '',
      roomType: json['roomType'] ?? '',
      advance: json['advance'] ?? 0,
    );
  }
}

class Documents {
  final String aadhar;
  final String idCard;
  final String profileImage;

  Documents({
    required this.aadhar,
    required this.idCard,
    required this.profileImage,
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
      aadhar: json['aadhar'] ?? '',
      idCard: json['idCard'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }
}