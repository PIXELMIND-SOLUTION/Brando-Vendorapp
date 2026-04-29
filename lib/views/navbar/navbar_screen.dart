// import 'package:brando_vendor/helper/shared_preference.dart';
// import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
// import 'package:brando_vendor/provider/navbar/navbar_provider.dart';
// import 'package:brando_vendor/views/home/booking_screen.dart';
// import 'package:brando_vendor/views/home/home_screen.dart';
// import 'package:brando_vendor/views/home/menu_screen.dart';
// import 'package:brando_vendor/views/home/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class _NavItem {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;

//   const _NavItem({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//   });
// }

// class CustomBottomNavbar extends StatelessWidget {
//   const CustomBottomNavbar({super.key});

//   static const _items = [
//     _NavItem(
//       icon: Icons.home_outlined,
//       activeIcon: Icons.home_rounded,
//       label: 'Home',
//     ),
//     _NavItem(
//       icon: Icons.format_list_bulleted,
//       activeIcon: Icons.format_list_bulleted,
//       label: 'Menu',
//     ),
//     _NavItem(
//       icon: Icons.king_bed_outlined,
//       activeIcon: Icons.king_bed_rounded,
//       label: 'Bookings',
//     ),
//     _NavItem(
//       icon: Icons.menu_rounded,
//       activeIcon: Icons.menu_rounded,
//       label: 'Discover',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final currentIndex = context.watch<BottomNavbarProvider>().currentIndex;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 24,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: SizedBox(
//           height: 64,
//           child: Row(
//             children: List.generate(_items.length, (index) {
//               final item = _items[index];
//               final isActive = index == currentIndex;

//               return Expanded(
//                 child: _NavBarItem(
//                   item: item,
//                   isActive: isActive,
//                   onTap: () =>
//                       context.read<BottomNavbarProvider>().setIndex(index),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NavBarItem extends StatefulWidget {
//   final _NavItem item;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _NavBarItem({
//     required this.item,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   State<_NavBarItem> createState() => _NavBarItemState();
// }

// class _NavBarItemState extends State<_NavBarItem>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scaleAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 180),
//     );
//     _scaleAnim = Tween<double>(
//       begin: 1.0,
//       end: 0.92,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _handleTap() {
//     _controller.forward().then((_) => _controller.reverse());
//     widget.onTap();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const activeColor = Color(0xFFE84A4A);
//     const inactiveColor = Color(0xFFB0B0B0);

//     return GestureDetector(
//       onTap: _handleTap,
//       behavior: HitTestBehavior.opaque,
//       child: ScaleTransition(
//         scale: _scaleAnim,
//         child: Center(
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeInOut,
//             margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: widget.isActive
//                   ? const Color.fromARGB(255, 253, 212, 212)
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Flexible(
//                   child: Icon(
//                     widget.isActive ? widget.item.activeIcon : widget.item.icon,
//                     color: widget.isActive ? activeColor : inactiveColor,
//                     size: 22,
//                   ),
//                 ),
//                 if (widget.isActive)
//                   Flexible(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 6),
//                       child: Text(
//                         widget.item.label,
//                         maxLines: 1,
//                         overflow: TextOverflow.fade,
//                         softWrap: false,
//                         style: const TextStyle(
//                           color: activeColor,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // class NavbarScreen extends StatefulWidget {
// //   const NavbarScreen({super.key});

// //   @override
// //   State<NavbarScreen> createState() => _NavbarScreenState();
// // }

// // class _NavbarScreenState extends State<NavbarScreen> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) => _loadHostels());
// //   }

// //   Future<void> _loadHostels() async {
// //     final vendorId = await SharedPreferenceHelper.getVendorId();
// //     if (vendorId != null && vendorId.isNotEmpty && mounted) {
// //       await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final currentIndex = context.watch<BottomNavbarProvider>().currentIndex;

// //     return Consumer<HostelProvider>(
// //       builder: (context, hostelProvider, _) {
// //         final hostelId = hostelProvider.hostels.isNotEmpty
// //             ? hostelProvider.hostels.first.id
// //             : '';

// //         final qrUrl = hostelProvider.hostels.isNotEmpty
// //             ? hostelProvider
// //                   .hostels
// //                   .first
// //                   .qrUrl
// //             : null;

// //         final pages = [
// //           const HomeScreen(),
// //           MenuScreen(hostelId: hostelId),
// //           BookingScreen(qrUrl: qrUrl),
// //           const ProfileScreen(),
// //         ];

// //         return Scaffold(
// //           backgroundColor: const Color(0xFFF8F8F8),
// //           body: hostelProvider.isLoading && hostelId.isEmpty
// //               // Show a single centered loader while the very first fetch runs
// //               ? const Center(
// //                   child: CircularProgressIndicator(color: Color(0xFFE53935)),
// //                 )
// //               : IndexedStack(index: currentIndex, children: pages),
// //           bottomNavigationBar: const CustomBottomNavbar(),
// //         );
// //       },
// //     );
// //   }
// // }

// class NavbarScreen extends StatefulWidget {
//   const NavbarScreen({super.key});

//   @override
//   State<NavbarScreen> createState() => _NavbarScreenState();
// }

// class _NavbarScreenState extends State<NavbarScreen> {
//   String _hostelId = '';
//   String? _qrUrl;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadHostels());
//   }

//   Future<void> _loadHostels() async {
//     final vendorId = await SharedPreferenceHelper.getVendorId();
//     if (vendorId == null || vendorId.isEmpty || !mounted) {
//       setState(() => _isLoading = false);
//       return;
//     }

//     await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);

//     if (!mounted) return;
//     final hostels = context.read<HostelProvider>().hostels;
//     setState(() {
//       _hostelId = hostels.isNotEmpty ? hostels.first.id : '';
//       _qrUrl = hostels.isNotEmpty ? hostels.first.qrUrl : null;
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentIndex = context.watch<BottomNavbarProvider>().currentIndex;

//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Color(0xFFF8F8F8),
//         body: Center(
//           child: CircularProgressIndicator(color: Color(0xFFE53935)),
//         ),
//       );
//     }

//     final pages = [
//       const HomeScreen(),
//       MenuScreen(),
//       BookingScreen(qrUrl: _qrUrl),
//       const ProfileScreen(),
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F8F8),
//       body: IndexedStack(index: currentIndex, children: pages),
//       bottomNavigationBar: const CustomBottomNavbar(),
//     );
//   }
// }

import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
import 'package:brando_vendor/provider/navbar/navbar_provider.dart';
import 'package:brando_vendor/views/home/booking_screen.dart';
import 'package:brando_vendor/views/home/home_screen.dart';
import 'package:brando_vendor/views/home/menu_screen.dart';
import 'package:brando_vendor/views/home/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class CustomBottomNavbar extends StatelessWidget {
  const CustomBottomNavbar({super.key});

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.format_list_bulleted,
      activeIcon: Icons.format_list_bulleted,
      label: 'Menu',
    ),
    _NavItem(
      icon: Icons.king_bed_outlined,
      activeIcon: Icons.king_bed_rounded,
      label: 'Bookings',
    ),
    _NavItem(
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      label: 'Discover',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<BottomNavbarProvider>().currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: _NavBarItem(
                  item: item,
                  isActive: isActive,
                  onTap: () =>
                      context.read<BottomNavbarProvider>().setIndex(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFE84A4A);
    const inactiveColor = Color(0xFFB0B0B0);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color.fromARGB(255, 253, 212, 212)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Icon(
                    widget.isActive ? widget.item.activeIcon : widget.item.icon,
                    color: widget.isActive ? activeColor : inactiveColor,
                    size: 22,
                  ),
                ),
                if (widget.isActive)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        widget.item.label,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          color: activeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

class NavbarScreen extends StatefulWidget {
  final int initialIndex; // Add initial index parameter

  const NavbarScreen({super.key, this.initialIndex = 0}); // Default to 0 (Home)

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  String _hostelId = '';
  String? _qrUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHostels();
      // Set initial index when provider is available
      if (mounted) {
        final bottomNavProvider = context.read<BottomNavbarProvider>();
        bottomNavProvider.setIndex(widget.initialIndex);
      }
    });
  }

  Future<void> _loadHostels() async {
    final vendorId = await SharedPreferenceHelper.getVendorId();
    if (vendorId == null || vendorId.isEmpty || !mounted) {
      setState(() => _isLoading = false);
      return;
    }

    await context.read<HostelProvider>().fetchHostelsByVendor(vendorId);

    if (!mounted) return;
    final hostels = context.read<HostelProvider>().hostels;
    setState(() {
      _hostelId = hostels.isNotEmpty ? hostels.first.id : '';
      _qrUrl = hostels.isNotEmpty ? hostels.first.qrUrl : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<BottomNavbarProvider>().currentIndex;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        ),
      );
    }

    final pages = [
      const HomeScreen(),
      MenuScreen(),
      BookingScreen(qrUrl: _qrUrl),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: const CustomBottomNavbar(),
    );
  }
}
