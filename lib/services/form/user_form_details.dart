import 'dart:convert';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/user_form_model.dart';
import 'package:http/http.dart' as http;


class HostelBookingService {
  Future<List<HostelBooking>> getHostelBookings(String vendorId) async {
    final response = await http.get(
      Uri.parse(ApiConstant.getHostelBookings(vendorId)),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);


    print('Response stattus code for get user form detaailssssssssss ${response.statusCode}');
        print('Response bodddddddddddddddddddddyyyyyyy for get user form detaailssssssssss ${response.body}');


    if (response.statusCode == 200 && data['success'] == true) {
      final List bookings = data['bookings'] ?? [];
      return bookings.map((e) => HostelBooking.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch bookings');
    }
  }

  Future<bool> updateHostelBooking(
    String bookingId,
    UpdateBookingRequest request,
  ) async {
    final response = await http.put(
      Uri.parse(ApiConstant.updateHostelBooking(bookingId)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final data = jsonDecode(response.body);


    
    print('Response stattus code for uuuuuuuuuuuuupdateeeeee user form detaailssssssssss ${response.statusCode}');
        print('Response bodddddddddddddddddddddyyyyyyy for updaaaaaaaaaaaateeeeee user form detaailssssssssss ${response.body}');

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to update booking');
    }
  }

  Future<bool> deleteHostelBooking(String bookingId) async {
    final response = await http.delete(
      Uri.parse(ApiConstant.deleteHostelBooking(bookingId)),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);


        print('Response stattus code for deleteeeeeeeeeeeeee user form detaailssssssssss ${response.statusCode}');
        print('Response bodddddddddddddddddddddyyyyyyy for deleteeeeeeeeeeeee user form detaailssssssssss ${response.body}');

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete booking');
    }
  }
}