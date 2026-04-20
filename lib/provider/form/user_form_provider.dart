import 'package:brando_vendor/model/user_form_model.dart';
import 'package:brando_vendor/services/form/user_form_details.dart';
import 'package:flutter/material.dart';


class HostelBookingProvider extends ChangeNotifier {
  final HostelBookingService _service = HostelBookingService();

  List<HostelBooking> _bookings = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;

  List<HostelBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchBookings(String vendorId) async {
    _setLoading(true);
    _setError(null);
    try {
      _bookings = await _service.getHostelBookings(vendorId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBooking(
    String bookingId,
    UpdateBookingRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    _isUpdating = true;
    _setError(null);
    notifyListeners();
    try {
      final success = await _service.updateHostelBooking(bookingId, request);
      if (success) {
        // Update the local list to reflect changes immediately
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          final updated = _bookings[index];
          _bookings[index] = HostelBooking(
            id: updated.id,
            user: updated.user,
            hostel: updated.hostel,
            vendorId: updated.vendorId,
            shareType: updated.shareType,
            roomType: updated.roomType,
            roomNo: updated.roomNo,
            name: updated.name,
            mobileNumber: updated.mobileNumber,
            email: updated.email,
            aadharCardImage: updated.aadharCardImage,
            panCardImage: updated.panCardImage,
            profileImage: updated.profileImage,
            paymentStatus: request.paymentStatus,
            price: request.price,
            assignedDate: request.assignedDate,
            status: request.status,
            createdAt: updated.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
        }
        onSuccess?.call();
      }
      return success;
    } catch (e) {
      final msg = e.toString();
      _setError(msg);
      onError?.call(msg);
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBooking(
    String bookingId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    _isDeleting = true;
    _setError(null);
    notifyListeners();
    try {
      final success = await _service.deleteHostelBooking(bookingId);
      if (success) {
        _bookings.removeWhere((b) => b.id == bookingId);
        onSuccess?.call();
      }
      return success;
    } catch (e) {
      final msg = e.toString();
      _setError(msg);
      onError?.call(msg);
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}