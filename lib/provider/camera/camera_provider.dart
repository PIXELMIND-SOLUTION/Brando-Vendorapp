import 'package:brando_vendor/model/camera_model.dart';
import 'package:brando_vendor/services/camera/camera_service.dart';
import 'package:flutter/foundation.dart';

enum CameraState { idle, loading, success, error }

class CameraProvider extends ChangeNotifier {
  final CameraService _service = CameraService();

  // ── State ────────────────────────────────────────────────────────────────────

  CameraState _state = CameraState.idle;
  String _errorMessage = '';
  List<CameraModel> _cameras = [];
  CameraModel? _selectedCamera;

  // ── Getters ──────────────────────────────────────────────────────────────────

  CameraState get state => _state;
  String get errorMessage => _errorMessage;
  List<CameraModel> get cameras => _cameras;
  CameraModel? get selectedCamera => _selectedCamera;
  bool get isLoading => _state == CameraState.loading;

  // ── Add Camera ───────────────────────────────────────────────────────────────

  Future<bool> addCamera({
    required String hostelId,
    required CameraPayload payload,
  }) async {
    _setState(CameraState.loading);
    try {
      final response = await _service.addCamera(
        hostelId: hostelId,
        payload: payload,
      );
      if (response.success && response.camera != null) {
        _cameras.add(response.camera!);
        _setState(CameraState.success);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Get All Hostel Cameras ───────────────────────────────────────────────────

  Future<void> getAllHostelCameras(String hostelId) async {
    _setState(CameraState.loading);
    try {
      _cameras = await _service.getAllHostelCameras(hostelId);
      _setState(CameraState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Get Single Camera ────────────────────────────────────────────────────────

  Future<void> getSingleCamera({
    required String hostelId,
    required String cameraId,
  }) async {
    _setState(CameraState.loading);
    try {
      _selectedCamera = await _service.getSingleCamera(
        hostelId: hostelId,
        cameraId: cameraId,
      );
      _setState(CameraState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Update Camera ────────────────────────────────────────────────────────────

  Future<bool> updateCamera({
    required String hostelId,
    required String cameraId,
    required CameraPayload payload,
  }) async {
    _setState(CameraState.loading);
    try {
      final response = await _service.updateCamera(
        hostelId: hostelId,
        cameraId: cameraId,
        payload: payload,
      );
      if (response.success && response.camera != null) {
        final index =
            _cameras.indexWhere((c) => c.cameraId == cameraId);
        if (index != -1) {
          _cameras[index] = response.camera!;
        }
        if (_selectedCamera?.cameraId == cameraId) {
          _selectedCamera = response.camera;
        }
        _setState(CameraState.success);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Delete Camera ────────────────────────────────────────────────────────────

  Future<bool> deleteCamera({
    required String hostelId,
    required String cameraId,
  }) async {
    _setState(CameraState.loading);
    try {
      final success = await _service.deleteCamera(
        hostelId: hostelId,
        cameraId: cameraId,
      );
      if (success) {
        _cameras.removeWhere((c) => c.cameraId == cameraId);
        if (_selectedCamera?.cameraId == cameraId) {
          _selectedCamera = null;
        }
        _setState(CameraState.success);
        return true;
      } else {
        _setError('Failed to delete camera');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void clearSelectedCamera() {
    _selectedCamera = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _state = CameraState.idle;
    notifyListeners();
  }

  void _setState(CameraState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message.replaceAll('Exception: ', '');
    _state = CameraState.error;
    notifyListeners();
  }
}