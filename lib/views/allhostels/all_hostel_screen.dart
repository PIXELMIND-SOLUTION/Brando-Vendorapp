import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/user_booking_model.dart';
import 'package:brando_vendor/provider/booking/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllHostelScreen extends StatefulWidget {
  const AllHostelScreen({super.key});

  @override
  State<AllHostelScreen> createState() => _AllHostelScreenState();
}

class _AllHostelScreenState extends State<AllHostelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _vendorId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVendorAndFetch();
  }

  Future<void> _loadVendorAndFetch() async {
    _vendorId = await SharedPreferenceHelper.getVendorId();
    if (_vendorId != null && mounted) {
      await context
          .read<BookingRequestProvider>()
          .fetchAllBookingRequests(_vendorId!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF4F46E5),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Consumer<BookingRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F46E5),
              ),
            );
          }

          if (provider.status == BookingRequestStatus.error) {
            return _buildErrorState(provider.errorMessage, provider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(provider.pendingRequests, provider,
                  showActions: true),
              _buildBookingList(provider.acceptedRequests, provider),
              _buildBookingList(provider.rejectedRequests, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
      String message, BookingRequestProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFEF4444), size: 56),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_vendorId != null) {
                  provider.fetchAllBookingRequests(_vendorId!);
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingRequestModel> requests,
    BookingRequestProvider provider, {
    bool showActions = false,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No requests here',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4F46E5),
      onRefresh: () async {
        if (_vendorId != null) {
          await provider.fetchAllBookingRequests(_vendorId!);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _BookingRequestCard(
            booking: requests[index],
            provider: provider,
            showActions: showActions,
          );
        },
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final BookingRequestModel booking;
  final BookingRequestProvider provider;
  final bool showActions;

  const _BookingRequestCard({
    required this.booking,
    required this.provider,
    this.showActions = false,
  });

  Color get _statusColor {
    switch (booking.status) {
      case 'Accepted':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case 'Accepted':
        return Icons.check_circle_rounded;
      case 'Rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleStatusUpdate(
      BuildContext context, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '$status Request?',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to $status this booking from ${booking.user.name}?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Accepted'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(status),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.updateBookingStatus(
        bookingId: booking.id,
        status: status,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Request $status successfully'
                : provider.errorMessage),
            backgroundColor:
                success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Request?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text(
          'This will permanently delete the booking request from ${booking.user.name}.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.deleteBookingRequest(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'Request deleted' : provider.errorMessage),
            backgroundColor:
                success ? const Color(0xFF1A1A2E) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    booking.user.name.isNotEmpty
                        ? booking.user.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+91 ${booking.user.mobileNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 12, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        booking.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),

            // Hostel info
            Row(
              children: [
                const Icon(Icons.apartment_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.hostel.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.hostel.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  _formatDate(booking.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),

            // Action buttons for pending
            if (showActions) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _handleStatusUpdate(context, 'Rejected'),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _handleStatusUpdate(context, 'Accepted'),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Delete button for non-pending
            if (!showActions) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _handleDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 15, color: Color(0xFFEF4444)),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFFEF4444)),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    backgroundColor:
                        const Color(0xFFEF4444).withOpacity(0.06),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}