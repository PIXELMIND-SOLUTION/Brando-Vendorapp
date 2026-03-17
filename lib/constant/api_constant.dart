class ApiConstant {
  static const String baseUrl = 'http://31.97.206.144:2003/api/vendors';
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String verifyOtp = '$baseUrl/verify-otp';
  static const String profile = '$baseUrl/profile';
  static const String updateProfile = '$baseUrl/update-profile';

  // Admin endpoints
  static const String adminBase = 'http://31.97.206.144:2003/api/Admin';
  static const String createHostel = '$adminBase/createHostel';
  static String updateHostel(String hostelId) => '$adminBase/hostel/$hostelId';
static String gethostelbyvendor(String vendorId) => '$adminBase/hostels/vendor/$vendorId';}
