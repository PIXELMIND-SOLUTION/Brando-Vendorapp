// import 'dart:io';
// import 'package:brando_vendor/widgets/app_back_control.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:gal/gal.dart';

// class BookingScreen extends StatelessWidget {
//   final String? qrUrl;

//   const BookingScreen({super.key, this.qrUrl});

//   Future<void> _downloadQR(BuildContext context) async {
//     try {
//       if (qrUrl == null || qrUrl!.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No QR available to download")),
//         );
//         return;
//       }

//       // 🔽 Show loading
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(child: CircularProgressIndicator()),
//       );

//       // Step 1: Download image
//       final response = await http.get(Uri.parse(qrUrl!));

//       // Step 2: Save temporarily
//       final tempDir = await getTemporaryDirectory();
//       final filePath =
//           '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';

//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);

//       // Step 3: Save to gallery
//       await Gal.putImage(filePath);

//       Navigator.pop(context); // close loader

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.green,
//           content: Text('QR Downloaded Successfully...!'),
//         ),
//       );
//     } catch (e) {
//       if (context.mounted) {
//         Navigator.pop(context); // close loader

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: Colors.red,
//             content: Text('Download failed: $e'),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasQR = qrUrl != null && qrUrl!.isNotEmpty;

//     return AppBackControl(
//       showConfirmationDialog: true,
//       dialogTitle: 'Exit App?',
//       dialogMessage: 'Are you sure you want to exit the app?',
//       confirmText: 'Exit',
//       cancelText: 'Stay',
//       onBackPressed: () {
//         // Optional: Do any cleanup if needed
//         print('User exiting app');
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF2F2F2),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//           title: const Text(
//             "QR Code Generator",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
//           ),
//         ),
//         body: Column(
//           children: [
//             const SizedBox(height: 40),

//             // ── QR Image OR Message ─────────────────────────────
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: hasQR
//                     ? Image.network(
//                         qrUrl!,
//                         height: 200,
//                         width: 200,
//                         fit: BoxFit.contain,
//                         loadingBuilder: (context, child, progress) {
//                           if (progress == null) return child;
//                           return const SizedBox(
//                             height: 200,
//                             width: 200,
//                             child: Center(child: CircularProgressIndicator()),
//                           );
//                         },
//                         errorBuilder: (_, __, ___) => const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.qr_code_scanner,
//                               size: 60,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 12),
//                             Text(
//                               "Failed to load QR",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : const Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.qr_code_scanner_outlined,
//                             size: 60,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             "QR Code Not Available",
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             "No QR code has been generated for this booking",
//                             style: TextStyle(color: Colors.grey, fontSize: 12),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ── Note ───────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30),
//               child: RichText(
//                 textAlign: TextAlign.center,
//                 text: const TextSpan(
//                   style: TextStyle(fontSize: 13),
//                   children: [
//                     TextSpan(
//                       text: "Note : ",
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text:
//                           "After scanning the QR code, data will be reflected in the menu screen.",
//                       style: TextStyle(color: Colors.black54),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Copy URL (only if QR exists) ───────────────────────────
//             if (hasQR) ...[
//               const SizedBox(height: 14),
//               GestureDetector(
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: qrUrl!));
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('QR URL copied!'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE53935).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.copy, size: 14, color: Color(0xFFE53935)),
//                       SizedBox(width: 6),
//                       Text(
//                         'Copy URL',
//                         style: TextStyle(
//                           color: Color(0xFFE53935),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],

//             const Spacer(),

//             // ── Download Button (only if QR exists) ────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: hasQR ? Colors.red : Colors.grey,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: hasQR ? () => _downloadQR(context) : null,
//                   child: const Text(
//                     "Download",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:brando_vendor/model/create_hostel_model.dart';
import 'package:brando_vendor/widgets/app_back_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class BookingScreen extends StatelessWidget {
  final List<Hostel> hostels;

  const BookingScreen({super.key, this.hostels = const []});

  Future<void> _downloadQR(
    BuildContext context,
    String qrUrl,
    String hostelName,
  ) async {
    try {
      if (qrUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No QR available to download")),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.get(Uri.parse(qrUrl));
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/qr_${hostelName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await Gal.putImage(filePath);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('QR for "$hostelName" downloaded successfully!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Download failed: $e'),
          ),
        );
      }
    }
  }

  void _showQRDetails(BuildContext context, Hostel hostel) {
    final hasQR = hostel.qrUrl != null && hostel.qrUrl!.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Hostel Name
              Text(
                hostel.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // QR Image
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: hasQR
                    ? Image.network(
                        hostel.qrUrl!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            height: 200,
                            width: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Failed to load QR",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        children: [
                          Icon(
                            Icons.qr_code_scanner_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "QR Code Not Available",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "After scanning the QR code, data will be reflected in the menu screen.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              // Row(
              //   children: [
              //     // Copy URL Button
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: hasQR
              //             ? () {
              //                 Clipboard.setData(
              //                   ClipboardData(text: hostel.qrUrl!),
              //                 );
              //                 ScaffoldMessenger.of(context).showSnackBar(
              //                   const SnackBar(
              //                     content: Text('QR URL copied!'),
              //                     backgroundColor: Colors.green,
              //                   ),
              //                 );
              //               }
              //             : null,
              //         icon: const Icon(Icons.copy, size: 18),
              //         label: const Text('Copy URL'),
              //         style: OutlinedButton.styleFrom(
              //           foregroundColor: const Color(0xFFE53935),
              //           side: const BorderSide(color: Color(0xFFE53935)),
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),

              //     // Download Button
              //     Expanded(
              //       child: ElevatedButton.icon(
              //         onPressed: hasQR
              //             ? () {
              //                 Navigator.pop(context);
              //                 _downloadQR(context, hostel.qrUrl!, hostel.name);
              //               }
              //             : null,
              //         icon: const Icon(Icons.download, size: 18),
              //         label: const Text('Download'),
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: const Color(0xFFE53935),
              //           foregroundColor: Colors.white,
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

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
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            "QR Code",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        body: hostels.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No Hostels Found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Add a hostel to generate QR codes",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: hostels.length,
                itemBuilder: (context, index) {
                  final hostel = hostels[index];
                  final hasQR =
                      hostel.qrUrl != null && hostel.qrUrl!.isNotEmpty;

                  return GestureDetector(
                    onTap: () => _showQRDetails(context, hostel),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // QR Icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: hasQR
                                  ? const Color(0xFFFFF0F0)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              hasQR
                                  ? Icons.qr_code
                                  : Icons.qr_code_scanner_outlined,
                              size: 32,
                              color: hasQR
                                  ? const Color(0xFFE53935)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Hostel Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                  hasQR
                                      ? "Tap to view QR code"
                                      : "No QR code available",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hasQR ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow Icon
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
