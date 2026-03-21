// import 'dart:convert';
// import 'dart:io';
// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/model/create_hostel_model.dart';
// import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
// import 'package:brando_vendor/views/notifications/notification_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class _SuccessOverlay extends StatefulWidget {
//   final String message;
//   final VoidCallback onDismiss;

//   const _SuccessOverlay({required this.message, required this.onDismiss});

//   @override
//   State<_SuccessOverlay> createState() => _SuccessOverlayState();
// }

// class _SuccessOverlayState extends State<_SuccessOverlay>
//     with TickerProviderStateMixin {
//   late AnimationController _bgController;
//   late AnimationController _circleController;
//   late AnimationController _checkController;
//   late AnimationController _textController;

//   late Animation<double> _bgFade;
//   late Animation<double> _circleScale;
//   late Animation<double> _checkDraw;
//   late Animation<double> _textFade;
//   late Animation<Offset> _textSlide;

//   @override
//   void initState() {
//     super.initState();

//     _bgController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _circleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _checkController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _textController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );

//     _bgFade = CurvedAnimation(parent: _bgController, curve: Curves.easeIn);
//     _circleScale = CurvedAnimation(
//       parent: _circleController,
//       curve: Curves.elasticOut,
//     );
//     _checkDraw = CurvedAnimation(parent: _checkController, curve: Curves.easeOut);
//     _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
//     _textSlide = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

//     // Sequence the animations
//     _bgController.forward().then((_) {
//       _circleController.forward().then((_) {
//         _checkController.forward().then((_) {
//           _textController.forward().then((_) {
//             Future.delayed(const Duration(milliseconds: 1400), () {
//               if (mounted) widget.onDismiss();
//             });
//           });
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _bgController.dispose();
//     _circleController.dispose();
//     _checkController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _bgFade,
//       child: Container(
//         color: Colors.black.withOpacity(0.55),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Animated circle with check
//               ScaleTransition(
//                 scale: _circleScale,
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFFE53935).withOpacity(0.35),
//                         blurRadius: 30,
//                         spreadRadius: 6,
//                       ),
//                     ],
//                   ),
//                   child: AnimatedBuilder(
//                     animation: _checkDraw,
//                     builder: (_, __) => CustomPaint(
//                       painter: _CheckPainter(progress: _checkDraw.value),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Animated text
//               SlideTransition(
//                 position: _textSlide,
//                 child: FadeTransition(
//                   opacity: _textFade,
//                   child: Column(
//                     children: [
//                       Text(
//                         widget.message,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       const Text(
//                         'Your hostel is live now!',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Custom painter for animated checkmark
// class _CheckPainter extends CustomPainter {
//   final double progress;
//   _CheckPainter({required this.progress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFE53935)
//       ..strokeWidth = 5
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;

//     final cx = size.width / 2;
//     final cy = size.height / 2;

//     // Checkmark path: two segments
//     // Segment 1: bottom-left diagonal  (40% of progress)
//     // Segment 2: bottom to top-right   (remaining 60%)
//     final p1 = Offset(cx - 18, cy + 2);
//     final pMid = Offset(cx - 4, cy + 16);
//     final p2 = Offset(cx + 20, cy - 14);

//     final seg1Length = (pMid - p1).distance;
//     final seg2Length = (p2 - pMid).distance;
//     final totalLength = seg1Length + seg2Length;

//     final drawn = progress * totalLength;

//     final path = Path();
//     if (drawn <= seg1Length) {
//       final t = drawn / seg1Length;
//       path.moveTo(p1.dx, p1.dy);
//       path.lineTo(
//         p1.dx + (pMid.dx - p1.dx) * t,
//         p1.dy + (pMid.dy - p1.dy) * t,
//       );
//     } else {
//       path.moveTo(p1.dx, p1.dy);
//       path.lineTo(pMid.dx, pMid.dy);
//       final t = (drawn - seg1Length) / seg2Length;
//       path.lineTo(
//         pMid.dx + (p2.dx - pMid.dx) * t,
//         pMid.dy + (p2.dy - pMid.dy) * t,
//       );
//     }

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(_CheckPainter old) => old.progress != progress;
// }

// // ─────────────────────────────────────────────
// // HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PageController _carouselController = PageController();
//   int _carouselPage = 0;
//   List<String> _carouselImages = [];
//   bool _isLoadingBanners = true;
//   bool _showSuccessOverlay = false;
//   String _successMessage = '';

//   // Camera images (local, not yet submitted)
//   final List<XFile> _cameraImages = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchBanners();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadHostels());
//   }

//   Future<void> _loadHostels() async {
//     final vendorId = await SharedPreferenceHelper.getVendorId();
//     if (vendorId == null) return;
//     if (!mounted) return;
//     await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);
//   }

//   Future<void> fetchBanners() async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://31.97.206.144:2003/api/Admin/getAllBanners"),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true) {
//           List banners = data['banners'];
//           List<String> images = [];
//           for (var banner in banners) {
//             images.addAll((banner['images'] as List).map((e) => e.toString()));
//           }
//           setState(() {
//             _carouselImages = images;
//             _isLoadingBanners = false;
//           });
//           return;
//         }
//       }
//     } catch (_) {}
//     setState(() => _isLoadingBanners = false);
//   }

//   @override
//   void dispose() {
//     _carouselController.dispose();
//     super.dispose();
//   }

//   void _showSuccess(String message) {
//     setState(() {
//       _successMessage = message;
//       _showSuccessOverlay = true;
//     });
//   }

//   void _dismissSuccess() {
//     if (mounted) setState(() => _showSuccessOverlay = false);
//   }

//   // ── Determine default AC state for new hostel ─────────────────────────
//   // If existing hostels are all Non-AC → force AC for next one
//   // If existing hostels are all AC → force Non-AC for next one
//   // If mixed or empty → let user choose (default: Non-AC)
//   bool _getDefaultAcForNewHostel() {
//     final hostels = context.read<HostelProvider>().hostels;
//     if (hostels.isEmpty) return false;
//     final hasNonAc = hostels.any((h) => !h.type.contains('AC'));
//     final hasAc = hostels.any((h) => h.type.contains('AC'));
//     if (hasNonAc && !hasAc) return true;   // all Non-AC → next must be AC
//     if (hasAc && !hasNonAc) return false;  // all AC → next must be Non-AC
//     return false; // mixed → default Non-AC, user can toggle
//   }

//   bool _shouldLockAcToggleForNew() {
//     final hostels = context.read<HostelProvider>().hostels;
//     if (hostels.isEmpty) return false;
//     final hasNonAc = hostels.any((h) => !h.type.contains('AC'));
//     final hasAc = hostels.any((h) => h.type.contains('AC'));
//     // Lock if all are the same type — force the opposite
//     return (hasNonAc && !hasAc) || (hasAc && !hasNonAc);
//   }

//   // ── Open HifiDetailsScreen for CREATE ──────────────────────────────────
//   Future<void> _openCreateHostel() async {
//     final defaultAc = _getDefaultAcForNewHostel();
//     final lockToggle = _shouldLockAcToggleForNew();

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => HifiDetailsScreen(
//           cameraImages: _cameraImages,
//           forcedIsAc: defaultAc,
//           lockAcToggle: lockToggle,
//           onSave: (request) async {
//             final vendorId = await SharedPreferenceHelper.getVendorId();
//             if (vendorId == null) return;
//             final finalRequest = HostelRequest(
//               categoryId: request.categoryId,
//               vendorId: vendorId,
//               name: request.name,
//               rating: request.rating,
//               address: request.address,
//               monthlyAdvance: request.monthlyAdvance,
//               latitude: request.latitude,
//               longitude: request.longitude,
//               sharings: request.sharings,
//               imagePaths: request.imagePaths,
//             );
//             if (!mounted) return;
//             final success = await context.read<HostelProvider>().createHostel(
//               finalRequest,
//             );
//             if (mounted) {
//               if (success) {
//                 _showSuccess('Hostel Created!');
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       context.read<HostelProvider>().errorMessage ??
//                           'Failed to create hostel',
//                     ),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             }
//           },
//         ),
//       ),
//     );
//   }

//   // ── Open HifiDetailsScreen for EDIT ───────────────────────────────────
//   Future<void> _openEditHostel(Hostel hostel) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => HifiDetailsScreen(
//           cameraImages: _cameraImages,
//           existingHostel: hostel,
//           onSave: (request) async {
//             if (!mounted) return;
//             final success = await context.read<HostelProvider>().updateHostel(
//               hostelId: hostel.id,
//               request: request,
//             );
//             if (mounted) {
//               if (success) {
//                 _showSuccess('Hostel Updated!');
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       context.read<HostelProvider>().errorMessage ??
//                           'Failed to update hostel',
//                     ),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             }
//           },
//         ),
//       ),
//     );
//   }

//   // ── Delete Hostel ─────────────────────────────────────────────────────
//   Future<void> _deleteHostel(Hostel hostel) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.delete_outline,
//                   color: Color(0xFFE53935),
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Delete Hostel',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Are you sure you want to delete "${hostel.name}"? This action cannot be undone.',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         side: BorderSide(color: Colors.grey.shade300),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: () => Navigator.pop(ctx, false),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE53935),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: () => Navigator.pop(ctx, true),
//                       child: const Text('Delete'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     if (confirmed != true || !mounted) return;

//     final success =
//         await context.read<HostelProvider>().deleteHostel(hostel.id);
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             success
//                 ? 'Hostel deleted successfully'
//                 : context.read<HostelProvider>().errorMessage ??
//                     'Failed to delete hostel',
//           ),
//           backgroundColor: success ? Colors.green : Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Top bar ──────────────────────────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 10,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Location',
//                               style:
//                                   TextStyle(fontSize: 11, color: Colors.grey),
//                             ),
//                             Row(
//                               children: const [
//                                 Icon(
//                                   Icons.location_on,
//                                   color: Color(0xFFE53935),
//                                   size: 16,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   'Kphb Hyderabad Kukatpally ...',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 Icon(Icons.keyboard_arrow_down, size: 18),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Stack(
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         NotificationScreen(),
//                                   ),
//                                 );
//                               },
//                               child: const Icon(
//                                   Icons.notifications_none, size: 26),
//                             ),
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: Container(
//                                 width: 8,
//                                 height: 8,
//                                 decoration: const BoxDecoration(
//                                   color: Color(0xFFE53935),
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ── Carousel ─────────────────────────────────────────────
//                   SizedBox(
//                     height: 130,
//                     child: _isLoadingBanners
//                         ? const Center(child: CircularProgressIndicator())
//                         : _carouselImages.isEmpty
//                             ? const Center(
//                                 child: Text("No banners available"))
//                             : PageView.builder(
//                                 controller: _carouselController,
//                                 itemCount: _carouselImages.length,
//                                 onPageChanged: (i) =>
//                                     setState(() => _carouselPage = i),
//                                 itemBuilder: (context, index) {
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 16),
//                                     child: ClipRRect(
//                                       borderRadius:
//                                           BorderRadius.circular(12),
//                                       child: Stack(
//                                         fit: StackFit.expand,
//                                         children: [
//                                           Image.network(
//                                             _carouselImages[index],
//                                             fit: BoxFit.cover,
//                                             errorBuilder: (_, __, ___) =>
//                                                 Container(
//                                               color:
//                                                   const Color(0xFFEEEEEE),
//                                               child: const Center(
//                                                 child: Icon(
//                                                   Icons.broken_image,
//                                                   size: 40,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               gradient: LinearGradient(
//                                                 begin:
//                                                     Alignment.centerLeft,
//                                                 end: Alignment.centerRight,
//                                                 colors: [
//                                                   Colors.black
//                                                       .withOpacity(0.4),
//                                                   Colors.transparent,
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                   ),

//                   // ── Carousel dots ─────────────────────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(_carouselImages.length, (i) {
//                         return AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: const EdgeInsets.symmetric(horizontal: 3),
//                           width: _carouselPage == i ? 18 : 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(4),
//                             color: _carouselPage == i
//                                 ? const Color(0xFFE53935)
//                                 : Colors.grey.shade300,
//                           ),
//                         );
//                       }),
//                     ),
//                   ),

//                   // ── Camera Section ────────────────────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     child: RichText(
//                       text: const TextSpan(
//                         children: [
//                           TextSpan(
//                             text: 'Camera ',
//                             style: TextStyle(
//                               color: Color(0xFFE53935),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           TextSpan(
//                             text: 'Capturing',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     child: Row(
//                       children: [
//                         ..._cameraImages
//                             .take(3)
//                             .map(
//                               (img) => Padding(
//                                 padding: const EdgeInsets.only(right: 8),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.file(
//                                     File(img.path),
//                                     width: 85,
//                                     height: 90,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => CameraCapturingScreen(
//                                     images: _cameraImages,
//                                     onSave: () => setState(() {}),
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               height: 90,
//                               decoration: BoxDecoration(
//                                 color: _cameraImages.isEmpty
//                                     ? Colors.white
//                                     : Colors.grey.shade50,
//                                 border: Border.all(
//                                     color: Colors.grey.shade300),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.add,
//                                       size: 28, color: Colors.black54),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Add Your Camera',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ── HiFi Details Section ──────────────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     child: RichText(
//                       text: const TextSpan(
//                         children: [
//                           TextSpan(
//                             text: 'Hifi ',
//                             style: TextStyle(
//                               color: Color(0xFFE53935),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           TextSpan(
//                             text: 'Details',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // ── Hostel Cards from Provider ────────────────────────────
//                   Consumer<HostelProvider>(
//                     builder: (context, provider, _) {
//                       if (provider.isLoading) {
//                         return const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }
//                       if (provider.hasError) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 10,
//                           ),
//                           child: Text(
//                             provider.errorMessage ?? 'Something went wrong',
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         );
//                       }
//                       return Column(
//                         children: provider.hostels
//                             .map(
//                               (hostel) => Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 6,
//                                 ),
//                                 child: _HifiHostelCard(
//                                   hostel: hostel,
//                                   isDeleting:
//                                       provider.isDeleting &&
//                                       provider.deletingHostelId == hostel.id,
//                                   onEdit: () => _openEditHostel(hostel),
//                                   onDelete: () => _deleteHostel(hostel),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       );
//                     },
//                   ),

//                   // ── Add Details button ────────────────────────────────────
//                   GestureDetector(
//                     onTap: _openCreateHostel,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       child: Container(
//                         width: double.infinity,
//                         height: 90,
//                         decoration: BoxDecoration(
//                           border:
//                               Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.add,
//                                 size: 32, color: Colors.black54),
//                             SizedBox(height: 6),
//                             Text(
//                               'Add Details',
//                               style: TextStyle(
//                                   fontSize: 14, color: Colors.black54),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 80),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // ── Success overlay ──────────────────────────────────────────────
//         if (_showSuccessOverlay)
//           Positioned.fill(
//             child: _SuccessOverlay(
//               message: _successMessage,
//               onDismiss: _dismissSuccess,
//             ),
//           ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // HIFI HOSTEL CARD
// // ─────────────────────────────────────────────
// class _HifiHostelCard extends StatelessWidget {
//   final Hostel hostel;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final bool isDeleting;

//   const _HifiHostelCard({
//     required this.hostel,
//     required this.onEdit,
//     required this.onDelete,
//     this.isDeleting = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final sharings = hostel.sharings.isNotEmpty
//         ? hostel.sharings
//         : (hostel.rooms?.ac.isNotEmpty == true
//             ? hostel.rooms!.ac
//             : hostel.rooms?.nonAc ?? []);

//     final isAc = hostel.type.contains('AC');
//     final typeLabel =
//         hostel.type.isNotEmpty ? hostel.type.join(' / ') : 'Hostel';

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
//                   ),
//                   child: hostel.images.isNotEmpty
//                       ? Image.network(
//                           hostel.images.first,
//                           width: 100,
//                           height: 110,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => _placeholderImage(),
//                         )
//                       : _placeholderImage(),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 4),
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
//                                   horizontal: 6, vertical: 2),
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
//                             const Icon(Icons.star,
//                                 color: Colors.amber, size: 13),
//                             const SizedBox(width: 2),
//                             Text(
//                               '${hostel.rating}',
//                               style: const TextStyle(fontSize: 11),
//                             ),
//                             const SizedBox(width: 6),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 5, vertical: 2),
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
//                             const Icon(Icons.location_on,
//                                 size: 11, color: Colors.grey),
//                             const SizedBox(width: 2),
//                             Expanded(
//                               child: Text(
//                                 hostel.address,
//                                 style: const TextStyle(
//                                     fontSize: 10, color: Colors.grey),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Wrap(
//                           spacing: 4,
//                           runSpacing: 4,
//                           children: sharings.take(4).map((s) {
//                             final price = s.monthlyPrice ??
//                                 s.acMonthlyPrice ??
//                                 s.nonAcMonthlyPrice;
//                             return Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE53935),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 '${s.shareType}: ₹${price?.toStringAsFixed(0) ?? '-'}/-',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             );
//                           }).toList(),
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
//                       final Uri callUri =
//                           Uri(scheme: 'tel', path: '9961593179');
//                       if (await canLaunchUrl(callUri)) {
//                         await launchUrl(callUri);
//                       }
//                     },
//                   ),
//                   _ActionBtn(
//                     icon: Icons.chat_bubble_outline,
//                     label: 'Whatsapp',
//                     color: const Color(0xFF25D366),
//                     onTap: () async {
//                       final Uri whatsappUri = Uri.parse(
//                         'https://wa.me/919961593179',
//                       );
//                       if (await canLaunchUrl(whatsappUri)) {
//                         await launchUrl(
//                           whatsappUri,
//                           mode: LaunchMode.externalApplication,
//                         );
//                       } else {
//                         final Uri fallbackUri = Uri.parse(
//                           'whatsapp://send?phone=919961593179',
//                         );
//                         if (await canLaunchUrl(fallbackUri)) {
//                           await launchUrl(fallbackUri);
//                         }
//                       }
//                     },
//                   ),
//                   _ActionBtn(
//                     icon: Icons.location_on,
//                     label: 'Location',
//                     color: const Color(0xFF2196F3),
//                     onTap: () {},
//                   ),
//                   _ActionBtn(
//                     icon: Icons.edit,
//                     label: 'Edit',
//                     color: const Color(0xFFE53935),
//                     onTap: onEdit,
//                   ),
//                   // ── Delete button ───────────────────────────────────
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

//   Widget _placeholderImage() {
//     return Container(
//       width: 100,
//       height: 110,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(12),
//           bottomLeft: Radius.circular(12),
//         ),
//       ),
//       child: const Icon(Icons.apartment, size: 40, color: Colors.grey),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // ACTION BUTTON
// // ─────────────────────────────────────────────
// class _ActionBtn extends StatelessWidget {
//   final IconData? icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   final bool isLoading;

//   const _ActionBtn({
//     this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isLoading) ...[
//               const SizedBox(
//                 width: 10,
//                 height: 10,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 1.5,
//                 ),
//               ),
//               const SizedBox(width: 3),
//             ] else if (icon != null) ...[
//               Icon(icon, size: 12, color: Colors.white),
//               const SizedBox(width: 3),
//             ],
//             Text(
//               label,
//               style: const TextStyle(color: Colors.white, fontSize: 10),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // CAMERA CAPTURING SCREEN
// // ─────────────────────────────────────────────
// class CameraCapturingScreen extends StatefulWidget {
//   final List<XFile> images;
//   final VoidCallback onSave;

//   const CameraCapturingScreen({
//     super.key,
//     required this.images,
//     required this.onSave,
//   });

//   @override
//   State<CameraCapturingScreen> createState() => _CameraCapturingScreenState();
// }

// class _CameraCapturingScreenState extends State<CameraCapturingScreen> {
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     XFile? image;
//     try {
//       image = await _picker.pickImage(source: ImageSource.camera);
//     } catch (_) {
//       image = await _picker.pickImage(source: ImageSource.gallery);
//     }
//     if (image != null) setState(() => widget.images.add(image!));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: RichText(
//           text: const TextSpan(
//             children: [
//               TextSpan(
//                 text: 'Camera ',
//                 style: TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               TextSpan(
//                 text: 'Capturing',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: [
//                 ...widget.images.map(
//                   (img) => Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.file(
//                           File(img.path),
//                           width: 150,
//                           height: 150,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Positioned(
//                         right: 4,
//                         top: 4,
//                         child: GestureDetector(
//                           onTap: () =>
//                               setState(() => widget.images.remove(img)),
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.close,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add, size: 32, color: Colors.black54),
//                         SizedBox(height: 6),
//                         Text(
//                           'Add Your Camera',
//                           style:
//                               TextStyle(fontSize: 13, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   widget.onSave();
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Save', style: TextStyle(fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HifiDetailsScreen extends StatefulWidget {
//   final List<XFile> cameraImages;
//   final Hostel? existingHostel;
//   final Function(HostelRequest) onSave;

//   final bool forcedIsAc;

//   final bool lockAcToggle;

//   const HifiDetailsScreen({
//     super.key,
//     required this.cameraImages,
//     required this.onSave,
//     this.existingHostel,
//     this.forcedIsAc = false,
//     this.lockAcToggle = false,
//   });

//   @override
//   State<HifiDetailsScreen> createState() => _HifiDetailsScreenState();
// }

// class _HifiDetailsScreenState extends State<HifiDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late bool _isAcEnabled;

//   // ── Dynamic date state ─────────────────────────────────────────────────
//   late DateTime _selectedDate;
//   late List<Map<String, dynamic>> _dates;

//   final List<XFile> _hostelImages = [];
//   final ImagePicker _picker = ImagePicker();

//   late TextEditingController _titleController;
//   late TextEditingController _addressController;
//   late TextEditingController _advanceController;
//   late TextEditingController _ratingController;
//   late TextEditingController _latController;
//   late TextEditingController _lngController;

//   late Map<String, TextEditingController> _monthlyNonAc;
//   late Map<String, TextEditingController> _monthlyAc;
//   late Map<String, TextEditingController> _dailyNonAc;
//   late Map<String, TextEditingController> _dailyAc;

//   final List<String> _shareKeys = [
//     '1 Share',
//     '2 Share',
//     '3 Share',
//     '4 Share',
//     '5 Share',
//     '6 Share',
//   ];

//   List<Map<String, dynamic>> _buildDates() {
//     const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     final today = DateTime.now();
//     return List.generate(6, (i) {
//       final d = today.add(Duration(days: i));
//       return {
//         'day': dayNames[d.weekday - 1],
//         'date': d.day,
//         'fullDate': d,
//       };
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);

//     _dates = _buildDates();
//     _selectedDate = _dates.first['fullDate'] as DateTime;

//     final h = widget.existingHostel;

//     // AC toggle: existing hostel preserves its type; new hostel uses forced value
//     _isAcEnabled = h != null ? h.type.contains('AC') : widget.forcedIsAc;

//     _titleController =
//         TextEditingController(text: h?.name ?? '');
//     _addressController = TextEditingController(
//       text: h?.address ?? '',
//     );
//     _advanceController = TextEditingController(
//       text: h != null ? h.monthlyAdvance.toStringAsFixed(0) : '',
//     );
//     _ratingController = TextEditingController(
//       text: h != null ? h.rating.toString() : '4.5',
//     );
//     _latController = TextEditingController(
//       text: h != null ? h.latitude.toString() : '',
//     );
//     _lngController = TextEditingController(
//       text: h != null ? h.longitude.toString() : '',
//     );

//     final List<SharingOption> effectiveSharings = h == null
//         ? []
//         : h.sharings.isNotEmpty
//             ? h.sharings
//             : (h.rooms?.ac.isNotEmpty == true
//                 ? h.rooms!.ac
//                 : h.rooms?.nonAc ?? []);

//     _monthlyNonAc = _buildControllers(
//       _shareKeys,
//       effectiveSharings.isEmpty ? null : effectiveSharings,
//       isAc: false,
//       isMonthly: true,
//     );
//     _monthlyAc = _buildControllers(
//       _shareKeys,
//       effectiveSharings.isEmpty ? null : effectiveSharings,
//       isAc: true,
//       isMonthly: true,
//     );
//     _dailyNonAc = _buildControllers(
//       _shareKeys,
//       effectiveSharings.isEmpty ? null : effectiveSharings,
//       isAc: false,
//       isMonthly: false,
//     );
//     _dailyAc = _buildControllers(
//       _shareKeys,
//       effectiveSharings.isEmpty ? null : effectiveSharings,
//       isAc: true,
//       isMonthly: false,
//     );
//   }

//   Map<String, TextEditingController> _buildControllers(
//     List<String> keys,
//     List<SharingOption>? sharings, {
//     required bool isAc,
//     required bool isMonthly,
//   }) {
//     final Map<String, String> defaults = isMonthly
//         ? {
//             '1 Share': isAc ? '9000' : '7000',
//             '2 Share': isAc ? '8000' : '6000',
//             '3 Share': isAc ? '7000' : '5000',
//             '4 Share': isAc ? '6000' : '4500',
//             '5 Share': isAc ? '5000' : '4000',
//             '6 Share': isAc ? '4500' : '3500',
//           }
//         : {
//             '1 Share': isAc ? '600' : '500',
//             '2 Share': isAc ? '550' : '450',
//             '3 Share': isAc ? '500' : '400',
//             '4 Share': isAc ? '450' : '350',
//             '5 Share': isAc ? '400' : '300',
//             '6 Share': isAc ? '350' : '250',
//           };

//     return {
//       for (var key in keys)
//         key: TextEditingController(
//           text: sharings != null
//               ? _findPrice(sharings, key, isAc: isAc, isMonthly: isMonthly)
//               : defaults[key] ?? '0',
//         ),
//     };
//   }

//   String _findPrice(
//     List<SharingOption>? sharings,
//     String shareType, {
//     required bool isAc,
//     required bool isMonthly,
//   }) {
//     if (sharings == null || sharings.isEmpty) return '0';
//     try {
//       SharingOption? match;
//       final lowerKey = shareType.toLowerCase();
//       try {
//         match = sharings.firstWhere(
//           (s) => s.shareType.toLowerCase() == lowerKey,
//         );
//       } catch (_) {}
//       match ??= sharings.firstWhere(
//         (s) => s.shareType.toLowerCase().contains(
//               shareType.split(' ').first.toLowerCase(),
//             ),
//       );

//       double? price;
//       if (isAc) {
//         price = isMonthly ? match.acMonthlyPrice : match.acDailyPrice;
//         if (price == null || price == 0) {
//           price = isMonthly ? match.monthlyPrice : match.dailyPrice;
//         }
//       } else {
//         price = isMonthly ? match.nonAcMonthlyPrice : match.nonAcDailyPrice;
//         if (price == null || price == 0) {
//           price = isMonthly ? match.monthlyPrice : match.dailyPrice;
//         }
//       }

//       if (price == null || price.isNaN || price.isInfinite || price < 0) {
//         return '0';
//       }
//       return price.toStringAsFixed(0);
//     } catch (_) {
//       return '0';
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _titleController.dispose();
//     _addressController.dispose();
//     _advanceController.dispose();
//     _ratingController.dispose();
//     _latController.dispose();
//     _lngController.dispose();
//     for (var c in [
//       ..._monthlyNonAc.values,
//       ..._monthlyAc.values,
//       ..._dailyNonAc.values,
//       ..._dailyAc.values,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _pickHostelImage() async {
//     final image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) setState(() => _hostelImages.add(image));
//   }

//   double _parsePrice(TextEditingController? controller) {
//     if (controller == null) return 0;
//     final text = controller.text.trim();
//     if (text.isEmpty) return 0;
//     final parsed = double.tryParse(text);
//     return (parsed == null || parsed.isNaN || parsed.isInfinite) ? 0 : parsed;
//   }

//   void _saveAndGoBack() {
//     final List<SharingOption> sharings = _shareKeys.map((key) {
//       final nonAcMonthly = _parsePrice(_monthlyNonAc[key]);
//       final nonAcDaily = _parsePrice(_dailyNonAc[key]);
//       final acMonthly = _parsePrice(_monthlyAc[key]);
//       final acDaily = _parsePrice(_dailyAc[key]);

//       if (_isAcEnabled) {
//         return SharingOption(
//           shareType: key,
//           acMonthlyPrice: acMonthly,
//           acDailyPrice: acDaily,
//           nonAcMonthlyPrice: 0,
//           nonAcDailyPrice: 0,
//           monthlyPrice: acMonthly,
//           dailyPrice: acDaily,
//         );
//       } else {
//         return SharingOption(
//           shareType: key,
//           type: 'Non-AC',
//           monthlyPrice: nonAcMonthly,
//           dailyPrice: nonAcDaily,
//           acMonthlyPrice: 0,
//           acDailyPrice: 0,
//           nonAcMonthlyPrice: nonAcMonthly,
//           nonAcDailyPrice: nonAcDaily,
//         );
//       }
//     }).toList();

//     final imagePaths = _hostelImages.isNotEmpty
//         ? _hostelImages.map((x) => x.path).toList()
//         : widget.cameraImages.map((x) => x.path).toList();

//     final request = HostelRequest(
//       name: _titleController.text.trim(),
//       rating: double.tryParse(_ratingController.text.trim()) ?? 4.5,
//       address: _addressController.text.trim(),
//       monthlyAdvance:
//           double.tryParse(_advanceController.text.trim()) ?? 0,
//       latitude: double.tryParse(_latController.text.trim()) ?? 0,
//       longitude: double.tryParse(_lngController.text.trim()) ?? 0,
//       sharings: sharings,
//       imagePaths: imagePaths,
//     );

//     widget.onSave(request);
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.existingHostel != null;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: isEdit ? 'Edit ' : 'Hifi ',
//                 style: const TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               TextSpan(
//                 text: isEdit ? 'Hostel' : 'Details',
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           if (!widget.lockAcToggle || isEdit)
//             Row(
//               children: [
//                 Text(
//                   _isAcEnabled ? 'AC' : 'Non-AC',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 Switch(
//                   value: _isAcEnabled,
//                   onChanged: (v) => setState(() => _isAcEnabled = v),
//                   activeColor: const Color(0xFFE53935),
//                 ),
//               ],
//             )
//           else
//             // Show a locked badge when the type is forced
//             Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: _isAcEnabled
//                       ? Colors.blue.shade50
//                       : Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _isAcEnabled
//                         ? Colors.blue.shade200
//                         : Colors.orange.shade200,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.lock_outline,
//                       size: 12,
//                       color: _isAcEnabled
//                           ? Colors.blue.shade700
//                           : Colors.orange.shade700,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       _isAcEnabled ? 'AC Only' : 'Non-AC Only',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                         color: _isAcEnabled
//                             ? Colors.blue.shade700
//                             : Colors.orange.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),

//       body: SingleChildScrollView(
//         keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Type info banner when locked ─────────────────────────
//             if (widget.lockAcToggle && !isEdit)
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: _isAcEnabled
//                         ? Colors.blue.shade50
//                         : Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: _isAcEnabled
//                           ? Colors.blue.shade200
//                           : Colors.orange.shade200,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.info_outline,
//                         size: 16,
//                         color: _isAcEnabled
//                             ? Colors.blue.shade700
//                             : Colors.orange.shade700,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _isAcEnabled
//                               ? 'You already have Non-AC hostels. This new hostel will be AC only.'
//                               : 'You already have AC hostels. This new hostel will be Non-AC only.',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: _isAcEnabled
//                                 ? Colors.blue.shade700
//                                 : Colors.orange.shade700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // ── Tab bar ──────────────────────────────────────────────
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: TabBar(
//                   controller: _tabController,
//                   indicator: BoxDecoration(
//                     color: const Color(0xFFE53935),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.black54,
//                   tabs: const [
//                     Tab(text: 'Monthly'),
//                     Tab(text: 'Daily'),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Text fields ──────────────────────────────────────────
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Column(
//                 children: [
//                   _buildField(_titleController, 'Hostel Name'),
//                   const SizedBox(height: 8),
//                   _buildField(_addressController, 'Address'),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildField(
//                             _advanceController, 'Monthly Advance'),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                           child: _buildField(_ratingController, 'Rating')),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                           child:
//                               _buildField(_latController, 'Latitude')),
//                       const SizedBox(width: 8),
//                       Expanded(
//                           child:
//                               _buildField(_lngController, 'Longitude')),
//                       const SizedBox(width: 8),
//                       Consumer<HostelProvider>(
//                         builder: (context, provider, _) {
//                           return GestureDetector(
//                             onTap: provider.isFetchingLocation
//                                 ? null
//                                 : () async {
//                                     final success = await provider
//                                         .fetchCurrentLocation();
//                                     if (success && mounted) {
//                                       setState(() {
//                                         _latController.text =
//                                             provider.currentLatitude
//                                                     ?.toStringAsFixed(6) ??
//                                                 '';
//                                         _lngController.text =
//                                             provider.currentLongitude
//                                                     ?.toStringAsFixed(6) ??
//                                                 '';
//                                       });
//                                     } else if (!success && mounted) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             provider.errorMessage ??
//                                                 'Could not fetch location',
//                                           ),
//                                           backgroundColor: Colors.red,
//                                         ),
//                                       );
//                                     }
//                                   },
//                             child: Container(
//                               height: 48,
//                               width: 48,
//                               decoration: BoxDecoration(
//                                 color: provider.isFetchingLocation
//                                     ? Colors.grey.shade300
//                                     : const Color(0xFFE53935),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: provider.isFetchingLocation
//                                   ? const Padding(
//                                       padding: EdgeInsets.all(12),
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : const Icon(
//                                       Icons.my_location,
//                                       color: Colors.white,
//                                       size: 22,
//                                     ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // ── Image picker row ─────────────────────────────────────
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: SizedBox(
//                 height: 80,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     ..._hostelImages.map(
//                       (img) => Stack(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.file(
//                                 File(img.path),
//                                 width: 80,
//                                 height: 80,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             right: 10,
//                             top: 2,
//                             child: GestureDetector(
//                               onTap: () => setState(
//                                   () => _hostelImages.remove(img)),
//                               child: Container(
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.close,
//                                   color: Colors.white,
//                                   size: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (widget.existingHostel != null)
//                       ...widget.existingHostel!.images.map(
//                         (url) => Padding(
//                           padding: const EdgeInsets.only(right: 8),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               url,
//                               width: 80,
//                               height: 80,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(
//                                 width: 80,
//                                 height: 80,
//                                 color: Colors.grey.shade200,
//                                 child: const Icon(
//                                   Icons.broken_image,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     GestureDetector(
//                       onTap: _pickHostelImage,
//                       child: Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.add_a_photo,
//                                 size: 24, color: Colors.black54),
//                             SizedBox(height: 4),
//                             Text(
//                               'Add Image',
//                               style: TextStyle(
//                                   fontSize: 10, color: Colors.black54),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // ── Price section ─────────────────────────────────────────
//             // Only shows the relevant price section based on AC toggle
//             AnimatedBuilder(
//               animation: _tabController,
//               builder: (_, __) {
//                 final label =
//                     _tabController.index == 0 ? 'Monthly' : 'Daily';
//                 return _buildPriceSection(label);
//               },
//             ),

//             // ── Dynamic Date Picker ───────────────────────────────────
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Select Date To Book a Hostel',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     height: 62,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _dates.length,
//                       itemBuilder: (_, i) {
//                         final d = _dates[i];
//                         final fullDate = d['fullDate'] as DateTime;
//                         final isSel =
//                             fullDate.year == _selectedDate.year &&
//                             fullDate.month == _selectedDate.month &&
//                             fullDate.day == _selectedDate.day;

//                         return GestureDetector(
//                           onTap: () =>
//                               setState(() => _selectedDate = fullDate),
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             margin: const EdgeInsets.only(right: 8),
//                             width: 50,
//                             decoration: BoxDecoration(
//                               color: isSel
//                                   ? const Color(0xFFE53935)
//                                   : Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   d['day'] as String,
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: isSel
//                                         ? Colors.white
//                                         : Colors.black54,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${d['date']}',
//                                   style: TextStyle(
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.bold,
//                                     color: isSel
//                                         ? Colors.white
//                                         : Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Submit button ────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Consumer<HostelProvider>(
//                   builder: (context, provider, _) {
//                     return ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE53935),
//                         foregroundColor: Colors.white,
//                         padding:
//                             const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed:
//                           provider.isLoading ? null : _saveAndGoBack,
//                       child: provider.isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               isEdit ? 'Update' : 'Create Hostel',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                     );
//                   },
//                 ),
//               ),
//             ),

//             SizedBox(
//               height:
//                   MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildField(TextEditingController c, String hint,
//       {int maxLines = 1}) {
//     return TextField(
//       controller: c,
//       maxLines: maxLines,
//       keyboardType: maxLines == 1
//           ? TextInputType.text
//           : TextInputType.multiline,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle:
//             const TextStyle(color: Colors.black38, fontSize: 14),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFE53935)),
//         ),
//       ),
//     );
//   }

//   // ── Price section: shows ONLY the relevant AC/Non-AC grid ─────────────
//   Widget _buildPriceSection(String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (_isAcEnabled) ...[
//             // AC hostel → show ONLY AC prices
//             Text(
//               '$label Prices for AC',
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             _buildGrid(
//               label == 'Monthly' ? _monthlyAc : _dailyAc,
//               Colors.blue.shade700,
//             ),
//             const SizedBox(height: 10),
//           ] else ...[
//             // Non-AC hostel → show ONLY Non-AC prices
//             Text(
//               '$label Prices for Non-AC',
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             _buildGrid(
//               label == 'Monthly' ? _monthlyNonAc : _dailyNonAc,
//               const Color(0xFFE53935),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildGrid(
//       Map<String, TextEditingController> prices, Color color) {
//     final keys = prices.keys.toList();
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//         childAspectRatio: 1.4,
//       ),
//       itemCount: keys.length,
//       itemBuilder: (_, i) {
//         final key = keys[i];
//         return Container(
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding: const EdgeInsets.all(6),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 key,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               SizedBox(
//                 height: 22,
//                 child: TextField(
//                   controller: prices[key],
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   decoration: const InputDecoration(
//                     isDense: true,
//                     contentPadding: EdgeInsets.zero,
//                     border: InputBorder.none,
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }







import 'dart:convert';
import 'dart:io';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/create_hostel_model.dart';
import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
import 'package:brando_vendor/views/notifications/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


bool _hostelIsAc(Hostel hostel) {
  final types = hostel.type.map((t) => t.trim().toUpperCase()).toList();
  if (types.any((t) => t == 'NON-AC' || t == 'NON AC')) return false;
  return types.contains('AC');
}

class _SuccessOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  const _SuccessOverlay({required this.message, required this.onDismiss});
  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgController, _circleController,
      _checkController, _textController;
  late Animation<double> _bgFade, _circleScale, _checkDraw, _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _circleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

    _bgFade = CurvedAnimation(parent: _bgController, curve: Curves.easeIn);
    _circleScale = CurvedAnimation(parent: _circleController, curve: Curves.elasticOut);
    _checkDraw = CurvedAnimation(parent: _checkController, curve: Curves.easeOut);
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _bgController.forward().then((_) => _circleController.forward().then((_) =>
        _checkController.forward().then((_) => _textController.forward().then((_) =>
            Future.delayed(const Duration(milliseconds: 1400), () {
              if (mounted) widget.onDismiss();
            })))));
  }

  @override
  void dispose() {
    _bgController.dispose(); _circleController.dispose();
    _checkController.dispose(); _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _bgFade,
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ScaleTransition(
              scale: _circleScale,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white,
                  boxShadow: [BoxShadow(color: const Color(0xFFE53935).withOpacity(0.35), blurRadius: 30, spreadRadius: 6)],
                ),
                child: AnimatedBuilder(
                  animation: _checkDraw,
                  builder: (_, __) => CustomPaint(painter: _CheckPainter(progress: _checkDraw.value)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(children: [
                  Text(widget.message, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                  const SizedBox(height: 6),
                  const Text('Your hostel is live now!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              ),
            ),
          ]),
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
    final paint = Paint()..color = const Color(0xFFE53935)..strokeWidth = 5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final cx = size.width / 2; final cy = size.height / 2;
    final p1 = Offset(cx - 18, cy + 2); final pMid = Offset(cx - 4, cy + 16); final p2 = Offset(cx + 20, cy - 14);
    final seg1Length = (pMid - p1).distance; final seg2Length = (p2 - pMid).distance;
    final drawn = progress * (seg1Length + seg2Length);
    final path = Path();
    if (drawn <= seg1Length) {
      final t = drawn / seg1Length;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p1.dx + (pMid.dx - p1.dx) * t, p1.dy + (pMid.dy - p1.dy) * t);
    } else {
      path.moveTo(p1.dx, p1.dy); path.lineTo(pMid.dx, pMid.dy);
      final t = (drawn - seg1Length) / seg2Length;
      path.lineTo(pMid.dx + (p2.dx - pMid.dx) * t, pMid.dy + (p2.dy - pMid.dy) * t);
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
  final List<XFile> _cameraImages = [];

  @override
  void initState() {
    super.initState();
    fetchBanners();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHostels());
  }

  Future<void> _loadHostels() async {
    final vendorId = await SharedPreferenceHelper.getVendorId();
    if (vendorId == null || !mounted) return;
    await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);
  }

  Future<void> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse("http://31.97.206.144:2003/api/Admin/getAllBanners"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final images = <String>[];
          for (var banner in data['banners'] as List) {
            images.addAll((banner['images'] as List).map((e) => e.toString()));
          }
          setState(() { _carouselImages = images; _isLoadingBanners = false; });
          return;
        }
      }
    } catch (_) {}
    setState(() => _isLoadingBanners = false);
  }

  @override
  void dispose() { _carouselController.dispose(); super.dispose(); }

  void _showSuccess(String message) => setState(() { _successMessage = message; _showSuccessOverlay = true; });
  void _dismissSuccess() { if (mounted) setState(() => _showSuccessOverlay = false); }

  // ── Alternation logic ──────────────────────────────────────────────────
  bool _getDefaultAcForNewHostel() {
    final hostels = context.read<HostelProvider>().hostels;
    if (hostels.isEmpty) return false;
    final hasNonAc = hostels.any((h) => !_hostelIsAc(h));
    final hasAc = hostels.any((h) => _hostelIsAc(h));
    if (hasNonAc && !hasAc) return true;   // all Non-AC → next must be AC
    if (hasAc && !hasNonAc) return false;  // all AC → next must be Non-AC
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
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => HifiDetailsScreen(
        cameraImages: _cameraImages,
        forcedIsAc: defaultAc,
        lockAcToggle: lockToggle,
        onSave: (request) async {
          final vendorId = await SharedPreferenceHelper.getVendorId();
          if (vendorId == null) return;
          // FIX: forward isAc from the request
          final finalRequest = HostelRequest(
            categoryId: request.categoryId,
            vendorId: vendorId,
            name: request.name,
            rating: request.rating,
            address: request.address,
            monthlyAdvance: request.monthlyAdvance,
            latitude: request.latitude,
            longitude: request.longitude,
            isAc: request.isAc,           // ← THE FIX
            sharings: request.sharings,
            imagePaths: request.imagePaths,
          );
          if (!mounted) return;
          final success = await context.read<HostelProvider>().createHostel(finalRequest);
          if (mounted) {
            if (success) {
              _showSuccess('Hostel Created!');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.read<HostelProvider>().errorMessage ?? 'Failed to create hostel'),
                backgroundColor: Colors.red,
              ));
            }
          }
        },
      ),
    ));
  }

  Future<void> _openEditHostel(Hostel hostel) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => HifiDetailsScreen(
        cameraImages: _cameraImages,
        existingHostel: hostel,
        onSave: (request) async {
          if (!mounted) return;
          // isAc is already inside request — no extra wrapping needed for edit
          final success = await context.read<HostelProvider>().updateHostel(hostelId: hostel.id, request: request);
          if (mounted) {
            if (success) {
              _showSuccess('Hostel Updated!');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.read<HostelProvider>().errorMessage ?? 'Failed to update hostel'),
                backgroundColor: Colors.red,
              ));
            }
          }
        },
      ),
    ));
  }

  Future<void> _deleteHostel(Hostel hostel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Delete Hostel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Are you sure you want to delete "${hostel.name}"? This action cannot be undone.',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              )),
            ]),
          ]),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context.read<HostelProvider>().deleteHostel(hostel.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Hostel deleted successfully' : context.read<HostelProvider>().errorMessage ?? 'Failed to delete hostel'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Location', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Row(children: const [
                    Icon(Icons.location_on, color: Color(0xFFE53935), size: 16),
                    SizedBox(width: 4),
                    Text('Kphb Hyderabad Kukatpally ...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Icon(Icons.keyboard_arrow_down, size: 18),
                  ]),
                ]),
                Stack(children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen())),
                    child: const Icon(Icons.notifications_none, size: 26),
                  ),
                  Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle))),
                ]),
              ]),
            ),

            // Carousel
            SizedBox(
              height: 130,
              child: _isLoadingBanners
                  ? const Center(child: CircularProgressIndicator())
                  : _carouselImages.isEmpty
                      ? const Center(child: Text("No banners available"))
                      : PageView.builder(
                          controller: _carouselController,
                          itemCount: _carouselImages.length,
                          onPageChanged: (i) => setState(() => _carouselPage = i),
                          itemBuilder: (_, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(fit: StackFit.expand, children: [
                                Image.network(_carouselImages[index], fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEEEEEE), child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)))),
                                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withOpacity(0.4), Colors.transparent]))),
                              ]),
                            ),
                          ),
                        ),
            ),

            // Dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_carouselImages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _carouselPage == i ? 18 : 8, height: 8,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: _carouselPage == i ? const Color(0xFFE53935) : Colors.grey.shade300),
                )),
              ),
            ),

            // Camera section
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: RichText(text: const TextSpan(children: [
              TextSpan(text: 'Camera ', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 16)),
              TextSpan(text: 'Capturing', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ]))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                ..._cameraImages.take(3).map((img) => Padding(padding: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(img.path), width: 85, height: 90, fit: BoxFit.cover)))),
                Expanded(child: GestureDetector(
                  onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => CameraCapturingScreen(images: _cameraImages, onSave: () => setState(() {})))); },
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(color: _cameraImages.isEmpty ? Colors.white : Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 28, color: Colors.black54), SizedBox(height: 4), Text('Add Your Camera', style: TextStyle(fontSize: 12, color: Colors.black54))]),
                  ),
                )),
              ]),
            ),

            // Hifi heading
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: RichText(text: const TextSpan(children: [
              TextSpan(text: 'Hifi ', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 16)),
              TextSpan(text: 'Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ]))),

            // Hostel cards
            Consumer<HostelProvider>(builder: (context, provider, _) {
              if (provider.isLoading) return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()));
              if (provider.hasError) return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Text(provider.errorMessage ?? 'Something went wrong', style: const TextStyle(color: Colors.red)));
              return Column(children: provider.hostels.map((hostel) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _HifiHostelCard(
                  hostel: hostel,
                  isDeleting: provider.isDeleting && provider.deletingHostelId == hostel.id,
                  onEdit: () => _openEditHostel(hostel),
                  onDelete: () => _deleteHostel(hostel),
                ),
              )).toList());
            }),

            // Add details button
            GestureDetector(
              onTap: _openCreateHostel,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity, height: 90,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 32, color: Colors.black54), SizedBox(height: 6), Text('Add Details', style: TextStyle(fontSize: 14, color: Colors.black54))]),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ))),
      ),
      if (_showSuccessOverlay)
        Positioned.fill(child: _SuccessOverlay(message: _successMessage, onDismiss: _dismissSuccess)),
    ]);
  }
}

// ─────────────────────────────────────────────
// HIFI HOSTEL CARD
// ─────────────────────────────────────────────
class _HifiHostelCard extends StatelessWidget {
  final Hostel hostel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  const _HifiHostelCard({required this.hostel, required this.onEdit, required this.onDelete, this.isDeleting = false});

  @override
  Widget build(BuildContext context) {
    final isAc = _hostelIsAc(hostel); // FIX: safe helper
    final sharings = hostel.sharings.isNotEmpty
        ? hostel.sharings
        : (isAc
            ? (hostel.rooms?.ac.isNotEmpty == true ? hostel.rooms!.ac : hostel.rooms?.nonAc ?? [])
            : (hostel.rooms?.nonAc.isNotEmpty == true ? hostel.rooms!.nonAc : hostel.rooms?.ac ?? []));
    final typeLabel = hostel.type.isNotEmpty ? hostel.type.join(' / ') : 'Hostel';

    return AnimatedOpacity(
      opacity: isDeleting ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12), color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: hostel.images.isNotEmpty
                  ? Image.network(hostel.images.first, width: 100, height: 110, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderImage())
                  : _placeholderImage(),
            ),
            const SizedBox(width: 10),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(hostel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(4)),
                    child: Text(typeLabel, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 13),
                  const SizedBox(width: 2),
                  Text('${hostel.rating}', style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 6),
                  // FIX: AC badge uses safe _hostelIsAc()
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAc ? Colors.blue.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isAc ? Colors.blue.shade200 : Colors.orange.shade200),
                    ),
                    child: Text(isAc ? 'AC' : 'Non-AC', style: TextStyle(fontSize: 9, color: isAc ? Colors.blue.shade700 : Colors.orange.shade700, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on, size: 11, color: Colors.grey),
                  const SizedBox(width: 2),
                  Expanded(child: Text(hostel.address, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 4, runSpacing: 4, children: sharings.take(4).map((s) {
                  final price = s.monthlyPrice ?? s.acMonthlyPrice ?? s.nonAcMonthlyPrice;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(4)),
                    child: Text('${s.shareType}: ₹${price?.toStringAsFixed(0) ?? '-'}/-', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  );
                }).toList()),
              ]),
            )),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              _ActionBtn(icon: Icons.call, label: 'Call', color: const Color(0xFF4CAF50), onTap: () async { final uri = Uri(scheme: 'tel', path: '9961593179'); if (await canLaunchUrl(uri)) await launchUrl(uri); }),
              _ActionBtn(icon: Icons.chat_bubble_outline, label: 'Whatsapp', color: const Color(0xFF25D366), onTap: () async { final uri = Uri.parse('https://wa.me/919961593179'); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }),
              _ActionBtn(icon: Icons.location_on, label: 'Location', color: const Color(0xFF2196F3), onTap: () {}),
              _ActionBtn(icon: Icons.edit, label: 'Edit', color: const Color(0xFFE53935), onTap: onEdit),
              _ActionBtn(icon: isDeleting ? null : Icons.delete_outline, label: isDeleting ? '...' : 'Delete', color: const Color(0xFF757575), onTap: isDeleting ? () {} : onDelete, isLoading: isDeleting),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholderImage() => Container(
    width: 100, height: 110,
    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))),
    child: const Icon(Icons.apartment, size: 40, color: Colors.grey),
  );
}

// ─────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData? icon; final String label; final Color color; final VoidCallback onTap; final bool isLoading;
  const _ActionBtn({this.icon, required this.label, required this.color, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (isLoading) ...[const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5)), const SizedBox(width: 3)]
        else if (icon != null) ...[Icon(icon, size: 12, color: Colors.white), const SizedBox(width: 3)],
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
// CAMERA CAPTURING SCREEN
// ─────────────────────────────────────────────
class CameraCapturingScreen extends StatefulWidget {
  final List<XFile> images; final VoidCallback onSave;
  const CameraCapturingScreen({super.key, required this.images, required this.onSave});
  @override
  State<CameraCapturingScreen> createState() => _CameraCapturingScreenState();
}

class _CameraCapturingScreenState extends State<CameraCapturingScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    XFile? image;
    try { image = await _picker.pickImage(source: ImageSource.camera); } catch (_) { image = await _picker.pickImage(source: ImageSource.gallery); }
    if (image != null) setState(() => widget.images.add(image!));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      title: RichText(text: const TextSpan(children: [
        TextSpan(text: 'Camera ', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 18)),
        TextSpan(text: 'Capturing', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ])),
    ),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Wrap(spacing: 10, runSpacing: 10, children: [
        ...widget.images.map((img) => Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(img.path), width: 150, height: 150, fit: BoxFit.cover)),
          Positioned(right: 4, top: 4, child: GestureDetector(onTap: () => setState(() => widget.images.remove(img)), child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 16)))),
        ])),
        GestureDetector(onTap: _pickImage, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 32, color: Colors.black54), SizedBox(height: 6), Text('Add Your Camera', style: TextStyle(fontSize: 13, color: Colors.black54))]))),
      ]),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () { widget.onSave(); Navigator.pop(context); },
        child: const Text('Save', style: TextStyle(fontSize: 16)),
      )),
    ])),
  );
}

// ─────────────────────────────────────────────
// HIFI DETAILS SCREEN
// ─────────────────────────────────────────────
class HifiDetailsScreen extends StatefulWidget {
  final List<XFile> cameraImages;
  final Hostel? existingHostel;
  final Function(HostelRequest) onSave;
  final bool forcedIsAc;
  final bool lockAcToggle;

  const HifiDetailsScreen({super.key, required this.cameraImages, required this.onSave, this.existingHostel, this.forcedIsAc = false, this.lockAcToggle = false});
  @override
  State<HifiDetailsScreen> createState() => _HifiDetailsScreenState();
}

class _HifiDetailsScreenState extends State<HifiDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isAcEnabled;
  late DateTime _selectedDate;
  late List<Map<String, dynamic>> _dates;
  final List<XFile> _hostelImages = [];
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleController, _addressController, _advanceController, _ratingController, _latController, _lngController;
  late Map<String, TextEditingController> _monthlyNonAc, _monthlyAc, _dailyNonAc, _dailyAc;

  final List<String> _shareKeys = ['1 Share', '2 Share', '3 Share', '4 Share', '5 Share', '6 Share'];

  List<Map<String, dynamic>> _buildDates() {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    return List.generate(6, (i) { final d = today.add(Duration(days: i)); return {'day': dayNames[d.weekday - 1], 'date': d.day, 'fullDate': d}; });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dates = _buildDates();
    _selectedDate = _dates.first['fullDate'] as DateTime;

    final h = widget.existingHostel;
    // FIX: use safe helper for existing hostel
    _isAcEnabled = h != null ? _hostelIsAc(h) : widget.forcedIsAc;

    _titleController = TextEditingController(text: h?.name ?? '');
    _addressController = TextEditingController(text: h?.address ?? '');
    _advanceController = TextEditingController(text: h != null ? h.monthlyAdvance.toStringAsFixed(0) : '');
    _ratingController = TextEditingController(text: h != null ? h.rating.toString() : '4.5');
    _latController = TextEditingController(text: h != null ? h.latitude.toString() : '');
    _lngController = TextEditingController(text: h != null ? h.longitude.toString() : '');

    // FIX: pick sharings based on correct AC type
    final effectiveSharings = h == null ? <SharingOption>[] : h.sharings.isNotEmpty ? h.sharings
        : (_hostelIsAc(h) ? (h.rooms?.ac.isNotEmpty == true ? h.rooms!.ac : h.rooms?.nonAc ?? [])
                          : (h.rooms?.nonAc.isNotEmpty == true ? h.rooms!.nonAc : h.rooms?.ac ?? []));

    _monthlyNonAc = _buildControllers(effectiveSharings, isAc: false, isMonthly: true);
    _monthlyAc    = _buildControllers(effectiveSharings, isAc: true,  isMonthly: true);
    _dailyNonAc   = _buildControllers(effectiveSharings, isAc: false, isMonthly: false);
    _dailyAc      = _buildControllers(effectiveSharings, isAc: true,  isMonthly: false);
  }

  Map<String, TextEditingController> _buildControllers(List<SharingOption> sharings, {required bool isAc, required bool isMonthly}) {
    final defaults = isMonthly
        ? {'1 Share': isAc ? '9000' : '7000', '2 Share': isAc ? '8000' : '6000', '3 Share': isAc ? '7000' : '5000', '4 Share': isAc ? '6000' : '4500', '5 Share': isAc ? '5000' : '4000', '6 Share': isAc ? '4500' : '3500'}
        : {'1 Share': isAc ? '600' : '500', '2 Share': isAc ? '550' : '450', '3 Share': isAc ? '500' : '400', '4 Share': isAc ? '450' : '350', '5 Share': isAc ? '400' : '300', '6 Share': isAc ? '350' : '250'};
    return { for (var key in _shareKeys) key: TextEditingController(text: sharings.isNotEmpty ? _findPrice(sharings, key, isAc: isAc, isMonthly: isMonthly) : defaults[key] ?? '0') };
  }

  // FIX: normalise "1-sharing" → extract number "1" to match "1 Share"
  String _findPrice(List<SharingOption> sharings, String shareKey, {required bool isAc, required bool isMonthly}) {
    if (sharings.isEmpty) return '0';
    final keyNumber = shareKey.split(' ').first.trim();
    SharingOption? match;
    try { match = sharings.firstWhere((s) => s.shareType.toLowerCase() == shareKey.toLowerCase()); } catch (_) {}
    if (match == null) {
      try { match = sharings.firstWhere((s) => s.shareType.replaceAll(RegExp(r'[^0-9]'), '') == keyNumber); } catch (_) {}
    }
    if (match == null) return '0';
    double? price;
    if (isAc) {
      price = isMonthly ? match.acMonthlyPrice : match.acDailyPrice;
      if (price == null || price == 0) price = isMonthly ? match.monthlyPrice : match.dailyPrice;
    } else {
      price = isMonthly ? match.nonAcMonthlyPrice : match.nonAcDailyPrice;
      if (price == null || price == 0) price = isMonthly ? match.monthlyPrice : match.dailyPrice;
    }
    if (price == null || price.isNaN || price.isInfinite || price < 0) return '0';
    return price.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _tabController.dispose(); _titleController.dispose(); _addressController.dispose();
    _advanceController.dispose(); _ratingController.dispose(); _latController.dispose(); _lngController.dispose();
    for (var c in [..._monthlyNonAc.values, ..._monthlyAc.values, ..._dailyNonAc.values, ..._dailyAc.values]) c.dispose();
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

  void _saveAndGoBack() {
    final sharings = _shareKeys.map((key) {
      if (_isAcEnabled) {
        final acMonthly = _parsePrice(_monthlyAc[key]);
        final acDaily   = _parsePrice(_dailyAc[key]);
        return SharingOption(shareType: key, type: 'AC', acMonthlyPrice: acMonthly, acDailyPrice: acDaily, nonAcMonthlyPrice: 0, nonAcDailyPrice: 0, monthlyPrice: acMonthly, dailyPrice: acDaily);
      } else {
        final nonAcMonthly = _parsePrice(_monthlyNonAc[key]);
        final nonAcDaily   = _parsePrice(_dailyNonAc[key]);
        return SharingOption(shareType: key, type: 'Non-AC', monthlyPrice: nonAcMonthly, dailyPrice: nonAcDaily, acMonthlyPrice: 0, acDailyPrice: 0, nonAcMonthlyPrice: nonAcMonthly, nonAcDailyPrice: nonAcDaily);
      }
    }).toList();

    final imagePaths = _hostelImages.isNotEmpty ? _hostelImages.map((x) => x.path).toList() : widget.cameraImages.map((x) => x.path).toList();

    // FIX: isAc is now passed → toFormFields() will send type: ["AC"] or type: ["Non-AC"]
    final request = HostelRequest(
      name: _titleController.text.trim(),
      rating: double.tryParse(_ratingController.text.trim()) ?? 4.5,
      address: _addressController.text.trim(),
      monthlyAdvance: double.tryParse(_advanceController.text.trim()) ?? 0,
      latitude: double.tryParse(_latController.text.trim()) ?? 0,
      longitude: double.tryParse(_lngController.text.trim()) ?? 0,
      isAc: _isAcEnabled,   // ← THE KEY FIX
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
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: RichText(text: TextSpan(children: [
          TextSpan(text: isEdit ? 'Edit ' : 'Hifi ', style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: isEdit ? 'Hostel' : 'Details', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ])),
        actions: [
          if (!widget.lockAcToggle || isEdit)
            Row(children: [
              Text(_isAcEnabled ? 'AC' : 'Non-AC', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
              Switch(value: _isAcEnabled, onChanged: (v) => setState(() => _isAcEnabled = v), activeColor: const Color(0xFFE53935)),
            ])
          else
            Padding(padding: const EdgeInsets.only(right: 16), child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _isAcEnabled ? Colors.blue.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: _isAcEnabled ? Colors.blue.shade200 : Colors.orange.shade200)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_outline, size: 12, color: _isAcEnabled ? Colors.blue.shade700 : Colors.orange.shade700),
                const SizedBox(width: 4),
                Text(_isAcEnabled ? 'AC Only' : 'Non-AC Only', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _isAcEnabled ? Colors.blue.shade700 : Colors.orange.shade700)),
              ]),
            )),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info banner
          if (widget.lockAcToggle && !isEdit)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _isAcEnabled ? Colors.blue.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: _isAcEnabled ? Colors.blue.shade200 : Colors.orange.shade200)),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: _isAcEnabled ? Colors.blue.shade700 : Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text(_isAcEnabled ? 'You already have Non-AC hostels. This new hostel will be AC only.' : 'You already have AC hostels. This new hostel will be Non-AC only.',
                    style: TextStyle(fontSize: 12, color: _isAcEnabled ? Colors.blue.shade700 : Colors.orange.shade700))),
              ]),
            )),

          // Tab bar
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: TabBar(controller: _tabController, indicator: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(8)), indicatorSize: TabBarIndicatorSize.tab, labelColor: Colors.white, unselectedLabelColor: Colors.black54, tabs: const [Tab(text: 'Monthly'), Tab(text: 'Daily')]),
          )),

          // Fields
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            _buildField(_titleController, 'Hostel Name'),
            const SizedBox(height: 8),
            _buildField(_addressController, 'Address'),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: _buildField(_advanceController, 'Monthly Advance')), const SizedBox(width: 8), Expanded(child: _buildField(_ratingController, 'Rating'))]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField(_latController, 'Latitude')),
              const SizedBox(width: 8),
              Expanded(child: _buildField(_lngController, 'Longitude')),
              const SizedBox(width: 8),
              Consumer<HostelProvider>(builder: (context, provider, _) => GestureDetector(
                onTap: provider.isFetchingLocation ? null : () async {
                  final success = await provider.fetchCurrentLocation();
                  if (success && mounted) {
                    setState(() { _latController.text = provider.currentLatitude?.toStringAsFixed(6) ?? ''; _lngController.text = provider.currentLongitude?.toStringAsFixed(6) ?? ''; });
                  } else if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Could not fetch location'), backgroundColor: Colors.red));
                  }
                },
                child: Container(
                  height: 48, width: 48,
                  decoration: BoxDecoration(color: provider.isFetchingLocation ? Colors.grey.shade300 : const Color(0xFFE53935), borderRadius: BorderRadius.circular(8)),
                  child: provider.isFetchingLocation ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.my_location, color: Colors.white, size: 22),
                ),
              )),
            ]),
          ])),

          // Image picker
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: SizedBox(height: 80, child: ListView(scrollDirection: Axis.horizontal, children: [
            ..._hostelImages.map((img) => Stack(children: [
              Padding(padding: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(img.path), width: 80, height: 80, fit: BoxFit.cover))),
              Positioned(right: 10, top: 2, child: GestureDetector(onTap: () => setState(() => _hostelImages.remove(img)), child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)))),
            ])),
            if (widget.existingHostel != null)
              ...widget.existingHostel!.images.map((url) => Padding(padding: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)))))),
            GestureDetector(onTap: _pickHostelImage, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 24, color: Colors.black54), SizedBox(height: 4), Text('Add Image', style: TextStyle(fontSize: 10, color: Colors.black54))]))),
          ]))),

          const SizedBox(height: 8),

          // Price section
          AnimatedBuilder(animation: _tabController, builder: (_, __) => _buildPriceSection(_tabController.index == 0 ? 'Monthly' : 'Daily')),

          // Date picker
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select Date To Book a Hostel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            SizedBox(height: 62, child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemBuilder: (_, i) {
                final d = _dates[i]; final fullDate = d['fullDate'] as DateTime;
                final isSel = fullDate.year == _selectedDate.year && fullDate.month == _selectedDate.month && fullDate.day == _selectedDate.day;
                return GestureDetector(onTap: () => setState(() => _selectedDate = fullDate), child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8), width: 50,
                  decoration: BoxDecoration(color: isSel ? const Color(0xFFE53935) : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(d['day'] as String, style: TextStyle(fontSize: 10, color: isSel ? Colors.white : Colors.black54)),
                    Text('${d['date']}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black)),
                  ]),
                ));
              },
            )),
          ])),

          // Submit
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), child: SizedBox(width: double.infinity, child: Consumer<HostelProvider>(builder: (context, provider, _) => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: provider.isLoading ? null : _saveAndGoBack,
            child: provider.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(isEdit ? 'Update' : 'Create Hostel', style: const TextStyle(fontSize: 16)),
          )))),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint, {int maxLines = 1}) => TextField(
    controller: c, maxLines: maxLines,
    keyboardType: maxLines == 1 ? TextInputType.text : TextInputType.multiline,
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE53935))),
    ),
  );

  Widget _buildPriceSection(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_isAcEnabled) ...[
        Text('$label Prices for AC', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildGrid(label == 'Monthly' ? _monthlyAc : _dailyAc, Colors.blue.shade700),
        const SizedBox(height: 10),
      ] else ...[
        Text('$label Prices for Non-AC', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildGrid(label == 'Monthly' ? _monthlyNonAc : _dailyNonAc, const Color(0xFFE53935)),
        const SizedBox(height: 10),
      ],
    ]),
  );

  Widget _buildGrid(Map<String, TextEditingController> prices, Color color) {
    final keys = prices.keys.toList();
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.4),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        return Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(6),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(key, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            SizedBox(height: 22, child: TextField(controller: prices[key], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none), keyboardType: TextInputType.number)),
          ]),
        );
      },
    );
  }
}