import 'package:brando_vendor/model/streaming_model.dart';
import 'package:brando_vendor/services/streaming/stream_service.dart';
import 'package:flutter/foundation.dart';

enum StreamingStatus { idle, loading, streaming, stopped, error }

class CameraStreamingProvider extends ChangeNotifier {
  final CameraStreamingService _service = CameraStreamingService();

  // ── State ────────────────────────────────────────────────────────────────────

  StreamingStatus _streamingStatus = StreamingStatus.idle;
  StreamingStatus get streamingStatus => _streamingStatus;

  StartStreamingResponseModel? _startStreamingResponse;
  StartStreamingResponseModel? get startStreamingResponse =>
      _startStreamingResponse;

  StopStreamingResponseModel? _stopStreamingResponse;
  StopStreamingResponseModel? get stopStreamingResponse =>
      _stopStreamingResponse;

  LiveStreamModel? _liveStream;
  LiveStreamModel? get liveStream => _liveStream;

  UnknownVisitorsResponseModel? _unknownVisitorsResponse;
  UnknownVisitorsResponseModel? get unknownVisitorsResponse =>
      _unknownVisitorsResponse;

  bool _isLoadingVisitors = false;
  bool get isLoadingVisitors => _isLoadingVisitors;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isStreaming => _streamingStatus == StreamingStatus.streaming;
  bool get isLoading => _streamingStatus == StreamingStatus.loading;
  bool get hasError => _streamingStatus == StreamingStatus.error;

  // ── Start Streaming ──────────────────────────────────────────────────────────

  Future<void> startStreaming({
    required String hostelId,
    required String cameraId,
    String? token,
  }) async {
    _setStreamingStatus(StreamingStatus.loading);
    _clearError();

    try {
      final response = await _service.startStreaming(
        hostelId: hostelId,
        cameraId: cameraId,
        token: token,
      );

      _startStreamingResponse = response;
      _setStreamingStatus(StreamingStatus.streaming);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Stop Streaming ───────────────────────────────────────────────────────────

  Future<void> stopStreaming({
    required String hostelId,
    required String cameraId,
    String? token,
  }) async {
    _setStreamingStatus(StreamingStatus.loading);
    _clearError();

    try {
      final response = await _service.stopStreaming(
        hostelId: hostelId,
        cameraId: cameraId,
        token: token,
      );

      _stopStreamingResponse = response;
      _startStreamingResponse = null;
      _liveStream = null;
      _setStreamingStatus(StreamingStatus.stopped);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Get Live Stream ──────────────────────────────────────────────────────────

  Future<void> getLiveStream({
    required String hostelId,
    required String cameraId,
    String? token,
  }) async {
    _setStreamingStatus(StreamingStatus.loading);
    _clearError();

    try {
      final response = await _service.getLiveStream(
        hostelId: hostelId,
        cameraId: cameraId,
        token: token,
      );

      _liveStream = response;
      _setStreamingStatus(StreamingStatus.streaming);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Get Unknown Visitors ─────────────────────────────────────────────────────

  Future<void> getUnknownVisitors({
    required String hostelId,
    String? token,
  }) async {
    _isLoadingVisitors = true;
    _clearError();
    notifyListeners();

    try {
      final response = await _service.getUnknownVisitors(
        hostelId: hostelId,
        token: token,
      );

      _unknownVisitorsResponse = response;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingVisitors = false;
      notifyListeners();
    }
  }

  // ── Reset ────────────────────────────────────────────────────────────────────

  void resetStreaming() {
    _streamingStatus = StreamingStatus.idle;
    _startStreamingResponse = null;
    _stopStreamingResponse = null;
    _liveStream = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearVisitors() {
    _unknownVisitorsResponse = null;
    notifyListeners();
  }

  // ── Private Helpers ──────────────────────────────────────────────────────────

  void _setStreamingStatus(StreamingStatus status) {
    _streamingStatus = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _streamingStatus = StreamingStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}