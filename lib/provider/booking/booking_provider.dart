import 'package:brando_vendor/model/user_booking_model.dart';
import 'package:brando_vendor/services/booking/user_booking_service.dart';
import 'package:flutter/material.dart';

enum BookingRequestStatus { idle, loading, success, error }

class BookingRequestProvider extends ChangeNotifier {
  final BookingRequestService _service = BookingRequestService();

  List<BookingRequestModel> _bookingRequests = [];
  BookingRequestStatus _status = BookingRequestStatus.idle;
  String _errorMessage = '';

  // Getters
  List<BookingRequestModel> get bookingRequests => _bookingRequests;
  BookingRequestStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == BookingRequestStatus.loading;

  // Filtered getters
  // List<BookingRequestModel> get pendingRequests =>
  //     _bookingRequests.where((r) => r.status == 'Pending').toList();



  List<BookingRequestModel> get pendingRequests =>
    _bookingRequests.where((r) => r.status == 'Requested').toList();

  List<BookingRequestModel> get acceptedRequests =>
      _bookingRequests.where((r) => r.status == 'Accepted').toList();

  List<BookingRequestModel> get rejectedRequests =>
      _bookingRequests.where((r) => r.status == 'Rejected').toList();

  void _setState(BookingRequestStatus s, [String error = '']) {
    _status = s;
    _errorMessage = error;
    notifyListeners();
  }

  // Fetch all booking requests
  Future<void> fetchAllBookingRequests(String vendorId) async {
    _setState(BookingRequestStatus.loading);
    try {
      _bookingRequests = await _service.getAllBookingRequests(vendorId);
      _setState(BookingRequestStatus.success);
    } catch (e) {
      _setState(BookingRequestStatus.error, e.toString());
    }
  }

  // Update booking status (Accepted / Rejected)
  // Future<bool> updateBookingStatus({
  //   required String bookingId,
  //   required String status,
  // }) async {
  //   _setState(BookingRequestStatus.loading);
  //   try {
  //     final updated = await _service.updateBookingRequest(
  //       bookingId: bookingId,
  //       status: status,
  //     );
  //     final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
  //     if (index != -1) {
  //       _bookingRequests[index] = updated;
  //     }
  //     _setState(BookingRequestStatus.success);
  //     return true;
  //   } catch (e) {
  //     _setState(BookingRequestStatus.error, e.toString());
  //     return false;
  //   }
  // }



  Future<bool> updateBookingStatus({
  required String bookingId,
  required String status,
}) async {
  _setState(BookingRequestStatus.loading);
  try {
    await _service.updateBookingRequest(
      bookingId: bookingId,
      status: status,
    );
    // Use copyWith to only update status, preserving existing user/hostel data
    final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
    if (index != -1) {
      _bookingRequests[index] = _bookingRequests[index].copyWith(status: status);
    }
    _setState(BookingRequestStatus.success);
    return true;
  } catch (e) {
    _setState(BookingRequestStatus.error, e.toString());
    return false;
  }
}

  // Delete booking request
  Future<bool> deleteBookingRequest(String bookingId) async {
    _setState(BookingRequestStatus.loading);
    try {
      await _service.deleteBookingRequest(bookingId);
      _bookingRequests.removeWhere((r) => r.id == bookingId);
      _setState(BookingRequestStatus.success);
      return true;
    } catch (e) {
      _setState(BookingRequestStatus.error, e.toString());
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    _status = BookingRequestStatus.idle;
    notifyListeners();
  }
}