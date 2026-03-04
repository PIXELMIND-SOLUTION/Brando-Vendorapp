import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _hostelNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _hostelNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Row
            Row(
              children: [
                // Left: Selected image or placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          width: 150,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/profile.png',
                          width: 150,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                // Right: Add Camera button
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    width: 150,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 36, color: Colors.black54),
                        SizedBox(height: 6),
                        Text(
                          'Add Your Camera',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Hostel Name Field
            _buildTextField(
              controller: _hostelNameController,
              hint: 'Hostel Name',
              isValidated: true,
            ),
            const SizedBox(height: 14),

            // Mobile Number Field
            _buildTextField(
              controller: _mobileController,
              hint: 'Mobile Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            // Email Field
            _buildTextField(
              controller: _emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isValidated = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
        suffixIcon: isValidated
            ? const Icon(Icons.check, color: Color(0xFFE53935))
            : const Icon(Icons.edit_outlined, color: Colors.black38, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isValidated
                ? const Color(0xFFE53935)
                : const Color(0xFFDDDDDD),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.4),
        ),
      ),
    );
  }
}