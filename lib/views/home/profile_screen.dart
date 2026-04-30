// import 'package:brando_vendor/help/need_help_screen.dart';
// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/provider/auth/auth_provider.dart';
// import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
// import 'package:brando_vendor/provider/navbar/navbar_provider.dart';
// import 'package:brando_vendor/views/allhostels/all_hostel_screen.dart';
// import 'package:brando_vendor/views/deleteaccount/delete_account.dart';
// import 'package:brando_vendor/views/details/bank/bank_detail.dart';
// import 'package:brando_vendor/views/home/menu_screen.dart';
// import 'package:brando_vendor/views/navbar/navbar_screen.dart';
// import 'package:brando_vendor/views/profile/edit_profile.dart';
// import 'package:brando_vendor/views/splash/splash_screen.dart';
// import 'package:brando_vendor/views/userform/user_form_details.dart';
// import 'package:brando_vendor/widgets/app_back_control.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Logout',
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF1A1A1A),
//           ),
//         ),
//         content: const Text(
//           'Are you sure you want to logout?',
//           style: TextStyle(color: Color(0xFF757575), fontSize: 14),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Color(0xFF757575),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(ctx);
//               await context.read<VendorProvider>().logout();
//               if (context.mounted) {
//                 context.read<BottomNavbarProvider>().setIndex(0);
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => const SplashScreen()),
//                   (route) => false,
//                 );
//               }
//             },
//             child: const Text(
//               'Logout',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmDeleteAccount(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Delete Account',
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF1A1A1A),
//           ),
//         ),
//         content: const Text(
//           'Are you sure you want to delete your account? This action cannot be undone.',
//           style: TextStyle(color: Color(0xFF757575), fontSize: 14),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Color(0xFF757575),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(ctx);
//               await _deleteVendorAccount(context);
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteVendorAccount(BuildContext context) async {
//     try {
//       final vendorId = await SharedPreferenceHelper.getVendorId();

//       if (vendorId == null) {
//         _showSnackBar(
//           context,
//           'Unable to delete account. Vendor ID not found.',
//           isError: true,
//         );
//         return;
//       }

//       // Show loading indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );

//       final response = await http.delete(
//         Uri.parse(
//           'http://187.127.146.52:2003/api/vendors/deletevendor/$vendorId',
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           // Add authorization token if required
//           // 'Authorization': 'Bearer ${vendorProvider.token}',
//         },
//       );

//       // Close loading dialog
//       if (context.mounted) {
//         Navigator.pop(context);
//       }

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         // Successfully deleted
//         if (context.mounted) {
//           _showSnackBar(context, 'Account deleted successfully');

//           // Logout the user
//           if (context.mounted) {
//             // Navigate to login screen
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const SplashScreen(),
//               ), // Replace with your login screen
//               (route) => false,
//             );
//           }
//         }
//       } else {
//         // Handle error response
//         final errorData = json.decode(response.body);
//         final errorMessage = errorData['message'] ?? 'Failed to delete account';
//         if (context.mounted) {
//           _showSnackBar(context, errorMessage, isError: true);
//         }
//       }
//     } catch (e) {
//       // Close loading dialog if still showing
//       if (context.mounted) {
//         Navigator.pop(context);
//         _showSnackBar(context, 'Network error: ${e.toString()}', isError: true);
//       }
//     }
//   }

//   void _showSnackBar(
//     BuildContext context,
//     String message, {
//     bool isError = false,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//       ),
//     );
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
//         // Optional: Do any cleanup if needed
//         print('User exiting app');
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F5F5),
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: ListView(
//               children: [
//                 const SizedBox(height: 10),
//                 const Center(
//                   child: Text(
//                     "Discover",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Divider(),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Account",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 12),

//                 GestureDetector(
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => EditProfile()),
//                   ),
//                   child: _buildTile(
//                     Icons.person_outline,
//                     "Personal information",
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     final hostelId =
//                         context.read<HostelProvider>().hostels.isNotEmpty
//                         ? context.read<HostelProvider>().hostels.first.id
//                         : '';
//                     if (hostelId.isEmpty) return;
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NavbarScreen(initialIndex: 1),
//                       ),
//                     );
//                   },
//                   child: _buildTile(Icons.history, "History"),
//                 ),

//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => NeedHelpScreen()),
//                     );
//                   },
//                   child: _buildTile(Icons.help_outline, "Need Help?"),
//                 ),

//                 GestureDetector(
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => AllHostelScreen()),
//                   ),
//                   child: _buildTile(Icons.hotel, "All Bookings"),
//                 ),

//                 _buildTile(Icons.description_outlined, "Terms & Conditions"),

//                 GestureDetector(
//                   onTap: () => _confirmDeleteAccount(
//                     context,
//                   ), // Updated to show confirmation dialog
//                   child: _buildTile(
//                     Icons.delete,
//                     "Delete Account",
//                     isLogout: true,
//                   ),
//                 ),

//                 _buildTile(Icons.privacy_tip_outlined, "Privacy Policy"),

//                 const SizedBox(height: 8),

//                 GestureDetector(
//                   onTap: () => _confirmLogout(context),
//                   child: _buildTile(Icons.logout, "Logout", isLogout: true),
//                 ),

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget _buildTile(
//     IconData icon,
//     String title, {
//     bool isLogout = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 14,
//             color: isLogout ? Colors.red : Colors.black,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           size: 16,
//           color: isLogout ? Colors.red : Colors.grey,
//         ),
//       ),
//     );
//   }
// }

// // Make sure to import your LoginScreen
// // import 'package:brando_vendor/views/login/login_screen.dart';

import 'package:brando_vendor/help/need_help_screen.dart';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/provider/auth/auth_provider.dart';
import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
import 'package:brando_vendor/provider/navbar/navbar_provider.dart';
import 'package:brando_vendor/views/allhostels/all_hostel_screen.dart';
import 'package:brando_vendor/views/deleteaccount/delete_account.dart';
import 'package:brando_vendor/views/details/bank/bank_detail.dart';
import 'package:brando_vendor/views/home/menu_screen.dart';
import 'package:brando_vendor/views/navbar/navbar_screen.dart';
import 'package:brando_vendor/views/profile/edit_profile.dart';
import 'package:brando_vendor/views/splash/splash_screen.dart';
import 'package:brando_vendor/views/userform/user_form_details.dart';
import 'package:brando_vendor/widgets/app_back_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Add this import

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper method to launch URLs
  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showSnackBar(context, 'Could not open the link', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Error opening link: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF757575), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<VendorProvider>().logout();
              if (context.mounted) {
                context.read<BottomNavbarProvider>().setIndex(0);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF757575), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteVendorAccount(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVendorAccount(BuildContext context) async {
    try {
      final vendorId = await SharedPreferenceHelper.getVendorId();

      if (vendorId == null) {
        _showSnackBar(
          context,
          'Unable to delete account. Vendor ID not found.',
          isError: true,
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.delete(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/deletevendor/$vendorId',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if required
          // 'Authorization': 'Bearer ${vendorProvider.token}',
        },
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Successfully deleted
        if (context.mounted) {
          _showSnackBar(context, 'Account deleted successfully');

          // Logout the user
          if (context.mounted) {
            // Navigate to login screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              ), // Replace with your login screen
              (route) => false,
            );
          }
        }
      } else {
        // Handle error response
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to delete account';
        if (context.mounted) {
          _showSnackBar(context, errorMessage, isError: true);
        }
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(context, 'Network error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
        // Optional: Do any cleanup if needed
        print('User exiting app');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Discover",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Account",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfile()),
                  ),
                  child: _buildTile(
                    Icons.person_outline,
                    "Personal information",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final hostelId =
                        context.read<HostelProvider>().hostels.isNotEmpty
                        ? context.read<HostelProvider>().hostels.first.id
                        : '';
                    if (hostelId.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NavbarScreen(initialIndex: 1),
                      ),
                    );
                  },
                  child: _buildTile(Icons.history, "History"),
                ),

                GestureDetector(
                  onTap: () {
                    // Updated: Open contact URL instead of NeedHelpScreen
                    _launchURL(
                      context,
                      'https://brando-vendor-policy.onrender.com/contact',
                    );
                  },
                  child: _buildTile(Icons.help_outline, "Need Help?"),
                ),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AllHostelScreen()),
                  ),
                  child: _buildTile(Icons.hotel, "All Bookings"),
                ),

                GestureDetector(
                  onTap: () {
                    // Updated: Open Terms & Conditions URL
                    _launchURL(
                      context,
                      'https://brando-vendor-policy.onrender.com/terms-and-conditions',
                    );
                  },
                  child: _buildTile(
                    Icons.description_outlined,
                    "Terms & Conditions",
                  ),
                ),

                GestureDetector(
                  onTap: () => _confirmDeleteAccount(context),
                  child: _buildTile(
                    Icons.delete,
                    "Delete Account",
                    isLogout: true,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    // Updated: Open Privacy Policy URL
                    _launchURL(
                      context,
                      'https://brando-vendor-policy.onrender.com/privacy-and-policy',
                    );
                  },
                  child: _buildTile(
                    Icons.privacy_tip_outlined,
                    "Privacy Policy",
                  ),
                ),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: () => _confirmLogout(context),
                  child: _buildTile(Icons.logout, "Logout", isLogout: true),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTile(
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isLogout ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}
