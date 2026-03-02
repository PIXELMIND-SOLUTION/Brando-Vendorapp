import 'package:brando_vendor/views/details/bank/bank_detail.dart';
import 'package:brando_vendor/views/history/history_screen.dart';
import 'package:brando_vendor/views/profile/edit_profile.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// Title
              const Center(
                child: Text(
                  "Discover",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 20),

              const Divider(),

              const SizedBox(height: 10),

              /// Account Label
              const Text(
                "Account",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              /// Menu Items
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile()));
                },
                child: _buildTile(Icons.person_outline, "Personal information")),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
                child: _buildTile(Icons.history, "History"),
              ),
              _buildTile(Icons.help_outline, "Need Help?"),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BankDetail()),
                  );
                },
                child: _buildTile(Icons.phone_outlined, "Bank Details"),
              ),
              _buildTile(Icons.description_outlined, "Terms & Conditions"),
              _buildTile(Icons.privacy_tip_outlined, "Privacy Policy"),

              const SizedBox(height: 8),

              /// Logout
              _buildTile(Icons.logout, "Logout", isLogout: true),
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
