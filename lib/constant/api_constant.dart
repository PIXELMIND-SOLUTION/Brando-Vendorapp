// class ApiConstant {
//   static const String baseUrl = 'http://31.97.206.144:2003/api/vendors';
//   static const String register = '$baseUrl/register';
//   static const String login = '$baseUrl/login';
//   static const String verifyOtp = '$baseUrl/verify-otp';
//   static const String profile = '$baseUrl/profile';
//   static const String updateProfile = '$baseUrl/update-profile';

//   // Admin endpoints
//   static const String adminBase = 'http://31.97.206.144:2003/api/Admin';
//   static const String createHostel = '$adminBase/createHostel';
//   static String updateHostel(String hostelId) => '$adminBase/hostel/$hostelId';
//   static String deletehostel(String hostelId) => '$adminBase/hostel/$hostelId';
//   static String gethostelbyvendor(String vendorId) =>
//       '$adminBase/hostels/vendor/$vendorId';

// static const String cameraurl='http://31.97.206.144:2003/api/cameras';

// }

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
  static String deletehostel(String hostelId) => '$adminBase/hostel/$hostelId';
  static String gethostelbyvendor(String vendorId) =>
      '$adminBase/hostels/vendor/$vendorId';

  // Camera endpoints
  static const String cameraBase = 'http://31.97.206.144:2003/api/cameras';

  static String addCamera(String hostelId) =>
      '$cameraBase/addcameras/$hostelId';

  static String getAllHostelCameras(String hostelId) =>
      '$cameraBase/allhostelcameras/$hostelId';

  static String getSingleCamera(String hostelId, String cameraId) =>
      '$cameraBase/hostelsinglecamera/hostelId/$cameraId';

  static String updateCamera(String hostelId, String cameraId) =>
      '$cameraBase/updatehostelcameras/$hostelId/$cameraId';

  static String deleteCamera(String hostelId, String cameraId) =>
      '$cameraBase/deletehostelcameras/$hostelId/$cameraId';

  // Start streaming apis

  static String startStreaming(String hostelId, String cameraId) =>
      '$cameraBase/startcamerasstreaming/$hostelId/$cameraId';

  static String stopStreaming(String hostelId, String cameraId) =>
      '$cameraBase/stopcamerasstreaming/$hostelId/$cameraId';

  static String getLiveStream(String hostelId, String cameraId) =>
      '$cameraBase/getstream/$hostelId/$cameraId';

  static String getUnknownVisitors(String hostelId) =>
      '$cameraBase/getunknown-visitors/$hostelId';
}
