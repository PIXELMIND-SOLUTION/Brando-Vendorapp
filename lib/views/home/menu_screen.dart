// import 'dart:io';

// import 'package:brando_vendor/model/form_details_model.dart';
// import 'package:brando_vendor/provider/form/form_details_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MenuScreen extends StatefulWidget {
//   final String hostelId;
//   const MenuScreen({super.key, required this.hostelId});

//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (widget.hostelId.isNotEmpty) {
//         context.read<FormDetailsProvider>().fetchFormDetails(widget.hostelId);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('Hostellllllllllllllll idddddddddddddddddd ${widget.hostelId}');
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         // leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: const Text(
//           'History',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//         // actions: [
//         //   Padding(
//         //     padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
//         //     child: ElevatedButton(
//         //       onPressed: () {},
//         //       style: ElevatedButton.styleFrom(
//         //         backgroundColor: const Color(0xFFE53935),
//         //         foregroundColor: Colors.white,
//         //         shape: RoundedRectangleBorder(
//         //           borderRadius: BorderRadius.circular(6),
//         //         ),
//         //         padding: const EdgeInsets.symmetric(horizontal: 14),
//         //         elevation: 0,
//         //       ),
//         //       child: const Text(
//         //         'Export',
//         //         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//         //       ),
//         //     ),
//         //   ),
//         // ],
//       ),
//       body: Consumer<FormDetailsProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFFE53935)),
//             );
//           }

//           if (provider.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.error_outline,
//                       color: Color(0xFFE53935), size: 48),
//                   const SizedBox(height: 12),
//                   Text(
//                     provider.errorMessage,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.black54, fontSize: 14),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () =>
//                         provider.fetchFormDetails(widget.hostelId),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE53935),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                     ),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (provider.submissions.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No history found.',
//                 style: TextStyle(color: Colors.black54, fontSize: 15),
//               ),
//             );
//           }

//           // Group submissions by roomNo
//           final Map<String, List<Submission>> grouped = {};
//           for (final s in provider.submissions) {
//             final room = s.stayDetails.roomNo;
//             grouped.putIfAbsent(room, () => []).add(s);
//           }

//           return Column(
//             children: [
//               const Divider(height: 1, color: Color(0xFFEEEEEE)),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   children: const [
//                     SizedBox(
//                       width: 90,
//                       child: Text('Date',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: Colors.black)),
//                     ),
//                     Expanded(
//                       child: Text('Name',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: Colors.black)),
//                     ),
//                     Text('Icons',
//                         style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: Colors.black)),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFEEEEEE)),
//               Expanded(
//                 child: ListView(
//                   children: grouped.entries.map((entry) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: Text(
//                             entry.key,
//                             style: const TextStyle(
//                               color: Color(0xFFF80500),
//                               fontWeight: FontWeight.w600,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                         ...entry.value
//                             .map((s) => _HistoryRow(
//                                   submission: s,
//                                   hostelId: widget.hostelId,
//                                 ))
//                             .toList(),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  HISTORY ROW
// // ─────────────────────────────────────────────
// class _HistoryRow extends StatelessWidget {
//   final Submission submission;
//   final String hostelId;
//   const _HistoryRow({required this.submission, required this.hostelId});

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   Future<void> _makeCall(BuildContext context) async {
//     final Uri callUri = Uri(scheme: 'tel', path: submission.guest.mobile);
//     if (await canLaunchUrl(callUri)) {
//       await launchUrl(callUri);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Could not launch call to ${submission.guest.mobile}'),
//           backgroundColor: const Color(0xFFE53935),
//         ),
//       );
//     }
//   }

//   void _showTransferPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black26,
//       builder: (_) => ChangeNotifierProvider.value(
//         value: context.read<FormDetailsProvider>(),
//         child: TransferPopup(
//           submission: submission,
//           hostelId: hostelId,
//         ),
//       ),
//     );
//   }

//   void _navigateToView(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (_) => TenantViewScreen(submission: submission)),
//     );
//   }

//   void _navigateToEdit(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChangeNotifierProvider.value(
//           value: context.read<FormDetailsProvider>(),
//           child: TenantEditScreen(
//             submission: submission,
//             hostelId: hostelId,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black38,
//       builder: (_) => ChangeNotifierProvider.value(
//         value: context.read<FormDetailsProvider>(),
//         child: DeleteConfirmationDialog(
//           submission: submission,
//           hostelId: hostelId,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const iconColor = Color(0xFFE53935);
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 90,
//                 child: Text(
//                   _formatDate(submission.submittedAt),
//                   style: const TextStyle(fontSize: 13, color: Colors.black87),
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   submission.guest.name,
//                   style: const TextStyle(fontSize: 13, color: Colors.black87),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GestureDetector(
//                     onTap: () => _makeCall(context),
//                     child:
//                         const Icon(Icons.phone, size: 18, color: Colors.black),
//                   ),
//                   const SizedBox(width: 6),
//                   GestureDetector(
//                     onTap: () => _showTransferPopup(context),
//                     child:
//                         const Icon(Icons.share, size: 18, color: Colors.black),
//                   ),
//                   const SizedBox(width: 6),
//                   GestureDetector(
//                     onTap: () => _navigateToView(context),
//                     child: const Icon(Icons.visibility,
//                         size: 18, color: Color(0xFF970BFB)),
//                   ),
//                   const SizedBox(width: 6),
//                   GestureDetector(
//                     onTap: () => _navigateToEdit(context),
//                     child: const Icon(Icons.edit,
//                         size: 18, color: Color(0xFF174AE2)),
//                   ),
//                   const SizedBox(width: 6),
//                   GestureDetector(
//                     onTap: () => _showDeleteConfirmation(context),
//                     child:
//                         const Icon(Icons.delete, size: 18, color: iconColor),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const Divider(height: 1, color: Color(0xFFEEEEEE)),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  DELETE CONFIRMATION DIALOG
// // ─────────────────────────────────────────────
// class DeleteConfirmationDialog extends StatelessWidget {
//   final Submission submission;
//   final String hostelId;
//   const DeleteConfirmationDialog({
//     super.key,
//     required this.submission,
//     required this.hostelId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding:
//           const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
//         child: Consumer<FormDetailsProvider>(
//           builder: (context, provider, _) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 64,
//                   height: 64,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFFFEBEE),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.delete_outline,
//                       color: Color(0xFFE53935), size: 32),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Are you sure?',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 18),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Do you want to delete ${submission.guest.name}?\nThis action cannot be undone.',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       color: Colors.black54, fontSize: 13.5, height: 1.5),
//                 ),
//                 const SizedBox(height: 24),

//                 // ── Error message ──
//                 if (provider.deleteError.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Text(
//                       provider.deleteError,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                           color: Color(0xFFE53935), fontSize: 12),
//                     ),
//                   ),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: provider.isDeleting
//                             ? null
//                             : () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.black87,
//                           side:
//                               const BorderSide(color: Color(0xFFDDDDDD)),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           padding:
//                               const EdgeInsets.symmetric(vertical: 13),
//                         ),
//                         child: const Text('Cancel',
//                             style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: provider.isDeleting
//                             ? null
//                             : () async {
//                                 final success =
//                                     await provider.deleteSubmission(
//                                   submissionId: submission.id,
//                                   hostelId: hostelId,
//                                 );
//                                 if (success && context.mounted) {
//                                   Navigator.pop(context);
//                                   ScaffoldMessenger.of(context)
//                                       .showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                           '${submission.guest.name} deleted successfully'),
//                                       backgroundColor:
//                                           const Color(0xFFE53935),
//                                     ),
//                                   );
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFE53935),
//                           foregroundColor: Colors.white,
//                           disabledBackgroundColor:
//                               const Color(0xFFE53935).withOpacity(0.6),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           padding:
//                               const EdgeInsets.symmetric(vertical: 13),
//                           elevation: 0,
//                         ),
//                         child: provider.isDeleting
//                             ? const SizedBox(
//                                 height: 18,
//                                 width: 18,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Delete',
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  TRANSFER POPUP
// // ─────────────────────────────────────────────
// class TransferPopup extends StatefulWidget {
//   final Submission submission;
//   final String hostelId;
//   const TransferPopup({
//     super.key,
//     required this.submission,
//     required this.hostelId,
//   });

//   @override
//   State<TransferPopup> createState() => _TransferPopupState();
// }

// class _TransferPopupState extends State<TransferPopup> {
//   final _roomController = TextEditingController();

//   @override
//   void dispose() {
//     _roomController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding:
//           const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
//         child: Consumer<FormDetailsProvider>(
//           builder: (context, provider, _) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Transfer',
//                   style: TextStyle(
//                       color: Color(0xFFF80500),
//                       fontWeight: FontWeight.w700,
//                       fontSize: 20),
//                 ),
//                 const SizedBox(height: 20),

//                 // ── Room number text field ──
//                 TextField(
//                   controller: _roomController,
//                   keyboardType: TextInputType.text,
//                   style: const TextStyle(fontSize: 14, color: Colors.black87),
//                   decoration: InputDecoration(
//                     hintText: 'Enter room number',
//                     hintStyle:
//                         const TextStyle(fontSize: 14, color: Colors.black54),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 14),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color(0xFFE53935), width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color(0xFFE53935), width: 1.5),
//                     ),
//                   ),
//                 ),

//                 // ── Error message ──
//                 if (provider.transferError.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       provider.transferError,
//                       style: const TextStyle(
//                           color: Color(0xFFE53935), fontSize: 12),
//                     ),
//                   ),

//                 const SizedBox(height: 28),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: provider.isTransferring
//                         ? null
//                         : () async {
//                             final roomNo = _roomController.text.trim();
//                             if (roomNo.isEmpty) return;

//                             final success = await provider.transferRoom(
//                               submissionId: widget.submission.id,
//                               hostelId: widget.hostelId,
//                               roomNo: roomNo,
//                             );
//                             if (success && context.mounted) {
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content:
//                                       Text('Transferred to Room $roomNo'),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                             }
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF80500),
//                       disabledBackgroundColor:
//                           const Color(0xFFF80500).withOpacity(0.6),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       elevation: 0,
//                     ),
//                     child: provider.isTransferring
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Text('Update',
//                             style: TextStyle(
//                                 fontSize: 15, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  TENANT VIEW SCREEN
// // ─────────────────────────────────────────────
// class TenantViewScreen extends StatelessWidget {
//   final Submission submission;
//   const TenantViewScreen({super.key, required this.submission});

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   @override
//   Widget build(BuildContext context) {
//     final guest = submission.guest;
//     final stay = submission.stayDetails;
//     final docs = submission.documents;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           guest.name,
//           style: const TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.w600,
//               fontSize: 20),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Divider(height: 1, color: Color(0xFFEEEEEE)),
//             const SizedBox(height: 16),
//             const Text('Details',
//                 style: TextStyle(
//                     color: Color(0xFFE53935),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16)),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Name', value: guest.name),
//             _DetailRow(label: 'Mobile Number', value: guest.mobile),
//             _DetailRow(label: 'Emergency No', value: guest.emergencyNumber),
//             _DetailRow(label: 'Email', value: guest.email),
//             _DetailRow(label: 'Advance', value: '${stay.advance}/-'),
//             _DetailRow(label: 'Room No', value: stay.roomNo),
//             _DetailRow(
//                 label: 'Joining Date', value: _formatDate(stay.joiningDate)),
//             _DetailRow(label: 'Tenure', value: stay.tenure),
//             _DetailRow(label: 'Ac / Non-ac', value: stay.roomType),
//             const SizedBox(height: 24),
//             const Text('Documents',
//                 style: TextStyle(
//                     color: Color(0xFFE53935),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16)),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 _DocumentImage(url: docs.aadhar, label: 'Aadhar'),
//                 const SizedBox(width: 12),
//                 _DocumentImage(url: docs.idCard, label: 'ID Card'),
//                 const SizedBox(width: 12),
//                 _DocumentImage(url: docs.profileImage, label: 'Photo'),
//               ],
//             ),
//             const SizedBox(height: 24),
//             const Text('Payment History',
//                 style: TextStyle(
//                     color: Color(0xFFE53935),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16)),
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
//         child: SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: () async {
//               final Uri callUri = Uri(scheme: 'tel', path: guest.mobile);
//               if (await canLaunchUrl(callUri)) {
//                 await launchUrl(callUri);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF80500),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               elevation: 0,
//             ),
//             child: const Text('Call',
//                 style:
//                     TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;
//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(label,
//                 style: const TextStyle(
//                     fontSize: 13.5,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500)),
//           ),
//           const Text(': ',
//               style: TextStyle(fontSize: 13.5, color: Colors.black87)),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(
//                     fontSize: 13.5, color: Colors.black87)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DocumentImage extends StatelessWidget {
//   final String url;
//   final String label;
//   const _DocumentImage({required this.url, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: url.isNotEmpty
//               ? Image.network(
//                   url,
//                   width: 72,
//                   height: 72,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => _placeholder(),
//                 )
//               : _placeholder(),
//         ),
//         const SizedBox(height: 4),
//         Text(label,
//             style: const TextStyle(fontSize: 10, color: Colors.black54)),
//       ],
//     );
//   }

//   Widget _placeholder() {
//     return Container(
//       width: 72,
//       height: 72,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0F0F0),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Icon(Icons.image_not_supported,
//           color: Colors.black38, size: 28),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  TENANT EDIT SCREEN
// // ─────────────────────────────────────────────
// class TenantEditScreen extends StatefulWidget {
//   final Submission submission;
//   final String hostelId;
//   const TenantEditScreen({
//     super.key,
//     required this.submission,
//     required this.hostelId,
//   });

//   @override
//   State<TenantEditScreen> createState() => _TenantEditScreenState();
// }

// class _TenantEditScreenState extends State<TenantEditScreen> {
//   late TextEditingController _nameCtrl;
//   late TextEditingController _mobileCtrl;
//   late TextEditingController _emergencyCtrl;
//   late TextEditingController _emailCtrl;
//   late TextEditingController _roomCtrl;
//   late TextEditingController _joiningDateCtrl;
//   late TextEditingController _tenureCtrl;
//   late TextEditingController _acCtrl;
//   late TextEditingController _advanceCtrl;

//   // Local picked file paths (null = not changed, keep existing)
//   String? _aadharPath;
//   String? _idCardPath;
//   String? _profileImagePath;

//   final _picker = ImagePicker();

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   @override
//   void initState() {
//     super.initState();
//     final g = widget.submission.guest;
//     final s = widget.submission.stayDetails;
//     _nameCtrl = TextEditingController(text: g.name);
//     _mobileCtrl = TextEditingController(text: g.mobile);
//     _emergencyCtrl = TextEditingController(text: g.emergencyNumber);
//     _emailCtrl = TextEditingController(text: g.email);
//     _roomCtrl = TextEditingController(text: s.roomNo);
//     _joiningDateCtrl =
//         TextEditingController(text: _formatDate(s.joiningDate));
//     _tenureCtrl = TextEditingController(text: s.tenure);
//     _acCtrl = TextEditingController(text: s.roomType);
//     _advanceCtrl = TextEditingController(text: s.advance.toString());
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _mobileCtrl.dispose();
//     _emergencyCtrl.dispose();
//     _emailCtrl.dispose();
//     _roomCtrl.dispose();
//     _joiningDateCtrl.dispose();
//     _tenureCtrl.dispose();
//     _acCtrl.dispose();
//     _advanceCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickFile(String field) async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//     setState(() {
//       if (field == 'aadhar') _aadharPath = picked.path;
//       if (field == 'idCard') _idCardPath = picked.path;
//       if (field == 'profileImage') _profileImagePath = picked.path;
//     });
//   }

//   Future<void> _submit() async {
//     final provider = context.read<FormDetailsProvider>();

//     final fields = {
//       'name': _nameCtrl.text.trim(),
//       'email': _emailCtrl.text.trim(),
//       'mobile': _mobileCtrl.text.trim(),
//       'emergencyNumber': _emergencyCtrl.text.trim(),
//       'joiningDate': _joiningDateCtrl.text.trim(),
//       'tenure': _tenureCtrl.text.trim(),
//       'roomType': _acCtrl.text.trim(),
//       'advance': _advanceCtrl.text.trim(),
//     };

//     // Only send file fields that the user actually changed
//     final filePaths = <String, String>{};
//     if (_aadharPath != null) filePaths['aadhar'] = _aadharPath!;
//     if (_idCardPath != null) filePaths['idCard'] = _idCardPath!;
//     if (_profileImagePath != null)
//       filePaths['profileImage'] = _profileImagePath!;

//     final success = await provider.updateSubmission(
//       submissionId: widget.submission.id,
//       hostelId: widget.hostelId,
//       fields: fields,
//       filePaths: filePaths.isEmpty ? null : filePaths,
//     );

//     if (success && mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Details updated successfully'),
//           backgroundColor: Color(0xFFE53935),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           widget.submission.guest.name,
//           style: const TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.w600,
//               fontSize: 20),
//         ),
//       ),
//       body: Consumer<FormDetailsProvider>(
//         builder: (context, provider, _) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _EditField(controller: _nameCtrl, hint: 'Name'),
//                 const SizedBox(height: 12),
//                 _EditField(
//                     controller: _mobileCtrl,
//                     hint: 'Mobile Number',
//                     keyboardType: TextInputType.phone),
//                 const SizedBox(height: 12),
//                 _EditField(
//                     controller: _emergencyCtrl,
//                     hint: 'Emergency Number',
//                     keyboardType: TextInputType.phone),
//                 const SizedBox(height: 12),
//                 _EditField(controller: _emailCtrl, hint: 'Email'),
//                 const SizedBox(height: 12),
//                 _EditField(controller: _roomCtrl, hint: 'Room No'),
//                 const SizedBox(height: 12),
//                 _EditField(
//                     controller: _joiningDateCtrl, hint: 'Joining Date'),
//                 const SizedBox(height: 12),
//                 _EditField(controller: _tenureCtrl, hint: 'Tenure (monthly/yearly)'),
//                 const SizedBox(height: 12),
//                 _EditField(controller: _acCtrl, hint: 'AC / Non-AC'),
//                 const SizedBox(height: 12),
//                 _EditField(
//                     controller: _advanceCtrl,
//                     hint: 'Advance',
//                     keyboardType: TextInputType.number),
//                 const SizedBox(height: 24),

//                 // ── Document pickers ──
//                 const Text('Documents',
//                     style: TextStyle(
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16)),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     _FilePicker(
//                       label: 'Aadhar',
//                       existingUrl: widget.submission.documents.aadhar,
//                       pickedPath: _aadharPath,
//                       onTap: () => _pickFile('aadhar'),
//                     ),
//                     const SizedBox(width: 12),
//                     _FilePicker(
//                       label: 'ID Card',
//                       existingUrl: widget.submission.documents.idCard,
//                       pickedPath: _idCardPath,
//                       onTap: () => _pickFile('idCard'),
//                     ),
//                     const SizedBox(width: 12),
//                     _FilePicker(
//                       label: 'Photo',
//                       existingUrl: widget.submission.documents.profileImage,
//                       pickedPath: _profileImagePath,
//                       onTap: () => _pickFile('profileImage'),
//                     ),
//                   ],
//                 ),

//                 // ── Error message ──
//                 if (provider.updateError.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16),
//                     child: Text(
//                       provider.updateError,
//                       style: const TextStyle(
//                           color: Color(0xFFE53935), fontSize: 13),
//                     ),
//                   ),

//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: provider.isUpdating ? null : _submit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF80500),
//                       disabledBackgroundColor:
//                           const Color(0xFFF80500).withOpacity(0.6),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       elevation: 0,
//                     ),
//                     child: provider.isUpdating
//                         ? const SizedBox(
//                             height: 22,
//                             width: 22,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Text('Update',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  FILE PICKER TILE
// // ─────────────────────────────────────────────
// class _FilePicker extends StatelessWidget {
//   final String label;
//   final String existingUrl;
//   final String? pickedPath;
//   final VoidCallback onTap;

//   const _FilePicker({
//     required this.label,
//     required this.existingUrl,
//     required this.pickedPath,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasNewFile = pickedPath != null;

//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: hasNewFile
//                 ? Image.file(
//                     File(pickedPath!),
//                     width: 72,
//                     height: 72,
//                     fit: BoxFit.cover,
//                   )
//                 : (existingUrl.isNotEmpty
//                     ? Image.network(
//                         existingUrl,
//                         width: 72,
//                         height: 72,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => _placeholder(),
//                       )
//                     : _placeholder()),
//           ),
//           const SizedBox(height: 4),
//           Text(label,
//               style: const TextStyle(fontSize: 10, color: Colors.black54)),
//           Text(
//             hasNewFile ? 'Changed' : 'Tap to change',
//             style: TextStyle(
//               fontSize: 9,
//               color: hasNewFile
//                   ? const Color(0xFF4CAF50)
//                   : Colors.black38,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _placeholder() {
//     return Container(
//       width: 72,
//       height: 72,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0F0F0),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Icon(Icons.add_a_photo, color: Colors.black38, size: 24),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  EDIT FIELD
// // ─────────────────────────────────────────────
// class _EditField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final TextInputType keyboardType;

//   const _EditField({
//     required this.controller,
//     required this.hint,
//     this.keyboardType = TextInputType.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       style: const TextStyle(fontSize: 14, color: Colors.black87),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
//         ),
//       ),
//     );
//   }
// }

// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/model/history_model.dart';
// import 'package:brando_vendor/provider/history/history_provider.dart';
// import 'package:brando_vendor/widgets/app_back_control.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});

//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   String? vendorId;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => _loadVendorAndFetchHistory());
//   }

//   Future<void> _loadVendorAndFetchHistory() async {
//     print('MenuScreen: Starting to load vendor ID');

//     // Check if mounted before proceeding
//     if (!mounted) return;

//     try {
//       vendorId = await SharedPreferenceHelper.getVendorId();
//       print('MenuScreen: Vendor ID retrieved - $vendorId');

//       if (vendorId != null && vendorId!.isNotEmpty) {
//         print('MenuScreen: Calling fetchHistory with vendorId: $vendorId');

//         // Now the provider should be available
//         final provider = Provider.of<HistoryProvider>(context, listen: false);
//         if (provider != null) {
//           await provider.fetchHistory(vendorId!);
//           print('MenuScreen: fetchHistory completed');
//         } else {
//           print('MenuScreen: HistoryProvider not found in context');
//         }
//       } else {
//         print('MenuScreen: Vendor ID is null or empty');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Vendor ID not found. Please login again.'),
//               backgroundColor: Color(0xFFE53935),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('MenuScreen: Error loading vendor ID - $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Color(0xFFE53935),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBackControl(
//       showConfirmationDialog: true,
//       dialogTitle: 'Exit App?',
//       dialogMessage: 'Are you sure you want to exit the app?',
//       confirmText: 'Exit',
//       cancelText: 'Stay',
//       onBackPressed: () {
//         print('User exiting app');
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: const BackButton(color: Colors.black),
//           centerTitle: true,
//           title: const Text(
//             'History',
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.w600,
//               fontSize: 18,
//             ),
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
//               child: ElevatedButton(
//                 onPressed: () {
//                   // TODO: Implement export functionality
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Export feature coming soon'),
//                       backgroundColor: Color(0xFFE53935),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 14),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Export',
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: Consumer<HistoryProvider>(
//           builder: (context, provider, _) {
//             if (provider.isLoading) {
//               return const Center(
//                 child: CircularProgressIndicator(color: Color(0xFFE53935)),
//               );
//             }

//             if (provider.hasError) {
//               return Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       color: Color(0xFFE53935),
//                       size: 48,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       provider.errorMessage,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.black54,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (vendorId != null && vendorId!.isNotEmpty) {
//                           provider.fetchHistory(vendorId!);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE53935),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             if (provider.bookings.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.history, size: 64, color: Colors.black26),
//                     SizedBox(height: 16),
//                     Text(
//                       'No history found.',
//                       style: TextStyle(color: Colors.black54, fontSize: 15),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Column(
//               children: [
//                 const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                 // Table Header
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 10,
//                   ),
//                   child: Row(
//                     children: const [
//                       SizedBox(
//                         width: 80,
//                         child: Text(
//                           'Date',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           'Name',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 70,
//                         child: Text(
//                           'Status',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 100),
//                     ],
//                   ),
//                 ),
//                 const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                 // Grouped Rows
//                 Expanded(
//                   child: ListView(
//                     children: provider.bookings.map((roomData) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Room No Group Label
//                           Container(
//                             width: double.infinity,
//                             color: const Color(0xFFFFF5F5),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 10,
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(
//                                   Icons.meeting_room,
//                                   size: 18,
//                                   color: Color(0xFFF80500),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Room ${roomData.roomNo}',
//                                   style: const TextStyle(
//                                     color: Color(0xFFF80500),
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: const Color(
//                                       0xFFF80500,
//                                     ).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     '${roomData.totalBookings} booking${roomData.totalBookings > 1 ? 's' : ''}',
//                                     style: const TextStyle(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w500,
//                                       color: Color(0xFFF80500),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           ...roomData.bookings
//                               .map((booking) => _HistoryRow(booking: booking))
//                               .toList(),
//                           const SizedBox(height: 8),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  HISTORY ROW
// // ─────────────────────────────────────────────
// class _HistoryRow extends StatelessWidget {
//   final Booking booking;
//   const _HistoryRow({required this.booking});

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'running':
//         return const Color(0xFF4CAF50);
//       case 'completed':
//         return const Color(0xFF9E9E9E);
//       case 'cancelled':
//         return const Color(0xFFE53935);
//       default:
//         return const Color(0xFFFF9800);
//     }
//   }

//   String _getFormattedAmount() {
//     return '₹${booking.totalAmount}';
//   }

//   Future<void> _makeCall(BuildContext context) async {
//     if (booking.userId != null) {
//       final Uri callUri = Uri(
//         scheme: 'tel',
//         path: booking.userId!.mobileNumber.toString(),
//       );
//       if (await canLaunchUrl(callUri)) {
//         await launchUrl(callUri);
//       } else {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Could not call ${booking.userId!.mobileNumber}'),
//               backgroundColor: const Color(0xFFE53935),
//             ),
//           );
//         }
//       }
//     }
//   }

//   void _showTransferPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black26,
//       builder: (_) => TransferPopup(
//         tenantName: booking.userId?.name ?? 'Tenant',
//         currentRoom: booking.roomNo,
//         bookingId: booking.id,
//       ),
//     );
//   }

//   void _navigateToView(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => TenantViewScreen(booking: booking)),
//     );
//   }

//   void _navigateToEdit(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => TenantEditScreen(booking: booking)),
//     );
//   }

//   void _showDeleteConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black38,
//       builder: (_) => DeleteConfirmationDialog(
//         tenantName: booking.userId?.name ?? 'Tenant',
//         bookingId: booking.id,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 80,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _formatDate(booking.startDate),
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       _getFormattedAmount(),
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Colors.black54,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       booking.userId?.name ?? 'Unknown',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       'Ref: ${booking.bookingReference}',
//                       style: const TextStyle(
//                         fontSize: 10,
//                         color: Colors.black45,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: 70,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(booking.status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     booking.status.toUpperCase(),
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: _getStatusColor(booking.status),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _ActionButton(
//                     onTap: () => _makeCall(context),
//                     icon: Icons.phone,
//                     color: Colors.green,
//                   ),
//                   const SizedBox(width: 4),
//                   _ActionButton(
//                     onTap: () => _showTransferPopup(context),
//                     icon: Icons.swap_horiz,
//                     color: Colors.blue,
//                   ),
//                   const SizedBox(width: 4),
//                   _ActionButton(
//                     onTap: () => _navigateToView(context),
//                     icon: Icons.visibility,
//                     color: const Color(0xFF970BFB),
//                   ),
//                   const SizedBox(width: 4),
//                   _ActionButton(
//                     onTap: () => _navigateToEdit(context),
//                     icon: Icons.edit,
//                     color: const Color(0xFF174AE2),
//                   ),
//                   const SizedBox(width: 4),
//                   _ActionButton(
//                     onTap: () => _showDeleteConfirmation(context),
//                     icon: Icons.delete,
//                     color: const Color(0xFFE53935),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const Divider(height: 1, color: Color(0xFFEEEEEE)),
//       ],
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final VoidCallback onTap;
//   final IconData icon;
//   final Color color;

//   const _ActionButton({
//     required this.onTap,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         child: Icon(icon, size: 18, color: color),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  DELETE CONFIRMATION DIALOG
// // ─────────────────────────────────────────────
// class DeleteConfirmationDialog extends StatelessWidget {
//   final String tenantName;
//   final String bookingId;

//   const DeleteConfirmationDialog({
//     super.key,
//     required this.tenantName,
//     required this.bookingId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: const BoxDecoration(
//                 color: Color(0xFFFFEBEE),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.delete_outline,
//                 color: Color(0xFFE53935),
//                 size: 32,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Are you sure?',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Do you want to delete $tenantName?\nThis action cannot be undone.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.black54,
//                 fontSize: 13.5,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.black87,
//                       side: const BorderSide(color: Color(0xFFDDDDDD)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 13),
//                     ),
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       // TODO: Implement actual delete API call
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('$tenantName deleted successfully'),
//                           backgroundColor: const Color(0xFFE53935),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE53935),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 13),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Delete',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
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

// // ─────────────────────────────────────────────
// //  TRANSFER POPUP
// // ─────────────────────────────────────────────
// class TransferPopup extends StatefulWidget {
//   final String tenantName;
//   final String currentRoom;
//   final String bookingId;

//   const TransferPopup({
//     super.key,
//     required this.tenantName,
//     required this.currentRoom,
//     required this.bookingId,
//   });

//   @override
//   State<TransferPopup> createState() => _TransferPopupState();
// }

// class _TransferPopupState extends State<TransferPopup> {
//   String? _selectedRoom;
//   final List<String> _availableRooms = ['101', '102', '103', '104', '105'];

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Transfer Room',
//               style: TextStyle(
//                 color: Color(0xFFF80500),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 20,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${widget.tenantName} - Current Room: ${widget.currentRoom}',
//               style: const TextStyle(color: Colors.black54, fontSize: 13),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Select New Room',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               children: _availableRooms.map((room) {
//                 final isSelected = _selectedRoom == room;
//                 final isCurrentRoom = widget.currentRoom == room;
//                 return GestureDetector(
//                   onTap: isCurrentRoom
//                       ? null
//                       : () => setState(() => _selectedRoom = room),
//                   child: Container(
//                     width: 70,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? const Color(0xFFF80500)
//                           : isCurrentRoom
//                           ? const Color(0xFFEEEEEE)
//                           : Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: isSelected
//                             ? const Color(0xFFF80500)
//                             : isCurrentRoom
//                             ? const Color(0xFFCCCCCC)
//                             : const Color(0xFFDDDDDD),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           room,
//                           style: TextStyle(
//                             color: isSelected
//                                 ? Colors.white
//                                 : isCurrentRoom
//                                 ? Colors.black54
//                                 : Colors.black87,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                         if (isCurrentRoom)
//                           const Text(
//                             'Current',
//                             style: TextStyle(
//                               fontSize: 8,
//                               color: Colors.black45,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed:
//                     _selectedRoom != null && _selectedRoom != widget.currentRoom
//                     ? () {
//                         Navigator.pop(context);
//                         // TODO: Implement actual transfer API call
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               '${widget.tenantName} transferred from Room ${widget.currentRoom} to Room $_selectedRoom',
//                             ),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFF80500),
//                   disabledBackgroundColor: const Color(0xFFCCCCCC),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Transfer',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  TENANT VIEW SCREEN
// // ─────────────────────────────────────────────
// class TenantViewScreen extends StatelessWidget {
//   final Booking booking;
//   const TenantViewScreen({super.key, required this.booking});

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   @override
//   Widget build(BuildContext context) {
//     final user = booking.userId;
//     final hostel = booking.hostelId;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           user?.name ?? 'Tenant Details',
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               // TODO: Implement share functionality
//             },
//             icon: const Icon(Icons.share, color: Colors.black54),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Hostel Info Card
//             if (hostel != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF5F5),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFFFE0E0)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Hostel Information',
//                       style: TextStyle(
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       hostel.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       hostel.address,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 20),
//             const Text(
//               'Personal Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Name', value: user?.name ?? 'N/A'),
//             _DetailRow(
//               label: 'Mobile Number',
//               value: user?.mobileNumber.toString() ?? 'N/A',
//             ),
//             _DetailRow(
//               label: 'Booking Reference',
//               value: booking.bookingReference,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Stay Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Room No', value: booking.roomNo),
//             _DetailRow(label: 'Room Type', value: booking.roomType),
//             _DetailRow(label: 'Share Type', value: booking.shareType),
//             _DetailRow(label: 'Booking Type', value: booking.bookingType),
//             _DetailRow(
//               label: 'Start Date',
//               value: _formatDate(booking.startDate),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Payment Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Total Amount', value: '₹${booking.totalAmount}'),
//             _DetailRow(
//               label: 'Monthly Advance',
//               value: '₹${booking.monthlyAdvance}',
//             ),
//             _DetailRow(label: 'Status', value: booking.status.toUpperCase()),
//             const SizedBox(height: 20),
//             const Text(
//               'Booking Timeline',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(
//               label: 'Created At',
//               value: _formatDate(booking.createdAt),
//             ),
//             _DetailRow(
//               label: 'Last Updated',
//               value: _formatDate(booking.updatedAt),
//             ),
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
//         child: Row(
//           children: [
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: () {
//                   // TODO: Implement message functionality
//                 },
//                 icon: const Icon(Icons.message, size: 20),
//                 label: const Text('Message'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: const Color(0xFFF80500),
//                   side: const BorderSide(color: Color(0xFFF80500)),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () async {
//                   if (user != null) {
//                     final Uri callUri = Uri(
//                       scheme: 'tel',
//                       path: user.mobileNumber.toString(),
//                     );
//                     if (await canLaunchUrl(callUri)) {
//                       await launchUrl(callUri);
//                     }
//                   }
//                 },
//                 icon: const Icon(Icons.call, size: 20),
//                 label: const Text('Call'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFF80500),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;
//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 13.5,
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 13.5,
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  TENANT EDIT SCREEN
// // ─────────────────────────────────────────────
// class TenantEditScreen extends StatefulWidget {
//   final Booking booking;
//   const TenantEditScreen({super.key, required this.booking});

//   @override
//   State<TenantEditScreen> createState() => _TenantEditScreenState();
// }

// class _TenantEditScreenState extends State<TenantEditScreen> {
//   late TextEditingController _nameCtrl;
//   late TextEditingController _mobileCtrl;
//   late TextEditingController _roomCtrl;
//   late TextEditingController _roomTypeCtrl;
//   late TextEditingController _shareTypeCtrl;
//   late TextEditingController _totalAmountCtrl;
//   late TextEditingController _advanceCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.booking.userId?.name ?? '');
//     _mobileCtrl = TextEditingController(
//       text: widget.booking.userId?.mobileNumber.toString() ?? '',
//     );
//     _roomCtrl = TextEditingController(text: widget.booking.roomNo);
//     _roomTypeCtrl = TextEditingController(text: widget.booking.roomType);
//     _shareTypeCtrl = TextEditingController(text: widget.booking.shareType);
//     _totalAmountCtrl = TextEditingController(
//       text: widget.booking.totalAmount.toString(),
//     );
//     _advanceCtrl = TextEditingController(
//       text: widget.booking.monthlyAdvance.toString(),
//     );
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _mobileCtrl.dispose();
//     _roomCtrl.dispose();
//     _roomTypeCtrl.dispose();
//     _shareTypeCtrl.dispose();
//     _totalAmountCtrl.dispose();
//     _advanceCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           'Edit ${widget.booking.userId?.name ?? 'Tenant'}',
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: Column(
//           children: [
//             _EditField(
//               controller: _nameCtrl,
//               hint: 'Full Name',
//               icon: Icons.person_outline,
//             ),
//             const SizedBox(height: 12),
//             _EditField(
//               controller: _mobileCtrl,
//               hint: 'Mobile Number',
//               keyboardType: TextInputType.phone,
//               icon: Icons.phone_outlined,
//             ),
//             const SizedBox(height: 12),
//             _EditField(
//               controller: _roomCtrl,
//               hint: 'Room Number',
//               icon: Icons.meeting_room_outlined,
//             ),
//             const SizedBox(height: 12),
//             _EditField(
//               controller: _roomTypeCtrl,
//               hint: 'Room Type (AC/Non-AC)',
//               icon: Icons.ac_unit,
//             ),
//             const SizedBox(height: 12),
//             _EditField(
//               controller: _shareTypeCtrl,
//               hint: 'Share Type',
//               icon: Icons.people_outline,
//             ),
//             const SizedBox(height: 12),
//             _EditField(
//               controller: _totalAmountCtrl,
//               hint: 'Total Amount',
//               keyboardType: TextInputType.number,
//               icon: Icons.currency_rupee,
//             ),
//             const SizedBox(height: 12),
//             _EditField(
//               controller: _advanceCtrl,
//               hint: 'Advance Amount',
//               keyboardType: TextInputType.number,
//               icon: Icons.payment,
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // TODO: Implement actual update API call
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Details updated successfully'),
//                       backgroundColor: Color(0xFFE53935),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFF80500),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Save Changes',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _EditField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final TextInputType keyboardType;
//   final IconData icon;

//   const _EditField({
//     required this.controller,
//     required this.hint,
//     this.keyboardType = TextInputType.text,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       style: const TextStyle(fontSize: 14, color: Colors.black87),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
//         prefixIcon: Icon(icon, size: 20, color: const Color(0xFFE53935)),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
//         ),
//       ),
//     );
//   }
// }

import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/history_model.dart';
import 'package:brando_vendor/provider/history/history_provider.dart';
import 'package:brando_vendor/widgets/app_back_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? vendorId;
  final RefreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadVendorAndFetchHistory());
  }

  Future<void> _loadVendorAndFetchHistory() async {
    print('MenuScreen: Starting to load vendor ID');

    if (!mounted) return;

    try {
      vendorId = await SharedPreferenceHelper.getVendorId();
      print('MenuScreen: Vendor ID retrieved - $vendorId');

      if (vendorId != null && vendorId!.isNotEmpty) {
        print('MenuScreen: Calling fetchHistory with vendorId: $vendorId');

        final provider = Provider.of<HistoryProvider>(context, listen: false);
        if (provider != null) {
          await provider.fetchHistory(vendorId!);
          print('MenuScreen: fetchHistory completed');
        } else {
          print('MenuScreen: HistoryProvider not found in context');
        }
      } else {
        print('MenuScreen: Vendor ID is null or empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor ID not found. Please login again.'),
              backgroundColor: Color(0xFFE53935),
            ),
          );
        }
      }
    } catch (e) {
      print('MenuScreen: Error loading vendor ID - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
      }
    }
  }

  Future<void> _refreshHistory() async {
    if (vendorId != null && vendorId!.isNotEmpty) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      await provider.fetchHistory(vendorId!);
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final provider = Provider.of<HistoryProvider>(context, listen: false);

      if (provider.bookings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No data to export'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
        return;
      }

      // Create Excel file
      var excel = Excel.createExcel();

      // Create sheet
      Sheet sheetObject = excel['Bookings History'];

      // Define headers
      List<String> headers = [
        'Room No',
        'Date',
        'Name',
        'Mobile Number',
        'Booking Reference',
        'Amount',
        'Status',
        'Room Type',
        'Share Type',
        'Booking Type',
        'Start Date',
        'End Date',
        'Monthly Advance',
      ];

      // Add headers to sheet with styling
      for (int i = 0; i < headers.length; i++) {
        final cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);

        // Apply header style
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.red,
          fontColorHex: ExcelColor.white,
        );
      }

      int rowIndex = 1;

      // Add data to sheet
      for (var roomData in provider.bookings) {
        for (var booking in roomData.bookings) {
          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            roomData.roomNo,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            _formatDate(booking.startDate),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.userId?.name ?? 'Unknown',
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.userId?.mobileNumber.toString() ?? 'N/A',
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.bookingReference,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
              )
              .value = DoubleCellValue(
            booking.totalAmount.toDouble(),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.status.toUpperCase(),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.roomType,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.shareType,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.bookingType,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            _formatDate(booking.startDate),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex),
              )
              .value = DoubleCellValue(
            booking.monthlyAdvance.toDouble(),
          );

          rowIndex++;
        }
      }

      // Save file to temporary directory
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/bookings_history_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final File file = File(filePath);

      // Encode and save
      List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);

        // Share the file using share_plus (works without storage permission)
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Bookings History Export',
          subject: 'Bookings History Report',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel file exported and shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to encode Excel file');
      }
    } catch (e) {
      print('Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting file: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return AppBackControl(
      showConfirmationDialog: true,
      dialogTitle: 'Exit App?',
      dialogMessage: 'Are you sure you want to exit the app?',
      confirmText: 'Exit',
      cancelText: 'Stay',
      onBackPressed: () {
        print('User exiting app');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          centerTitle: true,
          title: const Text(
            'History',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            // Refresh Button
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  _refreshHistory();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  elevation: 0,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Export Button
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: _exportToExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  elevation: 0,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.download, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Export',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          key: RefreshIndicatorKey,
          color: const Color(0xFFE53935),
          onRefresh: _refreshHistory,
          child: Consumer<HistoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE53935)),
                );
              }

              if (provider.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFE53935),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (vendorId != null && vendorId!.isNotEmpty) {
                            provider.fetchHistory(vendorId!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (provider.bookings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.black26),
                      SizedBox(height: 16),
                      Text(
                        'No history found.',
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 80,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 100),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  Expanded(
                    child: ListView(
                      children: provider.bookings.map((roomData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              color: const Color(0xFFFFF5F5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.meeting_room,
                                    size: 18,
                                    color: Color(0xFFF80500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Room ${roomData.roomNo}',
                                    style: const TextStyle(
                                      color: Color(0xFFF80500),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF80500,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${roomData.totalBookings} booking${roomData.totalBookings > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF80500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...roomData.bookings
                                .map((booking) => _HistoryRow(booking: booking))
                                .toList(),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final Booking booking;
  const _HistoryRow({required this.booking});

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF9E9E9E);
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFF9800);
    }
  }

  String _getFormattedAmount() {
    return '₹${booking.totalAmount}';
  }

  Future<void> _makeCall(BuildContext context) async {
    if (booking.userId != null) {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: booking.userId!.mobileNumber.toString(),
      );
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not call ${booking.userId!.mobileNumber}'),
              backgroundColor: const Color(0xFFE53935),
            ),
          );
        }
      }
    }
  }

  void _showTransferPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => TransferPopup(
        tenantName: booking.userId?.name ?? 'Tenant',
        currentRoom: booking.roomNo,
        bookingId: booking.id,
      ),
    );
  }

  void _navigateToView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TenantViewScreen(booking: booking)),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TenantEditScreen(
          booking: booking,
          onUpdate: () {
            // Refresh after update
            if (context.mounted) {
              final provider = Provider.of<HistoryProvider>(
                context,
                listen: false,
              );
              provider.fetchHistory(booking.vendorId);
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => DeleteConfirmationDialog(
        tenantName: booking.userId?.name ?? 'Tenant',
        bookingId: booking.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(booking.startDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFormattedAmount(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.userId?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref: ${booking.bookingReference}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 70,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(booking.status),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    onTap: () => _makeCall(context),
                    icon: Icons.phone,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    onTap: () => _showTransferPopup(context),
                    icon: Icons.swap_horiz,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    onTap: () => _navigateToView(context),
                    icon: Icons.visibility,
                    color: const Color(0xFF970BFB),
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    onTap: () => _navigateToEdit(context),
                    icon: Icons.edit,
                    color: const Color(0xFF174AE2),
                  ),
                  // const SizedBox(width: 4),
                  // _ActionButton(
                  //   onTap: () => _showDeleteConfirmation(context),
                  //   icon: Icons.delete,
                  //   color: const Color(0xFFE53935),
                  // ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final String tenantName;
  final String bookingId;

  const DeleteConfirmationDialog({
    super.key,
    required this.tenantName,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
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
              'Are you sure?',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Do you want to delete $tenantName?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$tenantName deleted successfully'),
                          backgroundColor: const Color(0xFFE53935),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransferPopup extends StatefulWidget {
  final String tenantName;
  final String currentRoom;
  final String bookingId;

  const TransferPopup({
    super.key,
    required this.tenantName,
    required this.currentRoom,
    required this.bookingId,
  });

  @override
  State<TransferPopup> createState() => _TransferPopupState();
}

class _TransferPopupState extends State<TransferPopup> {
  final TextEditingController _roomController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _transferRoom() async {
    final newRoomNo = _roomController.text.trim();

    if (newRoomNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room number'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (newRoomNo == widget.currentRoom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New room number is same as current room'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/changebookingroomno/${widget.bookingId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomNo': newRoomNo}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.tenantName} transferred from Room ${widget.currentRoom} to Room $newRoomNo',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the history
          final provider = Provider.of<HistoryProvider>(context, listen: false);
          final vendorId = await SharedPreferenceHelper.getVendorId();
          if (vendorId != null) {
            await provider.fetchHistory(vendorId);
          }
        }
      } else {
        throw Exception('Failed to transfer room');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error transferring room: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Transfer Room',
              style: TextStyle(
                color: Color(0xFFF80500),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.tenantName} - Current Room: ${widget.currentRoom}',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter New Room Number',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter room number',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.meeting_room,
                  size: 20,
                  color: Color(0xFFE53935),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE53935),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _transferRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Transfer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class TenantViewScreen extends StatelessWidget {
//   final Booking booking;
//   const TenantViewScreen({super.key, required this.booking});

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   @override
//   Widget build(BuildContext context) {
//     final user = booking.userId;
//     final hostel = booking.hostelId;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           user?.name ?? 'Tenant Details',
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.share, color: Colors.black54),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (hostel != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF5F5),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFFFE0E0)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Hostel Information',
//                       style: TextStyle(
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       hostel.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       hostel.address,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 20),
//             const Text(
//               'Personal Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Name', value: user?.name ?? 'N/A'),
//             _DetailRow(
//               label: 'Mobile Number',
//               value: user?.mobileNumber.toString() ?? 'N/A',
//             ),
//             _DetailRow(
//               label: 'Booking Reference',
//               value: booking.bookingReference,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Stay Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Room No', value: booking.roomNo),
//             _DetailRow(label: 'Room Type', value: booking.roomType),
//             _DetailRow(label: 'Share Type', value: booking.shareType),
//             _DetailRow(label: 'Booking Type', value: booking.bookingType),
//             _DetailRow(
//               label: 'Start Date',
//               value: _formatDate(booking.startDate),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Payment Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Total Amount', value: '₹${booking.totalAmount}'),
//             _DetailRow(
//               label: 'Monthly Advance',
//               value: '₹${booking.monthlyAdvance}',
//             ),
//             _DetailRow(label: 'Status', value: booking.status.toUpperCase()),
//             const SizedBox(height: 20),
//             const Text(
//               'Booking Timeline',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(
//               label: 'Created At',
//               value: _formatDate(booking.createdAt),
//             ),
//             _DetailRow(
//               label: 'Last Updated',
//               value: _formatDate(booking.updatedAt),
//             ),
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//       // bottomNavigationBar: Padding(
//       //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
//       //   child: Row(
//       //     children: [
//       //       Expanded(
//       //         child: OutlinedButton.icon(
//       //           onPressed: () {},
//       //           icon: const Icon(Icons.message, size: 20),
//       //           label: const Text('Message'),
//       //           style: OutlinedButton.styleFrom(
//       //             foregroundColor: const Color(0xFFF80500),
//       //             side: const BorderSide(color: Color(0xFFF80500)),
//       //             shape: RoundedRectangleBorder(
//       //               borderRadius: BorderRadius.circular(10),
//       //             ),
//       //             padding: const EdgeInsets.symmetric(vertical: 14),
//       //           ),
//       //         ),
//       //       ),
//       //       const SizedBox(width: 12),
//       //       Expanded(
//       //         child: ElevatedButton.icon(
//       //           onPressed: () async {
//       //             if (user != null) {
//       //               final Uri callUri = Uri(
//       //                 scheme: 'tel',
//       //                 path: user.mobileNumber.toString(),
//       //               );
//       //               if (await canLaunchUrl(callUri)) {
//       //                 await launchUrl(callUri);
//       //               }
//       //             }
//       //           },
//       //           icon: const Icon(Icons.call, size: 20),
//       //           label: const Text('Call'),
//       //           style: ElevatedButton.styleFrom(
//       //             backgroundColor: const Color(0xFFF80500),
//       //             foregroundColor: Colors.white,
//       //             shape: RoundedRectangleBorder(
//       //               borderRadius: BorderRadius.circular(10),
//       //             ),
//       //             padding: const EdgeInsets.symmetric(vertical: 14),
//       //             elevation: 0,
//       //           ),
//       //         ),
//       //       ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }
// }

class TenantViewScreen extends StatelessWidget {
  final Booking booking;
  const TenantViewScreen({super.key, required this.booking});

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  String _formatDateFromString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr.split('T')[0]; // Fallback to YYYY-MM-DD
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = booking.userId;
    final hostel = booking.hostelId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          user?.name ?? 'Tenant Details',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.share, color: Colors.black54),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hostel != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hostel Information',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hostel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hostel.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Personal Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Name', value: user?.name ?? 'N/A'),
            _DetailRow(
              label: 'Mobile Number',
              value: user?.mobileNumber.toString() ?? 'N/A',
            ),
            _DetailRow(
              label: 'Booking Reference',
              value: booking.bookingReference,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stay Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Room No', value: booking.roomNo),
            _DetailRow(label: 'Room Type', value: booking.roomType),
            _DetailRow(label: 'Share Type', value: booking.shareType),
            _DetailRow(label: 'Booking Type', value: booking.bookingType),
            _DetailRow(
              label: 'Start Date',
              value: _formatDate(booking.startDate),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Total Amount', value: '₹${booking.totalAmount}'),
            _DetailRow(
              label: 'Monthly Advance',
              value: '₹${booking.monthlyAdvance}',
            ),
            _DetailRow(label: 'Status', value: booking.status.toUpperCase()),

            // Payment History Section
            if (booking.paymentHistory.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Payment History',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Payment History Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Payment History List
                    ...booking.paymentHistory.map((payment) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatDateFromString(payment.date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${payment.amount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: payment.status == 'paid'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  payment.status.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: payment.status == 'paid'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              'Booking Timeline',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Created At',
              value: _formatDate(booking.createdAt),
            ),
            _DetailRow(
              label: 'Last Updated',
              value: _formatDate(booking.updatedAt),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      //   child: Row(
      //     children: [
      //       Expanded(
      //         child: OutlinedButton.icon(
      //           onPressed: () {},
      //           icon: const Icon(Icons.message, size: 20),
      //           label: const Text('Message'),
      //           style: OutlinedButton.styleFrom(
      //             foregroundColor: const Color(0xFFF80500),
      //             side: const BorderSide(color: Color(0xFFF80500)),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(10),
      //             ),
      //             padding: const EdgeInsets.symmetric(vertical: 14),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //       Expanded(
      //         child: ElevatedButton.icon(
      //           onPressed: () async {
      //             if (user != null) {
      //               final Uri callUri = Uri(
      //                 scheme: 'tel',
      //                 path: user.mobileNumber.toString(),
      //               );
      //               if (await canLaunchUrl(callUri)) {
      //                 await launchUrl(callUri);
      //               }
      //             }
      //           },
      //           icon: const Icon(Icons.call, size: 20),
      //           label: const Text('Call'),
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: const Color(0xFFF80500),
      //             foregroundColor: Colors.white,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(10),
      //             ),
      //             padding: const EdgeInsets.symmetric(vertical: 14),
      //             elevation: 0,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TenantEditScreen extends StatefulWidget {
  final Booking booking;
  final VoidCallback onUpdate;

  const TenantEditScreen({
    super.key,
    required this.booking,
    required this.onUpdate,
  });

  @override
  State<TenantEditScreen> createState() => _TenantEditScreenState();
}

class _TenantEditScreenState extends State<TenantEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _roomCtrl;
  late TextEditingController _roomTypeCtrl;
  late TextEditingController _shareTypeCtrl;
  late TextEditingController _totalAmountCtrl;
  late TextEditingController _advanceCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.booking.userId?.name ?? '');
    _mobileCtrl = TextEditingController(
      text: widget.booking.userId?.mobileNumber.toString() ?? '',
    );
    _roomCtrl = TextEditingController(text: widget.booking.roomNo);
    _roomTypeCtrl = TextEditingController(text: widget.booking.roomType);
    _shareTypeCtrl = TextEditingController(text: widget.booking.shareType);
    _totalAmountCtrl = TextEditingController(
      text: widget.booking.totalAmount.toString(),
    );
    _advanceCtrl = TextEditingController(
      text: widget.booking.monthlyAdvance.toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _roomCtrl.dispose();
    _roomTypeCtrl.dispose();
    _shareTypeCtrl.dispose();
    _totalAmountCtrl.dispose();
    _advanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePayment() async {
    final amount = double.tryParse(_totalAmountCtrl.text);

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/addmonthlypaymnet/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'status': 'paid',
          'date': DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onUpdate();
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to update payment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating payment: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          'View ${widget.booking.userId?.name ?? 'Tenant'}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _ViewField(
              controller: _nameCtrl,
              hint: 'Full Name',
              icon: Icons.person_outline,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _ViewField(
              controller: _mobileCtrl,
              hint: 'Mobile Number',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _ViewField(
              controller: _roomCtrl,
              hint: 'Room Number',
              icon: Icons.meeting_room_outlined,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _ViewField(
              controller: _roomTypeCtrl,
              hint: 'Room Type (AC/Non-AC)',
              icon: Icons.ac_unit,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _ViewField(
              controller: _shareTypeCtrl,
              hint: 'Share Type',
              icon: Icons.people_outline,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _ViewField(
              controller: _advanceCtrl,
              hint: 'Advance Amount',
              keyboardType: TextInputType.number,
              icon: Icons.payment,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _ViewField(
              controller: _totalAmountCtrl,
              hint: 'Total Amount',
              keyboardType: TextInputType.number,
              icon: Icons.currency_rupee,
              enabled: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Update Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ViewField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final IconData icon;
  final bool enabled;

  const _ViewField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        fontSize: 14,
        color: enabled ? Colors.black87 : Colors.black54,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFFE53935)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
    );
  }
}
