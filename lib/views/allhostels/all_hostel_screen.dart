// // import 'package:brando_vendor/helper/shared_preference.dart';
// // import 'package:brando_vendor/model/user_booking_model.dart';
// // import 'package:brando_vendor/provider/booking/booking_provider.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // class AllHostelScreen extends StatefulWidget {
// //   const AllHostelScreen({super.key});

// //   @override
// //   State<AllHostelScreen> createState() => _AllHostelScreenState();
// // }

// // class _AllHostelScreenState extends State<AllHostelScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   String? _vendorId;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 3, vsync: this); // 3 tabs only
// //     _loadVendorAndFetch();
// //   }

// //   Future<void> _loadVendorAndFetch() async {
// //     _vendorId = await SharedPreferenceHelper.getVendorId();
// //     if (_vendorId != null && mounted) {
// //       await context.read<BookingRequestProvider>().fetchAllBookingRequests(
// //         _vendorId!,
// //       );
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F6FA),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         title: const Text(
// //           'Booking Requests',
// //           style: TextStyle(
// //             color: Color(0xFF1A1A2E),
// //             fontWeight: FontWeight.w700,
// //             fontSize: 20,
// //           ),
// //         ),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           labelColor: const Color(0xFF4F46E5),
// //           unselectedLabelColor: const Color(0xFF9CA3AF),
// //           indicatorColor: const Color(0xFF4F46E5),
// //           indicatorWeight: 3,
// //           labelStyle: const TextStyle(
// //             fontWeight: FontWeight.w600,
// //             fontSize: 13,
// //           ),
// //           tabs: const [
// //             Tab(text: 'Pending'),
// //             Tab(text: 'Running'),
// //             Tab(text: 'Cancelled'),
// //           ],
// //         ),
// //       ),
// //       body: Consumer<BookingRequestProvider>(
// //         builder: (context, provider, _) {
// //           if (provider.isLoading) {
// //             return const Center(
// //               child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
// //             );
// //           }

// //           if (provider.status == BookingRequestStatus.error) {
// //             return _buildErrorState(provider.errorMessage, provider);
// //           }

// //           return TabBarView(
// //             controller: _tabController,
// //             children: [
// //               // Pending Tab - Show Accept/Reject buttons
// //               _buildBookingList(
// //                 provider.pendingRequests,
// //                 provider,
// //                 showActions: true,
// //               ),
// //               // Running Tab - No buttons (view only)
// //               _buildBookingList(
// //                 provider.runningRequests,
// //                 provider,
// //                 showActions: false,
// //               ),
// //               // Cancelled Tab - No buttons (view only)
// //               _buildBookingList(
// //                 provider.cancelledRequests,
// //                 provider,
// //                 showActions: false,
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildErrorState(String message, BookingRequestProvider provider) {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(
// //               Icons.error_outline_rounded,
// //               color: Color(0xFFEF4444),
// //               size: 56,
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               'Something went wrong',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600,
// //                 color: Colors.grey[800],
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               message,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(fontSize: 13, color: Colors.grey[500]),
// //             ),
// //             const SizedBox(height: 24),
// //             ElevatedButton.icon(
// //               onPressed: () {
// //                 if (_vendorId != null) {
// //                   provider.fetchAllBookingRequests(_vendorId!);
// //                 }
// //               },
// //               icon: const Icon(Icons.refresh_rounded, size: 18),
// //               label: const Text('Retry'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF4F46E5),
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 24,
// //                   vertical: 12,
// //                 ),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBookingList(
// //     List<BookingRequestModel> requests,
// //     BookingRequestProvider provider, {
// //     bool showActions = false,
// //   }) {
// //     if (requests.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
// //             const SizedBox(height: 12),
// //             Text(
// //               'No ${_getTabTitle()} bookings',
// //               style: TextStyle(
// //                 fontSize: 15,
// //                 color: Colors.grey[400],
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return RefreshIndicator(
// //       color: const Color(0xFF4F46E5),
// //       onRefresh: () async {
// //         if (_vendorId != null) {
// //           await provider.fetchAllBookingRequests(_vendorId!);
// //         }
// //       },
// //       child: ListView.separated(
// //         padding: const EdgeInsets.all(16),
// //         itemCount: requests.length,
// //         separatorBuilder: (_, __) => const SizedBox(height: 12),
// //         itemBuilder: (context, index) {
// //           return _BookingRequestCard(
// //             booking: requests[index],
// //             provider: provider,
// //             vendorId: _vendorId,
// //             showActions: showActions,
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   String _getTabTitle() {
// //     switch (_tabController.index) {
// //       case 0:
// //         return 'pending';
// //       case 1:
// //         return 'running';
// //       case 2:
// //         return 'cancelled';
// //       default:
// //         return '';
// //     }
// //   }
// // }

// // class _BookingRequestCard extends StatelessWidget {
// //   final BookingRequestModel booking;
// //   final BookingRequestProvider provider;
// //   final String? vendorId;
// //   final bool showActions;

// //   const _BookingRequestCard({
// //     required this.booking,
// //     required this.provider,
// //     this.vendorId,
// //     this.showActions = false,
// //   });

// //   Color get _statusColor => booking.getStatusColor();

// //   IconData get _statusIcon {
// //     switch (booking.status.toLowerCase()) {
// //       case 'running':
// //         return Icons.play_circle_rounded;
// //       case 'cancelled':
// //         return Icons.cancel_rounded;
// //       default:
// //         return Icons.schedule_rounded;
// //     }
// //   }

// //   String _formatDate(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year}';
// //   }

// //   Future<void> _handleAccept(BuildContext context) async {
// //     if (vendorId == null) return;

// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: const Text(
// //           'Accept Request?',
// //           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
// //         ),
// //         content: Text(
// //           'Are you sure you want to accept this booking from ${booking.user.name}?',
// //           style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx, false),
// //             child: const Text(
// //               'Cancel',
// //               style: TextStyle(color: Color(0xFF6B7280)),
// //             ),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(ctx, true),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: const Color(0xFF10B981),
// //               foregroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //             ),
// //             child: const Text('Accept'),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirmed == true && context.mounted) {
// //       final success = await provider.acceptBooking(
// //         vendorId: vendorId!,
// //         bookingId: booking.id,
// //       );

// //       if (context.mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(
// //               success ? 'Booking accepted successfully' : provider.errorMessage,
// //             ),
// //             backgroundColor: success
// //                 ? const Color(0xFF10B981)
// //                 : const Color(0xFFEF4444),
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   Future<void> _handleReject(BuildContext context) async {
// //     if (vendorId == null) return;

// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: const Text(
// //           'Reject Request?',
// //           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
// //         ),
// //         content: Text(
// //           'Are you sure you want to reject this booking from ${booking.user.name}?',
// //           style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx, false),
// //             child: const Text(
// //               'Cancel',
// //               style: TextStyle(color: Color(0xFF6B7280)),
// //             ),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(ctx, true),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: const Color(0xFFEF4444),
// //               foregroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //             ),
// //             child: const Text('Reject'),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirmed == true && context.mounted) {
// //       final success = await provider.rejectBooking(
// //         vendorId: vendorId!,
// //         bookingId: booking.id,
// //       );

// //       if (context.mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(success ? 'Booking rejected' : provider.errorMessage),
// //             backgroundColor: success
// //                 ? const Color(0xFF10B981)
// //                 : const Color(0xFFEF4444),
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Header row
// //             Row(
// //               children: [
// //                 CircleAvatar(
// //                   radius: 22,
// //                   backgroundColor: const Color(0xFFEEF2FF),
// //                   child: Text(
// //                     booking.user.name.isNotEmpty
// //                         ? booking.user.name[0].toUpperCase()
// //                         : '?',
// //                     style: const TextStyle(
// //                       color: Color(0xFF4F46E5),
// //                       fontWeight: FontWeight.w700,
// //                       fontSize: 16,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         booking.user.name,
// //                         style: const TextStyle(
// //                           fontSize: 15,
// //                           fontWeight: FontWeight.w700,
// //                           color: Color(0xFF1A1A2E),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 2),
// //                       Text(
// //                         '+91 ${booking.user.mobileNumber}',
// //                         style: const TextStyle(
// //                           fontSize: 12,
// //                           color: Color(0xFF6B7280),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 // Status badge (show for running and cancelled only)
// //                 if (booking.status.toLowerCase() != 'pending')
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 10,
// //                       vertical: 4,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: _statusColor.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Row(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         Icon(_statusIcon, size: 12, color: _statusColor),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           booking.displayStatus,
// //                           style: TextStyle(
// //                             fontSize: 11,
// //                             fontWeight: FontWeight.w600,
// //                             color: _statusColor,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),
// //             const Divider(height: 1, color: Color(0xFFF3F4F6)),
// //             const SizedBox(height: 12),

// //             // Booking Reference
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.receipt_rounded,
// //                   size: 14,
// //                   color: Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Expanded(
// //                   child: Text(
// //                     'Ref: ${booking.bookingReference}',
// //                     style: const TextStyle(
// //                       fontSize: 12,
// //                       color: Color(0xFF6B7280),
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),

// //             // Hostel info
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.apartment_rounded,
// //                   size: 14,
// //                   color: Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Expanded(
// //                   child: Text(
// //                     booking.hostel.name,
// //                     style: const TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w600,
// //                       color: Color(0xFF374151),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.location_on_rounded,
// //                   size: 14,
// //                   color: Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Expanded(
// //                   child: Text(
// //                     booking.hostel.address,
// //                     style: const TextStyle(
// //                       fontSize: 12,
// //                       color: Color(0xFF6B7280),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),
// //             // Room & Share details
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.bed_rounded,
// //                   size: 14,
// //                   color: Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Text(
// //                   '${booking.roomType} • ${booking.shareType} • ${booking.bookingType}',
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     color: Color(0xFF6B7280),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),
// //             // Amount and date
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.currency_rupee_rounded,
// //                   size: 14,
// //                   color: Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Text(
// //                   '₹${booking.totalAmount}',
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFF1A1A2E),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 const Icon(
// //                   Icons.calendar_today_rounded,
// //                   size: 14,
// //                   color: Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Text(
// //                   'From ${_formatDate(booking.startDate)}',
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     color: Color(0xFF6B7280),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.access_time_rounded,
// //                   size: 14,
// //                   color: Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Text(
// //                   'Booked on ${_formatDate(booking.createdAt)}',
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     color: Color(0xFF9CA3AF),
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             // Action buttons for PENDING tab only
// //             // if (showActions) ...[
// //             //   const SizedBox(height: 14),
// //             //   Row(
// //             //     children: [
// //             //       Expanded(
// //             //         child: OutlinedButton.icon(
// //             //           onPressed: () => _handleReject(context),
// //             //           icon: const Icon(Icons.close_rounded, size: 16),
// //             //           label: const Text('Reject'),
// //             //           style: OutlinedButton.styleFrom(
// //             //             foregroundColor: const Color(0xFFEF4444),
// //             //             side: const BorderSide(color: Color(0xFFEF4444)),
// //             //             shape: RoundedRectangleBorder(
// //             //               borderRadius: BorderRadius.circular(10),
// //             //             ),
// //             //             padding: const EdgeInsets.symmetric(vertical: 10),
// //             //           ),
// //             //         ),
// //             //       ),
// //             //       const SizedBox(width: 10),
// //             //       Expanded(
// //             //         child: ElevatedButton.icon(
// //             //           onPressed: () => _handleAccept(context),
// //             //           icon: const Icon(Icons.check_rounded, size: 16),
// //             //           label: const Text('Accept'),
// //             //           style: ElevatedButton.styleFrom(
// //             //             backgroundColor: const Color(0xFF10B981),
// //             //             foregroundColor: Colors.white,
// //             //             elevation: 0,
// //             //             shape: RoundedRectangleBorder(
// //             //               borderRadius: BorderRadius.circular(10),
// //             //             ),
// //             //             padding: const EdgeInsets.symmetric(vertical: 10),
// //             //           ),
// //             //         ),
// //             //       ),
// //             //     ],
// //             //   ),
// //             // ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:math' as math;
// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/model/user_booking_model.dart';
// import 'package:brando_vendor/provider/booking/booking_provider.dart';
// import 'package:brando_vendor/widgets/loader.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AllHostelScreen extends StatefulWidget {
//   const AllHostelScreen({super.key});

//   @override
//   State<AllHostelScreen> createState() => _AllHostelScreenState();
// }

// class _AllHostelScreenState extends State<AllHostelScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String? _vendorId;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadVendorAndFetch();
//   }

//   Future<void> _loadVendorAndFetch() async {
//     _vendorId = await SharedPreferenceHelper.getVendorId();
//     if (_vendorId != null && mounted) {
//       await context.read<BookingRequestProvider>().fetchAllBookingRequests(
//         _vendorId!,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Booking Requests',
//           style: TextStyle(
//             color: Color(0xFF1A1A2E),
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: const Color(0xFF4F46E5),
//           unselectedLabelColor: const Color(0xFF9CA3AF),
//           indicatorColor: const Color(0xFF4F46E5),
//           indicatorWeight: 3,
//           labelStyle: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//           ),
//           tabs: const [
//             Tab(text: 'Pending'),
//             Tab(text: 'Running'),
//             Tab(text: 'Cancelled'),
//           ],
//         ),
//       ),
//       body: Consumer<BookingRequestProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return const Center(child: BrandoLoader(size: 60));
//           }

//           if (provider.status == BookingRequestStatus.error) {
//             return _buildErrorState(provider.errorMessage, provider);
//           }

//           return TabBarView(
//             controller: _tabController,
//             children: [
//               _buildBookingList(
//                 provider.pendingRequests,
//                 provider,
//                 showActions: true,
//               ),
//               _buildBookingList(
//                 provider.runningRequests,
//                 provider,
//                 showActions: false,
//               ),
//               _buildBookingList(
//                 provider.cancelledRequests,
//                 provider,
//                 showActions: false,
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(String message, BookingRequestProvider provider) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline_rounded,
//               color: Color(0xFFEF4444),
//               size: 56,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Something went wrong',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 13, color: Colors.grey[500]),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 if (_vendorId != null) {
//                   provider.fetchAllBookingRequests(_vendorId!);
//                 }
//               },
//               icon: const Icon(Icons.refresh_rounded, size: 18),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4F46E5),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBookingList(
//     List<BookingRequestModel> requests,
//     BookingRequestProvider provider, {
//     bool showActions = false,
//   }) {
//     if (requests.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
//             const SizedBox(height: 12),
//             Text(
//               'No ${_getTabTitle()} bookings',
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey[400],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       color: const Color(0xFF4F46E5),
//       onRefresh: () async {
//         if (_vendorId != null) {
//           await provider.fetchAllBookingRequests(_vendorId!);
//         }
//       },
//       child: ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemCount: requests.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 12),
//         itemBuilder: (context, index) {
//           return _BookingRequestCard(
//             booking: requests[index],
//             provider: provider,
//             vendorId: _vendorId,
//             showActions: showActions,
//           );
//         },
//       ),
//     );
//   }

//   String _getTabTitle() {
//     switch (_tabController.index) {
//       case 0:
//         return 'pending';
//       case 1:
//         return 'running';
//       case 2:
//         return 'cancelled';
//       default:
//         return '';
//     }
//   }
// }

// class _BookingRequestCard extends StatelessWidget {
//   final BookingRequestModel booking;
//   final BookingRequestProvider provider;
//   final String? vendorId;
//   final bool showActions;

//   const _BookingRequestCard({
//     required this.booking,
//     required this.provider,
//     this.vendorId,
//     this.showActions = false,
//   });

//   Color get _statusColor => booking.getStatusColor();

//   IconData get _statusIcon {
//     switch (booking.status.toLowerCase()) {
//       case 'running':
//         return Icons.play_circle_rounded;
//       case 'cancelled':
//         return Icons.cancel_rounded;
//       default:
//         return Icons.schedule_rounded;
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   Future<void> _handleAccept(BuildContext context) async {
//     if (vendorId == null) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Accept Request?',
//           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
//         ),
//         content: Text(
//           'Are you sure you want to accept this booking from ${booking.user.name}?',
//           style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Color(0xFF6B7280)),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF10B981),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Accept'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true && context.mounted) {
//       final success = await provider.acceptBooking(
//         vendorId: vendorId!,
//         bookingId: booking.id,
//       );

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               success ? 'Booking accepted successfully' : provider.errorMessage,
//             ),
//             backgroundColor: success
//                 ? const Color(0xFF10B981)
//                 : const Color(0xFFEF4444),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _handleReject(BuildContext context) async {
//     if (vendorId == null) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Reject Request?',
//           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
//         ),
//         content: Text(
//           'Are you sure you want to reject this booking from ${booking.user.name}?',
//           style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Color(0xFF6B7280)),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFEF4444),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Reject'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true && context.mounted) {
//       final success = await provider.rejectBooking(
//         vendorId: vendorId!,
//         bookingId: booking.id,
//       );

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(success ? 'Booking rejected' : provider.errorMessage),
//             backgroundColor: success
//                 ? const Color(0xFF10B981)
//                 : const Color(0xFFEF4444),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header row
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 22,
//                   backgroundColor: const Color(0xFFEEF2FF),
//                   child: Text(
//                     booking.user.name.isNotEmpty
//                         ? booking.user.name[0].toUpperCase()
//                         : '?',
//                     style: const TextStyle(
//                       color: Color(0xFF4F46E5),
//                       fontWeight: FontWeight.w700,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         booking.user.name,
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         '+91 ${booking.user.mobileNumber}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Status badge (show for running and cancelled only)
//                 if (booking.status.toLowerCase() != 'pending')
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _statusColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(_statusIcon, size: 12, color: _statusColor),
//                         const SizedBox(width: 4),
//                         Text(
//                           booking.displayStatus,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: _statusColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             const SizedBox(height: 12),
//             const Divider(height: 1, color: Color(0xFFF3F4F6)),
//             const SizedBox(height: 12),

//             // Booking Reference
//             Row(
//               children: [
//                 const Icon(
//                   Icons.receipt_rounded,
//                   size: 14,
//                   color: Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     'Ref: ${booking.bookingReference}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF6B7280),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),

//             // Hostel info
//             Row(
//               children: [
//                 const Icon(
//                   Icons.apartment_rounded,
//                   size: 14,
//                   color: Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     booking.hostel.name,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF374151),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 const Icon(
//                   Icons.location_on_rounded,
//                   size: 14,
//                   color: Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     booking.hostel.address,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF6B7280),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             // Room & Share details
//             Row(
//               children: [
//                 const Icon(
//                   Icons.bed_rounded,
//                   size: 14,
//                   color: Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   '${booking.roomType} • ${booking.shareType} • ${booking.bookingType}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             // Amount and date
//             Row(
//               children: [
//                 const Icon(
//                   Icons.currency_rupee_rounded,
//                   size: 14,
//                   color: Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   '₹${booking.totalAmount}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Icon(
//                   Icons.calendar_today_rounded,
//                   size: 14,
//                   color: Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'From ${_formatDate(booking.startDate)}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 const Icon(
//                   Icons.access_time_rounded,
//                   size: 14,
//                   color: Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Booked on ${_formatDate(booking.createdAt)}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF9CA3AF),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math' as math;
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/user_booking_model.dart';
import 'package:brando_vendor/provider/booking/booking_provider.dart';
import 'package:brando_vendor/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllHostelScreen extends StatefulWidget {
  const AllHostelScreen({super.key});

  @override
  State<AllHostelScreen> createState() => _AllHostelScreenState();
}

class _AllHostelScreenState extends State<AllHostelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _vendorId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVendorAndFetch();
  }

  Future<void> _loadVendorAndFetch() async {
    _vendorId = await SharedPreferenceHelper.getVendorId();
    if (_vendorId != null && mounted) {
      await context.read<BookingRequestProvider>().fetchAllBookingRequests(
        _vendorId!,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF4F46E5),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Running'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<BookingRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: BrandoLoader(size: 60));
          }

          if (provider.status == BookingRequestStatus.error) {
            return _buildErrorState(provider.errorMessage, provider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(
                provider.pendingRequests,
                provider,
                showActions: true,
              ),
              _buildBookingList(
                provider.runningRequests,
                provider,
                showActions: false,
                showVacateButton: true,
              ),
              _buildBookingList(
                provider.cancelledRequests,
                provider,
                showActions: false,
                showVacateButton: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message, BookingRequestProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_vendorId != null) {
                  provider.fetchAllBookingRequests(_vendorId!);
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingRequestModel> requests,
    BookingRequestProvider provider, {
    bool showActions = false,
    bool showVacateButton = false,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No ${_getTabTitle()} bookings',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4F46E5),
      onRefresh: () async {
        if (_vendorId != null) {
          await provider.fetchAllBookingRequests(_vendorId!);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _BookingRequestCard(
            booking: requests[index],
            provider: provider,
            vendorId: _vendorId,
            showActions: showActions,
            showVacateButton: showVacateButton,
          );
        },
      ),
    );
  }

  String _getTabTitle() {
    switch (_tabController.index) {
      case 0:
        return 'pending';
      case 1:
        return 'running';
      case 2:
        return 'completed';
      default:
        return '';
    }
  }
}

class _BookingRequestCard extends StatelessWidget {
  final BookingRequestModel booking;
  final BookingRequestProvider provider;
  final String? vendorId;
  final bool showActions;
  final bool showVacateButton;

  const _BookingRequestCard({
    required this.booking,
    required this.provider,
    this.vendorId,
    this.showActions = false,
    this.showVacateButton = false,
  });

  Color get _statusColor => booking.getStatusColor();

  IconData get _statusIcon {
    switch (booking.status.toLowerCase()) {
      case 'running':
        return Icons.play_circle_rounded;
      case 'completed':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleAccept(BuildContext context) async {
    if (vendorId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Accept Request?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to accept this booking from ${booking.user.name}?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.acceptBooking(
        vendorId: vendorId!,
        bookingId: booking.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Booking accepted successfully' : provider.errorMessage,
            ),
            backgroundColor: success
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    if (vendorId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reject Request?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to reject this booking from ${booking.user.name}?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.rejectBooking(
        vendorId: vendorId!,
        bookingId: booking.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Booking rejected' : provider.errorMessage),
            backgroundColor: success
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Future<void> _handleVacate(BuildContext context) async {
  //   if (vendorId == null) return;

  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: const Text(
  //         'Vacate Hostel?',
  //         style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Are you sure you want to vacate this booking for ${booking.user.name}?',
  //             style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
  //           ),
  //           const SizedBox(height: 12),
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.amber.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.amber.shade200),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.info_outline,
  //                   color: Colors.amber.shade700,
  //                   size: 20,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'This action will mark the booking as completed and vacate the room.',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.amber.shade800,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text(
  //             'Cancel',
  //             style: TextStyle(color: Color(0xFF6B7280)),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFFE53935),
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: const Text('Vacate'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true && context.mounted) {
  //     final success = await provider.vacateBooking(
  //       vendorId: vendorId!,
  //       bookingId: booking.id,
  //     );

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             success ? 'Booking vacated successfully' : provider.errorMessage,
  //           ),
  //           backgroundColor: success
  //               ? const Color(0xFF10B981)
  //               : const Color(0xFFEF4444),
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       );
  //     }
  //   }
  // }

  // Future<void> _handleVacate(BuildContext context) async {
  //   if (vendorId == null) return;

  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: const Text(
  //         'Vacate Hostel?',
  //         style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Are you sure you want to vacate this booking for ${booking.user.name}?',
  //             style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
  //           ),
  //           const SizedBox(height: 12),
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.amber.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.amber.shade200),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.info_outline,
  //                   color: Colors.amber.shade700,
  //                   size: 20,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'This action will mark the booking as completed and vacate the room.',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.amber.shade800,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text(
  //             'Cancel',
  //             style: TextStyle(color: Color(0xFF6B7280)),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFFE53935),
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: const Text('Vacate'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true && context.mounted) {
  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (ctx) => const Center(child: CircularProgressIndicator()),
  //     );

  //     final success = await provider.vacateBooking(
  //       vendorId: vendorId!,
  //       bookingId: booking.id,
  //     );

  //     // Close loading dialog
  //     Navigator.pop(context);

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             success ? 'Booking vacated successfully' : provider.errorMessage,
  //           ),
  //           backgroundColor: success
  //               ? const Color(0xFF10B981)
  //               : const Color(0xFFEF4444),
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       );

  //       // Refresh the data after successful vacate
  //       if (success) {
  //         await provider.fetchAllBookingRequests(vendorId.toString());
  //       }
  //     }
  //   }
  // }

  Future<void> _handleVacate(BuildContext context) async {
    if (vendorId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Vacate Hostel?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to vacate this booking for ${booking.user.name}?',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action will mark the booking as completed and vacate the room.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Vacate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Use a different navigator key or use the provider's loading state instead
      // Option 1: Just use the provider's loading state (simpler, no dialog issues)
      final success = await provider.vacateBooking(
        vendorId: vendorId!,
        bookingId: booking.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Booking vacated successfully' : provider.errorMessage,
            ),
            backgroundColor: success
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    booking.user.name.isNotEmpty
                        ? booking.user.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+91 ${booking.user.mobileNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge (show for running and cancelled only)
                if (booking.status.toLowerCase() != 'pending')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 12, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(
                          booking.displayStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),

            // Booking Reference
            Row(
              children: [
                const Icon(
                  Icons.receipt_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ref: ${booking.bookingReference}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Hostel info
            Row(
              children: [
                const Icon(
                  Icons.apartment_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.hostel.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.hostel.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Room & Share details
            Row(
              children: [
                const Icon(
                  Icons.bed_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  '${booking.roomType} • ${booking.shareType} • ${booking.bookingType}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Amount and date
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  '₹${booking.totalAmount}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  'From ${_formatDate(booking.startDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  'Booked on ${_formatDate(booking.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.home, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  'Room No: ${booking.roomNo.toString()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),

            // Vacate Button for Running Bookings
            if (showVacateButton) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleVacate(context),
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Vacate Hostel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Action buttons for PENDING tab only
            if (showActions) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReject(context),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAccept(context),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
