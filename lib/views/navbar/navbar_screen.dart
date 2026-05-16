import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/create_hostel_model.dart';
import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
import 'package:brando_vendor/provider/navbar/navbar_provider.dart';
import 'package:brando_vendor/views/home/analysis.dart';
import 'package:brando_vendor/views/home/booking_screen.dart';
import 'package:brando_vendor/views/home/ecomerce.dart';
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
  final VoidCallback onCenterTap;

  const CustomBottomNavbar({super.key, required this.onCenterTap});

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.format_list_bulleted,
      activeIcon: Icons.format_list_bulleted,
      label: 'List',
    ),
    _NavItem(
      icon: Icons.king_bed_outlined,
      activeIcon: Icons.analytics,
      label: 'Accounts',
    ),
    _NavItem(
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      label: 'Menu',
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
          child: Stack(
            clipBehavior: Clip.none, // allows child to overflow above the bar
            children: [
              // ── Nav items row (full width, leaves gap in center)
              Row(
                children: [
                  // Left two items
                  Expanded(
                    child: Row(
                      children: List.generate(2, (index) {
                        final item = _items[index];
                        final isActive = index == currentIndex;
                        return Expanded(
                          child: _NavBarItem(
                            item: item,
                            isActive: isActive,
                            onTap: () => context
                                .read<BottomNavbarProvider>()
                                .setIndex(index),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Empty space where center button sits
                  const SizedBox(width: 72),

                  // Right two items
                  Expanded(
                    child: Row(
                      children: List.generate(2, (index) {
                        final actualIndex = index + 2;
                        final item = _items[actualIndex];
                        final isActive = actualIndex == currentIndex;
                        return Expanded(
                          child: _NavBarItem(
                            item: item,
                            isActive: isActive,
                            onTap: () => context
                                .read<BottomNavbarProvider>()
                                .setIndex(actualIndex),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),

              // ── Center button — pops above the bar
              Positioned(
                top: -26, // raise above the navbar top edge
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onCenterTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // circular image with white ring + shadow
                        Container(
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            shape: BoxShape.circle,
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.14),
                            //     blurRadius: 10,
                            //     offset: const Offset(0, -2),
                            //   ),
                            // ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/home.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Text(
                          'Farm to Home',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 17, 202, 54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color.fromARGB(255, 253, 212, 212)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isActive ? widget.item.activeIcon : widget.item.icon,
                  color: widget.isActive ? activeColor : inactiveColor,
                  size: 20,
                ),
                if (widget.isActive)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      widget.item.label,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        color: activeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
  final int initialIndex;

  const NavbarScreen({super.key, this.initialIndex = 0});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  List<Hostel> _hostels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHostels();
      if (mounted) {
        context.read<BottomNavbarProvider>().setIndex(widget.initialIndex);
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

    setState(() {
      _hostels = context.read<HostelProvider>().hostels;
      _isLoading = false;
    });
  }

  void _onCenterTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroceryScreen()),
    );
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
      Analysis(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNavbar(onCenterTap: _onCenterTap),
    );
  }
}
