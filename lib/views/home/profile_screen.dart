import 'package:brando_vendor/help/need_help_screen.dart';
import 'package:brando_vendor/provider/auth/auth_provider.dart';
import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
import 'package:brando_vendor/provider/navbar/navbar_provider.dart';
import 'package:brando_vendor/views/allhostels/all_hostel_screen.dart';
import 'package:brando_vendor/views/deleteaccount/delete_account.dart';
import 'package:brando_vendor/views/details/bank/bank_detail.dart';
import 'package:brando_vendor/views/home/menu_screen.dart';
import 'package:brando_vendor/views/profile/edit_profile.dart';
import 'package:brando_vendor/views/splash/splash_screen.dart';
import 'package:brando_vendor/views/userform/user_form_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            // onPressed: () async {
            //   Navigator.pop(ctx);
            //   await context.read<VendorProvider>().logout();
            //   if (context.mounted) {
            //     Navigator.pushAndRemoveUntil(
            //       context,
            //       MaterialPageRoute(builder: (_) => const SplashScreen()),
            //       (route) => false,
            //     );
            //   }
            // },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            // ✅ FIXED HERE
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
                child: _buildTile(Icons.person_outline, "Personal information"),
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
                      builder: (_) => MenuScreen(hostelId: hostelId),
                    ),
                  );
                },
                child: _buildTile(Icons.history, "History"),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NeedHelpScreen()),
                  );
                },
                child: _buildTile(Icons.help_outline, "Need Help?"),
              ),

              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BankDetail()),
                ),
                child: _buildTile(Icons.account_balance, "Bank Details"),
              ),

              // GestureDetector(
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => RecordingDetails()),
              //   ),
              //   child: _buildTile(Icons.image_outlined, "Recording & Images"),
              // ),


               GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AllHostelScreen()),
                ),
                child: _buildTile(Icons.hotel, "All Hostels"),
              ),


                GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserFormDetails()),
                ),
                child: _buildTile(Icons.description, "Form Details"),
              ),


              _buildTile(Icons.description_outlined, "Terms & Conditions"),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeleteAccount()),
                  );
                },
                child: _buildTile(Icons.delete, "Delete Account"),
              ),
              _buildTile(Icons.privacy_tip_outlined, "Privacy Policy"),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: () => _confirmLogout(context),
                child: _buildTile(Icons.logout, "Logout", isLogout: true),
              ),

              const SizedBox(height: 20), // extra bottom space
            ],
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
