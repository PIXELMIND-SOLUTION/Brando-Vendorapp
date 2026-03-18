import 'dart:convert';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount>
    with SingleTickerProviderStateMixin {
  final List<String> _consequences = [
    'All your personal data will be permanently erased',
    'Active sessions on all devices will be terminated',
    'You will lose access to all saved content',
  ];

  bool _confirmed = false;
  bool _isLoading = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _attemptDelete() async {
    if (!_confirmed) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vendorId = await SharedPreferenceHelper.getVendorId();
      final token = await SharedPreferenceHelper.getToken();

      if (vendorId == null || token == null) {
        _showSnackBar('Session expired. Please log in again.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse(
        'http://31.97.206.144:2003/api/vendors/delete-account/$vendorId',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseBody = jsonDecode(response.body);

      print('Response status code for delete account ${response.statusCode}');
      print('Response bodyyyyyyyyyyyyyy for delete account ${response.body}');

      if (response.statusCode == 200) {
        await SharedPreferenceHelper.clearAll();

        if (mounted) {
          _showSnackBar(
            responseBody['message'] ?? 'Account deleted successfully.',
            isError: false,
          );

          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          }
        }
      } else {
        _showSnackBar(
          responseBody['message'] ?? 'Failed to delete account. Try again.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Network error. Please check your connection.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE53E3E) : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFAAAAAA),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Color(0xFFAAAAAA),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // ── Header ──────────────────────────────────────────────────
              const SizedBox(height: 20),
              const Text(
                'Delete\nAccount',
                style: TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action is permanent and cannot be undone. '
                'Please read carefully before proceeding.',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 14,
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
              ),

              const SizedBox(height: 36),

              // ── Consequence List ─────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WHAT YOU\'LL LOSE',
                      style: TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_consequences.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53E3E),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _consequences[i],
                                style: const TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 13.5,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Divider ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: const Color(0xFF2A2A2A))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Confirmation required',
                      style: TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: const Color(0xFF2A2A2A))),
                ],
              ),

              const SizedBox(height: 24),

              // ── Checkbox ─────────────────────────────────────────────────
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final dx = _confirmed
                      ? 0.0
                      : (4 *
                            (0.5 - (_shakeAnimation.value - 0.5).abs()) *
                            (_shakeAnimation.value < 0.5 ? -1 : 1));
                  return Transform.translate(
                    offset: Offset(dx * 6, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _confirmed
                          ? const Color(0xFF1F0E0E)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _confirmed
                            ? const Color(0xFFE53E3E).withOpacity(0.5)
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _confirmed
                                ? const Color(0xFFE53E3E)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _confirmed
                                  ? const Color(0xFFE53E3E)
                                  : const Color(0xFF444444),
                              width: 1.5,
                            ),
                          ),
                          child: _confirmed
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'I understand this action is irreversible and all my data will be permanently deleted.',
                            style: TextStyle(
                              color: Color(0xFFBBBBBB),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Delete Button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _confirmed ? 1.0 : 0.4,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _attemptDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53E3E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE53E3E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_forever_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Delete My Account',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF888888),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Keep My Account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Need help? Contact support before deleting.',
                  style: TextStyle(
                    color: const Color(0xFF444444),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
