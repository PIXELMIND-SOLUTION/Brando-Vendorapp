// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// class HifiHostel {
//   final String title;
//   final double rating;
//   final String address;
//   final bool isAc;
//   final String type;
//   final Map<String, String> prices;
//   final String advance;
//   final String instructions;

//   HifiHostel({
//     required this.title,
//     required this.rating,
//     required this.address,
//     required this.isAc,
//     required this.type,
//     required this.prices,
//     required this.advance,
//     required this.instructions,
//   });
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PageController _carouselController = PageController();
//   int _carouselPage = 0;

//   // Shared state – camera images and hifi hostels
//   final List<XFile> _cameraImages = [];
//   final List<HifiHostel> _hifiHostels = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchBanners();
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

//           // Flatten all images into one list
//           List<String> images = [];
//           for (var banner in banners) {
//             List imgs = banner['images'];
//             images.addAll(imgs.map((e) => e.toString()));
//           }

//           setState(() {
//             _carouselImages = images;
//             _isLoadingBanners = false;
//           });
//         }
//       } else {
//         setState(() => _isLoadingBanners = false);
//       }
//     } catch (e) {
//       setState(() => _isLoadingBanners = false);
//     }
//   }

//   List<String> _carouselImages = [];
//   bool _isLoadingBanners = true;

//   @override
//   void dispose() {
//     _carouselController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Top bar ──────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Location',
//                           style: TextStyle(fontSize: 11, color: Colors.grey),
//                         ),
//                         Row(
//                           children: const [
//                             Icon(
//                               Icons.location_on,
//                               color: Color(0xFFE53935),
//                               size: 16,
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Kphb Hyderabad Kukatpally ...',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Icon(Icons.keyboard_arrow_down, size: 18),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Stack(
//                       children: [
//                         const Icon(Icons.notifications_none, size: 26),
//                         Positioned(
//                           right: 0,
//                           top: 0,
//                           child: Container(
//                             width: 8,
//                             height: 8,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFE53935),
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 130,
//                 child: _isLoadingBanners
//                     ? const Center(child: CircularProgressIndicator())
//                     : _carouselImages.isEmpty
//                     ? const Center(child: Text("No banners available"))
//                     : PageView.builder(
//                         controller: _carouselController,
//                         itemCount: _carouselImages.length,
//                         onPageChanged: (i) => setState(() => _carouselPage = i),
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   Image.network(
//                                     _carouselImages[index],
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) => Container(
//                                       color: const Color(0xFFEEEEEE),
//                                       child: const Center(
//                                         child: Icon(
//                                           Icons.broken_image,
//                                           size: 40,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ),
//                                   ),

//                                   // Gradient overlay
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         begin: Alignment.centerLeft,
//                                         end: Alignment.centerRight,
//                                         colors: [
//                                           Colors.black.withOpacity(0.4),
//                                           Colors.transparent,
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),

//               // ── Carousel dots ─────────────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(_carouselImages.length, (i) {
//                     return AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       margin: const EdgeInsets.symmetric(horizontal: 3),
//                       width: _carouselPage == i ? 18 : 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(4),
//                         color: _carouselPage == i
//                             ? const Color(0xFFE53935)
//                             : Colors.grey.shade300,
//                       ),
//                     );
//                   }),
//                 ),
//               ),

//               // ── Camera Section ────────────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 4,
//                 ),
//                 child: RichText(
//                   text: const TextSpan(
//                     children: [
//                       TextSpan(
//                         text: 'Camera ',
//                         style: TextStyle(
//                           color: Color(0xFFE53935),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       TextSpan(
//                         text: 'Capturing',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Camera thumbnails + add button
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: Row(
//                   children: [
//                     // Existing thumbnails
//                     ..._cameraImages
//                         .take(3)
//                         .map(
//                           (img) => Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.file(
//                                 File(img.path),
//                                 width: 85,
//                                 height: 90,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                         ),
//                     // Add Camera button (always visible)
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () async {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => CameraCapturingScreen(
//                                 images: _cameraImages,
//                                 onSave: () => setState(() {}),
//                               ),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           height: 90,
//                           decoration: BoxDecoration(
//                             color: _cameraImages.isEmpty
//                                 ? Colors.white
//                                 : Colors.grey.shade50,
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.add, size: 28, color: Colors.black54),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Add Your Camera',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ── HiFi Details Section ──────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 4,
//                 ),
//                 child: RichText(
//                   text: const TextSpan(
//                     children: [
//                       TextSpan(
//                         text: 'Hifi ',
//                         style: TextStyle(
//                           color: Color(0xFFE53935),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       TextSpan(
//                         text: 'Details',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Saved HiFi hostel cards
//               ..._hifiHostels.map(
//                 (h) => Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 6,
//                   ),
//                   child: _HifiHostelCard(hostel: h),
//                 ),
//               ),

//               // Add Details button (always visible)
//               GestureDetector(
//                 onTap: () async {
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => HifiDetailsScreen(
//                         onSave: (hostel) =>
//                             setState(() => _hifiHostels.add(hostel)),
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     height: 90,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add, size: 32, color: Colors.black54),
//                         SizedBox(height: 6),
//                         Text(
//                           'Add Details',
//                           style: TextStyle(fontSize: 14, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 80),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // HIFI HOSTEL CARD
// // ─────────────────────────────────────────────
// class _HifiHostelCard extends StatelessWidget {
//   final HifiHostel hostel;

//   const _HifiHostelCard({required this.hostel});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade200),
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image + info row
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Hostel image
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                   bottomLeft: Radius.circular(12),
//                   bottomRight: Radius.circular(12),
//                 ),
//                 child: Image.asset(
//                   'assets/hostelimage.png',
//                   width: 100,
//                   height: 110,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 100,
//                     height: 110,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(12),
//                         bottomLeft: Radius.circular(12),
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.apartment,
//                       size: 40,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               // Info
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 10,
//                     horizontal: 4,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               hostel.title,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFE53935),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               hostel.type,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(Icons.star, color: Colors.amber, size: 13),
//                           const SizedBox(width: 2),
//                           Text(
//                             '${hostel.rating}',
//                             style: const TextStyle(fontSize: 11),
//                           ),
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 5,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: hostel.isAc
//                                   ? Colors.blue.shade50
//                                   : Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(4),
//                               border: Border.all(
//                                 color: hostel.isAc
//                                     ? Colors.blue.shade200
//                                     : Colors.orange.shade200,
//                               ),
//                             ),
//                             child: Text(
//                               hostel.isAc ? 'AC' : 'Non-AC',
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 color: hostel.isAc
//                                     ? Colors.blue.shade700
//                                     : Colors.orange.shade700,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.location_on,
//                             size: 11,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 2),
//                           Expanded(
//                             child: Text(
//                               hostel.address,
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.grey,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       // Price chips
//                       Wrap(
//                         spacing: 4,
//                         runSpacing: 4,
//                         children: hostel.prices.entries
//                             .take(4)
//                             .map(
//                               (e) => Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 3,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFE53935),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   '${e.key}: ₹${e.value}/-',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // Action buttons
//           Padding(
//             padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
//             child: Row(
//               children: [
//                 _ActionBtn(
//                   icon: Icons.call,
//                   label: 'call',
//                   color: const Color(0xFF4CAF50),
//                   onTap: () {},
//                 ),
//                 const SizedBox(width: 6),
//                 _ActionBtn(
//                   icon: Icons.chat_bubble_outline,
//                   label: 'Whatsapp',
//                   color: const Color(0xFF25D366),
//                   onTap: () {},
//                 ),
//                 const SizedBox(width: 6),
//                 _ActionBtn(
//                   icon: Icons.location_on,
//                   label: 'Location',
//                   color: const Color(0xFF2196F3),
//                   onTap: () {},
//                 ),
//                 const SizedBox(width: 6),
//                 _ActionBtn(
//                   // icon: Icons.local_offer,
//                   label: 'Edit',
//                   color: const Color.fromARGB(255, 255, 0, 0),
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class _ActionBtn extends StatelessWidget {
//   final IconData? icon; // 👈 make nullable
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _ActionBtn({
//     this.icon, // 👈 not required
//     required this.label,
//     required this.color,
//     required this.onTap,
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
//             if (icon != null) ...[
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
//                           style: TextStyle(fontSize: 13, color: Colors.black54),
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

// // ─────────────────────────────────────────────
// // HIFI DETAILS SCREEN
// // ─────────────────────────────────────────────
// class HifiDetailsScreen extends StatefulWidget {
//   final Function(HifiHostel) onSave;

//   const HifiDetailsScreen({super.key, required this.onSave});

//   @override
//   State<HifiDetailsScreen> createState() => _HifiDetailsScreenState();
// }

// class _HifiDetailsScreenState extends State<HifiDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isAcEnabled = false;
//   int _selectedDate = 13;

//   final TextEditingController _titleController = TextEditingController(
//     text: 'HIFI HOSTELS',
//   );
//   final TextEditingController _addressController = TextEditingController(
//     text: 'Kukatpally, Hyderabad',
//   );
//   final TextEditingController _advanceController = TextEditingController();
//   final TextEditingController _instructionsController = TextEditingController();

//   final Map<String, TextEditingController> _monthlyNonAc = {
//     '1 SHARE': TextEditingController(text: '5000'),
//     '2 SHARE': TextEditingController(text: '4500'),
//     '3 SHARE': TextEditingController(text: '4000'),
//     '4 SHARE': TextEditingController(text: '3500'),
//   };
//   final Map<String, TextEditingController> _monthlyAc = {
//     '1 SHARE': TextEditingController(text: '7000'),
//     '2 SHARE': TextEditingController(text: '6000'),
//     '3 SHARE': TextEditingController(text: '5500'),
//     '4 SHARE': TextEditingController(text: '5000'),
//   };
//   final Map<String, TextEditingController> _dailyNonAc = {
//     '1 SHARE': TextEditingController(text: '350'),
//     '2 SHARE': TextEditingController(text: '300'),
//     '3 SHARE': TextEditingController(text: '250'),
//     '4 SHARE': TextEditingController(text: '200'),
//   };
//   final Map<String, TextEditingController> _dailyAc = {
//     '1 SHARE': TextEditingController(text: '600'),
//     '2 SHARE': TextEditingController(text: '500'),
//     '3 SHARE': TextEditingController(text: '450'),
//     '4 SHARE': TextEditingController(text: '400'),
//   };

//   final List<Map<String, dynamic>> _dates = [
//     {'day': 'Sun', 'date': 13},
//     {'day': 'Mon', 'date': 14},
//     {'day': 'Tue', 'date': 15},
//     {'day': 'Wed', 'date': 16},
//     {'day': 'Thu', 'date': 17},
//     {'day': 'Fri', 'date': 18},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _titleController.dispose();
//     _addressController.dispose();
//     _advanceController.dispose();
//     _instructionsController.dispose();
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

//   void _saveAndGoBack() {
//     final isMonthly = _tabController.index == 0;
//     final prices = isMonthly
//         ? (_isAcEnabled ? _monthlyAc : _monthlyNonAc)
//         : (_isAcEnabled ? _dailyAc : _dailyNonAc);

//     final hostel = HifiHostel(
//       title:
//           '${_titleController.text} ${_isAcEnabled ? 'AC' : 'Non-AC'} ${isMonthly ? 'Monthly' : 'Daily'}',
//       rating: 4.5,
//       address: _addressController.text,
//       isAc: _isAcEnabled,
//       type: isMonthly ? 'Monthly' : 'Daily',
//       prices: {for (var e in prices.entries) e.key: e.value.text},
//       advance: _advanceController.text,
//       instructions: _instructionsController.text,
//     );

//     widget.onSave(hostel);
//     Navigator.pop(context);
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
//                 text: 'Hifi ',
//                 style: TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               TextSpan(
//                 text: 'Details',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           Row(
//             children: [
//               Text(
//                 _isAcEnabled ? 'AC' : 'Non-AC',
//                 style: const TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black54,
//                 ),
//               ),
//               Switch(
//                 value: _isAcEnabled,
//                 onChanged: (v) => setState(() => _isAcEnabled = v),
//                 activeColor: const Color(0xFFE53935),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Tab bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: TabBar(
//                 controller: _tabController,
//                 indicator: BoxDecoration(
//                   color: const Color(0xFFE53935),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 indicatorSize: TabBarIndicatorSize.tab,
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.black54,
//                 tabs: const [
//                   Tab(text: 'Monthly'),
//                   Tab(text: 'Daily'),
//                 ],
//               ),
//             ),
//           ),

//           // Fields
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Column(
//               children: [
//                 _buildField(_titleController, 'Hostel Name'),
//                 const SizedBox(height: 8),
//                 _buildField(_addressController, 'Address'),
//                 const SizedBox(height: 8),
//                 _buildField(_advanceController, 'Advance'),
//                 const SizedBox(height: 8),
//                 _buildField(
//                   _instructionsController,
//                   'Instructions',
//                   maxLines: 2,
//                 ),
//               ],
//             ),
//           ),

//           // Price grids
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildPriceSection('Monthly'),
//                 _buildPriceSection('Daily'),
//               ],
//             ),
//           ),

//           // Date picker
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Select Date To Book a Hostel',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   height: 62,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _dates.length,
//                     itemBuilder: (_, i) {
//                       final d = _dates[i];
//                       final sel = d['date'] == _selectedDate;
//                       return GestureDetector(
//                         onTap: () =>
//                             setState(() => _selectedDate = d['date'] as int),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           margin: const EdgeInsets.only(right: 8),
//                           width: 50,
//                           decoration: BoxDecoration(
//                             color: sel
//                                 ? const Color(0xFFE53935)
//                                 : Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 d['day'] as String,
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: sel ? Colors.white : Colors.black54,
//                                 ),
//                               ),
//                               Text(
//                                 '${d['date']}',
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.bold,
//                                   color: sel ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Update button
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
//             child: SizedBox(
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
//                 onPressed: _saveAndGoBack,
//                 child: const Text('Update', style: TextStyle(fontSize: 16)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildField(TextEditingController c, String hint, {int maxLines = 1}) {
//     return TextField(
//       controller: c,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 12,
//         ),
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

//   Widget _buildPriceSection(String label) {
//     final nonAc = label == 'Monthly' ? _monthlyNonAc : _dailyNonAc;
//     final ac = label == 'Monthly' ? _monthlyAc : _dailyAc;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (_isAcEnabled) ...[
//             Text(
//               '$label Prices for AC',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             _buildGrid(ac, Colors.blue.shade700),
//             const SizedBox(height: 14),
//           ],
//           Text(
//             '$label Prices for Non-AC',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           ),
//           const SizedBox(height: 8),
//           _buildGrid(nonAc, const Color(0xFFE53935)),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   Widget _buildGrid(Map<String, TextEditingController> prices, Color color) {
//     final keys = prices.keys.toList();
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//         childAspectRatio: 1.1,
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
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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

  // Camera images (local, not yet submitted)
  final List<XFile> _cameraImages = [];

  @override
  void initState() {
    super.initState();
    fetchBanners();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHostels());
  }

  Future<void> _loadHostels() async {
    final vendorId = await SharedPreferenceHelper.getVendorId();
    if (vendorId == null) return;
    if (!mounted) return;
    await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);
  }

  Future<void> fetchBanners() async {
    try {
      final response = await http.get(
        Uri.parse("http://31.97.206.144:2003/api/Admin/getAllBanners"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List banners = data['banners'];
          List<String> images = [];
          for (var banner in banners) {
            images.addAll((banner['images'] as List).map((e) => e.toString()));
          }
          setState(() {
            _carouselImages = images;
            _isLoadingBanners = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() => _isLoadingBanners = false);
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  // ── Open HifiDetailsScreen for CREATE ──────────────────────────────────
  Future<void> _openCreateHostel() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HifiDetailsScreen(
          cameraImages: _cameraImages,
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
              sharings: request.sharings,
              imagePaths: request.imagePaths,
            );
            if (!mounted) return;
            final success = await context.read<HostelProvider>().createHostel(
              finalRequest,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Hostel created successfully!'
                        : context.read<HostelProvider>().errorMessage ??
                              'Failed to create hostel',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ── Open HifiDetailsScreen for EDIT ───────────────────────────────────
  Future<void> _openEditHostel(Hostel hostel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HifiDetailsScreen(
          cameraImages: _cameraImages,
          existingHostel: hostel,
          onSave: (request) async {
            if (!mounted) return;
            final success = await context.read<HostelProvider>().updateHostel(
              hostelId: hostel.id,
              request: request,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Hostel updated successfully!'
                        : context.read<HostelProvider>().errorMessage ??
                              'Failed to update hostel',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────
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
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.location_on,
                              color: Color(0xFFE53935),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Kphb Hyderabad Kukatpally ...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        const Icon(Icons.notifications_none, size: 26),
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
                    ? const Center(child: CircularProgressIndicator())
                    : _carouselImages.isEmpty
                    ? const Center(child: Text("No banners available"))
                    : PageView.builder(
                        controller: _carouselController,
                        itemCount: _carouselImages.length,
                        onPageChanged: (i) => setState(() => _carouselPage = i),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    _carouselImages[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFFEEEEEE),
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
                                          Colors.black.withOpacity(0.4),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ── Carousel dots ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_carouselImages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _carouselPage == i ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _carouselPage == i
                            ? const Color(0xFFE53935)
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),

              // ── Camera Section ────────────────────────────────────────
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

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ..._cameraImages
                        .take(3)
                        .map(
                          (img) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(img.path),
                                width: 85,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CameraCapturingScreen(
                                images: _cameraImages,
                                onSave: () => setState(() {}),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: _cameraImages.isEmpty
                                ? Colors.white
                                : Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 28, color: Colors.black54),
                              SizedBox(height: 4),
                              Text(
                                'Add Your Camera',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── HiFi Details Section ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: RichText(
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
              ),

              // ── Hostel Cards from Provider ────────────────────────────
              Consumer<HostelProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (provider.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        provider.errorMessage ?? 'Something went wrong',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return Column(
                    children: provider.hostels
                        .map(
                          (hostel) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: _HifiHostelCard(
                              hostel: hostel,
                              onEdit: () => _openEditHostel(hostel),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),

              // ── Add Details button ────────────────────────────────────
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
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 32, color: Colors.black54),
                        SizedBox(height: 6),
                        Text(
                          'Add Details',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HIFI HOSTEL CARD
// ─────────────────────────────────────────────
class _HifiHostelCard extends StatelessWidget {
  final Hostel hostel;
  final VoidCallback onEdit;

  const _HifiHostelCard({required this.hostel, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Pick the first sharing for price preview
    final sharings = hostel.sharings.isNotEmpty
        ? hostel.sharings
        : (hostel.rooms?.ac.isNotEmpty == true
              ? hostel.rooms!.ac
              : hostel.rooms?.nonAc ?? []);

    final isAc = hostel.type.contains('AC');
    final typeLabel = hostel.type.isNotEmpty
        ? hostel.type.join(' / ')
        : 'Hostel';

    return Container(
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
              // ── Hostel image (network or placeholder) ──
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: hostel.images.isNotEmpty
                    ? Image.network(
                        hostel.images.first,
                        width: 100,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 10),

              // ── Info ──────────────────────────────────
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
                          const Icon(Icons.star, color: Colors.amber, size: 13),
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

                      // ── Price chips ──────────────────────
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: sharings.take(4).map((s) {
                          final price =
                              s.monthlyPrice ??
                              s.acMonthlyPrice ??
                              s.nonAcMonthlyPrice;
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
                              '${s.shareType}: ₹${price?.toStringAsFixed(0) ?? '-'}/-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Action buttons ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                _ActionBtn(
                  icon: Icons.call,
                  label: 'Call',
                  color: const Color(0xFF4CAF50),
                  onTap: () {},
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline,
                  label: 'Whatsapp',
                  color: const Color(0xFF25D366),
                  onTap: () {},
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: const Color(0xFF2196F3),
                  onTap: () {},
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.edit,
                  label: 'Edit',
                  color: const Color(0xFFE53935),
                  onTap: onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 100,
      height: 110,
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
}

// ─────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            if (icon != null) ...[
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
}

// ─────────────────────────────────────────────
// CAMERA CAPTURING SCREEN
// ─────────────────────────────────────────────
class CameraCapturingScreen extends StatefulWidget {
  final List<XFile> images;
  final VoidCallback onSave;

  const CameraCapturingScreen({
    super.key,
    required this.images,
    required this.onSave,
  });

  @override
  State<CameraCapturingScreen> createState() => _CameraCapturingScreenState();
}

class _CameraCapturingScreenState extends State<CameraCapturingScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    XFile? image;
    try {
      image = await _picker.pickImage(source: ImageSource.camera);
    } catch (_) {
      image = await _picker.pickImage(source: ImageSource.gallery);
    }
    if (image != null) setState(() => widget.images.add(image!));
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
                text: 'Capturing',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...widget.images.map(
                  (img) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(img.path),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => widget.images.remove(img)),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 32, color: Colors.black54),
                        SizedBox(height: 6),
                        Text(
                          'Add Your Camera',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  widget.onSave();
                  Navigator.pop(context);
                },
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HIFI DETAILS SCREEN  (Create + Edit)
// ─────────────────────────────────────────────
class HifiDetailsScreen extends StatefulWidget {
  final List<XFile> cameraImages;
  final Hostel? existingHostel; // null = create, non-null = edit
  final Function(HostelRequest) onSave;

  const HifiDetailsScreen({
    super.key,
    required this.cameraImages,
    required this.onSave,
    this.existingHostel,
  });

  @override
  State<HifiDetailsScreen> createState() => _HifiDetailsScreenState();
}

class _HifiDetailsScreenState extends State<HifiDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAcEnabled = false;
  int _selectedDate = 13;

  // Local images picked on this screen
  final List<XFile> _hostelImages = [];
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _advanceController;
  late TextEditingController _ratingController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  // Price controllers
  late Map<String, TextEditingController> _monthlyNonAc;
  late Map<String, TextEditingController> _monthlyAc;
  late Map<String, TextEditingController> _dailyNonAc;
  late Map<String, TextEditingController> _dailyAc;

  final List<String> _shareKeys = [
    '1 Share',
    '2 Share',
    '3 Share',
    '4 Share',
    '5 Share',
    '6 Share',
  ];

  final List<Map<String, dynamic>> _dates = [
    {'day': 'Sun', 'date': 13},
    {'day': 'Mon', 'date': 14},
    {'day': 'Tue', 'date': 15},
    {'day': 'Wed', 'date': 16},
    {'day': 'Thu', 'date': 17},
    {'day': 'Fri', 'date': 18},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final h = widget.existingHostel;

    _titleController = TextEditingController(text: h?.name ?? 'HIFI HOSTELS');
    _addressController = TextEditingController(
      text: h?.address ?? 'Kukatpally, Hyderabad',
    );
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

    if (h != null) {
      _isAcEnabled = h.type.contains('AC');
    }

    // Initialise price controllers — prefill from existing hostel if editing
    _monthlyNonAc = _buildControllers(
      _shareKeys,
      h?.sharings,
      isAc: false,
      isMonthly: true,
    );
    _monthlyAc = _buildControllers(
      _shareKeys,
      h?.sharings,
      isAc: true,
      isMonthly: true,
    );
    _dailyNonAc = _buildControllers(
      _shareKeys,
      h?.sharings,
      isAc: false,
      isMonthly: false,
    );
    _dailyAc = _buildControllers(
      _shareKeys,
      h?.sharings,
      isAc: true,
      isMonthly: false,
    );
  }

  /// Builds a controller map for a given share list.
  /// Falls back to empty string when no existing data found.
  // Map<String, TextEditingController> _buildControllers(
  //   List<String> keys,
  //   List<SharingOption>? sharings, {
  //   required bool isAc,
  //   required bool isMonthly,
  // }) {
  //   return {
  //     for (var key in keys)
  //       key: TextEditingController(
  //         text: _findPrice(sharings, key, isAc: isAc, isMonthly: isMonthly),
  //       ),
  //   };
  // }

  // Replace _buildControllers with default prices
  Map<String, TextEditingController> _buildControllers(
    List<String> keys,
    List<SharingOption>? sharings, {
    required bool isAc,
    required bool isMonthly,
  }) {
    // Default prices when creating new hostel
    final Map<String, String> defaults = isMonthly
        ? {
            '1 Share': isAc ? '9000' : '7000',
            '2 Share': isAc ? '8000' : '6000',
            '3 Share': isAc ? '7000' : '5000',
            '4 Share': isAc ? '6000' : '4500',
            '5 Share': isAc ? '5000' : '4000',
            '6 Share': isAc ? '4500' : '3500',
          }
        : {
            '1 Share': isAc ? '600' : '500',
            '2 Share': isAc ? '550' : '450',
            '3 Share': isAc ? '500' : '400',
            '4 Share': isAc ? '450' : '350',
            '5 Share': isAc ? '400' : '300',
            '6 Share': isAc ? '350' : '250',
          };

    return {
      for (var key in keys)
        key: TextEditingController(
          text: sharings != null
              ? _findPrice(sharings, key, isAc: isAc, isMonthly: isMonthly)
              : defaults[key] ?? '0',
        ),
    };
  }

  String _findPrice(
    List<SharingOption>? sharings,
    String shareType, {
    required bool isAc,
    required bool isMonthly,
  }) {
    if (sharings == null) return '';
    try {
      final match = sharings.firstWhere(
        (s) => s.shareType.toLowerCase() == shareType.toLowerCase(),
        orElse: () => sharings.firstWhere(
          (s) => s.shareType.toLowerCase().contains(
            shareType.split(' ').first.toLowerCase(),
          ),
        ),
      );
      double? price;
      if (isAc) {
        price = isMonthly ? match.acMonthlyPrice : match.acDailyPrice;
      } else {
        price = isMonthly ? match.nonAcMonthlyPrice : match.nonAcDailyPrice;
      }
      price ??= isMonthly ? match.monthlyPrice : match.dailyPrice;
      return price != null ? price.toStringAsFixed(0) : '';
    } catch (_) {
      return '';
    }
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
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickHostelImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _hostelImages.add(image));
  }

  // Replace _saveAndGoBack
  void _saveAndGoBack() {
    final List<SharingOption> sharings = _shareKeys.map((key) {
      // Parse with fallback to 0 — never null/NaN
      final acMonthly =
          double.tryParse(_monthlyAc[key]?.text.trim() ?? '') ?? 0;
      final acDaily = double.tryParse(_dailyAc[key]?.text.trim() ?? '') ?? 0;
      final nonAcMonthly =
          double.tryParse(_monthlyNonAc[key]?.text.trim() ?? '') ?? 0;
      final nonAcDaily =
          double.tryParse(_dailyNonAc[key]?.text.trim() ?? '') ?? 0;

      if (_isAcEnabled) {
        // Both AC and Non-AC → use ac* and nonAc* fields
        return SharingOption(
          shareType: key,
          acMonthlyPrice: acMonthly,
          acDailyPrice: acDaily,
          nonAcMonthlyPrice: nonAcMonthly,
          nonAcDailyPrice: nonAcDaily,
        );
      } else {
        // Non-AC only → use monthlyPrice / dailyPrice with type: "Non-AC"
        return SharingOption(
          shareType: key,
          type: 'Non-AC',
          monthlyPrice: nonAcMonthly,
          dailyPrice: nonAcDaily,
        );
      }
    }).toList();

    final imagePaths = _hostelImages.isNotEmpty
        ? _hostelImages.map((x) => x.path).toList()
        : widget.cameraImages.map((x) => x.path).toList();

    final request = HostelRequest(
      name: _titleController.text.trim(),
      rating: double.tryParse(_ratingController.text.trim()) ?? 4.5,
      address: _addressController.text.trim(),
      monthlyAdvance: double.tryParse(_advanceController.text.trim()) ?? 0,
      latitude: double.tryParse(_latController.text.trim()) ?? 0,
      longitude: double.tryParse(_lngController.text.trim()) ?? 0,
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
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Tab bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

          // ── Fields ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                _buildField(_titleController, 'Hostel Name'),
                const SizedBox(height: 8),
                _buildField(_addressController, 'Address'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(_advanceController, 'Monthly Advance'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(_ratingController, 'Rating')),
                  ],
                ),
                const SizedBox(height: 8),

                // Row(
                //   children: [
                //     Expanded(
                //         child: _buildField(_latController, 'Latitude')),
                //     const SizedBox(width: 8),
                //     Expanded(
                //         child: _buildField(_lngController, 'Longitude')),
                //   ],
                // ),
                Row(
                  children: [
                    Expanded(child: _buildField(_latController, 'Latitude')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(_lngController, 'Longitude')),
                    const SizedBox(width: 8),
                    Consumer<HostelProvider>(
                      builder: (context, provider, _) {
                        return GestureDetector(
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
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Image picker row ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Picked images
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
                  // Existing network images (edit mode)
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
                  // Add image button
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

          // ── Price grids ──────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPriceSection('Monthly'),
                _buildPriceSection('Daily'),
              ],
            ),
          ),

          // ── Date picker ──────────────────────────────────────────────
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
                      final sel = d['date'] == _selectedDate;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDate = d['date'] as int),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          width: 50,
                          decoration: BoxDecoration(
                            color: sel
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
                                  color: sel ? Colors.white : Colors.black54,
                                ),
                              ),
                              Text(
                                '${d['date']}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: sel ? Colors.white : Colors.black,
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

          // ── Submit button ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: Consumer<HostelProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: maxLines == 1
          ? TextInputType.text
          : TextInputType.multiline,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
  }

  Widget _buildPriceSection(String label) {
    final nonAc = label == 'Monthly' ? _monthlyNonAc : _dailyNonAc;
    final ac = label == 'Monthly' ? _monthlyAc : _dailyAc;

    return SingleChildScrollView(
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
            _buildGrid(ac, Colors.blue.shade700),
            const SizedBox(height: 14),
          ],
          Text(
            '$label Prices for Non-AC',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildGrid(nonAc, const Color(0xFFE53935)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildGrid(Map<String, TextEditingController> prices, Color color) {
    final keys = prices.keys.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
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
                key,
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
                  controller: prices[key],
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
