import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/camera_model.dart';
import 'package:brando_vendor/model/category_model.dart';
import 'package:brando_vendor/model/create_hostel_model.dart';
import 'package:brando_vendor/model/streaming_model.dart';
import 'package:brando_vendor/provider/camera/camera_provider.dart';
import 'package:brando_vendor/provider/create/category/category_provider.dart';
import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
import 'package:brando_vendor/provider/stream/stream_provider.dart';
import 'package:brando_vendor/views/details/hostel_details.dart';
import 'package:brando_vendor/views/location/location_screen.dart';
import 'package:brando_vendor/views/notifications/notification_screen.dart';
import 'package:brando_vendor/widgets/app_back_control.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' hide StreamProvider;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// bool _hostelIsAc(Hostel hostel) {
//   final types = hostel.type.map((t) => t.trim().toUpperCase()).toList();
//   if (types.any((t) => t == 'NON-AC' || t == 'NON AC')) return false;
//   return types.contains('AC');
// }

bool _hostelIsAc(Hostel hostel) {
  // First check sharings (what the API actually returns)
  if (hostel.sharings.isNotEmpty) {
    return hostel.sharings.any((s) => s.type!.trim().toUpperCase() == 'AC');
  }

  // Fallback to type field
  final types = hostel.type.map((t) => t.trim().toUpperCase()).toList();
  if (types.any((t) => t == 'NON-AC' || t == 'NON AC')) return false;
  return types.contains('AC');
}

// ─────────────────────────────────────────────
// LIVE STREAM WEBVIEW SCREEN
// ─────────────────────────────────────────────
class LiveStreamWebViewScreen extends StatefulWidget {
  final String url;
  final String cameraName;

  const LiveStreamWebViewScreen({
    super.key,
    required this.url,
    required this.cameraName,
  });

  @override
  State<LiveStreamWebViewScreen> createState() =>
      _LiveStreamWebViewScreenState();
}

class _LiveStreamWebViewScreenState extends State<LiveStreamWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    // ── Android: allow media autoplay with audio ──────────────────────────
    if (Platform.isAndroid) {
      final androidParams = AndroidWebViewControllerCreationParams();
      final androidController = AndroidWebViewController(androidParams);
      // KEY FIX: disable the requirement for a user gesture to start media
      androidController.setMediaPlaybackRequiresUserGesture(false);

      _controller = WebViewController.fromPlatform(androidController);
    } else {
      _controller = WebViewController();
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            // After page loads, unmute and try to play any media elements
            _controller.runJavaScript('''
              (function() {
                function tryPlay() {
                  var media = document.querySelectorAll('video, audio');
                  media.forEach(function(el) {
                    el.muted = false;
                    el.volume = 1.0;
                    el.play().catch(function(e) { console.log('play error:', e); });
                  });
                }
                tryPlay();
                // Also attempt after a short delay in case player initialises late
                setTimeout(tryPlay, 1500);
                setTimeout(tryPlay, 3000);
              })();
            ''');
          },
          onWebResourceError: (error) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.cameraName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 6),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => _controller.reload(),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF0D1B2A),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.greenAccent,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Connecting to live stream...',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUCCESS OVERLAY
// ─────────────────────────────────────────────
class _SuccessOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  const _SuccessOverlay({required this.message, required this.onDismiss});
  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgController,
      _circleController,
      _checkController,
      _textController;
  late Animation<double> _bgFade, _circleScale, _checkDraw, _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _bgFade = CurvedAnimation(parent: _bgController, curve: Curves.easeIn);
    _circleScale = CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut,
    );
    _checkDraw = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOut,
    );
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _bgController.forward().then(
      (_) => _circleController.forward().then(
        (_) => _checkController.forward().then(
          (_) => _textController.forward().then(
            (_) => Future.delayed(const Duration(milliseconds: 1400), () {
              if (mounted) widget.onDismiss();
            }),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _circleController.dispose();
    _checkController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _bgFade,
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _circleScale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.35),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkDraw,
                    builder: (_, __) => CustomPaint(
                      painter: _CheckPainter(progress: _checkDraw.value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your hostel is live now!',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final p1 = Offset(cx - 18, cy + 2);
    final pMid = Offset(cx - 4, cy + 16);
    final p2 = Offset(cx + 20, cy - 14);
    final seg1Length = (pMid - p1).distance;
    final seg2Length = (p2 - pMid).distance;
    final drawn = progress * (seg1Length + seg2Length);
    final path = Path();
    if (drawn <= seg1Length) {
      final t = drawn / seg1Length;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p1.dx + (pMid.dx - p1.dx) * t, p1.dy + (pMid.dy - p1.dy) * t);
    } else {
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(pMid.dx, pMid.dy);
      final t = (drawn - seg1Length) / seg2Length;
      path.lineTo(
        pMid.dx + (p2.dx - pMid.dx) * t,
        pMid.dy + (p2.dy - pMid.dy) * t,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _carouselController = PageController();
  int _carouselPage = 0;
  List<String> _carouselImages = [];
  bool _isLoadingBanners = true;
  bool _showSuccessOverlay = false;
  String _successMessage = '';
  bool _showDailyPrice = false;

  @override
  void initState() {
    super.initState();
    fetchBanners();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHostels());
  }

  Future<void> _loadHostels() async {
    final vendorId = await SharedPreferenceHelper.getVendorId();
    if (vendorId == null || !mounted) return; // ← already exists, good
    await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);

    if (!mounted) return; // ← ADD THIS
    final hostels = context.read<HostelProvider>().hostels;
    if (hostels.isNotEmpty && mounted) {
      await context.read<CameraProvider>().getAllHostelCameras(
        hostels.first.id,
      );

      if (!mounted) return; // ← ADD THIS
      final cameras = context.read<CameraProvider>().cameras;
      final token = await SharedPreferenceHelper.getToken() ?? '';
      if (cameras.isNotEmpty && mounted) {
        await context.read<StreamCameraProvider>().fetchAllCameraStreams(
          hostelId: hostels.first.id,
          cameras: cameras,
          token: token,
        );
      }
    }
  }

  // Future<void> _loadHostels() async {
  //   final vendorId = await SharedPreferenceHelper.getVendorId();
  //   if (vendorId == null || !mounted) return;
  //   await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);

  //   final hostels = context.read<HostelProvider>().hostels;
  //   if (hostels.isNotEmpty && mounted) {
  //     await context.read<CameraProvider>().getAllHostelCameras(
  //       hostels.first.id,
  //     );

  //     final cameras = context.read<CameraProvider>().cameras;
  //     final token = await SharedPreferenceHelper.getToken() ?? '';
  //     if (cameras.isNotEmpty && mounted) {
  //       await context.read<StreamCameraProvider>().fetchAllCameraStreams(
  //         hostelId: hostels.first.id,
  //         cameras: cameras,
  //         token: token,
  //       );
  //     }
  //   }
  // }

  //   Future<void> fetchBanners() async {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('http://187.127.146.52:2003/api/Admin/getAllBanners'),
  //       );
  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         if (data['success'] == true) {
  //           final images = <String>[];
  //           for (var banner in data['banners'] as List) {
  //             images.addAll((banner['images'] as List).map((e) => e.toString()));
  //           }

  //           if (!mounted) return;
  // setState(() {
  //   _carouselImages = images;
  //   _isLoadingBanners = false;
  // });
  //           // setState(() {
  //           //   _carouselImages = images;
  //           //   _isLoadingBanners = false;
  //           // });
  //           return;
  //         }
  //       }
  //     } catch (_) {}
  //     setState(() => _isLoadingBanners = false);
  //   }

  Future<void> fetchBanners() async {
    try {
      final response = await http.get(
        Uri.parse('http://187.127.146.52:2003/api/Admin/getAllBanners'),
      );
      if (!mounted) return; // ← ADD THIS
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final images = <String>[];
          for (var banner in data['banners'] as List) {
            images.addAll((banner['images'] as List).map((e) => e.toString()));
          }
          if (!mounted) return; // ← ADD THIS (redundant but safe)
          setState(() {
            _carouselImages = images;
            _isLoadingBanners = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted)
      setState(() => _isLoadingBanners = false); // ← WRAP with mounted check
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) => setState(() {
    _successMessage = message;
    _showSuccessOverlay = true;
  });

  void _dismissSuccess() {
    if (mounted) setState(() => _showSuccessOverlay = false);
  }

  bool _getDefaultAcForNewHostel() {
    final hostels = context.read<HostelProvider>().hostels;
    if (hostels.isEmpty) return false;
    final hasNonAc = hostels.any((h) => !_hostelIsAc(h));
    final hasAc = hostels.any((h) => _hostelIsAc(h));
    if (hasNonAc && !hasAc) return true;
    if (hasAc && !hasNonAc) return false;
    return false;
  }

  bool _shouldLockAcToggleForNew() {
    final hostels = context.read<HostelProvider>().hostels;
    if (hostels.isEmpty) return false;
    final hasNonAc = hostels.any((h) => !_hostelIsAc(h));
    final hasAc = hostels.any((h) => _hostelIsAc(h));
    return (hasNonAc && !hasAc) || (hasAc && !hasNonAc);
  }

  Future<void> _openCreateHostel() async {
    final defaultAc = _getDefaultAcForNewHostel();
    final lockToggle = _shouldLockAcToggleForNew();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HifiDetailsScreen(
          forcedIsAc: defaultAc,
          lockAcToggle: lockToggle,
          onSave: (request) async {
            final vendorId = await SharedPreferenceHelper.getVendorId();
            if (vendorId == null) return;
            final finalRequest = HostelRequest(
              categoryId: request.categoryId,
              vendorId: vendorId,
              name: request.name,
              rating: request.rating,
              address: request.address,
              monthlyAdvance: request.monthlyAdvance,
              latitude: request.latitude,
              longitude: request.longitude,
              isAc: request.isAc,
              sharings: request.sharings,
              imagePaths: request.imagePaths,
            );
            if (!mounted) return;
            final success = await context.read<HostelProvider>().createHostel(
              finalRequest,
            );
            if (mounted) {
              if (success) {
                _showSuccess('Hostel Created!');
              } else {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(
                //       context.read<HostelProvider>().errorMessage ??
                //           'Failed to create hostel',
                //     ),
                //     backgroundColor: Colors.red,
                //   ),
                // );
              }
            }
          },
        ),
      ),
    );
  }

  // Future<void> _openEditHostel(Hostel hostel) async {
  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => HifiDetailsScreen(
  //         existingHostel: hostel,
  //         onSave: (request) async {
  //           if (!mounted) return;
  //           final success = await context.read<HostelProvider>().updateHostel(
  //             hostelId: hostel.id,
  //             request: request,
  //           );
  //           if (mounted) {
  //             if (success) {
  //               _showSuccess('Hostel Updated!');
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text(
  //                     context.read<HostelProvider>().errorMessage ??
  //                         'Failed to update hostel',
  //                   ),
  //                   backgroundColor: Colors.red,
  //                 ),
  //               );
  //             }
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }

  Future<void> _openEditHostel(Hostel hostel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HifiDetailsScreen(
          existingHostel: hostel,
          onSave: (request) async {
            if (!mounted) return;
            final vendorId = await SharedPreferenceHelper.getVendorId();

            final updatedRequest = HostelRequest(
              categoryId: request.categoryId,
              vendorId: vendorId, // ✅ FIX HERE
              name: request.name,
              rating: request.rating,
              address: request.address,
              monthlyAdvance: request.monthlyAdvance,
              latitude: request.latitude,
              longitude: request.longitude,
              isAc: request.isAc,
              sharings: request.sharings,
              imagePaths: request.imagePaths,
            );

            final success = await context.read<HostelProvider>().updateHostel(
              hostelId: hostel.id,
              request: updatedRequest,
            );
            if (mounted) {
              if (success) {
                _showSuccess('Hostel Updated!');
                // 🔥 THIS IS THE KEY FIX - Refresh after update
                await _refreshHostelsData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<HostelProvider>().errorMessage ??
                          'Failed to update hostel',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _refreshHostelsData() async {
    final vendorId = await SharedPreferenceHelper.getVendorId();
    if (vendorId == null || !mounted) return;

    // Refresh hostels
    await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);

    if (!mounted) return;
    final hostels = context.read<HostelProvider>().hostels;

    // Also refresh cameras and streams if hostels exist
    if (hostels.isNotEmpty && mounted) {
      await context.read<CameraProvider>().getAllHostelCameras(
        hostels.first.id,
      );

      if (!mounted) return;
      final cameras = context.read<CameraProvider>().cameras;
      final token = await SharedPreferenceHelper.getToken() ?? '';
      if (cameras.isNotEmpty && mounted) {
        await context.read<StreamCameraProvider>().fetchAllCameraStreams(
          hostelId: hostels.first.id,
          cameras: cameras,
          token: token,
        );
      }
    }
  }

  Future<void> _deleteHostel(Hostel hostel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE53935),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Hostel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${hostel.name}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context.read<HostelProvider>().deleteHostel(
      hostel.id,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Hostel deleted successfully'
                : context.read<HostelProvider>().errorMessage ??
                      'Failed to delete hostel',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _openAddCameraSheet(String hostelId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CameraProvider>(),
        child: _AddCameraSheet(hostelId: hostelId),
      ),
    );
  }

  // Add this method to _HomeScreenState class
  Future<void> _refreshAllData() async {
    try {
      // Refresh banners
      await fetchBanners();

      // Refresh hostels data
      final vendorId = await SharedPreferenceHelper.getVendorId();
      if (vendorId != null && mounted) {
        await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);

        if (mounted) {
          final hostels = context.read<HostelProvider>().hostels;
          if (hostels.isNotEmpty) {
            await context.read<CameraProvider>().getAllHostelCameras(
              hostels.first.id,
            );

            if (mounted) {
              final cameras = context.read<CameraProvider>().cameras;
              final token = await SharedPreferenceHelper.getToken() ?? '';
              if (cameras.isNotEmpty) {
                await context
                    .read<StreamCameraProvider>()
                    .fetchAllCameraStreams(
                      hostelId: hostels.first.id,
                      cameras: cameras,
                      token: token,
                    );
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return AppBackControl(
  //     showConfirmationDialog: true,
  //     dialogTitle: 'Exit App?',
  //     dialogMessage: 'Are you sure you want to exit the app?',
  //     confirmText: 'Exit',
  //     cancelText: 'Stay',
  //     onBackPressed: () {
  //       // Optional: Do any cleanup if needed
  //       print('User exiting app');
  //     },
  //     child: Stack(
  //       children: [
  //         Scaffold(
  //           backgroundColor: Colors.white,
  //           body: SafeArea(
  //             child: RefreshIndicator(
  //               onRefresh: _refreshAllData, // Add this method
  //               color: const Color(0xFFE53935),
  //               backgroundColor: Colors.white,
  //               strokeWidth: 2,

  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // ── Top bar ─────────────────────────────────────────────
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 10,
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               const Text(
  //                                 'Location',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                   color: Colors.grey,
  //                                 ),
  //                               ),
  //                               Row(
  //                                 children: [
  //                                   const Icon(
  //                                     Icons.location_on,
  //                                     color: Color(0xFFE53935),
  //                                     size: 16,
  //                                   ),
  //                                   const SizedBox(width: 4),
  //                                   GestureDetector(
  //                                     onTap: () {
  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               LocationScreen(),
  //                                         ),
  //                                       );
  //                                     },
  //                                     child: const Text(
  //                                       'Kphb Hyderabad Kukatpally ...',
  //                                       style: TextStyle(
  //                                         fontSize: 13,
  //                                         fontWeight: FontWeight.w600,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   const Icon(
  //                                     Icons.keyboard_arrow_down,
  //                                     size: 18,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                           Stack(
  //                             children: [
  //                               GestureDetector(
  //                                 onTap: () => Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                     builder: (_) => NotificationScreen(),
  //                                   ),
  //                                 ),
  //                                 child: const Icon(
  //                                   Icons.notifications_none,
  //                                   size: 26,
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 right: 0,
  //                                 top: 0,
  //                                 child: Container(
  //                                   width: 8,
  //                                   height: 8,
  //                                   decoration: const BoxDecoration(
  //                                     color: Color(0xFFE53935),
  //                                     shape: BoxShape.circle,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),

  //                     // ── Carousel ─────────────────────────────────────────────
  //                     SizedBox(
  //                       height: 130,
  //                       child: _isLoadingBanners
  //                           ? const Center(child: CircularProgressIndicator())
  //                           : _carouselImages.isEmpty
  //                           ? const Center(child: Text('No banners available'))
  //                           : PageView.builder(
  //                               controller: _carouselController,
  //                               itemCount: _carouselImages.length,
  //                               onPageChanged: (i) =>
  //                                   setState(() => _carouselPage = i),
  //                               itemBuilder: (_, index) => Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                   horizontal: 16,
  //                                 ),
  //                                 child: ClipRRect(
  //                                   borderRadius: BorderRadius.circular(12),
  //                                   child: Stack(
  //                                     fit: StackFit.expand,
  //                                     children: [
  //                                       Image.network(
  //                                         _carouselImages[index],
  //                                         fit: BoxFit.cover,
  //                                         errorBuilder: (_, __, ___) =>
  //                                             Container(
  //                                               color: const Color(0xFFEEEEEE),
  //                                               child: const Center(
  //                                                 child: Icon(
  //                                                   Icons.broken_image,
  //                                                   size: 40,
  //                                                   color: Colors.grey,
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                       ),
  //                                       Container(
  //                                         decoration: BoxDecoration(
  //                                           gradient: LinearGradient(
  //                                             begin: Alignment.centerLeft,
  //                                             end: Alignment.centerRight,
  //                                             colors: [
  //                                               Colors.black.withOpacity(0.4),
  //                                               Colors.transparent,
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                     ),

  //                     // Dots
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 8),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: List.generate(
  //                           _carouselImages.length,
  //                           (i) => AnimatedContainer(
  //                             duration: const Duration(milliseconds: 300),
  //                             margin: const EdgeInsets.symmetric(horizontal: 3),
  //                             width: _carouselPage == i ? 18 : 8,
  //                             height: 8,
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(4),
  //                               color: _carouselPage == i
  //                                   ? const Color(0xFFE53935)
  //                                   : Colors.grey.shade300,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),

  //                     // ── Camera Capturing section ──────────────────────────────
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 4,
  //                       ),
  //                       child: RichText(
  //                         text: const TextSpan(
  //                           children: [
  //                             TextSpan(
  //                               text: 'Camera ',
  //                               style: TextStyle(
  //                                 color: Color(0xFFE53935),
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 16,
  //                               ),
  //                             ),
  //                             TextSpan(
  //                               text: 'Capturing',
  //                               style: TextStyle(
  //                                 color: Colors.black,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 16,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),

  //                     Consumer3<
  //                       HostelProvider,
  //                       CameraProvider,
  //                       StreamCameraProvider
  //                     >(
  //                       builder:
  //                           (
  //                             context,
  //                             hostelProvider,
  //                             cameraProvider,
  //                             streamProvider,
  //                             _,
  //                           ) {
  //                             final hostels = hostelProvider.hostels;
  //                             if (hostels.isEmpty) {
  //                               return Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                   horizontal: 16,
  //                                   vertical: 8,
  //                                 ),
  //                                 child: _AddCameraCard(
  //                                   onTap: null,
  //                                   label: 'Add a hostel first to add cameras',
  //                                 ),
  //                               );
  //                             }

  //                             final hostel = hostels.first;

  //                             return Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                 horizontal: 16,
  //                                 vertical: 8,
  //                               ),
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   if (cameraProvider.cameras.isNotEmpty)
  //                                     SizedBox(
  //                                       height: 100,
  //                                       child: ListView.builder(
  //                                         scrollDirection: Axis.horizontal,
  //                                         itemCount:
  //                                             cameraProvider.cameras.length,
  //                                         itemBuilder: (_, i) {
  //                                           final cam =
  //                                               cameraProvider.cameras[i];
  //                                           final streamData = streamProvider
  //                                               .getStreamForCamera(
  //                                                 cam.cameraId,
  //                                               );
  //                                           return GestureDetector(
  //                                             onTap: () {
  //                                               cameraProvider.getSingleCamera(
  //                                                 hostelId: hostel.id,
  //                                                 cameraId: cam.cameraId,
  //                                               );
  //                                               Navigator.push(
  //                                                 context,
  //                                                 MaterialPageRoute(
  //                                                   builder: (_) => MultiProvider(
  //                                                     providers: [
  //                                                       ChangeNotifierProvider.value(
  //                                                         value: cameraProvider,
  //                                                       ),
  //                                                       ChangeNotifierProvider.value(
  //                                                         value: streamProvider,
  //                                                       ),
  //                                                     ],
  //                                                     child:
  //                                                         CameraDetailsScreen(
  //                                                           hostelId: hostel.id,
  //                                                           camera: cam,
  //                                                         ),
  //                                                   ),
  //                                                 ),
  //                                               );
  //                                             },
  //                                             child: _CameraThumbCard(
  //                                               camera: cam,
  //                                               streamData: streamData,
  //                                             ),
  //                                           );
  //                                         },
  //                                       ),
  //                                     ),

  //                                   if (cameraProvider.cameras.isNotEmpty) ...[
  //                                     const SizedBox(height: 12),
  //                                     _LiveStreamCompactPanel(
  //                                       hostelId: hostel.id,
  //                                       cameras: cameraProvider.cameras,
  //                                       streamProvider: streamProvider,
  //                                     ),
  //                                   ],

  //                                   const SizedBox(height: 10),
  //                                   _AddCameraCard(
  //                                     onTap: () =>
  //                                         _openAddCameraSheet(hostel.id),
  //                                     label: 'Add Your Camera',
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           },
  //                     ),

  //                     // ── Hifi heading + Monthly/Daily toggle ──────────────────
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 4,
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           RichText(
  //                             text: const TextSpan(
  //                               children: [
  //                                 TextSpan(
  //                                   text: 'Hifi ',
  //                                   style: TextStyle(
  //                                     color: Color(0xFFE53935),
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 16,
  //                                   ),
  //                                 ),
  //                                 TextSpan(
  //                                   text: 'Details',
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 16,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           Container(
  //                             decoration: BoxDecoration(
  //                               color: Colors.grey.shade100,
  //                               borderRadius: BorderRadius.circular(20),
  //                               border: Border.all(color: Colors.grey.shade300),
  //                             ),
  //                             child: Row(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 _PriceToggleChip(
  //                                   label: 'Monthly',
  //                                   selected: !_showDailyPrice,
  //                                   onTap: () =>
  //                                       setState(() => _showDailyPrice = false),
  //                                 ),
  //                                 _PriceToggleChip(
  //                                   label: 'Daily',
  //                                   selected: _showDailyPrice,
  //                                   onTap: () =>
  //                                       setState(() => _showDailyPrice = true),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),

  //                     // ── Hostel cards ─────────────────────────────────────────
  //                     Consumer<HostelProvider>(
  //                       builder: (context, provider, _) {
  //                         if (provider.isLoading)
  //                           return const Padding(
  //                             padding: EdgeInsets.symmetric(vertical: 20),
  //                             child: Center(child: CircularProgressIndicator()),
  //                           );
  //                         if (provider.hasError)
  //                           return Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 16,
  //                               vertical: 10,
  //                             ),
  //                             child: Text(
  //                               provider.errorMessage ?? 'Something went wrong',
  //                               style: const TextStyle(color: Colors.red),
  //                             ),
  //                           );
  //                         return Column(
  //                           children: provider.hostels
  //                               .map(
  //                                 (hostel) => Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                     horizontal: 16,
  //                                     vertical: 6,
  //                                   ),
  //                                   child: GestureDetector(
  //                                     onTap: () => Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (_) => HostelDetails(
  //                                           hostel: hostel,
  //                                           qrUrl: hostel.qrUrl,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     child: _HifiHostelCard(
  //                                       hostel: hostel,
  //                                       showDailyPrice: _showDailyPrice,
  //                                       isDeleting:
  //                                           provider.isDeleting &&
  //                                           provider.deletingHostelId ==
  //                                               hostel.id,
  //                                       onEdit: () => _openEditHostel(hostel),
  //                                       onDelete: () => _deleteHostel(hostel),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               )
  //                               .toList(),
  //                         );
  //                       },
  //                     ),

  //                     GestureDetector(
  //                       onTap: _openCreateHostel,
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 16,
  //                           vertical: 8,
  //                         ),
  //                         child: Container(
  //                           width: double.infinity,
  //                           height: 90,
  //                           decoration: BoxDecoration(
  //                             border: Border.all(color: Colors.grey.shade300),
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                           child: const Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.add,
  //                                 size: 32,
  //                                 color: Colors.black54,
  //                               ),
  //                               SizedBox(height: 6),
  //                               Text(
  //                                 'Add Details',
  //                                 style: TextStyle(
  //                                   fontSize: 14,
  //                                   color: Colors.black54,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 80),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         if (_showSuccessOverlay)
  //           Positioned.fill(
  //             child: _SuccessOverlay(
  //               message: _successMessage,
  //               onDismiss: _dismissSuccess,
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return AppBackControl(
      showConfirmationDialog: true,
      dialogTitle: 'Exit App?',
      dialogMessage: 'Are you sure you want to exit the app?',
      confirmText: 'Exit',
      cancelText: 'Stay',
      onBackPressed: () {
        // Optional: Do any cleanup if needed
        print('User exiting app');
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshAllData,
                color: const Color(0xFFE53935),
                backgroundColor: Colors.white,
                strokeWidth: 2,
                displacement: 40, // Add this to make it more responsive
                edgeOffset: 20, // Add this to trigger from edge
                child: CustomScrollView(
                  // Change from SingleChildScrollView to CustomScrollView
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Top bar ─────────────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Color(0xFFE53935),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LocationScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Kphb Hyderabad Kukatpally ...',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NotificationScreen(),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_none,
                                        size: 26,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE53935),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ── Carousel ─────────────────────────────────────────────
                          SizedBox(
                            height: 130,
                            child: _isLoadingBanners
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _carouselImages.isEmpty
                                ? const Center(
                                    child: Text('No banners available'),
                                  )
                                : PageView.builder(
                                    controller: _carouselController,
                                    itemCount: _carouselImages.length,
                                    onPageChanged: (i) =>
                                        setState(() => _carouselPage = i),
                                    itemBuilder: (_, index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              _carouselImages[index],
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    color: const Color(
                                                      0xFFEEEEEE,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.black.withOpacity(
                                                      0.4,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          // Dots
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _carouselImages.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: _carouselPage == i ? 18 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: _carouselPage == i
                                        ? const Color(0xFFE53935)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ── Camera Capturing section ──────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Camera ',
                                    style: TextStyle(
                                      color: Color(0xFFE53935),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Capturing',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Consumer3<
                            HostelProvider,
                            CameraProvider,
                            StreamCameraProvider
                          >(
                            builder:
                                (
                                  context,
                                  hostelProvider,
                                  cameraProvider,
                                  streamProvider,
                                  _,
                                ) {
                                  final hostels = hostelProvider.hostels;
                                  if (hostels.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: _AddCameraCard(
                                        onTap: null,
                                        label:
                                            'Add a hostel first to add cameras',
                                      ),
                                    );
                                  }

                                  final hostel = hostels.first;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (cameraProvider.cameras.isNotEmpty)
                                          SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  cameraProvider.cameras.length,
                                              itemBuilder: (_, i) {
                                                final cam =
                                                    cameraProvider.cameras[i];
                                                final streamData =
                                                    streamProvider
                                                        .getStreamForCamera(
                                                          cam.cameraId,
                                                        );
                                                return GestureDetector(
                                                  onTap: () {
                                                    cameraProvider
                                                        .getSingleCamera(
                                                          hostelId: hostel.id,
                                                          cameraId:
                                                              cam.cameraId,
                                                        );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => MultiProvider(
                                                          providers: [
                                                            ChangeNotifierProvider.value(
                                                              value:
                                                                  cameraProvider,
                                                            ),
                                                            ChangeNotifierProvider.value(
                                                              value:
                                                                  streamProvider,
                                                            ),
                                                          ],
                                                          child:
                                                              CameraDetailsScreen(
                                                                hostelId:
                                                                    hostel.id,
                                                                camera: cam,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: _CameraThumbCard(
                                                    camera: cam,
                                                    streamData: streamData,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                        if (cameraProvider
                                            .cameras
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          _LiveStreamCompactPanel(
                                            hostelId: hostel.id,
                                            cameras: cameraProvider.cameras,
                                            streamProvider: streamProvider,
                                          ),
                                        ],

                                        const SizedBox(height: 10),
                                        _AddCameraCard(
                                          onTap: () =>
                                              _openAddCameraSheet(hostel.id),
                                          label: 'Add Your Camera',
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          ),

                          // ── Hifi heading + Monthly/Daily toggle ──────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Hifi ',
                                        style: TextStyle(
                                          color: Color(0xFFE53935),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Details',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _PriceToggleChip(
                                        label: 'Monthly',
                                        selected: !_showDailyPrice,
                                        onTap: () => setState(
                                          () => _showDailyPrice = false,
                                        ),
                                      ),
                                      _PriceToggleChip(
                                        label: 'Daily',
                                        selected: _showDailyPrice,
                                        onTap: () => setState(
                                          () => _showDailyPrice = true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Hostel cards ─────────────────────────────────────────
                          Consumer<HostelProvider>(
                            builder: (context, provider, _) {
                              if (provider.isLoading)
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              if (provider.hasError)
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    provider.errorMessage ??
                                        'Something went wrong',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              return Column(
                                children: provider.hostels
                                    .map(
                                      (hostel) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HostelDetails(
                                                hostel: hostel,
                                                qrUrl: hostel.qrUrl,
                                              ),
                                            ),
                                          ),
                                          child: _HifiHostelCard(
                                            hostel: hostel,
                                            showDailyPrice: _showDailyPrice,
                                            isDeleting:
                                                provider.isDeleting &&
                                                provider.deletingHostelId ==
                                                    hostel.id,
                                            onEdit: () =>
                                                _openEditHostel(hostel),
                                            onDelete: () =>
                                                _deleteHostel(hostel),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),

                          GestureDetector(
                            onTap: _openCreateHostel,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 32,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Add Details',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showSuccessOverlay)
            Positioned.fill(
              child: _SuccessOverlay(
                message: _successMessage,
                onDismiss: _dismissSuccess,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LIVE STREAM COMPACT PANEL
// ─────────────────────────────────────────────
class _LiveStreamCompactPanel extends StatefulWidget {
  final String hostelId;
  final List<CameraModel> cameras;
  final StreamCameraProvider streamProvider;

  const _LiveStreamCompactPanel({
    required this.hostelId,
    required this.cameras,
    required this.streamProvider,
  });

  @override
  State<_LiveStreamCompactPanel> createState() =>
      _LiveStreamCompactPanelState();
}

class _LiveStreamCompactPanelState extends State<_LiveStreamCompactPanel> {
  int _selectedIndex = 0;

  CameraModel get _selectedCamera => widget.cameras[_selectedIndex];

  LiveStreamModel? get _currentStream =>
      widget.streamProvider.getStreamForCamera(_selectedCamera.cameraId);

  void _openWebView(String url, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveStreamWebViewScreen(url: url, cameraName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _currentStream;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stream?.isStreaming == true
                        ? Colors.greenAccent
                        : Colors.red,
                    boxShadow: [
                      if (stream?.isStreaming == true)
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Stream',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (widget.streamProvider.isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white54,
                      strokeWidth: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          // ── Camera selector tabs ──
          if (widget.cameras.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(widget.cameras.length, (i) {
                    final cam = widget.cameras[i];
                    final isSelected = i == _selectedIndex;
                    final s = widget.streamProvider.getStreamForCamera(
                      cam.cameraId,
                    );
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE53935)
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE53935)
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: s?.isStreaming == true
                                    ? Colors.greenAccent
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              cam.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // ── Stream info + Watch Live button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: stream?.isStreaming == true
                          ? Colors.greenAccent.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      stream?.isStreaming == true
                          ? Icons.videocam
                          : Icons.videocam_off_outlined,
                      color: stream?.isStreaming == true
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCamera.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (stream?.channel.isNotEmpty == true) ...[
                              const SizedBox(width: 6),
                              Text(
                                'Ch ${stream!.channel}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      final url = stream?.directPlayUrl ?? '';
                      if (url.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Stream URL not available'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      _openWebView(url, _selectedCamera.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Watch\nLive',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (stream != null)
            _UnknownDetectionBar(detection: stream.unknownUserDetection),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UNKNOWN DETECTION BAR
// ─────────────────────────────────────────────
class _UnknownDetectionBar extends StatelessWidget {
  final UnknownUserDetection detection;
  const _UnknownDetectionBar({required this.detection});

  @override
  Widget build(BuildContext context) {
    final hasUnknown = detection.hasUnknownUser;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasUnknown
              ? Colors.red.withOpacity(0.15)
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasUnknown
                ? Colors.red.withOpacity(0.4)
                : Colors.greenAccent.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasUnknown ? Icons.warning_amber_rounded : Icons.shield_outlined,
              color: hasUnknown ? Colors.redAccent : Colors.greenAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registered: ${detection.registeredUsersCount}  •  Interval: ${detection.detectionInterval}',
                    style: const TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
            ),
            if (hasUnknown)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${detection.unknownCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CAMERA THUMB CARD
// ─────────────────────────────────────────────
class _CameraThumbCard extends StatelessWidget {
  final CameraModel camera;
  final LiveStreamModel? streamData;
  const _CameraThumbCard({required this.camera, this.streamData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: streamData?.isStreaming == true
              ? Colors.greenAccent
              : const Color(0xFFE53935),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              const Icon(Icons.videocam, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  camera.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: camera.status == 'active'
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  camera.status.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 7),
                ),
              ),
            ],
          ),
          if (streamData?.isStreaming == true)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD CAMERA CARD
// ─────────────────────────────────────────────
class _AddCameraCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  const _AddCameraCard({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 28, color: Colors.black54),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD CAMERA BOTTOM-SHEET
// ─────────────────────────────────────────────
class _AddCameraSheet extends StatefulWidget {
  final String hostelId;
  const _AddCameraSheet({required this.hostelId});

  @override
  State<_AddCameraSheet> createState() => _AddCameraSheetState();
}

class _AddCameraSheetState extends State<_AddCameraSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '554');
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _manufacturerCtrl = TextEditingController();
  final _channelCtrl = TextEditingController(text: '1');
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _locationCtrl.dispose();
    _manufacturerCtrl.dispose();
    _channelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CameraProvider>();
    final payload = CameraPayload(
      name: _nameCtrl.text.trim(),
      ipAddress: _ipCtrl.text.trim(),
      port: int.tryParse(_portCtrl.text.trim()) ?? 554,
      username: _userCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      manufacturer: _manufacturerCtrl.text.trim(),
      channel: int.tryParse(_channelCtrl.text.trim()) ?? 1,
    );
    final success = await provider.addCamera(
      hostelId: widget.hostelId,
      payload: payload,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Add ',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: 'Camera',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in the camera connection details',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              _SheetField(
                controller: _nameCtrl,
                label: 'Camera Name',
                hint: 'e.g. Main Gate Camera',
                icon: Icons.videocam_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _ipCtrl,
                label: 'IP Address',
                hint: 'e.g. 192.168.1.100',
                icon: Icons.router_outlined,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'IP address is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _portCtrl,
                label: 'Port',
                hint: '554',
                icon: Icons.settings_ethernet,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Port is required';
                  if (int.tryParse(v) == null) return 'Enter a valid port';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _userCtrl,
                label: 'Username',
                hint: 'admin',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Username is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePass = !_obscurePass),
                    child: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _locationCtrl,
                label: 'Location',
                hint: 'e.g. Front Entrance',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _manufacturerCtrl,
                label: 'Manufacturer',
                hint: 'e.g. Hikvision, Dahua, CP Plus',
                icon: Icons.business_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Manufacturer is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _channelCtrl,
                label: 'Channel',
                hint: 'e.g. 1',
                icon: Icons.cable_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Channel is required';
                  if (int.tryParse(v) == null)
                    return 'Enter a valid channel number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<CameraProvider>(
                builder: (_, provider, __) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: provider.isLoading ? null : _submit,
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Add Camera',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE SHEET FIELD
// ─────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFE53935), size: 20),
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CAMERA DETAILS SCREEN
// ─────────────────────────────────────────────
class CameraDetailsScreen extends StatefulWidget {
  final String hostelId;
  final CameraModel camera;

  const CameraDetailsScreen({
    super.key,
    required this.hostelId,
    required this.camera,
  });

  @override
  State<CameraDetailsScreen> createState() => _CameraDetailsScreenState();
}

class _CameraDetailsScreenState extends State<CameraDetailsScreen> {
  late CameraModel _camera;

  @override
  void initState() {
    super.initState();
    _camera = widget.camera;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDetails());
  }

  Future<void> _fetchDetails() async {
    final provider = context.read<CameraProvider>();
    await provider.getSingleCamera(
      hostelId: widget.hostelId,
      cameraId: _camera.cameraId,
    );
    if (mounted && provider.selectedCamera != null) {
      setState(() => _camera = provider.selectedCamera!);
    }

    final token = await SharedPreferenceHelper.getToken() ?? '';
    if (mounted) {
      await context.read<StreamCameraProvider>().fetchLiveStream(
        hostelId: widget.hostelId,
        cameraId: _camera.cameraId,
        token: token,
      );
    }
  }

  void _openEditCameraSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CameraProvider>(),
        child: _EditCameraSheet(
          hostelId: widget.hostelId,
          camera: _camera,
          onUpdated: (updated) => setState(() => _camera = updated),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE53935),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Camera',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${_camera.name}"? This cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<CameraProvider>();
    final success = await provider.deleteCamera(
      hostelId: widget.hostelId,
      cameraId: _camera.cameraId,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Camera ',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: 'Details',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Consumer<CameraProvider>(
            builder: (_, provider, __) => provider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFFE53935),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFE53935),
                        ),
                        onPressed: _openEditCameraSheet,
                        tooltip: 'Edit Camera',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFE53935),
                        ),
                        onPressed: _confirmDelete,
                        tooltip: 'Delete Camera',
                      ),
                    ],
                  ),
          ),
        ],
      ),
      body: Consumer2<CameraProvider, StreamCameraProvider>(
        builder: (_, cameraProvider, streamProvider, __) {
          if (cameraProvider.isLoading &&
              cameraProvider.selectedCamera == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final cam = cameraProvider.selectedCamera ?? _camera;
          final streamData =
              streamProvider.getStreamForCamera(cam.cameraId) ??
              streamProvider.liveStream;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CameraDetailStreamCard(
                  stream: streamData,
                  cameraName: cam.name,
                  isLoadingStream: streamProvider.isLoadingToggle,
                ),

                const SizedBox(height: 20),
                const SizedBox(height: 24),

                const Text(
                  'Connection Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _DetailCard(
                  items: [
                    _DetailItem(
                      icon: Icons.router_outlined,
                      label: 'IP Address',
                      value: cam.ipAddress,
                    ),
                    _DetailItem(
                      icon: Icons.settings_ethernet,
                      label: 'Port',
                      value: cam.port.toString(),
                    ),
                    _DetailItem(
                      icon: Icons.person_outline,
                      label: 'Username',
                      value: cam.username,
                    ),
                    _DetailItem(
                      icon: Icons.lock_outline,
                      label: 'Password',
                      value: '••••••••',
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'Location & Stream',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _DetailCard(
                  items: [
                    _DetailItem(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: cam.location,
                    ),
                    _DetailItem(
                      icon: Icons.stream,
                      label: 'Stream URL',
                      value: cam.streamUrl,
                      isUrl: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'System Info',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _DetailCard(
                  items: [
                    _DetailItem(
                      icon: Icons.badge_outlined,
                      label: 'Camera ID',
                      value: cam.cameraId,
                    ),
                    _DetailItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Added On',
                      value:
                          '${cam.createdAt.day}/${cam.createdAt.month}/${cam.createdAt.year}',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Consumer<CameraProvider>(
                  builder: (_, provider, __) => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: provider.isLoading
                              ? null
                              : _openEditCameraSheet,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(
                            'Edit Camera',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935),
                            side: const BorderSide(color: Color(0xFFE53935)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: provider.isLoading ? null : _confirmDelete,
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE53935),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline, size: 18),
                          label: Text(
                            provider.isLoading ? 'Deleting...' : 'Delete',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CAMERA DETAIL STREAM CARD
// ─────────────────────────────────────────────
class _CameraDetailStreamCard extends StatelessWidget {
  final LiveStreamModel? stream;
  final String cameraName;
  final bool isLoadingStream;

  const _CameraDetailStreamCard({
    required this.stream,
    required this.cameraName,
    required this.isLoadingStream,
  });

  void _openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LiveStreamWebViewScreen(url: url, cameraName: cameraName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stream?.isStreaming == true
                        ? Colors.greenAccent
                        : Colors.red,
                    boxShadow: [
                      if (stream?.isStreaming == true)
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Stream Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (isLoadingStream)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white54,
                      strokeWidth: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: isLoadingStream && stream == null
                ? Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    ),
                  )
                : stream == null
                ? Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Stream data unavailable',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: stream!.isStreaming
                            ? Colors.greenAccent.withOpacity(0.3)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: stream!.isStreaming
                                ? Colors.greenAccent.withOpacity(0.12)
                                : Colors.redAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            stream!.isStreaming
                                ? Icons.videocam
                                : Icons.videocam_off_outlined,
                            color: stream!.isStreaming
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (stream!.channel.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ch ${stream!.channel}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            final url = stream!.directPlayUrl;
                            if (url.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Stream URL not available'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _openWebView(context, url);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Watch\nLive',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          if (stream != null)
            _UnknownDetectionBar(detection: stream!.unknownUserDetection),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EDIT CAMERA SHEET
// ─────────────────────────────────────────────
class _EditCameraSheet extends StatefulWidget {
  final String hostelId;
  final CameraModel camera;
  final void Function(CameraModel updated) onUpdated;

  const _EditCameraSheet({
    required this.hostelId,
    required this.camera,
    required this.onUpdated,
  });

  @override
  State<_EditCameraSheet> createState() => _EditCameraSheetState();
}

class _EditCameraSheetState extends State<_EditCameraSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ipCtrl;
  late final TextEditingController _portCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _manufacturerCtrl;
  late final TextEditingController _channelCtrl;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.camera.name);
    _ipCtrl = TextEditingController(text: widget.camera.ipAddress);
    _portCtrl = TextEditingController(text: widget.camera.port.toString());
    _userCtrl = TextEditingController(text: widget.camera.username);
    _passCtrl = TextEditingController(text: widget.camera.password);
    _locationCtrl = TextEditingController(text: widget.camera.location);
    _manufacturerCtrl = TextEditingController(
      text: (widget.camera as dynamic).manufacturer ?? '',
    );
    _channelCtrl = TextEditingController(
      text: ((widget.camera as dynamic).channel ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _locationCtrl.dispose();
    _manufacturerCtrl.dispose();
    _channelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CameraProvider>();
    final payload = CameraPayload(
      name: _nameCtrl.text.trim(),
      ipAddress: _ipCtrl.text.trim(),
      port: int.tryParse(_portCtrl.text.trim()) ?? 554,
      username: _userCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      manufacturer: _manufacturerCtrl.text.trim(),
      channel: int.tryParse(_channelCtrl.text.trim()) ?? 1,
    );
    final success = await provider.updateCamera(
      hostelId: widget.hostelId,
      cameraId: widget.camera.cameraId,
      payload: payload,
    );
    if (!mounted) return;
    if (success) {
      final updated =
          provider.selectedCamera ??
          widget.camera.copyWith(
            name: payload.name,
            ipAddress: payload.ipAddress,
            port: payload.port,
            username: payload.username,
            password: payload.password,
            location: payload.location,
          );
      widget.onUpdated(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Edit ',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: 'Camera',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Update the camera connection details',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              _SheetField(
                controller: _nameCtrl,
                label: 'Camera Name',
                hint: 'e.g. Main Gate Camera',
                icon: Icons.videocam_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _ipCtrl,
                label: 'IP Address',
                hint: 'e.g. 192.168.1.100',
                icon: Icons.router_outlined,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'IP address is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _portCtrl,
                label: 'Port',
                hint: '554',
                icon: Icons.settings_ethernet,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Port is required';
                  if (int.tryParse(v) == null) return 'Enter a valid port';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _userCtrl,
                label: 'Username',
                hint: 'admin',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Username is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePass = !_obscurePass),
                    child: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _locationCtrl,
                label: 'Location',
                hint: 'e.g. Front Entrance',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _manufacturerCtrl,
                label: 'Manufacturer',
                hint: 'e.g. Hikvision, Dahua, CP Plus',
                icon: Icons.business_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Manufacturer is required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _channelCtrl,
                label: 'Channel',
                hint: 'e.g. 1',
                icon: Icons.cable_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Channel is required';
                  if (int.tryParse(v) == null)
                    return 'Enter a valid channel number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<CameraProvider>(
                builder: (_, provider, __) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: provider.isLoading ? null : _submit,
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Update Camera',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DETAIL CARD & ITEM
// ─────────────────────────────────────────────
class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isUrl;
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isUrl = false,
  });
}

class _DetailCard extends StatelessWidget {
  final List<_DetailItem> items;
  const _DetailCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map(
              (entry) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            entry.value.icon,
                            color: const Color(0xFFE53935),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: entry.value.isUrl
                                      ? const Color(0xFFE53935)
                                      : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (entry.value.isUrl)
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(entry.value.value);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: const Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Color(0xFFE53935),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (entry.key < items.length - 1)
                    Divider(height: 1, color: Colors.grey.shade100, indent: 64),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRICE TOGGLE CHIP
// ─────────────────────────────────────────────
class _PriceToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PriceToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE53935) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : Colors.black54,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// HIFI HOSTEL CARD
// ─────────────────────────────────────────────
// class _HifiHostelCard extends StatelessWidget {
//   final Hostel hostel;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final bool isDeleting;
//   final bool showDailyPrice;

//   const _HifiHostelCard({
//     required this.hostel,
//     required this.onEdit,
//     required this.onDelete,
//     this.isDeleting = false,
//     this.showDailyPrice = false,
//   });

//   Future<void> openGoogleMaps(
//     double latitude,
//     double longitude,
//     BuildContext context,
//   ) async {
//     // Create both Google Maps app URL and web fallback
//     final googleMapsUrl = Uri.parse('comgooglemaps://?q=$latitude,$longitude');
//     final webUrl = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
//     );

//     try {
//       // Try to open Google Maps app first
//       if (await canLaunchUrl(googleMapsUrl)) {
//         await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
//       }
//       // Fallback to web browser
//       else if (await canLaunchUrl(webUrl)) {
//         await launchUrl(webUrl, mode: LaunchMode.externalApplication);
//       } else {
//         throw 'Could not open Google Maps';
//       }
//     } catch (e) {
//       print('Error opening maps: $e');
//       // Final fallback - try web URL with external application
//       if (await canLaunchUrl(webUrl)) {
//         await launchUrl(webUrl, mode: LaunchMode.externalApplication);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not open maps. Please install Google Maps.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Future<void> openWhatsApp(String phoneNumber) async {
//       final message = Uri.encodeComponent(
//         'Hello, I am interested in your hostel.',
//       );
//       final nativeUri = Uri.parse(
//         'whatsapp://send?phone=$phoneNumber&text=$message',
//       );
//       if (await canLaunchUrl(nativeUri)) {
//         await launchUrl(nativeUri);
//         return;
//       }
//       final webUri = Uri.parse('https://wa.me/$phoneNumber?text=$message');
//       await launchUrl(webUri, mode: LaunchMode.externalApplication);
//     }

//     final isAc = _hostelIsAc(hostel);
//     final sharings = hostel.sharings.isNotEmpty
//         ? hostel.sharings
//         : (isAc
//               ? (hostel.rooms?.ac.isNotEmpty == true
//                     ? hostel.rooms!.ac
//                     : hostel.rooms?.nonAc ?? [])
//               : (hostel.rooms?.nonAc.isNotEmpty == true
//                     ? hostel.rooms!.nonAc
//                     : hostel.rooms?.ac ?? []));
//     final typeLabel = hostel.type.isNotEmpty
//         ? hostel.type.join(' / ')
//         : 'Hostel';

//     return AnimatedOpacity(
//       opacity: isDeleting ? 0.5 : 1.0,
//       duration: const Duration(milliseconds: 300),
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade200),
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomRight: Radius.circular(12),
//                   ),
//                   child: hostel.images.isNotEmpty
//                       ? Image.network(
//                           hostel.images.first,
//                           width: 100,
//                           height: 110,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => _placeholder(),
//                         )
//                       : _placeholder(),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                       horizontal: 4,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 hostel.name,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 6,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE53935),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 typeLabel,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.star,
//                               color: Colors.amber,
//                               size: 13,
//                             ),
//                             const SizedBox(width: 2),
//                             Text(
//                               '${hostel.rating}',
//                               style: const TextStyle(fontSize: 11),
//                             ),
//                             const SizedBox(width: 6),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 5,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isAc
//                                     ? Colors.blue.shade50
//                                     : Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(4),
//                                 border: Border.all(
//                                   color: isAc
//                                       ? Colors.blue.shade200
//                                       : Colors.orange.shade200,
//                                 ),
//                               ),
//                               child: Text(
//                                 isAc ? 'AC' : 'Non-AC',
//                                 style: TextStyle(
//                                   fontSize: 9,
//                                   color: isAc
//                                       ? Colors.blue.shade700
//                                       : Colors.orange.shade700,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.location_on,
//                               size: 11,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(width: 2),
//                             Expanded(
//                               child: Text(
//                                 hostel.address,
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),

//                         // const SizedBox(height: 8),
//                         // Wrap(
//                         //   spacing: 4,
//                         //   runSpacing: 4,
//                         //   children: sharings.take(4).map((s) {
//                         //     final double? price = showDailyPrice
//                         //         ? (s.dailyPrice ??
//                         //               s.acDailyPrice ??
//                         //               s.nonAcDailyPrice)
//                         //         : (s.monthlyPrice ??
//                         //               s.acMonthlyPrice ??
//                         //               s.nonAcMonthlyPrice);
//                         //     return Container(
//                         //       padding: const EdgeInsets.symmetric(
//                         //         horizontal: 6,
//                         //         vertical: 3,
//                         //       ),
//                         //       decoration: BoxDecoration(
//                         //         color: const Color(0xFFE53935),
//                         //         borderRadius: BorderRadius.circular(4),
//                         //       ),
//                         //       child: Text(
//                         //         '${s.shareType}: ₹${price?.toStringAsFixed(0) ?? '-'}/${showDailyPrice ? 'day' : 'mo'}',
//                         //         style: const TextStyle(
//                         //           color: Colors.white,
//                         //           fontSize: 9,
//                         //           fontWeight: FontWeight.bold,
//                         //         ),
//                         //       ),
//                         //     );
//                         //   }).toList(),
//                         // ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Wrap(
//                                 spacing: 4,
//                                 runSpacing: 4,
//                                 children: sharings.take(4).map((s) {
//                                   final double? price = showDailyPrice
//                                       ? (s.dailyPrice ??
//                                             s.acDailyPrice ??
//                                             s.nonAcDailyPrice)
//                                       : (s.monthlyPrice ??
//                                             s.acMonthlyPrice ??
//                                             s.nonAcMonthlyPrice);
//                                   return Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 6,
//                                       vertical: 3,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFFE53935),
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                     child: Text(
//                                       '${s.shareType}: ₹${price?.toStringAsFixed(0) ?? '-'}/${showDailyPrice ? 'day' : 'mo'}',
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 9,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                             if (sharings.length > 4) ...[
//                               const SizedBox(width: 4),
//                               Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: const Color.fromARGB(255, 255, 0, 0),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: const Icon(
//                                   Icons.arrow_forward_ios,
//                                   size: 10,
//                                   color: Color.fromARGB(255, 255, 255, 255),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
//               child: Wrap(
//                 spacing: 6,
//                 runSpacing: 6,
//                 children: [
//                   _ActionBtn(
//                     icon: Icons.call,
//                     label: 'Call',
//                     color: const Color(0xFF4CAF50),
//                     onTap: () async {
//                       final uri = Uri(scheme: 'tel', path: '9961593179');
//                       if (await canLaunchUrl(uri)) await launchUrl(uri);
//                     },
//                   ),
//                   _ActionBtn(
//                     icon: Icons.chat_bubble_outline,
//                     label: 'Whatsapp',
//                     color: const Color(0xFF25D366),
//                     onTap: () => openWhatsApp('919961593179'),
//                   ),
//                   _ActionBtn(
//                     icon: Icons.location_on,
//                     label: 'Location',
//                     color: const Color(0xFF2196F3),
//                     onTap: () {
//                       openGoogleMaps(
//                         hostel.latitude,
//                         hostel.longitude,
//                         context,
//                       );
//                     },
//                   ),
//                   _ActionBtn(
//                     icon: Icons.edit,
//                     label: 'Edit',
//                     color: const Color(0xFFE53935),
//                     onTap: onEdit,
//                   ),
//                   _ActionBtn(
//                     icon: isDeleting ? null : Icons.delete_outline,
//                     label: isDeleting ? '...' : 'Delete',
//                     color: const Color(0xFF757575),
//                     onTap: isDeleting ? () {} : onDelete,
//                     isLoading: isDeleting,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _placeholder() => Container(
//     width: 100,
//     height: 110,
//     decoration: BoxDecoration(
//       color: Colors.grey.shade200,
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(12),
//         bottomLeft: Radius.circular(12),
//       ),
//     ),
//     child: const Icon(Icons.apartment, size: 40, color: Colors.grey),
//   );
// }

class _HifiHostelCard extends StatelessWidget {
  final Hostel hostel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;
  final bool showDailyPrice;

  const _HifiHostelCard({
    required this.hostel,
    required this.onEdit,
    required this.onDelete,
    this.isDeleting = false,
    this.showDailyPrice = false,
  });

  Future<void> openGoogleMaps(
    double latitude,
    double longitude,
    BuildContext context,
  ) async {
    final googleMapsUrl = Uri.parse('comgooglemaps://?q=$latitude,$longitude');
    final webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open Google Maps';
      }
    } catch (e) {
      print('Error opening maps: $e');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps. Please install Google Maps.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> openWhatsApp(String phoneNumber) async {
      final message = Uri.encodeComponent(
        'Hello, I am interested in your hostel.',
      );
      final nativeUri = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=$message',
      );
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri);
        return;
      }
      final webUri = Uri.parse('https://wa.me/$phoneNumber?text=$message');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    final isAc = _hostelIsAc(hostel);
    final sharings = hostel.sharings.isNotEmpty
        ? hostel.sharings
        : (isAc
              ? (hostel.rooms?.ac.isNotEmpty == true
                    ? hostel.rooms!.ac
                    : hostel.rooms?.nonAc ?? [])
              : (hostel.rooms?.nonAc.isNotEmpty == true
                    ? hostel.rooms!.nonAc
                    : hostel.rooms?.ac ?? []));
    final typeLabel = hostel.type.isNotEmpty
        ? hostel.type.join(' / ')
        : 'Hostel';

    // Get category name
    final categoryName = hostel.categoryName ?? 'Hostel';

    return AnimatedOpacity(
      opacity: isDeleting ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with category name below
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: hostel.images.isNotEmpty
                          ? Image.network(
                              hostel.images.first,
                              width: 100,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _placeholder(width: 100, height: 90),
                            )
                          : _placeholder(width: 100, height: 90),
                    ),
                    const SizedBox(height: 4),
                    // Category name below image
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        categoryName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53935),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hostel.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                typeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${hostel.rating}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isAc
                                    ? Colors.blue.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isAc
                                      ? Colors.blue.shade200
                                      : Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                isAc ? 'AC' : 'Non-AC',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isAc
                                      ? Colors.blue.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 11,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                hostel.address,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: sharings.take(4).map((s) {
                                  final double? price = showDailyPrice
                                      ? (s.dailyPrice ??
                                            s.acDailyPrice ??
                                            s.nonAcDailyPrice)
                                      : (s.monthlyPrice ??
                                            s.acMonthlyPrice ??
                                            s.nonAcMonthlyPrice);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53935),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${s.shareType}: ₹${price?.toStringAsFixed(0) ?? '-'}/${showDailyPrice ? 'day' : 'mo'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (sharings.length > 4) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 0, 0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _ActionBtn(
                    icon: Icons.call,
                    label: 'Call',
                    color: const Color(0xFF4CAF50),
                    onTap: () async {
                      final uri = Uri(scheme: 'tel', path: '9961593179');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                  ),
                  _ActionBtn(
                    icon: Icons.chat_bubble_outline,
                    label: 'Whatsapp',
                    color: const Color(0xFF25D366),
                    onTap: () => openWhatsApp('919961593179'),
                  ),
                  _ActionBtn(
                    icon: Icons.location_on,
                    label: 'Location',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      openGoogleMaps(
                        hostel.latitude,
                        hostel.longitude,
                        context,
                      );
                    },
                  ),
                  _ActionBtn(
                    icon: Icons.edit,
                    label: 'Edit',
                    color: const Color(0xFFE53935),
                    onTap: onEdit,
                  ),
                  _ActionBtn(
                    icon: isDeleting ? null : Icons.delete_outline,
                    label: isDeleting ? '...' : 'Delete',
                    color: const Color(0xFF757575),
                    onTap: isDeleting ? () {} : onDelete,
                    isLoading: isDeleting,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder({double width = 100, double height = 110}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
    ),
    child: const Icon(Icons.apartment, size: 40, color: Colors.grey),
  );
}

// ─────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;
  const _ActionBtn({
    this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
            const SizedBox(width: 3),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// HIFI DETAILS SCREEN
// ─────────────────────────────────────────────
class HifiDetailsScreen extends StatefulWidget {
  final Hostel? existingHostel;
  final Function(HostelRequest) onSave;
  final bool forcedIsAc;
  final bool lockAcToggle;

  const HifiDetailsScreen({
    super.key,
    required this.onSave,
    this.existingHostel,
    this.forcedIsAc = false,
    this.lockAcToggle = false,
  });
  @override
  State<HifiDetailsScreen> createState() => _HifiDetailsScreenState();
}

class _HifiDetailsScreenState extends State<HifiDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isAcEnabled;
  late DateTime _selectedDate;
  late List<Map<String, dynamic>> _dates;
  final List<XFile> _hostelImages = [];
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleController,
      _addressController,
      _advanceController,
      _ratingController,
      _latController,
      _lngController;
  late Map<String, TextEditingController> _monthlyNonAc,
      _monthlyAc,
      _dailyNonAc,
      _dailyAc;

  final List<String> _shareKeys = [
    '1 Share',
    '2 Share',
    '3 Share',
    '4 Share',
    '5 Share',
    '6 Share',
  ];

  List<Map<String, dynamic>> _buildDates() {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    return List.generate(6, (i) {
      final d = today.add(Duration(days: i));
      return {'day': dayNames[d.weekday - 1], 'date': d.day, 'fullDate': d};
    });
  }

  Category? _selectedCategory;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dates = _buildDates();
    _selectedDate = _dates.first['fullDate'] as DateTime;

    final h = widget.existingHostel;
    _isAcEnabled = h != null ? _hostelIsAc(h) : widget.forcedIsAc;

    _titleController = TextEditingController(text: h?.name ?? '');
    _addressController = TextEditingController(text: h?.address ?? '');
    _advanceController = TextEditingController(
      text: h != null ? h.monthlyAdvance.toStringAsFixed(0) : '',
    );
    _ratingController = TextEditingController(
      text: h != null ? h.rating.toString() : '4.5',
    );
    _latController = TextEditingController(
      text: h != null ? h.latitude.toString() : '',
    );
    _lngController = TextEditingController(
      text: h != null ? h.longitude.toString() : '',
    );

    final effectiveSharings = h == null
        ? <SharingOption>[]
        : h.sharings.isNotEmpty
        ? h.sharings
        : (_hostelIsAc(h)
              ? (h.rooms?.ac.isNotEmpty == true
                    ? h.rooms!.ac
                    : h.rooms?.nonAc ?? [])
              : (h.rooms?.nonAc.isNotEmpty == true
                    ? h.rooms!.nonAc
                    : h.rooms?.ac ?? []));

    _monthlyNonAc = _buildControllers(
      effectiveSharings,
      isAc: false,
      isMonthly: true,
    );
    _monthlyAc = _buildControllers(
      effectiveSharings,
      isAc: true,
      isMonthly: true,
    );
    _dailyNonAc = _buildControllers(
      effectiveSharings,
      isAc: false,
      isMonthly: false,
    );
    _dailyAc = _buildControllers(
      effectiveSharings,
      isAc: true,
      isMonthly: false,
    );

    _loadCategories().then((_) {
      // After categories are loaded, set the selected category for edit mode
      if (widget.existingHostel != null && mounted) {
        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        final category = categoryProvider.categories.firstWhere(
          (cat) => cat.id == widget.existingHostel!.categoryId,
          orElse: () => categoryProvider.categories.first,
        );
        setState(() {
          _selectedCategory = category;
        });
      }
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    await categoryProvider.fetchCategories();

    // If editing existing hostel, set the selected category
    if (widget.existingHostel != null && mounted) {
      final category = categoryProvider.categories.firstWhere(
        (cat) => cat.id == widget.existingHostel!.categoryId,
        orElse: () => categoryProvider.categories.first,
      );
      setState(() {
        _selectedCategory = category;
      });
    }

    setState(() => _isLoadingCategories = false);
  }
  // Map<String, TextEditingController> _buildControllers(
  //   List<SharingOption> sharings, {
  //   required bool isAc,
  //   required bool isMonthly,
  // }) {
  //   final defaults = isMonthly
  //       ? {
  //           '1 Share': isAc ? '0' : '0',
  //           '2 Share': isAc ? '0' : '0',
  //           '3 Share': isAc ? '0' : '0',
  //           '4 Share': isAc ? '0' : '0',
  //           '5 Share': isAc ? '0' : '0',
  //           '6 Share': isAc ? '0' : '0',
  //         }
  //       : {
  //           '1 Share': isAc ? '0' : '0',
  //           '2 Share': isAc ? '0' : '0',
  //           '3 Share': isAc ? '0' : '0',
  //           '4 Share': isAc ? '0' : '0',
  //           '5 Share': isAc ? '0' : '0',
  //           '6 Share': isAc ? '0' : '0',
  //         };
  //   return {
  //     for (var key in _shareKeys)
  //       key: TextEditingController(
  //         text: sharings.isNotEmpty
  //             ? _findPrice(sharings, key, isAc: isAc, isMonthly: isMonthly)
  //             : defaults[key] ?? '0',
  //       ),
  //   };
  // }

  // Map<String, TextEditingController> _buildControllers(
  //   List<SharingOption> sharings, {
  //   required bool isAc,
  //   required bool isMonthly,
  // }) {
  //   final controllers = <String, TextEditingController>{};

  //   for (var key in _shareKeys) {
  //     String initialValue = '0';

  //     if (sharings.isNotEmpty) {
  //       final price = _findPrice(
  //         sharings,
  //         key,
  //         isAc: isAc,
  //         isMonthly: isMonthly,
  //       );
  //       initialValue = price; // This will already be '0' if price <= 0
  //     }

  //     controllers[key] = TextEditingController(text: initialValue);
  //   }

  //   return controllers;
  // }

  Map<String, TextEditingController> _buildControllers(
    List<SharingOption> sharings, {
    required bool isAc,
    required bool isMonthly,
  }) {
    final controllers = <String, TextEditingController>{};

    for (var key in _shareKeys) {
      String initialValue = '0';

      if (sharings.isNotEmpty) {
        final price = _findPrice(
          sharings,
          key,
          isAc: isAc,
          isMonthly: isMonthly,
        );
        initialValue = price;
      }

      // Always create controller for all share types
      // Don't filter out zero prices here - let the grid handle filtering
      controllers[key] = TextEditingController(text: initialValue);
    }

    return controllers;
  }

  // String _findPrice(
  //   List<SharingOption> sharings,
  //   String shareKey, {
  //   required bool isAc,
  //   required bool isMonthly,
  // }) {
  //   if (sharings.isEmpty) return '0';
  //   final keyNumber = shareKey.split(' ').first.trim();
  //   SharingOption? match;
  //   try {
  //     match = sharings.firstWhere(
  //       (s) => s.shareType.toLowerCase() == shareKey.toLowerCase(),
  //     );
  //   } catch (_) {}
  //   if (match == null) {
  //     try {
  //       match = sharings.firstWhere(
  //         (s) => s.shareType.replaceAll(RegExp(r'[^0-9]'), '') == keyNumber,
  //       );
  //     } catch (_) {}
  //   }
  //   if (match == null) return '0';
  //   double? price;
  //   if (isAc) {
  //     price = isMonthly ? match.acMonthlyPrice : match.acDailyPrice;
  //     if (price == null || price == 0) {
  //       price = isMonthly ? match.monthlyPrice : match.dailyPrice;
  //     }
  //   } else {
  //     price = isMonthly ? match.nonAcMonthlyPrice : match.nonAcDailyPrice;
  //     if (price == null || price == 0) {
  //       price = isMonthly ? match.monthlyPrice : match.dailyPrice;
  //     }
  //   }
  //   if (price == null || price.isNaN || price.isInfinite || price < 0)
  //     return '0';
  //   return price.toStringAsFixed(0);
  // }

  // Widget _buildFilteredGrid(
  //   Map<String, TextEditingController> prices,
  //   Color color,
  //   String period,
  // ) {
  //   // Filter out entries where price is 0 or empty
  //   final filteredEntries = prices.entries.where((entry) {
  //     final priceText = entry.value.text.trim();
  //     if (priceText.isEmpty) return false;
  //     final price = double.tryParse(priceText);
  //     // Keep only if price is > 0
  //     return price != null && price > 0;
  //   }).toList();

  //   if (filteredEntries.isEmpty) {
  //     return Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.shade100,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Center(
  //         child: Text(
  //           'No $period prices available for ${_isAcEnabled ? "AC" : "Non-AC"}',
  //           style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
  //         ),
  //       ),
  //     );
  //   }

  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       mainAxisSpacing: 8,
  //       crossAxisSpacing: 8,
  //       childAspectRatio: 1.4,
  //     ),
  //     itemCount: filteredEntries.length,
  //     itemBuilder: (_, i) {
  //       final entry = filteredEntries[i];
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: color,
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         padding: const EdgeInsets.all(6),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               entry.key,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 9,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             SizedBox(
  //               height: 22,
  //               child: TextField(
  //                 controller: entry.value,
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 decoration: const InputDecoration(
  //                   isDense: true,
  //                   contentPadding: EdgeInsets.zero,
  //                   border: InputBorder.none,
  //                 ),
  //                 keyboardType: TextInputType.number,
  //                 onChanged: (_) {
  //                   // Trigger rebuild when price changes
  //                   setState(() {});
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildFilteredGrid(
    Map<String, TextEditingController> prices,
    Color color,
    String period,
  ) {
    // Filter out entries where price is 0 or empty
    final filteredEntries = prices.entries.where((entry) {
      final priceText = entry.value.text.trim();
      if (priceText.isEmpty) return false;
      final price = double.tryParse(priceText);
      // Keep only if price is > 0
      return price != null && price > 0;
    }).toList();

    if (filteredEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No $period prices available for ${_isAcEnabled ? "AC" : "Non-AC"}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: filteredEntries.length,
      itemBuilder: (_, i) {
        final entry = filteredEntries[i];
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.key,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 22,
                child: TextField(
                  controller: entry.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    setState(() {}); // Trigger rebuild when price changes
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _findPrice(
    List<SharingOption> sharings,
    String shareKey, {
    required bool isAc,
    required bool isMonthly,
  }) {
    if (sharings.isEmpty) return '0';
    final keyNumber = shareKey.split(' ').first.trim();
    SharingOption? match;
    try {
      match = sharings.firstWhere(
        (s) => s.shareType.toLowerCase() == shareKey.toLowerCase(),
      );
    } catch (_) {}
    if (match == null) {
      try {
        match = sharings.firstWhere(
          (s) => s.shareType.replaceAll(RegExp(r'[^0-9]'), '') == keyNumber,
        );
      } catch (_) {}
    }
    if (match == null) return '0';

    double? price;
    if (isAc) {
      price = isMonthly ? match.acMonthlyPrice : match.acDailyPrice;
      if (price == null || price == 0) {
        price = isMonthly ? match.monthlyPrice : match.dailyPrice;
      }
    } else {
      price = isMonthly ? match.nonAcMonthlyPrice : match.nonAcDailyPrice;
      if (price == null || price == 0) {
        price = isMonthly ? match.monthlyPrice : match.dailyPrice;
      }
    }

    // Return '0' for null, NaN, infinite, negative, or zero prices
    if (price == null || price.isNaN || price.isInfinite || price <= 0) {
      return '0';
    }

    return price.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _advanceController.dispose();
    _ratingController.dispose();
    _latController.dispose();
    _lngController.dispose();
    for (var c in [
      ..._monthlyNonAc.values,
      ..._monthlyAc.values,
      ..._dailyNonAc.values,
      ..._dailyAc.values,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _pickHostelImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _hostelImages.add(image));
  }

  double _parsePrice(TextEditingController? c) {
    if (c == null) return 0;
    final parsed = double.tryParse(c.text.trim());
    return (parsed == null || parsed.isNaN || parsed.isInfinite) ? 0 : parsed;
  }

  // void _saveAndGoBack() {
  //   if (_selectedCategory == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           'Please select a category (Men\'s PG, Women\'s PG, or Coliving PG)',
  //         ),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //   final sharings = _shareKeys.map((key) {
  //     if (_isAcEnabled) {
  //       final acMonthly = _parsePrice(_monthlyAc[key]);
  //       final acDaily = _parsePrice(_dailyAc[key]);
  //       return SharingOption(
  //         shareType: key,
  //         type: 'AC',
  //         acMonthlyPrice: acMonthly,
  //         acDailyPrice: acDaily,
  //         nonAcMonthlyPrice: 0,
  //         nonAcDailyPrice: 0,
  //         monthlyPrice: acMonthly,
  //         dailyPrice: acDaily,
  //       );
  //     } else {
  //       final nonAcMonthly = _parsePrice(_monthlyNonAc[key]);
  //       final nonAcDaily = _parsePrice(_dailyNonAc[key]);
  //       return SharingOption(
  //         shareType: key,
  //         type: 'Non-AC',
  //         monthlyPrice: nonAcMonthly,
  //         dailyPrice: nonAcDaily,
  //         acMonthlyPrice: 0,
  //         acDailyPrice: 0,
  //         nonAcMonthlyPrice: nonAcMonthly,
  //         nonAcDailyPrice: nonAcDaily,
  //       );
  //     }
  //   }).toList();

  //   final imagePaths = _hostelImages.map((x) => x.path).toList();
  //   final request = HostelRequest(
  //     categoryId:
  //         _selectedCategory!.id, // For new, selected category is required
  //     vendorId: '', // This will be set in the calling function
  //     name: _titleController.text.trim(),
  //     rating: double.tryParse(_ratingController.text.trim()) ?? 4.5,
  //     address: _addressController.text.trim(),
  //     monthlyAdvance: double.tryParse(_advanceController.text.trim()) ?? 0,
  //     latitude: double.tryParse(_latController.text.trim()) ?? 0,
  //     longitude: double.tryParse(_lngController.text.trim()) ?? 0,
  //     isAc: _isAcEnabled,
  //     sharings: sharings,
  //     imagePaths: imagePaths,
  //   );
  //   widget.onSave(request);
  //   Navigator.pop(context);
  // }

  void _saveAndGoBack() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a category (Men\'s PG, Women\'s PG, or Coliving PG)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final sharings = _shareKeys.map((key) {
      if (_isAcEnabled) {
        final acMonthly = _parsePrice(_monthlyAc[key]);
        final acDaily = _parsePrice(_dailyAc[key]);
        return SharingOption(
          shareType: key,
          type: 'AC',
          acMonthlyPrice: acMonthly,
          acDailyPrice: acDaily,
          nonAcMonthlyPrice: 0,
          nonAcDailyPrice: 0,
          monthlyPrice: acMonthly,
          dailyPrice: acDaily,
        );
      } else {
        final nonAcMonthly = _parsePrice(_monthlyNonAc[key]);
        final nonAcDaily = _parsePrice(_dailyNonAc[key]);
        return SharingOption(
          shareType: key,
          type: 'Non-AC',
          monthlyPrice: nonAcMonthly,
          dailyPrice: nonAcDaily,
          acMonthlyPrice: 0,
          acDailyPrice: 0,
          nonAcMonthlyPrice: nonAcMonthly,
          nonAcDailyPrice: nonAcDaily,
        );
      }
    }).toList();

    final imagePaths = _hostelImages.map((x) => x.path).toList();
    final request = HostelRequest(
      categoryId: _selectedCategory!.id,
      vendorId: '',
      name: _titleController.text.trim(),
      rating: double.tryParse(_ratingController.text.trim()) ?? 4.5,
      address: _addressController.text.trim(),
      monthlyAdvance: double.tryParse(_advanceController.text.trim()) ?? 0,
      latitude: double.tryParse(_latController.text.trim()) ?? 0,
      longitude: double.tryParse(_lngController.text.trim()) ?? 0,
      isAc: _isAcEnabled,
      sharings: sharings,
      imagePaths: imagePaths,
    );
    widget.onSave(request);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingHostel != null;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isEdit ? 'Edit ' : 'Hifi ',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: isEdit ? 'Hostel' : 'Details',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!widget.lockAcToggle || isEdit)
            Row(
              children: [
                Text(
                  _isAcEnabled ? 'AC' : 'Non-AC',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Switch(
                  value: _isAcEnabled,
                  onChanged: (v) => setState(() => _isAcEnabled = v),
                  activeColor: const Color(0xFFE53935),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _isAcEnabled
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isAcEnabled
                        ? Colors.blue.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 12,
                      color: _isAcEnabled
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isAcEnabled ? 'AC Only' : 'Non-AC Only',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isAcEnabled
                            ? Colors.blue.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Category Dropdown (only for new hostels, not for edit)
            // if (!isEdit) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category *',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, _) {
                      if (categoryProvider.isLoading) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      if (categoryProvider.categories.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No categories available',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Category>(
                            isExpanded: true,
                            hint: const Text('Select Category'),
                            value: _selectedCategory,
                            items: categoryProvider.categories.map((category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (Category? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  if (_selectedCategory == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Please select a category',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 24, thickness: 1),
            // ],
            if (widget.lockAcToggle && !isEdit)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isAcEnabled
                        ? Colors.blue.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isAcEnabled
                          ? Colors.blue.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: _isAcEnabled
                            ? Colors.blue.shade700
                            : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isAcEnabled
                              ? 'You already have Non-AC hostels. This new hostel will be AC only.'
                              : 'You already have AC hostels. This new hostel will be Non-AC only.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isAcEnabled
                                ? Colors.blue.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    Tab(text: 'Monthly'),
                    Tab(text: 'Daily'),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _buildField(_titleController, 'Hostel Name'),
                  const SizedBox(height: 8),
                  _buildField(_addressController, 'Address'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          _advanceController,
                          'Monthly Advance',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildField(_ratingController, 'Rating')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildField(_latController, 'Latitude')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildField(_lngController, 'Longitude')),
                      const SizedBox(width: 8),
                      Consumer<HostelProvider>(
                        builder: (context, provider, _) => GestureDetector(
                          onTap: provider.isFetchingLocation
                              ? null
                              : () async {
                                  final success = await provider
                                      .fetchCurrentLocation();
                                  if (success && mounted) {
                                    setState(() {
                                      _latController.text =
                                          provider.currentLatitude
                                              ?.toStringAsFixed(6) ??
                                          '';
                                      _lngController.text =
                                          provider.currentLongitude
                                              ?.toStringAsFixed(6) ??
                                          '';
                                    });
                                  } else if (!success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          provider.errorMessage ??
                                              'Could not fetch location',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: provider.isFetchingLocation
                                  ? Colors.grey.shade300
                                  : const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: provider.isFetchingLocation
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._hostelImages.map(
                      (img) => Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(img.path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 2,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _hostelImages.remove(img)),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.existingHostel != null)
                      ...widget.existingHostel!.images.map(
                        (url) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _pickHostelImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 24,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add Image',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            AnimatedBuilder(
              animation: _tabController,
              builder: (_, __) => _buildPriceSection(
                _tabController.index == 0 ? 'Monthly' : 'Daily',
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date To Book a Hostel',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 62,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dates.length,
                      itemBuilder: (_, i) {
                        final d = _dates[i];
                        final fullDate = d['fullDate'] as DateTime;
                        final isSel =
                            fullDate.year == _selectedDate.year &&
                            fullDate.month == _selectedDate.month &&
                            fullDate.day == _selectedDate.day;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate = fullDate),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            width: 50,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFFE53935)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  d['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSel
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  '${d['date']}',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: Consumer<HostelProvider>(
                  builder: (context, provider, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: provider.isLoading ? null : _saveAndGoBack,
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEdit ? 'Update' : 'Create Hostel',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
  }) => TextField(
    controller: c,
    maxLines: maxLines,
    keyboardType: maxLines == 1 ? TextInputType.text : TextInputType.multiline,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
    ),
  );

  // Widget _buildPriceSection(String label) => Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 16),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       if (_isAcEnabled) ...[
  //         Text(
  //           '$label Prices for AC',
  //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //         ),
  //         const SizedBox(height: 8),
  //         _buildGrid(
  //           label == 'Monthly' ? _monthlyAc : _dailyAc,
  //           Colors.blue.shade700,
  //         ),
  //         const SizedBox(height: 10),
  //       ] else ...[
  //         Text(
  //           '$label Prices for Non-AC',
  //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //         ),
  //         const SizedBox(height: 8),
  //         _buildGrid(
  //           label == 'Monthly' ? _monthlyNonAc : _dailyNonAc,
  //           const Color(0xFFE53935),
  //         ),
  //         const SizedBox(height: 10),
  //       ],
  //     ],
  //   ),
  // );

  Widget _buildPriceSection(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isAcEnabled) ...[
          Text(
            '$label Prices for AC',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildGrid(
            label == 'Monthly' ? _monthlyAc : _dailyAc,
            Colors.blue.shade700,
            isEditMode: widget.existingHostel != null,
          ),
          const SizedBox(height: 10),
        ] else ...[
          Text(
            '$label Prices for Non-AC',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildGrid(
            label == 'Monthly' ? _monthlyNonAc : _dailyNonAc,
            const Color(0xFFE53935),
            isEditMode: widget.existingHostel != null,
          ),
          const SizedBox(height: 10),
        ],
      ],
    ),
  );

  // Widget _buildGrid(Map<String, TextEditingController> prices, Color color) {
  //   final keys = prices.keys.toList();
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       mainAxisSpacing: 8,
  //       crossAxisSpacing: 8,
  //       childAspectRatio: 1.4,
  //     ),
  //     itemCount: keys.length,
  //     itemBuilder: (_, i) {
  //       final key = keys[i];
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: color,
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         padding: const EdgeInsets.all(6),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               key,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 9,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             SizedBox(
  //               height: 22,
  //               child: TextField(
  //                 controller: prices[key],
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 decoration: const InputDecoration(
  //                   isDense: true,
  //                   contentPadding: EdgeInsets.zero,
  //                   border: InputBorder.none,
  //                 ),
  //                 keyboardType: TextInputType.number,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget _buildGrid(
    Map<String, TextEditingController> prices,
    Color color, {
    bool isEditMode = false,
  }) {
    // For edit mode: show all share types (including zeros with a placeholder)
    // For new mode: show ALL share types (don't filter zeros)
    final entries = prices.entries.toList(); // Show ALL entries, don't filter

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            isEditMode
                ? 'Tap on any share to add price'
                : 'No prices available',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final entry = entries[i];
        final priceText = entry.value.text.trim();
        final hasPrice =
            priceText.isNotEmpty && (double.tryParse(priceText) ?? 0) > 0;

        return Container(
          decoration: BoxDecoration(
            color: hasPrice ? color : color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: (!hasPrice)
                ? Border.all(color: color.withOpacity(0.5), width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.key,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hasPrice ? Colors.white : Colors.white70,
                  fontSize: 9,
                  fontWeight: hasPrice ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 22,
                child: TextField(
                  controller: entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hasPrice ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: hasPrice ? FontWeight.bold : FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: !hasPrice ? 'Add' : null,
                    hintStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    setState(() {}); // Trigger rebuild when price changes
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
