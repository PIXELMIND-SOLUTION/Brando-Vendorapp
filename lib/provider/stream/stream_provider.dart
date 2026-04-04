
import 'dart:async';
import 'package:brando_vendor/model/camera_model.dart';
import 'package:brando_vendor/model/streaming_model.dart';
import 'package:brando_vendor/services/streaming/stream_service.dart';
import 'package:flutter/material.dart';


enum StreamStatus { idle, loading, streaming, stopped, error }

class StreamCameraProvider extends ChangeNotifier {
  final StreamService _streamService;

  StreamCameraProvider({StreamService? streamService})
      : _streamService = streamService ?? StreamService();

  // ── State ──────────────────────────────────────────────────────────────────
  LiveStreamModel? _liveStream;
  StreamStatus _status = StreamStatus.idle;
  String _errorMessage = '';
  bool _isLoadingToggle = false;
  Timer? _pollingTimer;

  /// Map of cameraId → LiveStreamModel for multi-camera home screen display
  final Map<String, LiveStreamModel> _cameraStreamMap = {};

  // ── Getters ────────────────────────────────────────────────────────────────
  LiveStreamModel? get liveStream => _liveStream;
  StreamStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoadingToggle => _isLoadingToggle;
  bool get isLoading => _status == StreamStatus.loading;
  bool get isStreaming => _liveStream?.isStreaming ?? false;
  bool get hasUnknownUser =>
      _liveStream?.unknownUserDetection.hasUnknownUser ?? false;
  String get resolvedStreamUrl => _liveStream?.resolvedStreamUrl ?? '';

  /// Returns the cached stream data for a specific camera
  LiveStreamModel? getStreamForCamera(String cameraId) =>
      _cameraStreamMap[cameraId];

  // ── Fetch All Camera Streams (for HomeScreen) ──────────────────────────────
  /// Fetches stream data for all cameras of a hostel in parallel and caches by cameraId.
  Future<void> fetchAllCameraStreams({
    required String hostelId,
    required List<CameraModel> cameras,
    required String token,
  }) async {
    _status = StreamStatus.loading;
    notifyListeners();

    try {
      // Fetch all in parallel
      final results = await Future.wait(
        cameras.map(
          (cam) => _streamService
              .getLiveStream(
                hostelId: hostelId,
                cameraId: cam.cameraId,
                token: token,
              )
              .then((stream) => MapEntry(cam.cameraId, stream))
              .catchError((_) => MapEntry(cam.cameraId, null)),
        ),
      );

      for (final entry in results) {
        if (entry.value != null) {
          _cameraStreamMap[entry.key] = entry.value!;
        }
      }

      // Set the first camera's stream as the primary liveStream
      if (_cameraStreamMap.isNotEmpty) {
        _liveStream = _cameraStreamMap.values.first;
        _status = _liveStream!.isStreaming
            ? StreamStatus.streaming
            : StreamStatus.stopped;
      } else {
        _status = StreamStatus.idle;
      }
    } catch (e) {
      _status = StreamStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // ── Fetch Live Stream (single camera) ─────────────────────────────────────
  Future<void> fetchLiveStream({
    required String hostelId,
    required String cameraId,
    required String token,
  }) async {
    _status = StreamStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final stream = await _streamService.getLiveStream(
        hostelId: hostelId,
        cameraId: cameraId,
        token: token,
      );
      _liveStream = stream;
      _cameraStreamMap[cameraId] = stream;
      _status = stream.isStreaming
          ? StreamStatus.streaming
          : StreamStatus.stopped;
    } catch (e) {
      _status = StreamStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // ── Start Streaming ────────────────────────────────────────────────────────
  Future<bool> startStreaming({
    required String hostelId,
    required String cameraId,
    required String token,
  }) async {
    _isLoadingToggle = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _streamService.startStreaming(
        hostelId: hostelId,
        cameraId: cameraId,
        token: token,
      );

      if (result.success) {
        await fetchLiveStream(
          hostelId: hostelId,
          cameraId: cameraId,
          token: token,
        );
        _startPolling(hostelId: hostelId, cameraId: cameraId, token: token);
      }

      _isLoadingToggle = false;
      notifyListeners();
      return result.success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingToggle = false;
      notifyListeners();
      return false;
    }
  }

  // ── Stop Streaming ─────────────────────────────────────────────────────────
  Future<bool> stopStreaming({
    required String hostelId,
    required String cameraId,
    required String token,
  }) async {
    _isLoadingToggle = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _streamService.stopStreaming(
        hostelId: hostelId,
        cameraId: cameraId,
        token: token,
      );

      if (result.success) {
        _stopPolling();
        await fetchLiveStream(
          hostelId: hostelId,
          cameraId: cameraId,
          token: token,
        );
      }

      _isLoadingToggle = false;
      notifyListeners();
      return result.success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingToggle = false;
      notifyListeners();
      return false;
    }
  }

  // ── Polling ────────────────────────────────────────────────────────────────
  void _startPolling({
    required String hostelId,
    required String cameraId,
    required String token,
    Duration interval = const Duration(seconds: 5),
  }) {
    _stopPolling();
    _pollingTimer = Timer.periodic(interval, (_) {
      fetchLiveStream(hostelId: hostelId, cameraId: cameraId, token: token);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ── Reset ──────────────────────────────────────────────────────────────────
  void reset() {
    _stopPolling();
    _liveStream = null;
    _cameraStreamMap.clear();
    _status = StreamStatus.idle;
    _errorMessage = '';
    _isLoadingToggle = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}