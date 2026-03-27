// import 'package:brando_vendor/model/form_details_model.dart';
// import 'package:brando_vendor/services/form/form_detail_service.dart';
// import 'package:flutter/material.dart';


// enum FormDetailsState { idle, loading, success, error }

// class FormDetailsProvider extends ChangeNotifier {
//   final FormDetailsService _service = FormDetailsService();

//   FormDetailsState _state = FormDetailsState.idle;
//   FormDetailsResponse? _formDetailsResponse;
//   String _errorMessage = '';

//   // Getters
//   FormDetailsState get state => _state;
//   FormDetailsResponse? get formDetailsResponse => _formDetailsResponse;
//   List<Submission> get submissions => _formDetailsResponse?.submissions ?? [];
//   String get errorMessage => _errorMessage;
//   bool get isLoading => _state == FormDetailsState.loading;
//   bool get hasError => _state == FormDetailsState.error;

//   Future<void> fetchFormDetails(String hostelId) async {
//     _setState(FormDetailsState.loading);
//     _errorMessage = '';

//     try {
//       _formDetailsResponse = await _service.getFormDetails(hostelId);
//       _setState(FormDetailsState.success);
//     } catch (e) {
//       _errorMessage = e.toString();
//       _setState(FormDetailsState.error);
//     }
//   }

//   void clearData() {
//     _formDetailsResponse = null;
//     _errorMessage = '';
//     _setState(FormDetailsState.idle);
//   }

//   void _setState(FormDetailsState newState) {
//     _state = newState;
//     notifyListeners();
//   }
// }

















import 'package:brando_vendor/model/form_details_model.dart';
import 'package:brando_vendor/services/form/form_detail_service.dart';
import 'package:flutter/material.dart';

enum FormDetailsState { idle, loading, success, error }

class FormDetailsProvider extends ChangeNotifier {
  final FormDetailsService _service = FormDetailsService();

  // ── Fetch state ──────────────────────────────────────────────
  FormDetailsState _state = FormDetailsState.idle;
  FormDetailsResponse? _formDetailsResponse;
  String _errorMessage = '';

  FormDetailsState get state => _state;
  FormDetailsResponse? get formDetailsResponse => _formDetailsResponse;
  List<Submission> get submissions => _formDetailsResponse?.submissions ?? [];
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == FormDetailsState.loading;
  bool get hasError => _state == FormDetailsState.error;

  // ── Update state ─────────────────────────────────────────────
  bool _isUpdating = false;
  String _updateError = '';

  bool get isUpdating => _isUpdating;
  String get updateError => _updateError;

  // ── Transfer room state ───────────────────────────────────────
  bool _isTransferring = false;
  String _transferError = '';

  bool get isTransferring => _isTransferring;
  String get transferError => _transferError;

  // ── Delete state ──────────────────────────────────────────────
  bool _isDeleting = false;
  String _deleteError = '';

  bool get isDeleting => _isDeleting;
  String get deleteError => _deleteError;

  // ── Actions ───────────────────────────────────────────────────

  Future<void> fetchFormDetails(String hostelId) async {
    _setState(FormDetailsState.loading);
    _errorMessage = '';

    try {
      _formDetailsResponse = await _service.getFormDetails(hostelId);
      _setState(FormDetailsState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(FormDetailsState.error);
    }
  }

  /// Returns `true` on success.
  Future<bool> updateSubmission({
    required String submissionId,
    required String hostelId,           // to refresh the list after update
    required Map<String, String> fields,
    Map<String, String>? filePaths,
  }) async {
    _isUpdating = true;
    _updateError = '';
    notifyListeners();

    try {
      await _service.updateSubmission(
        submissionId: submissionId,
        fields: fields,
        filePaths: filePaths,
      );
      await fetchFormDetails(hostelId); // refresh list
      return true;
    } catch (e) {
      _updateError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Returns `true` on success.
  Future<bool> transferRoom({
    required String submissionId,
    required String hostelId,           // to refresh the list after transfer
    required String roomNo,
  }) async {
    _isTransferring = true;
    _transferError = '';
    notifyListeners();

    try {
      await _service.transferRoom(
        submissionId: submissionId,
        roomNo: roomNo,
      );
      await fetchFormDetails(hostelId); // refresh list
      return true;
    } catch (e) {
      _transferError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isTransferring = false;
      notifyListeners();
    }
  }

  /// Returns `true` on success.
  Future<bool> deleteSubmission({
    required String submissionId,
    required String hostelId,           // to refresh the list after delete
  }) async {
    _isDeleting = true;
    _deleteError = '';
    notifyListeners();

    try {
      await _service.deleteSubmission(submissionId);
      await fetchFormDetails(hostelId); // refresh list
      return true;
    } catch (e) {
      _deleteError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void clearData() {
    _formDetailsResponse = null;
    _errorMessage = '';
    _updateError = '';
    _transferError = '';
    _deleteError = '';
    _setState(FormDetailsState.idle);
  }

  void _setState(FormDetailsState newState) {
    _state = newState;
    notifyListeners();
  }
}