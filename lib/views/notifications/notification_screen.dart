import 'package:flutter/material.dart';


class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;
  final String? actionLabel;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
    this.actionLabel,
  });
}

enum NotificationType { booking, offer, reminder, payment, review, system }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Bookings', 'Offers', 'Payments'];

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.booking,
      title: 'Booking Confirmed! 🎉',
      subtitle: 'Your stay at The Urban Nest, Banjara Hills is confirmed for Mar 28–31.',
      time: 'Just now',
      actionLabel: 'View Booking',
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.offer,
      title: 'Flash Deal: 40% Off',
      subtitle: 'Limited beds left at Wanderer\'s Den. Book before midnight tonight!',
      time: '15 min ago',
      actionLabel: 'Grab Deal',
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.reminder,
      title: 'Check-in Tomorrow',
      subtitle: 'Heads up! Your check-in at Skyline Hostel is scheduled for 2:00 PM tomorrow.',
      time: '1 hr ago',
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.payment,
      title: 'Payment Successful',
      subtitle: '₹1,299 paid for 3-night stay at The Urban Nest. Receipt sent to your email.',
      time: '3 hrs ago',
      isRead: true,
      actionLabel: 'Download Receipt',
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.review,
      title: 'How was your stay?',
      subtitle: 'You checked out from BackpackHub 2 days ago. Share your experience!',
      time: '2 days ago',
      isRead: true,
      actionLabel: 'Write Review',
    ),
    NotificationItem(
      id: '6',
      type: NotificationType.offer,
      title: 'Weekend Getaway Deals',
      subtitle: 'Hostels near Goa starting ₹499/night. Valid this weekend only.',
      time: '3 days ago',
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      type: NotificationType.system,
      title: 'Profile Verified ✅',
      subtitle: 'Your ID verification is complete. Enjoy faster bookings now!',
      time: '5 days ago',
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 0) return _notifications;
    final types = [
      null,
      NotificationType.booking,
      NotificationType.offer,
      NotificationType.payment,
    ];
    final type = types[_selectedFilter];
    return _notifications.where((n) => n.type == type).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _markAllRead() {
    setState(() {
      // In a real app, update the state properly
    });
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return const Color(0xFF00C9A7);
      case NotificationType.offer:
        return const Color(0xFFFF6B6B);
      case NotificationType.reminder:
        return const Color(0xFFFFB347);
      case NotificationType.payment:
        return const Color(0xFF4ECDC4);
      case NotificationType.review:
        return const Color(0xFFA78BFA);
      case NotificationType.system:
        return const Color(0xFF60A5FA);
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return Icons.hotel_rounded;
      case NotificationType.offer:
        return Icons.local_offer_rounded;
      case NotificationType.reminder:
        return Icons.access_time_rounded;
      case NotificationType.payment:
        return Icons.receipt_long_rounded;
      case NotificationType.review:
        return Icons.star_rounded;
      case NotificationType.system:
        return Icons.verified_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildHeader(),
              ),
            ),

            // Filter chips
            FadeTransition(
              opacity: _headerFade,
              child: _buildFilterRow(),
            ),

            // Notification list
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final item = _filteredNotifications[index];
                        final delay = index * 80;
                        return _AnimatedNotificationCard(
                          item: item,
                          typeColor: _getTypeColor(item.type),
                          typeIcon: _getTypeIcon(item.type),
                          animationDelay: delay,
                          controller: _listController,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2130),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2D3E), width: 1),
            ),
            child: IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: Icon(Icons.arrow_back_ios_new_rounded,color: Colors.white,)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount unread messages',
                    style: const TextStyle(
                      color: Color(0xFF8B8FA8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Unread badge + mark all read
          GestureDetector(
            onTap: _markAllRead,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF0099FF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.done_all_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text(
                    'Mark all read',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF00C9A7), Color(0xFF0099FF)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF1E2130),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFF2A2D3E),
                ),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8B8FA8),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2130),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_off_rounded,
                size: 36, color: Color(0xFF4A4D65)),
          ),
          const SizedBox(height: 16),
          const Text('No notifications here',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text("You're all caught up!",
              style: TextStyle(color: Color(0xFF4A4D65), fontSize: 13)),
        ],
      ),
    );
  }
}

class _AnimatedNotificationCard extends StatefulWidget {
  final NotificationItem item;
  final Color typeColor;
  final IconData typeIcon;
  final int animationDelay;
  final AnimationController controller;

  const _AnimatedNotificationCard({
    required this.item,
    required this.typeColor,
    required this.typeIcon,
    required this.animationDelay,
    required this.controller,
  });

  @override
  State<_AnimatedNotificationCard> createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<_AnimatedNotificationCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    final start = (widget.animationDelay / 900).clamp(0.0, 1.0);
    final end = ((widget.animationDelay + 400) / 900).clamp(0.0, 1.0);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 10),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.98 : 1.0),
            decoration: BoxDecoration(
              color: widget.item.isRead
                  ? const Color(0xFF161820)
                  : const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.item.isRead
                    ? const Color(0xFF21243A)
                    : widget.typeColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: widget.item.isRead
                  ? []
                  : [
                      BoxShadow(
                        color: widget.typeColor.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: widget.typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.typeIcon,
                        color: widget.typeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.title,
                                style: TextStyle(
                                  color: widget.item.isRead
                                      ? Colors.white70
                                      : Colors.white,
                                  fontSize: 14,
                                  fontWeight: widget.item.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!widget.item.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: widget.typeColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.typeColor.withOpacity(0.6),
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF8B8FA8),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12, color: Color(0xFF4A4D65)),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.time,
                              style: const TextStyle(
                                color: Color(0xFF4A4D65),
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            if (widget.item.actionLabel != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: widget.typeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.typeColor.withOpacity(0.25),
                                  ),
                                ),
                                child: Text(
                                  widget.item.actionLabel!,
                                  style: TextStyle(
                                    color: widget.typeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}