// import 'dart:async';
// import 'dart:io';
// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/provider/auth/auth_provider.dart';
// import 'package:brando_vendor/views/navbar/navbar_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _masterController;
//   late AnimationController _floatController;
//   late AnimationController _pulseController;

//   late Animation<double> _topRightScale, _topRightOpacity;
//   late Animation<Offset> _topRightSlide;
//   late Animation<double> _centerScale, _centerOpacity;
//   late Animation<Offset> _centerSlide;
//   late Animation<double> _bottomLeftScale, _bottomLeftOpacity;
//   late Animation<Offset> _bottomLeftSlide;
//   late Animation<double> _titleOpacity, _subtitleOpacity, _buttonOpacity;
//   late Animation<Offset> _titleSlide, _subtitleSlide;
//   late Animation<double> _buttonScale, _fabScale, _fabOpacity;
//   late Animation<double> _floatY, _pulse;

//   @override
//   void initState() {
//     super.initState();

//     _masterController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     );
//     _floatController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3000),
//     )..repeat(reverse: true);
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat(reverse: true);

//     Animation<double> interval(
//       double s,
//       double e, {
//       Curve curve = Curves.easeOut,
//     }) => CurvedAnimation(
//       parent: _masterController,
//       curve: Interval(s, e, curve: curve),
//     );

//     _topRightOpacity = Tween<double>(begin: 0, end: 1).animate(interval(0.0, 0.4));
//     _topRightScale = Tween<double>(begin: 0.5, end: 1.0).animate(interval(0.0, 0.5, curve: Curves.elasticOut));
//     _topRightSlide = Tween<Offset>(begin: const Offset(0.4, -0.4), end: Offset.zero).animate(interval(0.0, 0.45));

//     _centerOpacity = Tween<double>(begin: 0, end: 1).animate(interval(0.15, 0.55));
//     _centerScale = Tween<double>(begin: 0.4, end: 1.0).animate(interval(0.15, 0.65, curve: Curves.elasticOut));
//     _centerSlide = Tween<Offset>(begin: const Offset(-0.3, 0.3), end: Offset.zero).animate(interval(0.15, 0.55));

//     _bottomLeftOpacity = Tween<double>(begin: 0, end: 1).animate(interval(0.3, 0.65));
//     _bottomLeftScale = Tween<double>(begin: 0.5, end: 1.0).animate(interval(0.3, 0.75, curve: Curves.elasticOut));
//     _bottomLeftSlide = Tween<Offset>(begin: const Offset(-0.4, 0.3), end: Offset.zero).animate(interval(0.3, 0.65));

//     _fabOpacity = Tween<double>(begin: 0, end: 1).animate(interval(0.5, 0.75));
//     _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(interval(0.5, 0.8, curve: Curves.elasticOut));

//     _titleOpacity = Tween<double>(begin: 0, end: 1).animate(interval(0.55, 0.8));
//     _titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(interval(0.55, 0.8));
//     _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(interval(0.65, 0.88));
//     _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(interval(0.65, 0.88));

//     _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(interval(0.78, 1.0));
//     _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(interval(0.78, 1.0, curve: Curves.elasticOut));

//     _floatY = Tween<double>(begin: -8, end: 8).animate(
//       CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
//     );
//     _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     _masterController.forward();

//     _masterController.addStatusListener((status) async {
//       if (status == AnimationStatus.completed) {
//         final loggedIn = await SharedPreferenceHelper.isLoggedIn();
//         if (loggedIn && mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const NavbarScreen()),
//           );
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _masterController.dispose();
//     _floatController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   void _showGetOTPModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const GetOTPModal(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Color(0xFFFFF5F5), Colors.white],
//                   ),
//                 ),
//               ),
//             ),
//             Column(
//               children: [
//                 Expanded(
//                   flex: 58,
//                   child: ClipRect(
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Positioned(
//                           top: -size.height * 0.01,
//                           right: -size.width * 0.06,
//                           child: _buildBlob(
//                             opacity: _topRightOpacity,
//                             scale: _topRightScale,
//                             slide: _topRightSlide,
//                             width: size.width * 0.36,
//                             height: size.height * 0.22,
//                             borderRadius: BorderRadius.circular(999),
//                             floatFactor: 0.5,
//                           ),
//                         ),
//                         Positioned(
//                           bottom: -size.height * 0.02,
//                           left: -size.width * 0.06,
//                           child: _buildBlob(
//                             opacity: _bottomLeftOpacity,
//                             scale: _bottomLeftScale,
//                             slide: _bottomLeftSlide,
//                             width: size.width * 0.32,
//                             height: size.height * 0.19,
//                             borderRadius: BorderRadius.circular(999),
//                             floatFactor: 0.7,
//                           ),
//                         ),
//                         Positioned(
//                           top: size.height * 0.03,
//                           left: 0,
//                           right: 0,
//                           child: AnimatedBuilder(
//                             animation: Listenable.merge([_masterController, _floatController]),
//                             builder: (_, __) => Opacity(
//                               opacity: _centerOpacity.value.clamp(0.0, 1.0),
//                               child: SlideTransition(
//                                 position: _centerSlide,
//                                 child: Transform.scale(
//                                   scale: _centerScale.value,
//                                   child: Transform.translate(
//                                     offset: Offset(0, _floatY.value * -0.4),
//                                     child: Center(
//                                       child: SizedBox(
//                                         width: size.width * 0.62,
//                                         height: size.height * 0.42,
//                                         child: Stack(
//                                           children: [
//                                             Positioned(
//                                               top: size.height * 0.01,
//                                               left: -6,
//                                               right: -6,
//                                               bottom: -size.height * 0.025,
//                                               child: AnimatedBuilder(
//                                                 animation: _pulseController,
//                                                 builder: (_, __) => Transform.scale(
//                                                   scale: _pulse.value,
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                       borderRadius: BorderRadius.circular(999),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             ClipRRect(
//                                               borderRadius: BorderRadius.circular(999),
//                                               child: Image.asset(
//                                                 'assets/splash.png',
//                                                 width: size.width * 0.62,
//                                                 height: size.height * 0.42,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (_, __, ___) => Container(
//                                                   width: size.width * 0.62,
//                                                   height: size.height * 0.42,
//                                                   decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(999),
//                                                     gradient: const LinearGradient(
//                                                       begin: Alignment.topLeft,
//                                                       end: Alignment.bottomRight,
//                                                       colors: [Color(0xFFFFCDD2), Color(0xFFEF9A9A)],
//                                                     ),
//                                                   ),
//                                                   child: const Center(
//                                                     child: Icon(Icons.hotel, color: Colors.white54, size: 48),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: size.height * 0.04,
//                           right: size.width * 0.14,
//                           child: AnimatedBuilder(
//                             animation: Listenable.merge([_masterController, _pulseController]),
//                             builder: (_, __) => Opacity(
//                               opacity: _fabOpacity.value,
//                               child: Transform.scale(
//                                 scale: _fabScale.value * _pulse.value,
//                                 child: Container(
//                                   width: 52,
//                                   height: 52,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFE53935),
//                                     shape: BoxShape.circle,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: const Color(0xFFE53935).withOpacity(0.5),
//                                         blurRadius: 20,
//                                         spreadRadius: 2,
//                                         offset: const Offset(0, 6),
//                                       ),
//                                     ],
//                                   ),
//                                   child: const Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 26),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 42,
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         AnimatedBuilder(
//                           animation: _masterController,
//                           builder: (_, child) => Opacity(
//                             opacity: _titleOpacity.value,
//                             child: SlideTransition(position: _titleSlide, child: child),
//                           ),
//                           child: RichText(
//                             text: const TextSpan(
//                               style: TextStyle(
//                                 fontSize: 30,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF1A1A1A),
//                                 height: 1.25,
//                                 letterSpacing: -0.5,
//                               ),
//                               children: [
//                                 TextSpan(text: 'Redefining Your\n'),
//                                 TextSpan(
//                                   text: 'Hostel Booking ',
//                                   style: TextStyle(color: Color(0xFFE53935)),
//                                 ),
//                                 TextSpan(text: 'Experience'),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         AnimatedBuilder(
//                           animation: _masterController,
//                           builder: (_, child) => Opacity(
//                             opacity: _subtitleOpacity.value,
//                             child: SlideTransition(position: _subtitleSlide, child: child),
//                           ),
//                           child: const Text(
//                             'A hostel booking app should feature quick user registration, searchable listings with filters',
//                             style: TextStyle(fontSize: 14.5, color: Color(0xFF757575), height: 1.6),
//                           ),
//                         ),
//                         const Spacer(),
//                         AnimatedBuilder(
//                           animation: _masterController,
//                           builder: (_, child) => Opacity(
//                             opacity: _buttonOpacity.value,
//                             child: Transform.scale(scale: _buttonScale.value, child: child),
//                           ),
//                           child: _RedButton(label: "Let's Get Started", onTap: _showGetOTPModal),
//                         ),
//                       ],
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

//   Widget _buildBlob({
//     required Animation<double> opacity,
//     required Animation<double> scale,
//     required Animation<Offset> slide,
//     required double width,
//     required double height,
//     required BorderRadius borderRadius,
//     required double floatFactor,
//   }) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_masterController, _floatController]),
//       builder: (_, __) => Opacity(
//         opacity: opacity.value.clamp(0.0, 1.0),
//         child: SlideTransition(
//           position: slide,
//           child: Transform.scale(
//             scale: scale.value,
//             child: Transform.translate(
//               offset: Offset(0, _floatY.value * floatFactor),
//               child: Container(
//                 width: width,
//                 height: height,
//                 decoration: BoxDecoration(
//                   borderRadius: borderRadius,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 24,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: borderRadius,
//                   child: Image.asset(
//                     'assets/splash.png',
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       decoration: BoxDecoration(
//                         borderRadius: borderRadius,
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFFFCDD2), Color(0xFFEF9A9A)],
//                         ),
//                       ),
//                       child: const Center(
//                         child: Icon(Icons.hotel, color: Colors.white54, size: 36),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  GET OTP MODAL
// // ─────────────────────────────────────────────

// class GetOTPModal extends StatefulWidget {
//   final String prefillMobile;
//   final bool autoSendOtp;

//   const GetOTPModal({super.key, this.prefillMobile = '',this.autoSendOtp=false});

//   @override
//   State<GetOTPModal> createState() => _GetOTPModalState();
// }

// class _GetOTPModalState extends State<GetOTPModal>
//     with SingleTickerProviderStateMixin {
//   late TextEditingController _mobileController;
//   final _otpController = TextEditingController();
//   bool _otpSent = false;
//   int _resendSeconds = 0;
//   Timer? _timer;
//   late AnimationController _otpAnimCtrl;
//   late Animation<double> _otpOpacity;
//   late Animation<Offset> _otpSlide;

//   @override
//   void initState() {
//     super.initState();
//     _mobileController = TextEditingController(text: widget.prefillMobile);


//     if (widget.autoSendOtp && widget.prefillMobile.isNotEmpty) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _sendOTP();
//     });
//     }

//     _otpAnimCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _otpOpacity = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _otpAnimCtrl, curve: Curves.easeOut),
//     );
//     _otpSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//       CurvedAnimation(parent: _otpAnimCtrl, curve: Curves.easeOut),
//     );
//   }

//   @override
//   void dispose() {
//     _mobileController.dispose();
//     _otpController.dispose();
//     _otpAnimCtrl.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _startResendTimer() {
//     setState(() => _resendSeconds = 60);
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (_resendSeconds == 0) {
//         t.cancel();
//       } else {
//         setState(() => _resendSeconds--);
//       }
//     });
//   }

//   // Future<void> _sendOTP() async {
//   //   if (_mobileController.text.length < 10) return;
//   //   final provider = context.read<VendorProvider>();
//   //   final mobile = _mobileController.text.trim();

//   //   final success = await provider.login(mobile);
//   //   if (!mounted) return;

//   //   if (success) {
//   //     // ✅ Existing user → OTP sent → show OTP field
//   //     setState(() => _otpSent = true);
//   //     _otpAnimCtrl.forward();
//   //     _startResendTimer();
//   //   } else if (provider.isVendorExists == false) {
//   //     // 🆕 New user → close this modal → open RegisterModal with mobile pre-filled
//   //     Navigator.of(context).pop();
//   //     showModalBottomSheet(
//   //       context: context,
//   //       isScrollControlled: true,
//   //       backgroundColor: Colors.transparent,
//   //       builder: (_) => RegisterModal(prefillMobile: mobile),
//   //     );
//   //   } else {
//   //     // ❌ Some other error
//   //     _showError(provider.errorMessage);
//   //   }
//   // }





//   Future<void> _sendOTP() async {
//   if (_mobileController.text.length < 10) return;
//   final provider = context.read<VendorProvider>();
//   final mobile = _mobileController.text.trim();

//   final success = await provider.login(mobile);
//   if (!mounted) return;

//   if (success) {
//     setState(() => _otpSent = true);
//     _otpAnimCtrl.forward();
//     _startResendTimer();
//   } else if (provider.isVendorExists == false && !widget.autoSendOtp) {
//     // 👆 Only redirect to register if NOT coming from registration
//     Navigator.of(context).pop();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => RegisterModal(prefillMobile: mobile),
//     );
//   } else {
//     _showError(provider.errorMessage);
//   }
// }

//   Future<void> _verifyOTP() async {
//     if (_otpController.text.isEmpty) return;
//     final provider = context.read<VendorProvider>();
//     final success = await provider.verifyOtp(_otpController.text.trim());
//     if (!mounted) return;
//     if (success) {
//       Navigator.of(context).pop();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const NavbarScreen()),
//       );
//     } else {
//       _showError(provider.errorMessage);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFFE53935),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottom = MediaQuery.of(context).viewInsets.bottom;
//     return Consumer<VendorProvider>(
//       builder: (context, provider, _) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//           ),
//           padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE0E0E0),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               RichText(
//                 text: const TextSpan(
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1A1A1A),
//                     letterSpacing: -0.3,
//                   ),
//                   children: [
//                     TextSpan(text: 'Find Your '),
//                     TextSpan(
//                       text: 'Perfect',
//                       style: TextStyle(color: Color(0xFFE53935)),
//                     ),
//                     TextSpan(text: ' Stay'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _OutlinedField(
//                 controller: _mobileController,
//                 hint: 'Mobile Number',
//                 keyboardType: TextInputType.phone,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(10),
//                 ],
//                 onChanged: (_) => setState(() {}),
//                 enabled: !_otpSent,
//               ),
//               if (_otpSent) ...[
//                 const SizedBox(height: 12),
//                 AnimatedBuilder(
//                   animation: _otpAnimCtrl,
//                   builder: (_, child) => Opacity(
//                     opacity: _otpOpacity.value,
//                     child: SlideTransition(position: _otpSlide, child: child),
//                   ),
//                   child: Column(
//                     children: [
//                       _OutlinedField(
//                         controller: _otpController,
//                         hint: 'Enter OTP',
//                         keyboardType: TextInputType.number,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                           LengthLimitingTextInputFormatter(6),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: GestureDetector(
//                           onTap: _resendSeconds == 0 ? _sendOTP : null,
//                           child: Text(
//                             _resendSeconds > 0
//                                 ? 'Resend ${_resendSeconds.toString().padLeft(2, '0')}:00'
//                                 : 'Resend OTP',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: _resendSeconds > 0
//                                   ? const Color(0xFF9E9E9E)
//                                   : const Color(0xFFE53935),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 20),
//               _RedButton(
//                 label: _otpSent
//                     ? 'Login'
//                     : (provider.isLoading ? 'Sending...' : 'Get OTP'),
//                 onTap: provider.isLoading
//                     ? null
//                     : (_otpSent ? _verifyOTP : _sendOTP),
//               ),
//               const SizedBox(height: 4),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  REGISTER MODAL
// // ─────────────────────────────────────────────

// class RegisterModal extends StatefulWidget {
//   /// Mobile number pre-filled from GetOTPModal when isExists == false
//   final String prefillMobile;

//   const RegisterModal({super.key, this.prefillMobile = ''});

//   @override
//   State<RegisterModal> createState() => _RegisterModalState();
// }

// class _RegisterModalState extends State<RegisterModal>
//     with SingleTickerProviderStateMixin {
//   final _hostelController = TextEditingController();
//   late final TextEditingController _mobileController;
//   final _emailController = TextEditingController();
//   File? _pickedImage;

//   late AnimationController _animCtrl;
//   late Animation<double> _opacity;
//   late Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();

//     // Pre-fill mobile number passed from GetOTPModal
//     _mobileController = TextEditingController(text: widget.prefillMobile);

//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _opacity = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
//     );
//     _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
//       CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
//     );
//     _animCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _hostelController.dispose();
//     _mobileController.dispose();
//     _emailController.dispose();
//     _animCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _pickedImage = File(picked.path));
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFFE53935),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   /// After successful registration → close this modal and open GetOTPModal
//   void _openLoginModalWithMobile(String mobile) {
//     Navigator.pop(context);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => GetOTPModal(prefillMobile: mobile,autoSendOtp: true,),
//     );
//   }

//   Future<void> _register() async {
//     final name = _hostelController.text.trim();
//     final mobile = _mobileController.text.trim();
//     final email = _emailController.text.trim();

//     if (name.isEmpty || mobile.length < 10 || _pickedImage == null) {
//       _showError('Please fill all required fields and pick an image.');
//       return;
//     }

//     final provider = context.read<VendorProvider>();
//     final success = await provider.registerVendor(
//       name: name,
//       mobileNumber: mobile,
//       email: email,
//       hostelImage: _pickedImage!,
//     );

//     if (!mounted) return;
//     if (success) {
//       _openLoginModalWithMobile(mobile);
//     } else {
//       _showError(provider.errorMessage);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottom = MediaQuery.of(context).viewInsets.bottom;
//     return AnimatedBuilder(
//       animation: _animCtrl,
//       builder: (_, child) => Opacity(
//         opacity: _opacity.value,
//         child: SlideTransition(position: _slide, child: child),
//       ),
//       child: Consumer<VendorProvider>(
//         builder: (context, provider, _) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//             ),
//             padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE0E0E0),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 RichText(
//                   text: const TextSpan(
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1A1A1A),
//                       letterSpacing: -0.3,
//                     ),
//                     children: [
//                       TextSpan(text: 'Create Your '),
//                       TextSpan(
//                         text: 'Account',
//                         style: TextStyle(color: Color(0xFFE53935)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _OutlinedField(
//                   controller: _hostelController,
//                   hint: 'Hostel Name',
//                 ),
//                 const SizedBox(height: 12),
//                 // Mobile field — pre-filled and locked if passed from GetOTPModal
//                 _OutlinedField(
//                   controller: _mobileController,
//                   hint: 'Mobile Number',
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(10),
//                   ],
//                   enabled: widget.prefillMobile.isEmpty, // lock if pre-filled
//                 ),
//                 const SizedBox(height: 12),
//                 _OutlinedField(
//                   controller: _emailController,
//                   hint: 'Email ( Optional )',
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 12),

//                 // Image picker
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     height: 52,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: const Color(0xFFE53935)),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 14),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             _pickedImage != null
//                                 ? _pickedImage!.path.split('/').last
//                                 : 'Upload Hostel Image',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: _pickedImage != null
//                                   ? const Color(0xFF1A1A1A)
//                                   : const Color(0xFF9E9E9E),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Icon(
//                           _pickedImage != null
//                               ? Icons.check_circle_outline
//                               : Icons.upload_outlined,
//                           color: const Color(0xFFE53935),
//                           size: 20,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//                 _RedButton(
//                   label: provider.isLoading ? 'Registering...' : 'Register',
//                   onTap: provider.isLoading ? null : _register,
//                 ),
//                 const SizedBox(height: 4),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────

// class _OutlinedField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final TextInputType? keyboardType;
//   final List<TextInputFormatter>? inputFormatters;
//   final ValueChanged<String>? onChanged;
//   final bool enabled;

//   const _OutlinedField({
//     required this.controller,
//     required this.hint,
//     this.keyboardType,
//     this.inputFormatters,
//     this.onChanged,
//     this.enabled = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       onChanged: onChanged,
//       enabled: enabled,
//       style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         filled: !enabled,
//         fillColor: enabled ? null : const Color(0xFFF5F5F5),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFFE53935)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.8),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//         ),
//       ),
//     );
//   }
// }

// class _RedButton extends StatefulWidget {
//   final String label;
//   final VoidCallback? onTap;

//   const _RedButton({required this.label, this.onTap});

//   @override
//   State<_RedButton> createState() => _RedButtonState();
// }

// class _RedButtonState extends State<_RedButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _shimmer;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat();
//     _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
//       CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: _ctrl,
//         builder: (_, __) => Container(
//           width: double.infinity,
//           height: 52,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               colors: widget.onTap != null
//                   ? [const Color(0xFFE53935), const Color(0xFFEF5350)]
//                   : [const Color(0xFFBDBDBD), const Color(0xFFBDBDBD)],
//             ),
//             boxShadow: widget.onTap != null
//                 ? [
//                     BoxShadow(
//                       color: const Color(0xFFE53935).withOpacity(0.35),
//                       blurRadius: 16,
//                       offset: const Offset(0, 6),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Stack(
//               children: [
//                 if (widget.onTap != null)
//                   Positioned.fill(
//                     child: ShaderMask(
//                       shaderCallback: (bounds) => LinearGradient(
//                         begin: Alignment(_shimmer.value - 1, 0),
//                         end: Alignment(_shimmer.value, 0),
//                         colors: [
//                           Colors.transparent,
//                           Colors.white.withOpacity(0.2),
//                           Colors.transparent,
//                         ],
//                       ).createShader(bounds),
//                       child: Container(color: Colors.white),
//                     ),
//                   ),
//                 Center(
//                   child: Text(
//                     widget.label,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





















import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/provider/auth/auth_provider.dart';
import 'package:brando_vendor/views/navbar/navbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Animation<double> interval(
      double s,
      double e, {
      Curve curve = Curves.easeOut,
    }) =>
        CurvedAnimation(
          parent: _masterController,
          curve: Interval(s, e, curve: curve),
        );

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
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _masterController.forward();

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
                                                        Color(0xFFEF9A9A)
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
                                height: 1.6),
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
                              onTap: _showGetOTPModal),
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
                    ),
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
                        child: Icon(Icons.hotel, color: Colors.white54, size: 36),
                      ),
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
//  GET OTP MODAL  (Login flow)
// ─────────────────────────────────────────────

class GetOTPModal extends StatefulWidget {
  final String prefillMobile;
  final bool autoSendOtp;

  const GetOTPModal({
    super.key,
    this.prefillMobile = '',
    this.autoSendOtp = false,
  });

  @override
  State<GetOTPModal> createState() => _GetOTPModalState();
}

class _GetOTPModalState extends State<GetOTPModal>
    with SingleTickerProviderStateMixin {
  late TextEditingController _mobileController;
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
    _mobileController = TextEditingController(text: widget.prefillMobile);

    if (widget.autoSendOtp && widget.prefillMobile.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendOTP());
    }

    _otpAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _otpOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _otpAnimCtrl, curve: Curves.easeOut),
    );
    _otpSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _otpAnimCtrl, curve: Curves.easeOut),
    );
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
    _timer?.cancel();
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
    final mobile = _mobileController.text.trim();

    final success = await provider.login(mobile);
    if (!mounted) return;

    if (success) {
      setState(() => _otpSent = true);
      _otpAnimCtrl.forward();
      _startResendTimer();
    } else if (provider.isVendorExists == false && !widget.autoSendOtp) {
      Navigator.of(context).pop();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RegisterModal(prefillMobile: mobile),
      );
    } else {
      _showError(provider.errorMessage);
    }
  }

  Future<void> _resendOTP() async {
    final provider = context.read<VendorProvider>();
    final success = await provider.resendOtp();
    if (!mounted) return;
    if (success) {
      _otpController.clear();
      _startResendTimer();
      _showSuccess('OTP resent successfully');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
                    letterSpacing: -0.3,
                  ),
                  children: [
                    TextSpan(text: 'Find Your '),
                    TextSpan(
                      text: 'Perfect',
                      style: TextStyle(color: Color(0xFFE53935)),
                    ),
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
                          onTap: (_resendSeconds == 0 && !provider.isLoading)
                              ? _resendOTP
                              : null,
                          child: Text(
                            _resendSeconds > 0
                                ? 'Resend in ${_resendSeconds.toString().padLeft(2, '0')}s'
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
                    ? (provider.isLoading ? 'Verifying...' : 'Login')
                    : (provider.isLoading ? 'Sending...' : 'Get OTP'),
                onTap:
                    provider.isLoading ? null : (_otpSent ? _verifyOTP : _sendOTP),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  REGISTER MODAL
// ─────────────────────────────────────────────

class RegisterModal extends StatefulWidget {
  final String prefillMobile;

  const RegisterModal({super.key, this.prefillMobile = ''});

  @override
  State<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal>
    with SingleTickerProviderStateMixin {
  final _hostelController = TextEditingController();
  late final TextEditingController _mobileController;
  final _emailController = TextEditingController();
  File? _pickedImage;

  late AnimationController _animCtrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController(text: widget.prefillMobile);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
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
    if (picked != null) setState(() => _pickedImage = File(picked.path));
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

  /// After registration success → close this modal, open Registration OTP modal
  void _openRegistrationOtpModal(String mobile) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => RegistrationOtpModal(mobileNumber: mobile),
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
      _openRegistrationOtpModal(mobile);
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
                      letterSpacing: -0.3,
                    ),
                    children: [
                      TextSpan(text: 'Create Your '),
                      TextSpan(
                        text: 'Account',
                        style: TextStyle(color: Color(0xFFE53935)),
                      ),
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
                  enabled: widget.prefillMobile.isEmpty,
                ),
                const SizedBox(height: 12),
                _OutlinedField(
                  controller: _emailController,
                  hint: 'Email ( Optional )',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
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
//  REGISTRATION OTP MODAL
//  Handles verify-registration-otp + resend-registration-otp
//  On success: checks approvalStatus → shows ApprovalPendingModal
// ─────────────────────────────────────────────

class RegistrationOtpModal extends StatefulWidget {
  final String mobileNumber;

  const RegistrationOtpModal({super.key, required this.mobileNumber});

  @override
  State<RegistrationOtpModal> createState() => _RegistrationOtpModalState();
}

class _RegistrationOtpModalState extends State<RegistrationOtpModal>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  int _resendSeconds = 60;
  Timer? _timer;

  late AnimationController _animCtrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _resendOtp() async {
    final provider = context.read<VendorProvider>();
    final success = await provider.resendRegistrationOtp();
    if (!mounted) return;
    if (success) {
      _otpController.clear();
      _startResendTimer();
      _showSuccess('OTP resent successfully');
    } else {
      _showError(provider.errorMessage);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      _showError('Please enter a valid OTP.');
      return;
    }

    final provider = context.read<VendorProvider>();
    final success = await provider.verifyRegistrationOtp(otp);
    if (!mounted) return;

    if (success) {
      // Check approvalStatus from the response stored in provider
      final approvalStatus = provider.registrationApprovalStatus;

      Navigator.of(context).pop(); // close OTP modal

      if (approvalStatus == 'approved') {
        // Directly go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavbarScreen()),
        );
      } else {
        // pending / rejected → show approval status modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder: (_) =>
              ApprovalStatusModal(approvalStatus: approvalStatus ?? 'pending'),
        );
      }
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                // Handle bar
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

                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.verified_outlined,
                      color: Color(0xFFE53935), size: 28),
                ),
                const SizedBox(height: 16),

                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                    children: [
                      TextSpan(text: 'Verify Your '),
                      TextSpan(
                        text: 'Number',
                        style: TextStyle(color: Color(0xFFE53935)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter the OTP sent to +91 ${widget.mobileNumber}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                _OutlinedField(
                  controller: _otpController,
                  hint: 'Enter OTP',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                const SizedBox(height: 10),

                // Resend row
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: (_resendSeconds == 0 && !provider.isLoading)
                        ? _resendOtp
                        : null,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13),
                        children: [
                          const TextSpan(
                            text: "Didn't receive the OTP? ",
                            style: TextStyle(color: Color(0xFF9E9E9E)),
                          ),
                          TextSpan(
                            text: _resendSeconds > 0
                                ? 'Resend in ${_resendSeconds.toString().padLeft(2, '0')}s'
                                : 'Resend OTP',
                            style: TextStyle(
                              color: _resendSeconds > 0
                                  ? const Color(0xFF9E9E9E)
                                  : const Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _RedButton(
                  label: provider.isLoading ? 'Verifying...' : 'Verify OTP',
                  onTap: provider.isLoading ? null : _verifyOtp,
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
//  APPROVAL STATUS MODAL
//  Shown after registration OTP verified
//  approvalStatus: 'pending' | 'rejected'
// ─────────────────────────────────────────────

class ApprovalStatusModal extends StatefulWidget {
  final String approvalStatus;

  const ApprovalStatusModal({super.key, required this.approvalStatus});

  @override
  State<ApprovalStatusModal> createState() => _ApprovalStatusModalState();
}

class _ApprovalStatusModalState extends State<ApprovalStatusModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

   Timer? _pollingTimer;
   bool _isPolling = false;
 
  bool get _isPending => widget.approvalStatus == 'pending';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
    );
    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl, curve: const Interval(0.0, 0.5)),
    );

    if (_isPending) {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }


void _startPolling() {
    // Also check immediately on open, then every 5 seconds
    _checkApprovalStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkApprovalStatus();
    });
  }



    Future<void> _checkApprovalStatus() async {
    if (_isPolling || !mounted) return;
    _isPolling = true;

    try {
      // Fetch vendorId from SharedPreferences
      final vendorId = await SharedPreferenceHelper.getVendorId();
      if (vendorId == null || !mounted) return;

      final uri = Uri.parse(
        'http://187.127.146.52:2003/api/vendors/$vendorId/approval-status',
      );
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final approvalStatus = body['data']['approvalStatus'];

        if (approvalStatus == 'approved') {
          _pollingTimer?.cancel();
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NavbarScreen()),
          );
        }
      }
    } catch (_) {
      // Silently ignore, keep polling
    } finally {
      _isPolling = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        _isPending ? const Color(0xFFFF8F00) : const Color(0xFFE53935);
    final Color bgColor =
        _isPending ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE);
    final IconData icon =
        _isPending ? Icons.hourglass_top_rounded : Icons.cancel_outlined;
    final String title =
        _isPending ? 'Awaiting Approval' : 'Request Rejected';
    final String subtitle = _isPending
        ? 'Your registration is under review.\nAdmin will approve your account shortly.'
        : 'Your registration request was rejected by the admin.\nPlease contact support for assistance.';

    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, child) => Opacity(
        opacity: _opacityAnim.value,
        child: child,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            // Animated icon circle
            AnimatedBuilder(
              animation: _animCtrl,
              builder: (_, __) => Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 44),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Status pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: accentColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPending
                        ? Icons.schedule_rounded
                        : Icons.info_outline_rounded,
                    color: accentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPending ? 'Status: Pending' : 'Status: Rejected',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Go back button
            _RedButton(
              label: 'Back to Home',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
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
        hintStyle:
            const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
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
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 1.8),
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
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
                    ),
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