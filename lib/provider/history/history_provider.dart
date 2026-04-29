// lib/provider/history/history_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/history_model.dart';

class HistoryProvider extends ChangeNotifier {
  List<RoomBookingData> _bookings = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasError = false;

  List<RoomBookingData> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  // Get all bookings (flattened list if needed)
  List<Booking> getAllBookings() {
    return _bookings.expand((room) => room.bookings).toList();
  }

  // Get bookings for a specific room
  List<Booking> getBookingsByRoom(String roomNo) {
    final room = _bookings.firstWhere(
      (room) => room.roomNo == roomNo,
      orElse: () => RoomBookingData(roomNo: '', totalBookings: 0, bookings: []),
    );
    return room.bookings;
  }

  // Fetch history from API
  Future<void> fetchHistory(String vendorId) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final url = Uri.parse(
        'http://187.127.146.52:2003/api/vendors/vendor-bookingswithroomsno/$vendorId',
      );

      print('Fetching history from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final historyResponse = HistoryResponse.fromJson(jsonResponse);

        _bookings = historyResponse.data;
        _hasError = false;
        _errorMessage = '';
      } else {
        _hasError = true;
        _errorMessage =
            'Failed to load history. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error fetching history: $e';
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear bookings
  void clearBookings() {
    _bookings = [];
    notifyListeners();
  }
}
