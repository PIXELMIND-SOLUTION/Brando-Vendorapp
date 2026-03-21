import 'dart:async';
import 'dart:io';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/provider/auth/auth_provider.dart';
import 'package:brando_vendor/views/navbar/navbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _floatController;
  late AnimationController _pulseController;

  late Animation<double> _topRightScale, _topRightOpacity;
  late Animation<Offset> _topRightSlide;
  late Animation<double> _centerScale, _centerOpacity;
  late Animation<Offset> _centerSlide;
  late Animation<double> _bottomLeftScale, _bottomLeftOpacity;
  late Animation<Offset> _bottomLeftSlide;
  late Animation<double> _titleOpacity, _subtitleOpacity, _buttonOpacity;
  late Animation<Offset> _titleSlide, _subtitleSlide;
  late Animation<double> _buttonScale, _fabScale, _fabOpacity;
  late Animation<double> _floatY, _pulse;

  @override
void initState() {
  super.initState();

  // 1. Initialize controllers
  _masterController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200));
  _floatController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3000))
    ..repeat(reverse: true);
  _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))
    ..repeat(reverse: true);

  // 2. Helper
  Animation<double> interval(double s, double e,
          {Curve curve = Curves.easeOut}) =>
      CurvedAnimation(
          parent: _masterController,
          curve: Interval(s, e, curve: curve));

  // 3. ALL animation assignments
  _topRightOpacity =
      Tween<double>(begin: 0, end: 1).animate(interval(0.0, 0.4));
  _topRightScale = Tween<double>(begin: 0.5, end: 1.0)
      .animate(interval(0.0, 0.5, curve: Curves.elasticOut));
  _topRightSlide =
      Tween<Offset>(begin: const Offset(0.4, -0.4), end: Offset.zero)
          .animate(interval(0.0, 0.45));

  _centerOpacity =
      Tween<double>(begin: 0, end: 1).animate(interval(0.15, 0.55));
  _centerScale = Tween<double>(begin: 0.4, end: 1.0)
      .animate(interval(0.15, 0.65, curve: Curves.elasticOut));
  _centerSlide =
      Tween<Offset>(begin: const Offset(-0.3, 0.3), end: Offset.zero)
          .animate(interval(0.15, 0.55));

  _bottomLeftOpacity =
      Tween<double>(begin: 0, end: 1).animate(interval(0.3, 0.65));
  _bottomLeftScale = Tween<double>(begin: 0.5, end: 1.0)
      .animate(interval(0.3, 0.75, curve: Curves.elasticOut));
  _bottomLeftSlide =
      Tween<Offset>(begin: const Offset(-0.4, 0.3), end: Offset.zero)
          .animate(interval(0.3, 0.65));

  _fabOpacity =
      Tween<double>(begin: 0, end: 1).animate(interval(0.5, 0.75));
  _fabScale = Tween<double>(begin: 0.0, end: 1.0)
      .animate(interval(0.5, 0.8, curve: Curves.elasticOut));

  _titleOpacity =
      Tween<double>(begin: 0, end: 1).animate(interval(0.55, 0.8));
  _titleSlide =
      Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(interval(0.55, 0.8));
  _subtitleOpacity =
      Tween<double>(begin: 0, end: 1).animate(interval(0.65, 0.88));
  _subtitleSlide =
      Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
          .animate(interval(0.65, 0.88));

  _buttonOpacity =
      Tween<double>(begin: 0, end: 1).animate(interval(0.78, 1.0));
  _buttonScale = Tween<double>(begin: 0.8, end: 1.0)
      .animate(interval(0.78, 1.0, curve: Curves.elasticOut));

  _floatY = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
  _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

  // 4. Start animation
  _masterController.forward();

  // 5. After splash completes → check login → navigate if logged in
  _masterController.addStatusListener((status) async {
    if (status == AnimationStatus.completed) {
      final loggedIn = await SharedPreferenceHelper.isLoggedIn();
      if (loggedIn && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavbarScreen()),
        );
      }
    }
  });
}

  @override
  void dispose() {
    _masterController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showGetOTPModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GetOTPModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF5F5), Colors.white],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 58,
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -size.height * 0.01,
                          right: -size.width * 0.06,
                          child: _buildBlob(
                            opacity: _topRightOpacity,
                            scale: _topRightScale,
                            slide: _topRightSlide,
                            width: size.width * 0.36,
                            height: size.height * 0.22,
                            borderRadius: BorderRadius.circular(999),
                            floatFactor: 0.5,
                          ),
                        ),
                        Positioned(
                          bottom: -size.height * 0.02,
                          left: -size.width * 0.06,
                          child: _buildBlob(
                            opacity: _bottomLeftOpacity,
                            scale: _bottomLeftScale,
                            slide: _bottomLeftSlide,
                            width: size.width * 0.32,
                            height: size.height * 0.19,
                            borderRadius: BorderRadius.circular(999),
                            floatFactor: 0.7,
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.03,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: Listenable.merge(
                                [_masterController, _floatController]),
                            builder: (_, __) => Opacity(
                              opacity: _centerOpacity.value.clamp(0.0, 1.0),
                              child: SlideTransition(
                                position: _centerSlide,
                                child: Transform.scale(
                                  scale: _centerScale.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _floatY.value * -0.4),
                                    child: Center(
                                      child: SizedBox(
                                        width: size.width * 0.62,
                                        height: size.height * 0.42,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: size.height * 0.01,
                                              left: -6,
                                              right: -6,
                                              bottom: -size.height * 0.025,
                                              child: AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (_, __) =>
                                                    Transform.scale(
                                                  scale: _pulse.value,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999),
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xFFE53935),
                                                        width: 2.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              child: Image.asset(
                                                'assets/splash.png',
                                                width: size.width * 0.62,
                                                height: size.height * 0.42,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  width: size.width * 0.62,
                                                  height: size.height * 0.42,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                    gradient:
                                                        const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFFFFCDD2),
                                                        Color(0xFFEF9A9A),
                                                      ],
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(Icons.hotel,
                                                        color: Colors.white54,
                                                        size: 48),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: size.height * 0.04,
                          right: size.width * 0.14,
                          child: AnimatedBuilder(
                            animation: Listenable.merge(
                                [_masterController, _pulseController]),
                            builder: (_, __) => Opacity(
                              opacity: _fabOpacity.value,
                              child: Transform.scale(
                                scale: _fabScale.value * _pulse.value,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE53935)
                                            .withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                      Icons.arrow_outward_rounded,
                                      color: Colors.white,
                                      size: 26),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 42,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedBuilder(
                          animation: _masterController,
                          builder: (_, child) => Opacity(
                            opacity: _titleOpacity.value,
                            child: SlideTransition(
                                position: _titleSlide, child: child),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                height: 1.25,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(text: 'Redefining Your\n'),
                                TextSpan(
                                  text: 'Hostel Booking ',
                                  style: TextStyle(color: Color(0xFFE53935)),
                                ),
                                TextSpan(text: 'Experience'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _masterController,
                          builder: (_, child) => Opacity(
                            opacity: _subtitleOpacity.value,
                            child: SlideTransition(
                                position: _subtitleSlide, child: child),
                          ),
                          child: const Text(
                            'A hostel booking app should feature quick user registration, searchable listings with filters',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF757575),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _masterController,
                          builder: (_, child) => Opacity(
                            opacity: _buttonOpacity.value,
                            child: Transform.scale(
                                scale: _buttonScale.value, child: child),
                          ),
                          child: _RedButton(
                            label: "Let's Get Started",
                            onTap: _showGetOTPModal,
                          ),
                        ),
                      ],
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

  Widget _buildBlob({
    required Animation<double> opacity,
    required Animation<double> scale,
    required Animation<Offset> slide,
    required double width,
    required double height,
    required BorderRadius borderRadius,
    required double floatFactor,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterController, _floatController]),
      builder: (_, __) => Opacity(
        opacity: opacity.value.clamp(0.0, 1.0),
        child: SlideTransition(
          position: slide,
          child: Transform.scale(
            scale: scale.value,
            child: Transform.translate(
              offset: Offset(0, _floatY.value * floatFactor),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Image.asset(
                    'assets/splash.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFCDD2), Color(0xFFEF9A9A)],
                        ),
                      ),
                      child: const Center(
                          child: Icon(Icons.hotel,
                              color: Colors.white54, size: 36)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GET OTP MODAL
// ─────────────────────────────────────────────

class GetOTPModal extends StatefulWidget {
  const GetOTPModal({super.key});

  @override
  State<GetOTPModal> createState() => _GetOTPModalState();
}

class _GetOTPModalState extends State<GetOTPModal>
    with SingleTickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  int _resendSeconds = 0;
  Timer? _timer;
  late AnimationController _otpAnimCtrl;
  late Animation<double> _otpOpacity;
  late Animation<Offset> _otpSlide;

  @override
  void initState() {
    super.initState();
    _otpAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _otpOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _otpAnimCtrl, curve: Curves.easeOut));
    _otpSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _otpAnimCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _otpAnimCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _sendOTP() async {
    if (_mobileController.text.length < 10) return;
    final provider = context.read<VendorProvider>();
    final success = await provider.login(_mobileController.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _otpSent = true);
      _otpAnimCtrl.forward();
      _startResendTimer();
    } else {
      _showError(provider.errorMessage);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) return;
    final provider = context.read<VendorProvider>();
    final success = await provider.verifyOtp(_otpController.text.trim());
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavbarScreen()),
      );
    } else {
      _showError(provider.errorMessage);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showRegisterModal() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RegisterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Consumer<VendorProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3),
                  children: [
                    TextSpan(text: 'Find Your '),
                    TextSpan(
                        text: 'Perfect',
                        style: TextStyle(color: Color(0xFFE53935))),
                    TextSpan(text: ' Stay'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _OutlinedField(
                controller: _mobileController,
                hint: 'Mobile Number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (_) => setState(() {}),
                enabled: !_otpSent,
              ),
              if (_otpSent) ...[
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _otpAnimCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _otpOpacity.value,
                    child:
                        SlideTransition(position: _otpSlide, child: child),
                  ),
                  child: Column(
                    children: [
                      _OutlinedField(
                        controller: _otpController,
                        hint: 'Enter OTP',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _resendSeconds == 0 ? _sendOTP : null,
                          child: Text(
                            _resendSeconds > 0
                                ? 'Resend ${_resendSeconds.toString().padLeft(2, '0')}:00'
                                : 'Resend OTP',
                            style: TextStyle(
                              fontSize: 13,
                              color: _resendSeconds > 0
                                  ? const Color(0xFF9E9E9E)
                                  : const Color(0xFFE53935),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _RedButton(
                label: _otpSent
                    ? 'Login'
                    : (provider.isLoading ? 'Sending...' : 'Get OTP'),
                onTap: provider.isLoading
                    ? null
                    : (_otpSent ? _verifyOTP : _sendOTP),
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _showRegisterModal,
                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 14, color: Color(0xFF757575)),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}



class RegisterModal extends StatefulWidget {
  const RegisterModal({super.key});

  @override
  State<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal>
    with SingleTickerProviderStateMixin {
  final _hostelController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  File? _pickedImage;

  late AnimationController _animCtrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _hostelController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// After successful registration → close this modal and open GetOTPModal
  /// with the mobile number pre-filled.
  void _openLoginModalWithMobile(String mobile) {
    Navigator.pop(context); // close RegisterModal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GetOTPModal(),
    );
  }

  Future<void> _register() async {
    final name = _hostelController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || mobile.length < 10 || _pickedImage == null) {
      _showError('Please fill all required fields and pick an image.');
      return;
    }

    final provider = context.read<VendorProvider>();
    final success = await provider.registerVendor(
      name: name,
      mobileNumber: mobile,
      email: email,
      hostelImage: _pickedImage!,
    );

    if (!mounted) return;
    if (success) {
      _openLoginModalWithMobile(mobile);
    } else {
      _showError(provider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: SlideTransition(position: _slide, child: child),
      ),
      child: Consumer<VendorProvider>(
        builder: (context, provider, _) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3),
                    children: [
                      TextSpan(text: 'Create Your '),
                      TextSpan(
                          text: 'Account',
                          style: TextStyle(color: Color(0xFFE53935))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _OutlinedField(
                  controller: _hostelController,
                  hint: 'Hostel Name',
                ),
                const SizedBox(height: 12),
                _OutlinedField(
                  controller: _mobileController,
                  hint: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                const SizedBox(height: 12),
                _OutlinedField(
                  controller: _emailController,
                  hint: 'Email ( Optional )',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE53935)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _pickedImage != null
                                ? _pickedImage!.path.split('/').last
                                : 'Upload Hostel Image',
                            style: TextStyle(
                              fontSize: 14,
                              color: _pickedImage != null
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF9E9E9E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _pickedImage != null
                              ? Icons.check_circle_outline
                              : Icons.upload_outlined,
                          color: const Color(0xFFE53935),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _RedButton(
                  label: provider.isLoading ? 'Registering...' : 'Register',
                  onTap: provider.isLoading ? null : _register,
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────

class _OutlinedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const _OutlinedField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      enabled: enabled,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: !enabled,
        fillColor: enabled ? null : const Color(0xFFF5F5F5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.8),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}

class _RedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _RedButton({required this.label, this.onTap});

  @override
  State<_RedButton> createState() => _RedButtonState();
}

class _RedButtonState extends State<_RedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: widget.onTap != null
                  ? [const Color(0xFFE53935), const Color(0xFFEF5350)]
                  : [const Color(0xFFBDBDBD), const Color(0xFFBDBDBD)],
            ),
            boxShadow: widget.onTap != null
                ? [
                    BoxShadow(
                      color: const Color(0xFFE53935).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                if (widget.onTap != null)
                  Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment(_shimmer.value - 1, 0),
                        end: Alignment(_shimmer.value, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ).createShader(bounds),
                      child: Container(color: Colors.white),
                    ),
                  ),
                Center(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}