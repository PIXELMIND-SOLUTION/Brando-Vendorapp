// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   final PageController _carouselController = PageController();
//   int _carouselPage = 0;

//   final List<String> _carouselImages = [
//     'assets/carouselimage.png',
//     'assets/carouselimage.png',
//     'assets/carouselimage.png',
//   ];

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
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Location',
//                             style: TextStyle(fontSize: 11, color: Colors.grey)),
//                         Row(
//                           children: [
//                             const Icon(Icons.location_on,
//                                 color: Color(0xFFE53935), size: 16),
//                             const SizedBox(width: 4),
//                             const Text('Kphb Hyderabad Kukatpally ...',
//                                 style: TextStyle(
//                                     fontSize: 13, fontWeight: FontWeight.w600)),
//                             const Icon(Icons.keyboard_arrow_down, size: 18),
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

//               // ── Carousel ─────────────────────────────
//               SizedBox(
//                 height: 130,
//                 child: PageView.builder(
//                   controller: _carouselController,
//                   itemCount: _carouselImages.length,
//                   onPageChanged: (i) => setState(() => _carouselPage = i),
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             Image.asset(
//                               _carouselImages[index],
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(
//                                 color: const Color(0xFFEEEEEE),
//                                 child: const Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.apartment,
//                                           size: 40, color: Colors.grey),
//                                       SizedBox(height: 4),
//                                       Text('HOSTEL ROOMS\nAvailable',
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               color: Color(0xFFE53935))),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // gradient overlay
//                             Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.centerLeft,
//                                   end: Alignment.centerRight,
//                                   colors: [
//                                     Colors.black.withOpacity(0.4),
//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const Positioned(
//                               left: 12,
//                               top: 12,
//                               child: Text(
//                                 'HOSTEL ROOMS\nAvailable',
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
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
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 child: RichText(
//                   text: const TextSpan(
//                     children: [
//                       TextSpan(
//                           text: 'Camera ',
//                           style: TextStyle(
//                               color: Color(0xFFE53935),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16)),
//                       TextSpan(
//                           text: 'Capturing',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16)),
//                     ],
//                   ),
//                 ),
//               ),

//               GestureDetector(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => const CameraCapturingScreen()),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Container(
//                     width: double.infinity,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child:  Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add, size: 32, color: Colors.black54),
//                         SizedBox(height: 6),
//                         Text('Add Your Camera',
//                             style:
//                                 TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // ── HiFi Details Section ──────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 child: RichText(
//                   text: const TextSpan(
//                     children: [
//                       TextSpan(
//                           text: 'Hifi ',
//                           style: TextStyle(
//                               color: Color(0xFFE53935),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16)),
//                       TextSpan(
//                           text: 'Details',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16)),
//                     ],
//                   ),
//                 ),
//               ),

//               GestureDetector(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const HifiDetailsScreen()),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Container(
//                     width: double.infinity,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child:  Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add, size: 32, color: Colors.black54),
//                         SizedBox(height: 6),
//                         Text('Add Details',
//                             style:
//                                 TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.bold)),
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

// class CameraCapturingScreen extends StatefulWidget {
//   const CameraCapturingScreen({super.key});

//   @override
//   State<CameraCapturingScreen> createState() => _CameraCapturingScreenState();
// }

// class _CameraCapturingScreenState extends State<CameraCapturingScreen> {
//   XFile? _capturedImage;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final XFile? image =
//         await _picker.pickImage(source: ImageSource.camera).catchError((_) async {
//       return await _picker.pickImage(source: ImageSource.gallery);
//     });
//     if (image != null) setState(() => _capturedImage = image);
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
//                   text: 'Camera ',
//                   style: TextStyle(
//                       color: Color(0xFFE53935),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18)),
//               TextSpan(
//                   text: 'Capturing',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18)),
//             ],
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 // Captured image preview
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       height: 150,
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: _capturedImage != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.file(File(_capturedImage!.path),
//                                   fit: BoxFit.cover),
//                             )
//                           : Center(
//                               child: Container(
//                                 width: 60,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: Colors.white, width: 2),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Icon(Icons.crop_square,
//                                     color: Colors.white, size: 30),
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Add more camera button
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       height: 150,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: const Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add, size: 32, color: Colors.black54),
//                           SizedBox(height: 6),
//                           Text('Add Your Camera',
//                               style: TextStyle(
//                                   fontSize: 13, color: Colors.black54)),
//                         ],
//                       ),
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
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Navigator.pop(context),
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
//   const HifiDetailsScreen({super.key});

//   @override
//   State<HifiDetailsScreen> createState() => _HifiDetailsScreenState();
// }

// class _HifiDetailsScreenState extends State<HifiDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isAcEnabled = false;
//   int _selectedDate = 13;

//   // Editable price controllers – Monthly
//   final Map<String, TextEditingController> _monthlyPrices = {
//     '1 SHARE\n(AC)': TextEditingController(text: '7000'),
//     '2 SHARE\n(AC)': TextEditingController(text: '6000'),
//     '3 SHARE\n(AC)': TextEditingController(text: '5500'),
//     '4 SHARE\n(AC)': TextEditingController(text: '5000'),
//     '1 SHARE\n(Non-AC)': TextEditingController(text: '5000'),
//     '2 SHARE\n(Non-AC)': TextEditingController(text: '4500'),
//     '3 SHARE\n(Non-AC)': TextEditingController(text: '4000'),
//     '4 SHARE\n(Non-AC)': TextEditingController(text: '3500'),
//   };

//   // Editable price controllers – Daily
//   final Map<String, TextEditingController> _dailyPrices = {
//     '1 SHARE\n(AC)': TextEditingController(text: '600'),
//     '2 SHARE\n(AC)': TextEditingController(text: '500'),
//     '3 SHARE\n(AC)': TextEditingController(text: '450'),
//     '4 SHARE\n(AC)': TextEditingController(text: '400'),
//     '1 SHARE\n(Non-AC)': TextEditingController(text: '350'),
//     '2 SHARE\n(Non-AC)': TextEditingController(text: '300'),
//     '3 SHARE\n(Non-AC)': TextEditingController(text: '250'),
//     '4 SHARE\n(Non-AC)': TextEditingController(text: '200'),
//   };

//   final TextEditingController _advanceController =
//       TextEditingController(text: '');
//   final TextEditingController _instructionsController =
//       TextEditingController(text: '');

//   final List<Map<String, dynamic>> _dates = [
//     {'day': 'Sun', 'date': 13},
//     {'day': 'Mon', 'date': 14},
//     {'day': 'Tue', 'date': 15},
//     {'day': 'Wed', 'date': 16},
//     {'day': 'Tue', 'date': 17},
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
//     for (var c in _monthlyPrices.values) c.dispose();
//     for (var c in _dailyPrices.values) c.dispose();
//     _advanceController.dispose();
//     _instructionsController.dispose();
//     super.dispose();
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
//                   text: 'Hifi ',
//                   style: TextStyle(
//                       color: Color(0xFFE53935),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18)),
//               TextSpan(
//                   text: 'Details',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18)),
//             ],
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Switch(
//               value: _isAcEnabled,
//               onChanged: (v) => setState(() => _isAcEnabled = v),
//               activeColor: const Color(0xFFE53935),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // ── Tab bar ─────────────────────────────
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

//           // ── Advance & Instructions ───────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Column(
//               children: [
//                 _buildTextField(_advanceController, 'Advance'),
//                 const SizedBox(height: 8),
//                 _buildTextField(_instructionsController, 'Instructions',
//                     maxLines: 2),
//               ],
//             ),
//           ),

//           // ── Tab view ────────────────────────────
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildPriceGrid(_monthlyPrices, 'Monthly'),
//                 _buildPriceGrid(_dailyPrices, 'Daily'),
//               ],
//             ),
//           ),

//           // ── Date selector ────────────────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Select Date To Book a Hostel',
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                 const SizedBox(height: 10),
//                 SizedBox(
//                   height: 64,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _dates.length,
//                     itemBuilder: (_, i) {
//                       final d = _dates[i];
//                       final selected = d['date'] == _selectedDate;
//                       return GestureDetector(
//                         onTap: () =>
//                             setState(() => _selectedDate = d['date'] as int),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           margin: const EdgeInsets.only(right: 8),
//                           width: 52,
//                           decoration: BoxDecoration(
//                             color: selected
//                                 ? const Color(0xFFE53935)
//                                 : Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(d['day'] as String,
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: selected
//                                           ? Colors.white
//                                           : Colors.black54)),
//                               Text('${d['date']}',
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: selected
//                                           ? Colors.white
//                                           : Colors.black)),
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

//           // ── Update button ────────────────────────
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
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('Details updated!'),
//                         backgroundColor: Color(0xFFE53935)),
//                   );
//                 },
//                 child: const Text('Update', style: TextStyle(fontSize: 16)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String hint,
//       {int maxLines = 1}) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
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

//   Widget _buildPriceGrid(
//       Map<String, TextEditingController> prices, String label) {
//     final acKeys =
//         prices.keys.where((k) => k.contains('AC') && !k.contains('Non')).toList();
//     final nonAcKeys =
//         prices.keys.where((k) => k.contains('Non-AC')).toList();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (_isAcEnabled) ...[
//             Text('$label Prices for AC',
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 14)),
//             const SizedBox(height: 8),
//             _buildGrid(acKeys, prices, Colors.blue.shade700),
//             const SizedBox(height: 16),
//           ],
//           Text('$label Prices for Non- Ac',
//               style:
//                   const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//           const SizedBox(height: 8),
//           _buildGrid(nonAcKeys, prices, const Color(0xFFE53935)),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _buildGrid(List<String> keys,
//       Map<String, TextEditingController> prices, Color color) {
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
//               Text(key,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                       fontWeight: FontWeight.w500)),
//               const SizedBox(height: 4),
//               SizedBox(
//                 height: 22,
//                 child: TextField(
//                   controller: prices[key],
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold),
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













import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class HifiHostel {
  final String title;
  final double rating;
  final String address;
  final bool isAc;
  final String type;
  final Map<String, String> prices;
  final String advance;
  final String instructions;

  HifiHostel({
    required this.title,
    required this.rating,
    required this.address,
    required this.isAc,
    required this.type,
    required this.prices,
    required this.advance,
    required this.instructions,
  });
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _carouselController = PageController();
  int _carouselPage = 0;

  // Shared state – camera images and hifi hostels
  final List<XFile> _cameraImages = [];
  final List<HifiHostel> _hifiHostels = [];

  final List<String> _carouselImages = [
    'assets/carouselimage.png',
    'assets/carouselimage.png',
    'assets/carouselimage.png',
  ];

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
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
              // ── Top bar ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Row(
                          children: const [
                            Icon(Icons.location_on,
                                color: Color(0xFFE53935), size: 16),
                            SizedBox(width: 4),
                            Text('Kphb Hyderabad Kukatpally ...',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
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

              // ── Carousel ─────────────────────────────
              SizedBox(
                height: 130,
                child: PageView.builder(
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
                            Image.asset(
                              _carouselImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFEEEEEE),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.apartment,
                                          size: 40, color: Colors.grey),
                                      SizedBox(height: 4),
                                      Text('HOSTEL ROOMS\nAvailable',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE53935))),
                                    ],
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
                            const Positioned(
                              left: 12,
                              top: 12,
                              child: Text(
                                'HOSTEL ROOMS\nAvailable',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Carousel dots ─────────────────────────
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

              // ── Camera Section ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Camera ',
                          style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      TextSpan(
                          text: 'Capturing',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),

              // Camera thumbnails + add button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Existing thumbnails
                    ..._cameraImages.take(3).map((img) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(img.path),
                                width: 85,
                                height: 90,
                                fit: BoxFit.cover),
                          ),
                        )),
                    // Add Camera button (always visible)
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
                            border:
                                Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add,
                                  size: 28, color: Colors.black54),
                              SizedBox(height: 4),
                              Text('Add Your Camera',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── HiFi Details Section ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Hifi ',
                          style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      TextSpan(
                          text: 'Details',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),

              // Saved HiFi hostel cards
              ..._hifiHostels.map((h) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: _HifiHostelCard(hostel: h),
                  )),

              // Add Details button (always visible)
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HifiDetailsScreen(
                        onSave: (hostel) =>
                            setState(() => _hifiHostels.add(hostel)),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        Text('Add Details',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black54)),
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
  final HifiHostel hostel;

  const _HifiHostelCard({required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hostel image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)
                ),
                child: Image.asset(
                  'assets/hostelimage.png',
                  width: 100,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.apartment,
                        size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hostel.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(hostel.type,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 13),
                          const SizedBox(width: 2),
                          Text('${hostel.rating}',
                              style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: hostel.isAc
                                  ? Colors.blue.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: hostel.isAc
                                      ? Colors.blue.shade200
                                      : Colors.orange.shade200),
                            ),
                            child: Text(
                              hostel.isAc ? 'AC' : 'Non-AC',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: hostel.isAc
                                      ? Colors.blue.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 11, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              hostel.address,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Price chips
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: hostel.prices.entries
                            .take(4)
                            .map((e) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${e.key}: ₹${e.value}/-',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                _ActionBtn(
                    icon: Icons.call,
                    label: 'call',
                    color: const Color(0xFF4CAF50),
                    onTap: () {}),
                const SizedBox(width: 6),
                _ActionBtn(
                    icon: Icons.chat_bubble_outline,
                    label: 'Whatsapp',
                    color: const Color(0xFF25D366),
                    onTap: () {}),
                const SizedBox(width: 6),
                _ActionBtn(
                    icon: Icons.location_on,
                    label: 'Location',
                    color: const Color(0xFF2196F3),
                    onTap: () {}),
                const SizedBox(width: 6),
                _ActionBtn(
                    // icon: Icons.local_offer,
                    label: 'Edit',
                    color: const Color.fromARGB(255, 255, 0, 0),
                    onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _ActionBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _ActionBtn(
//       {required this.icon,
//       required this.label,
//       required this.color,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 12, color: Colors.white),
//             const SizedBox(width: 3),
//             Text(label,
//                 style: const TextStyle(
//                     color: Colors.white, fontSize: 10)),
//           ],
//         ),
//       ),
//     );
//   }
// }




class _ActionBtn extends StatelessWidget {
  final IconData? icon;   // 👈 make nullable
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    this.icon,            // 👈 not required
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
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

  const CameraCapturingScreen(
      {super.key, required this.images, required this.onSave});

  @override
  State<CameraCapturingScreen> createState() =>
      _CameraCapturingScreenState();
}

class _CameraCapturingScreenState
    extends State<CameraCapturingScreen> {
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
                      fontSize: 18)),
              TextSpan(
                  text: 'Capturing',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
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
                ...widget.images.map((img) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(img.path),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setState(
                                () => widget.images.remove(img)),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    )),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add,
                            size: 32, color: Colors.black54),
                        SizedBox(height: 6),
                        Text('Add Your Camera',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54)),
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
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  widget.onSave();
                  Navigator.pop(context);
                },
                child: const Text('Save',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HIFI DETAILS SCREEN
// ─────────────────────────────────────────────
class HifiDetailsScreen extends StatefulWidget {
  final Function(HifiHostel) onSave;

  const HifiDetailsScreen({super.key, required this.onSave});

  @override
  State<HifiDetailsScreen> createState() => _HifiDetailsScreenState();
}

class _HifiDetailsScreenState extends State<HifiDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAcEnabled = false;
  int _selectedDate = 13;

  final TextEditingController _titleController =
      TextEditingController(text: 'HIFI HOSTELS');
  final TextEditingController _addressController =
      TextEditingController(text: 'Kukatpally, Hyderabad');
  final TextEditingController _advanceController =
      TextEditingController();
  final TextEditingController _instructionsController =
      TextEditingController();

  final Map<String, TextEditingController> _monthlyNonAc = {
    '1 SHARE': TextEditingController(text: '5000'),
    '2 SHARE': TextEditingController(text: '4500'),
    '3 SHARE': TextEditingController(text: '4000'),
    '4 SHARE': TextEditingController(text: '3500'),
  };
  final Map<String, TextEditingController> _monthlyAc = {
    '1 SHARE': TextEditingController(text: '7000'),
    '2 SHARE': TextEditingController(text: '6000'),
    '3 SHARE': TextEditingController(text: '5500'),
    '4 SHARE': TextEditingController(text: '5000'),
  };
  final Map<String, TextEditingController> _dailyNonAc = {
    '1 SHARE': TextEditingController(text: '350'),
    '2 SHARE': TextEditingController(text: '300'),
    '3 SHARE': TextEditingController(text: '250'),
    '4 SHARE': TextEditingController(text: '200'),
  };
  final Map<String, TextEditingController> _dailyAc = {
    '1 SHARE': TextEditingController(text: '600'),
    '2 SHARE': TextEditingController(text: '500'),
    '3 SHARE': TextEditingController(text: '450'),
    '4 SHARE': TextEditingController(text: '400'),
  };

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _advanceController.dispose();
    _instructionsController.dispose();
    for (var c in [..._monthlyNonAc.values, ..._monthlyAc.values,
      ..._dailyNonAc.values, ..._dailyAc.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveAndGoBack() {
    final isMonthly = _tabController.index == 0;
    final prices = isMonthly
        ? (_isAcEnabled ? _monthlyAc : _monthlyNonAc)
        : (_isAcEnabled ? _dailyAc : _dailyNonAc);

    final hostel = HifiHostel(
      title:
          '${_titleController.text} ${_isAcEnabled ? 'AC' : 'Non-AC'} ${isMonthly ? 'Monthly' : 'Daily'}',
      rating: 4.5,
      address: _addressController.text,
      isAc: _isAcEnabled,
      type: isMonthly ? 'Monthly' : 'Daily',
      prices: {for (var e in prices.entries) e.key: e.value.text},
      advance: _advanceController.text,
      instructions: _instructionsController.text,
    );

    widget.onSave(hostel);
    Navigator.pop(context);
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
                  text: 'Hifi ',
                  style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              TextSpan(
                  text: 'Details',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
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
                    color: Colors.black54),
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
          // Tab bar
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

          // Fields
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Column(
              children: [
                _buildField(_titleController, 'Hostel Name'),
                const SizedBox(height: 8),
                _buildField(_addressController, 'Address'),
                const SizedBox(height: 8),
                _buildField(_advanceController, 'Advance'),
                const SizedBox(height: 8),
                _buildField(
                    _instructionsController, 'Instructions',
                    maxLines: 2),
              ],
            ),
          ),

          // Price grids
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPriceSection('Monthly'),
                _buildPriceSection('Daily'),
              ],
            ),
          ),

          // Date picker
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Date To Book a Hostel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
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
                        onTap: () => setState(
                            () => _selectedDate = d['date'] as int),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          width: 50,
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFE53935)
                                : Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(d['day'] as String,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: sel
                                          ? Colors.white
                                          : Colors.black54)),
                              Text('${d['date']}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: sel
                                          ? Colors.white
                                          : Colors.black)),
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

          // Update button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveAndGoBack,
                child: const Text('Update',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.black38, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFFE53935)),
        ),
      ),
    );
  }

  Widget _buildPriceSection(String label) {
    final nonAc =
        label == 'Monthly' ? _monthlyNonAc : _dailyNonAc;
    final ac = label == 'Monthly' ? _monthlyAc : _dailyAc;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAcEnabled) ...[
            Text('$label Prices for AC',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _buildGrid(ac, Colors.blue.shade700),
            const SizedBox(height: 14),
          ],
          Text('$label Prices for Non-AC',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildGrid(nonAc, const Color(0xFFE53935)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildGrid(
      Map<String, TextEditingController> prices, Color color) {
    final keys = prices.keys.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
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
              Text(key,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              SizedBox(
                height: 22,
                child: TextField(
                  controller: prices[key],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
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