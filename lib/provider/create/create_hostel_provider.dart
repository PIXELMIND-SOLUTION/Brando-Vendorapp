import 'package:brando_vendor/model/create_hostel_model.dart';
import 'package:brando_vendor/services/create/create_hostel_service.dart';
import 'package:brando_vendor/services/create/location_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum HostelStatus { idle, loading, success, error }

class HostelProvider extends ChangeNotifier {
  final HostelService _service;
  final LocationService _locationService;

  HostelProvider({HostelService? service, LocationService? locationService})
    : _service = service ?? HostelService(),
      _locationService = locationService ?? LocationService();

  // ── Hostel State ───────────────────────────────────────────────────────
  List<Hostel> _hostels = [];
  Hostel? _selectedHostel;
  HostelStatus _status = HostelStatus.idle;
  String? _errorMessage;

  // ── Delete State ───────────────────────────────────────────────────────
  bool _isDeleting = false;
  String? _deletingHostelId;

  // ── Location State ─────────────────────────────────────────────────────
  Position? _currentPosition;
  bool _isFetchingLocation = false;

  // ── Hostel Getters ─────────────────────────────────────────────────────
  List<Hostel> get hostels => List.unmodifiable(_hostels);
  Hostel? get selectedHostel => _selectedHostel;
  HostelStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HostelStatus.loading;
  bool get hasError => _status == HostelStatus.error;

  // ── Delete Getters ─────────────────────────────────────────────────────
  bool get isDeleting => _isDeleting;
  String? get deletingHostelId => _deletingHostelId;

  // ── Location Getters ───────────────────────────────────────────────────
  Position? get currentPosition => _currentPosition;
  bool get isFetchingLocation => _isFetchingLocation;
  double? get currentLatitude => _currentPosition?.latitude;
  double? get currentLongitude => _currentPosition?.longitude;

  Future<bool> fetchCurrentLocation() async {
    _isFetchingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentLocation();
      _isFetchingLocation = false;
      notifyListeners();
      return true;
    } on LocationServiceException catch (e) {
      _isFetchingLocation = false;
      _setError(e.message);
      return false;
    } catch (e) {
      _isFetchingLocation = false;
      _setError('Could not fetch location. Please try again.');
      return false;
    }
  }

  /// Clears any stored position (e.g. when user wants to reset).
  void clearLocation() {
    _currentPosition = null;
    notifyListeners();
  }

  // ── Create Hostel ──────────────────────────────────────────────────────
  Future<bool> createHostel(HostelRequest request) async {
    _setLoading();
    try {
      final response = await _service.createHostel(request);
      _hostels.insert(0, response.hostel);
      _selectedHostel = response.hostel;
      _setSuccess();
      return true;
    } on HostelServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // ── Update Hostel ──────────────────────────────────────────────────────
  Future<bool> updateHostel({
    required String hostelId,
    required HostelRequest request,
  }) async {
    _setLoading();
    try {
      final response = await _service.updateHostel(
        hostelId: hostelId,
        request: request,
      );
      final updatedHostel = response.hostel;

      // Replace in the local list
      final index = _hostels.indexWhere((h) => h.id == hostelId);
      if (index != -1) {
        _hostels[index] = updatedHostel;
      }

      // Update selectedHostel if it's the same one
      if (_selectedHostel?.id == hostelId) {
        _selectedHostel = updatedHostel;
      }

      _setSuccess();
      notifyListeners();

      return true;
    } on HostelServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // ── Delete Hostel ──────────────────────────────────────────────────────
  Future<bool> deleteHostel(String hostelId) async {
    _isDeleting = true;
    _deletingHostelId = hostelId;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteHostel(hostelId);

      // Remove from local list
      _hostels.removeWhere((h) => h.id == hostelId);

      // Clear selected if it's the deleted one
      if (_selectedHostel?.id == hostelId) {
        _selectedHostel = null;
      }

      _isDeleting = false;
      _deletingHostelId = null;
      notifyListeners();
      return true;
    } on HostelServiceException catch (e) {
      _isDeleting = false;
      _deletingHostelId = null;
      _setError(e.message);
      return false;
    } catch (e) {
      _isDeleting = false;
      _deletingHostelId = null;
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // ── Fetch Hostels by Vendor ────────────────────────────────────────────
  Future<void> fetchHostelsByVendor(String vendorId) async {
    _setLoading();
    try {
      final response = await _service.getHostelsByVendor(vendorId);
      _hostels = response.hostels;
      _setSuccess();
    } on HostelServiceException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
    }
  }

  // ── Select / Clear ────────────────────────────────────────────────────
  void selectHostel(String hostelId) {
    _selectedHostel = _hostels.firstWhere(
      (h) => h.id == hostelId,
      orElse: () => _selectedHostel!,
    );
    notifyListeners();
  }

  void clearSelectedHostel() {
    _selectedHostel = null;
    notifyListeners();
  }

  void clearHostels() {
    _hostels = [];
    _selectedHostel = null;
    _status = HostelStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == HostelStatus.error) {
      _status = HostelStatus.idle;
    }
    notifyListeners();
  }

  // ── Private setters ───────────────────────────────────────────────────
  void _setLoading() {
    _status = HostelStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = HostelStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = HostelStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
