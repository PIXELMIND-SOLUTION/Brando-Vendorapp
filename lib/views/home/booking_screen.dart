// // import 'package:flutter/material.dart';

// // class BookingScreen extends StatelessWidget {
// //   const BookingScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF2F2F2),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         centerTitle: true,
// //         automaticallyImplyLeading: false,
// //         // leading: IconButton(
// //         //   icon: const Icon(Icons.arrow_back, color: Colors.black),
// //         //   onPressed: () {
// //         //     Navigator.pop(context);
// //         //   },
// //         // ),
// //         title: const Text(
// //           "Qr code Generator",
// //           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           const SizedBox(height: 40),

// //           // QR Image
// //           Center(
// //             child: Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Image.asset(
// //                 "assets/qrimage.png",
// //                 height: 200,
// //                 width: 200,
// //                 fit: BoxFit.contain,
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // Note Text
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 30),
// //             child: RichText(
// //               textAlign: TextAlign.center,
// //               text: const TextSpan(
// //                 style: TextStyle(fontSize: 13),
// //                 children: [
// //                   TextSpan(
// //                     text: "Note : ",
// //                     style: TextStyle(
// //                       color: Colors.red,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   TextSpan(
// //                     text:
// //                         "After scan the qr code Data will be reflect in List screen",
// //                     style: TextStyle(color: Colors.black54),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const Spacer(),

// //           // Download Button
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
// //             child: SizedBox(
// //               width: double.infinity,
// //               height: 50,
// //               child: ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.red,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                 ),
// //                 onPressed: () {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       backgroundColor: Colors.green,
// //                       content: Text('QR Downloaded Successfully...!'),
// //                     ),
// //                   );
// //                 },
// //                 child: const Text(
// //                   "Download",
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }















import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class BookingScreen extends StatelessWidget {
  final String? qrUrl;

  const BookingScreen({super.key, this.qrUrl});

  Future<void> _downloadQR(BuildContext context) async {
    try {
      if (qrUrl == null || qrUrl!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No QR available")),
        );
        return;
      }

      // 🔽 Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Step 1: Download image
      final response = await http.get(Uri.parse(qrUrl!));

      // Step 2: Save temporarily
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Step 3: Save to gallery
      await Gal.putImage(filePath);

      Navigator.pop(context); // close loader

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('QR Downloaded Successfully...!'),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // close loader

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Download failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "QR Code Generator",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),

          // ── QR Image ─────────────────────────────
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: qrUrl != null
                  ? Image.network(
                      qrUrl!,
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
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 200,
                        width: 200,
                        child: Icon(Icons.qr_code,
                            size: 80, color: Colors.grey),
                      ),
                    )
                  : Image.asset(
                      "assets/qrimage.png",
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Note ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 13),
                children: [
                  TextSpan(
                    text: "Note : ",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        "After scanning the QR code, data will be reflected in the menu screen.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // ── Copy URL ───────────────────────────
          if (qrUrl != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: qrUrl!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('QR URL copied!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, size: 14, color: Color(0xFFE53935)),
                    SizedBox(width: 6),
                    Text(
                      'Copy URL',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const Spacer(),

          // ── Download Button ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _downloadQR(context),
                child: const Text(
                  "Download",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}