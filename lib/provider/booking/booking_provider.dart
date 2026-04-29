// // import 'package:brando_vendor/model/user_booking_model.dart';
// // import 'package:brando_vendor/services/booking/user_booking_service.dart';
// // import 'package:flutter/material.dart';

// // enum BookingRequestStatus { idle, loading, success, error }

// // class BookingRequestProvider extends ChangeNotifier {
// //   final BookingRequestService _service = BookingRequestService();

// //   List<BookingRequestModel> _bookingRequests = [];
// //   BookingRequestStatus _status = BookingRequestStatus.idle;
// //   String _errorMessage = '';

// //   // Getters
// //   List<BookingRequestModel> get bookingRequests => _bookingRequests;
// //   BookingRequestStatus get status => _status;
// //   String get errorMessage => _errorMessage;
// //   bool get isLoading => _status == BookingRequestStatus.loading;

// //   // Filtered getters
// //   // List<BookingRequestModel> get pendingRequests =>
// //   //     _bookingRequests.where((r) => r.status == 'Pending').toList();

// //   List<BookingRequestModel> get pendingRequests =>
// //     _bookingRequests.where((r) => r.status == 'Requested').toList();

// //   List<BookingRequestModel> get acceptedRequests =>
// //       _bookingRequests.where((r) => r.status == 'Accepted').toList();

// //   List<BookingRequestModel> get rejectedRequests =>
// //       _bookingRequests.where((r) => r.status == 'Rejected').toList();

// //   void _setState(BookingRequestStatus s, [String error = '']) {
// //     _status = s;
// //     _errorMessage = error;
// //     notifyListeners();
// //   }

// //   // Fetch all booking requests
// //   Future<void> fetchAllBookingRequests(String vendorId) async {
// //     _setState(BookingRequestStatus.loading);
// //     try {
// //       _bookingRequests = await _service.getAllBookingRequests(vendorId);
// //       _setState(BookingRequestStatus.success);
// //     } catch (e) {
// //       _setState(BookingRequestStatus.error, e.toString());
// //     }
// //   }

// //   // Update booking status (Accepted / Rejected)
// //   // Future<bool> updateBookingStatus({
// //   //   required String bookingId,
// //   //   required String status,
// //   // }) async {
// //   //   _setState(BookingRequestStatus.loading);
// //   //   try {
// //   //     final updated = await _service.updateBookingRequest(
// //   //       bookingId: bookingId,
// //   //       status: status,
// //   //     );
// //   //     final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
// //   //     if (index != -1) {
// //   //       _bookingRequests[index] = updated;
// //   //     }
// //   //     _setState(BookingRequestStatus.success);
// //   //     return true;
// //   //   } catch (e) {
// //   //     _setState(BookingRequestStatus.error, e.toString());
// //   //     return false;
// //   //   }
// //   // }

// //   Future<bool> updateBookingStatus({
// //   required String bookingId,
// //   required String status,
// // }) async {
// //   _setState(BookingRequestStatus.loading);
// //   try {
// //     await _service.updateBookingRequest(
// //       bookingId: bookingId,
// //       status: status,
// //     );
// //     // Use copyWith to only update status, preserving existing user/hostel data
// //     final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
// //     if (index != -1) {
// //       _bookingRequests[index] = _bookingRequests[index].copyWith(status: status);
// //     }
// //     _setState(BookingRequestStatus.success);
// //     return true;
// //   } catch (e) {
// //     _setState(BookingRequestStatus.error, e.toString());
// //     return false;
// //   }
// // }

// //   // Delete booking request
// //   Future<bool> deleteBookingRequest(String bookingId) async {
// //     _setState(BookingRequestStatus.loading);
// //     try {
// //       await _service.deleteBookingRequest(bookingId);
// //       _bookingRequests.removeWhere((r) => r.id == bookingId);
// //       _setState(BookingRequestStatus.success);
// //       return true;
// //     } catch (e) {
// //       _setState(BookingRequestStatus.error, e.toString());
// //       return false;
// //     }
// //   }

// //   void clearError() {
// //     _errorMessage = '';
// //     _status = BookingRequestStatus.idle;
// //     notifyListeners();
// //   }
// // }

// import 'package:brando_vendor/model/user_booking_model.dart';
// import 'package:brando_vendor/services/booking/user_booking_service.dart';
// import 'package:flutter/material.dart';

// enum BookingRequestStatus { idle, loading, success, error }

// class BookingRequestProvider extends ChangeNotifier {
//   final BookingRequestService _service = BookingRequestService();

//   List<BookingRequestModel> _bookingRequests = [];
//   BookingRequestStatus _status = BookingRequestStatus.idle;
//   String _errorMessage = '';

//   // Getters
//   List<BookingRequestModel> get bookingRequests => _bookingRequests;
//   BookingRequestStatus get status => _status;
//   String get errorMessage => _errorMessage;
//   bool get isLoading => _status == BookingRequestStatus.loading;

//   // Filtered getters based on actual API statuses
//   List<BookingRequestModel> get pendingRequests => _bookingRequests
//       .where((r) => r.status.toLowerCase() == 'pending')
//       .toList();

//   List<BookingRequestModel> get runningRequests => _bookingRequests
//       .where((r) => r.status.toLowerCase() == 'running')
//       .toList();

//   List<BookingRequestModel> get cancelledRequests => _bookingRequests
//       .where((r) => r.status.toLowerCase() == 'cancelled')
//       .toList();

//   void _setState(BookingRequestStatus s, [String error = '']) {
//     _status = s;
//     _errorMessage = error;
//     notifyListeners();
//   }

//   // Fetch all booking requests by status
//   Future<void> fetchAllBookingRequests(String vendorId) async {
//     _setState(BookingRequestStatus.loading);
//     try {
//       final List<BookingRequestModel> allBookings = [];

//       // Fetch pending bookings
//       final pendingBookings = await _service.getBookingsByStatus(
//         vendorId,
//         'pending',
//       );
//       allBookings.addAll(pendingBookings);

//       // Fetch running bookings
//       final runningBookings = await _service.getBookingsByStatus(
//         vendorId,
//         'running',
//       );
//       allBookings.addAll(runningBookings);

//       // Fetch cancelled bookings
//       final cancelledBookings = await _service.getBookingsByStatus(
//         vendorId,
//         'cancelled',
//       );
//       allBookings.addAll(cancelledBookings);

//       _bookingRequests = allBookings;
//       _setState(BookingRequestStatus.success);
//     } catch (e) {
//       _setState(BookingRequestStatus.error, e.toString());
//     }
//   }

//   Future<bool> vacateBooking({
//   required String vendorId,
//   required String bookingId,
// }) async {
//   setState(() => isLoading = true);

//   try {
//     final response = await http.put(
//       Uri.parse('YOUR_API_ENDPOINT/vendor/$vendorId/booking/$bookingId/vacate'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${await SharedPreferenceHelper.getToken()}',
//       },
//     );

//     if (response.statusCode == 200) {
//       // Refresh the bookings list
//       await fetchAllBookingRequests(vendorId);
//       return true;
//     } else {
//       errorMessage = 'Failed to vacate booking';
//       status = BookingRequestStatus.error;
//       return false;
//     }
//   } catch (e) {
//     errorMessage = e.toString();
//     status = BookingRequestStatus.error;
//     return false;
//   } finally {
//     setState(() => isLoading = false);
//   }
// }

//   // Accept booking (changes status from pending to running)
//   Future<bool> acceptBooking({
//     required String vendorId,
//     required String bookingId,
//   }) async {
//     _setState(BookingRequestStatus.loading);
//     try {
//       final updated = await _service.acceptBooking(
//         vendorId: vendorId,
//         bookingId: bookingId,
//       );
//       final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
//       if (index != -1) {
//         _bookingRequests[index] = updated;
//       }
//       _setState(BookingRequestStatus.success);
//       return true;
//     } catch (e) {
//       _setState(BookingRequestStatus.error, e.toString());
//       return false;
//     }
//   }

//   // Reject booking (changes status from pending to cancelled)
//   Future<bool> rejectBooking({
//     required String vendorId,
//     required String bookingId,
//   }) async {
//     _setState(BookingRequestStatus.loading);
//     try {
//       final updated = await _service.rejectBooking(
//         vendorId: vendorId,
//         bookingId: bookingId,
//       );
//       final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
//       if (index != -1) {
//         _bookingRequests[index] = updated;
//       }
//       _setState(BookingRequestStatus.success);
//       return true;
//     } catch (e) {
//       _setState(BookingRequestStatus.error, e.toString());
//       return false;
//     }
//   }

//   void clearError() {
//     _errorMessage = '';
//     _status = BookingRequestStatus.idle;
//     notifyListeners();
//   }
// }

import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/user_booking_model.dart';
import 'package:brando_vendor/services/booking/user_booking_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Filtered getters based on actual API statuses
  List<BookingRequestModel> get pendingRequests => _bookingRequests
      .where((r) => r.status.toLowerCase() == 'pending')
      .toList();

  List<BookingRequestModel> get runningRequests => _bookingRequests
      .where((r) => r.status.toLowerCase() == 'running')
      .toList();

  List<BookingRequestModel> get cancelledRequests => _bookingRequests
      .where((r) => r.status.toLowerCase() == 'completed')
      .toList();

  void _setState(BookingRequestStatus s, [String error = '']) {
    _status = s;
    _errorMessage = error;
    notifyListeners();
  }

  // Fetch all booking requests by status
  Future<void> fetchAllBookingRequests(String vendorId) async {
    _setState(BookingRequestStatus.loading);
    try {
      final List<BookingRequestModel> allBookings = [];

      // Fetch pending bookings
      final pendingBookings = await _service.getBookingsByStatus(
        vendorId,
        'pending',
      );
      allBookings.addAll(pendingBookings);

      // Fetch running bookings
      final runningBookings = await _service.getBookingsByStatus(
        vendorId,
        'running',
      );
      allBookings.addAll(runningBookings);

      // Fetch cancelled bookings
      final cancelledBookings = await _service.getBookingsByStatus(
        vendorId,
        'completed',
      );
      allBookings.addAll(cancelledBookings);

      _bookingRequests = allBookings;
      _setState(BookingRequestStatus.success);
    } catch (e) {
      _setState(BookingRequestStatus.error, e.toString());
    }
  }

  // Vacate booking (changes status from running to completed/vacated)
  Future<bool> vacateBooking({
    required String vendorId,
    required String bookingId,
  }) async {
    _setState(BookingRequestStatus.loading);

    try {
      final response = await http.put(
        // Uri.parse(
        //   'http://187.127.146.52:2003/api/Booking/vendor/$vendorId/booking/$bookingId/vacate',
        // ),
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/complete-booking/$vendorId/$bookingId',
        ),
      );

      print("ppppppppppppppppppppppppppppp${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Update the local booking status
          final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
          if (index != -1) {
            _bookingRequests[index] = _bookingRequests[index].copyWith(
              status: 'completed',
            );
          }
          _setState(BookingRequestStatus.success);
          return true;
        } else {
          _setState(
            BookingRequestStatus.error,
            data['message'] ?? 'Failed to vacate booking',
          );
          return false;
        }
      } else {
        _setState(BookingRequestStatus.error, 'Failed to vacate booking');
        return false;
      }
    } catch (e) {
      _setState(BookingRequestStatus.error, e.toString());
      return false;
    }
  }

  // Accept booking (changes status from pending to running)
  Future<bool> acceptBooking({
    required String vendorId,
    required String bookingId,
  }) async {
    _setState(BookingRequestStatus.loading);
    try {
      final updated = await _service.acceptBooking(
        vendorId: vendorId,
        bookingId: bookingId,
      );
      final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
      if (index != -1) {
        _bookingRequests[index] = updated;
      }
      _setState(BookingRequestStatus.success);
      return true;
    } catch (e) {
      _setState(BookingRequestStatus.error, e.toString());
      return false;
    }
  }

  // Reject booking (changes status from pending to cancelled)
  Future<bool> rejectBooking({
    required String vendorId,
    required String bookingId,
  }) async {
    _setState(BookingRequestStatus.loading);
    try {
      final updated = await _service.rejectBooking(
        vendorId: vendorId,
        bookingId: bookingId,
      );
      final index = _bookingRequests.indexWhere((r) => r.id == bookingId);
      if (index != -1) {
        _bookingRequests[index] = updated;
      }
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
