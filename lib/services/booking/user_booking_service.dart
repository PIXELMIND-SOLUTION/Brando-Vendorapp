import 'dart:convert';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/user_booking_model.dart';
import 'package:http/http.dart' as http;

class BookingRequestService {
  Future<List<BookingRequestModel>> getAllBookingRequests(
    String vendorId,
  ) async {
    final url = Uri.parse(ApiConstant.getAllBookingRequests(vendorId));
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      print(
        'Response status code for get all user booking appp ${response.statusCode}',
      );
      print(
        'Response boddddddddddyyyyyyyyy  for get all user booking appp ${response.body}',
      );

      if (response.statusCode == 200 && data['success'] == true) {
        final List requests = data['requests'] ?? [];
        return requests.map((e) => BookingRequestModel.fromJson(e)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch booking requests');
      }
    } catch (e) {
      throw Exception('Error fetching booking requests: $e');
    }
  }

  // PUT update booking request status
  Future<BookingRequestModel> updateBookingRequest({
    required String bookingId,
    required String status,
  }) async {
    final url = Uri.parse(ApiConstant.updateBookingRequest(bookingId));
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      final data = jsonDecode(response.body);

      print(
        'Response status code for updddddddddddateeeeeeeee booking  ${response.statusCode}',
      );
      print(
        'Response boddddddddddyyyyyyyyy  for updaaaaaaaaaaaaaaaaaateeeee user booking appp ${response.body}',
      );

      if (response.statusCode == 200 && data['success'] == true) {
        return BookingRequestModel.fromJson(data['booking']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update booking request');
      }
    } catch (e) {
      throw Exception('Error updating booking request: $e');
    }
  }

  // DELETE booking request
  Future<bool> deleteBookingRequest(String bookingId) async {
    final url = Uri.parse(ApiConstant.deleteBookingRequest(bookingId));
    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);

      print(
        'Response status code for deleteeeeeeeeee booking  ${response.statusCode}',
      );
      print(
        'Response boddddddddddyyyyyyyyy  for deleeeeeteeeeeeeee user booking  ${response.body}',
      );

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete booking request');
      }
    } catch (e) {
      throw Exception('Error deleting booking request: $e');
    }
  }
}
