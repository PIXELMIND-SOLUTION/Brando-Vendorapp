import 'dart:io';
import 'package:brando_vendor/provider/auth/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final provider =
        Provider.of<VendorProfileProvider>(context, listen: false);
    await provider.fetchVendorProfile();
    _prefillFields();
  }

  void _prefillFields() {
    final provider =
        Provider.of<VendorProfileProvider>(context, listen: false);
    if (provider.profile != null && !_isInitialized) {
      _hostelNameController.text = provider.profile!.name;
      _mobileController.text = provider.profile!.mobileNumber;
      _emailController.text = provider.profile!.email;
      _isInitialized = true;
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleUpdate() async {
    final name = _hostelNameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showSnackbar('Please fill in all required fields', isError: true);
      return;
    }

    final provider =
        Provider.of<VendorProfileProvider>(context, listen: false);

    final success = await provider.updateVendorProfile(
      name: name,
      email: email,
      hostelImage: _selectedImage,
    );

    if (!mounted) return;

    if (success) {
      _showSnackbar('Profile updated successfully!');
      provider.resetUpdateState();
    } else {
      _showSnackbar(provider.errorMessage ?? 'Update failed', isError: true);
      provider.resetUpdateState();
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
      body: Consumer<VendorProfileProvider>(
        builder: (context, provider, _) {
          // Prefill once data is loaded
          if (provider.fetchState == ProfileState.success && !_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _prefillFields();
              setState(() {});
            });
          }

          // Full screen loader on initial fetch
          if (provider.fetchState == ProfileState.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            );
          }

          // Error state on fetch
          if (provider.fetchState == ProfileState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage ?? 'Something went wrong',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final hostelImageUrl = provider.profile?.hostelImage;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image Row ──────────────────────────────────────
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              width: 150,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : (hostelImageUrl != null &&
                                  hostelImageUrl.isNotEmpty)
                              ? Image.network(
                                  hostelImageUrl,
                                  width: 150,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      width: 150,
                                      height: 120,
                                      color: const Color(0xFFF0F0F0),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFE53935),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stack) =>
                                      _imagePlaceholder(),
                                )
                              : Image.asset(
                                  'assets/profile.png',
                                  width: 150,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                    ),
                    const SizedBox(width: 12),

                    // Right: Add / Change image button
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        width: 150,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFDDDDDD),
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedImage != null
                                  ? Icons.edit
                                  : Icons.add_a_photo_outlined,
                              size: 36,
                              color: Colors.black54,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedImage != null
                                  ? 'Change Photo'
                                  : 'Add Your Camera',
                              style: const TextStyle(
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

                _buildTextField(
                  controller: _hostelNameController,
                  hint: 'Hostel Name',
                  isValidated: true,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _mobileController,
                  hint: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),

                // ── Update Button ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        provider.isUpdating ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      disabledBackgroundColor:
                          const Color(0xFFE53935).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: provider.isUpdating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Placeholder Widget ─────────────────────────────────────────────
  Widget _imagePlaceholder() {
    return Container(
      width: 150,
      height: 120,
      color: const Color(0xFFF0F0F0),
      child: const Icon(Icons.broken_image_outlined,
          size: 40, color: Colors.black38),
    );
  }

  // ── Reusable TextField ─────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isValidated = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? Colors.black45 : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline,
                color: Colors.black26, size: 20)
            : isValidated
                ? const Icon(Icons.check, color: Color(0xFFE53935))
                : const Icon(Icons.edit_outlined,
                    color: Colors.black38, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: readOnly ? const Color(0xFFF9F9F9) : Colors.white,
        filled: true,
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
          borderSide: BorderSide(
            color: readOnly
                ? const Color(0xFFDDDDDD)
                : const Color(0xFFE53935),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}