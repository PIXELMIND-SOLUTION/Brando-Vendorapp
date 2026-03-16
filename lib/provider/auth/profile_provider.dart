import 'dart:io';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/profile_model.dart';
import 'package:brando_vendor/model/vendor_model.dart';
import 'package:brando_vendor/services/auth/profile_service.dart';
import 'package:flutter/material.dart';

enum ProfileState { idle, loading, success, error }

class VendorProfileProvider extends ChangeNotifier {
  final VendorProfileService _service = VendorProfileService();

  VendorProfileModel? _profile;
  ProfileState _fetchState = ProfileState.idle;
  ProfileState _updateState = ProfileState.idle;
  String? _errorMessage;

  // Getters
  VendorProfileModel? get profile => _profile;
  ProfileState get fetchState => _fetchState;
  ProfileState get updateState => _updateState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _fetchState == ProfileState.loading;
  bool get isUpdating => _updateState == ProfileState.loading;

  // Fetch vendor profile
  Future<void> fetchVendorProfile() async {
    _fetchState = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final vendorId = await SharedPreferenceHelper.getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found. Please login again.');
      }


      print('vendorrrrrrrrrrrrrrr iddddddddddddddd $vendorId');

      _profile = await _service.getVendorProfile(vendorId);
      _fetchState = ProfileState.success;
    } catch (e) {
      _fetchState = ProfileState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  // Update vendor profile
  Future<bool> updateVendorProfile({
    required String name,
    required String email,
    File? hostelImage,
  }) async {
    _updateState = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final vendorId = await SharedPreferenceHelper.getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found. Please login again.');
      }

      final updatedProfile = await _service.updateVendorProfile(
        vendorId: vendorId,
        name: name,
        email: email,
        hostelImage: hostelImage,
      );

      _profile = updatedProfile;


      await SharedPreferenceHelper.saveVendorData(
        VendorModel(
          id: updatedProfile.vendorId,
          name: updatedProfile.name,
          mobileNumber: updatedProfile.mobileNumber,
          email: updatedProfile.email,
          hostelImage: updatedProfile.hostelImage.toString(),
        ),
      );

      _updateState = ProfileState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _updateState = ProfileState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void resetUpdateState() {
    _updateState = ProfileState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
