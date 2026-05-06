// lib/screens/history_screen.dart

import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/history_model.dart';
import 'package:brando_vendor/provider/history/history_provider.dart';
import 'package:brando_vendor/widgets/app_back_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? vendorId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadVendorAndFetchHistory());
  }

  Future<void> _loadVendorAndFetchHistory() async {
    print('HistoryScreen: Starting to load vendor ID');

    // Check if mounted before proceeding
    if (!mounted) return;

    try {
      vendorId = await SharedPreferenceHelper.getVendorId();
      print('HistoryScreen: Vendor ID retrieved - $vendorId');

      if (vendorId != null && vendorId!.isNotEmpty) {
        print('HistoryScreen: Calling fetchHistory with vendorId: $vendorId');

        // Now the provider should be available
        final provider = Provider.of<HistoryProvider>(context, listen: false);
        if (provider != null) {
          await provider.fetchHistory(vendorId!);
          print('HistoryScreen: fetchHistory completed');
        } else {
          print('HistoryScreen: HistoryProvider not found in context');
        }
      } else {
        print('HistoryScreen: Vendor ID is null or empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor ID not found. Please login again.'),
              backgroundColor: Color(0xFFE53935),
            ),
          );
        }
      }
    } catch (e) {
      print('HistoryScreen: Error loading vendor ID - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackControl(
      showConfirmationDialog: true,
      dialogTitle: 'Exit App?',
      dialogMessage: 'Are you sure you want to exit the app?',
      confirmText: 'Exit',
      cancelText: 'Stay',
      onBackPressed: () {
        print('User exiting app');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          centerTitle: true,
          title: const Text(
            'History',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement export functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export feature coming soon'),
                      backgroundColor: Color(0xFFE53935),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Export',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
        body: Consumer<HistoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE53935)),
              );
            }

            if (provider.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE53935),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (vendorId != null && vendorId!.isNotEmpty) {
                          provider.fetchHistory(vendorId!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.bookings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.black26),
                    SizedBox(height: 16),
                    Text(
                      'No history found.',
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                // Table Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 100),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                // Grouped Rows
                Expanded(
                  child: ListView(
                    children: provider.bookings.map((roomData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Room No Group Label
                          Container(
                            width: double.infinity,
                            color: const Color(0xFFFFF5F5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.meeting_room,
                                  size: 18,
                                  color: Color(0xFFF80500),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Room ${roomData.roomNo}',
                                  style: const TextStyle(
                                    color: Color(0xFFF80500),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF80500,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${roomData.totalBookings} booking${roomData.totalBookings > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFF80500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...roomData.bookings
                              .map((booking) => _HistoryRow(booking: booking))
                              .toList(),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HISTORY ROW
// ─────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final Booking booking;
  const _HistoryRow({required this.booking});

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF9E9E9E);
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFF9800);
    }
  }

  String _getFormattedAmount() {
    return '₹${booking.totalAmount}';
  }

  Future<void> _makeCall(BuildContext context) async {
    if (booking.userId != null) {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: booking.userId!.mobileNumber.toString(),
      );
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not call ${booking.userId!.mobileNumber}'),
              backgroundColor: const Color(0xFFE53935),
            ),
          );
        }
      }
    }
  }

  void _showTransferPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => TransferPopup(
        tenantName: booking.userId?.name ?? 'Tenant',
        currentRoom: booking.roomNo,
        bookingId: booking.id,
      ),
    );
  }

  void _navigateToView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TenantViewScreen(booking: booking)),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TenantEditScreen(booking: booking)),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => DeleteConfirmationDialog(
        tenantName: booking.userId?.name ?? 'Tenant',
        bookingId: booking.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(booking.startDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFormattedAmount(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.userId?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref: ${booking.bookingReference}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 70,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(booking.status),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    onTap: () => _makeCall(context),
                    icon: Icons.phone,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    onTap: () => _showTransferPopup(context),
                    icon: Icons.swap_horiz,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    onTap: () => _navigateToView(context),
                    icon: Icons.visibility,
                    color: const Color(0xFF970BFB),
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    onTap: () => _navigateToEdit(context),
                    icon: Icons.edit,
                    color: const Color(0xFF174AE2),
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    onTap: () => _showDeleteConfirmation(context),
                    icon: Icons.delete,
                    color: const Color(0xFFE53935),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DELETE CONFIRMATION DIALOG
// ─────────────────────────────────────────────
class DeleteConfirmationDialog extends StatelessWidget {
  final String tenantName;
  final String bookingId;

  const DeleteConfirmationDialog({
    super.key,
    required this.tenantName,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFE53935),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure?',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Do you want to delete $tenantName?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement actual delete API call
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$tenantName deleted successfully'),
                          backgroundColor: const Color(0xFFE53935),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
}

// ─────────────────────────────────────────────
//  TRANSFER POPUP
// ─────────────────────────────────────────────
class TransferPopup extends StatefulWidget {
  final String tenantName;
  final String currentRoom;
  final String bookingId;

  const TransferPopup({
    super.key,
    required this.tenantName,
    required this.currentRoom,
    required this.bookingId,
  });

  @override
  State<TransferPopup> createState() => _TransferPopupState();
}

class _TransferPopupState extends State<TransferPopup> {
  String? _selectedRoom;
  final List<String> _availableRooms = ['101', '102', '103', '104', '105'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Transfer Room',
              style: TextStyle(
                color: Color(0xFFF80500),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.tenantName} - Current Room: ${widget.currentRoom}',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select New Room',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableRooms.map((room) {
                final isSelected = _selectedRoom == room;
                final isCurrentRoom = widget.currentRoom == room;
                return GestureDetector(
                  onTap: isCurrentRoom
                      ? null
                      : () => setState(() => _selectedRoom = room),
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF80500)
                          : isCurrentRoom
                          ? const Color(0xFFEEEEEE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF80500)
                            : isCurrentRoom
                            ? const Color(0xFFCCCCCC)
                            : const Color(0xFFDDDDDD),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          room,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isCurrentRoom
                                ? Colors.black54
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (isCurrentRoom)
                          const Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.black45,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _selectedRoom != null && _selectedRoom != widget.currentRoom
                    ? () {
                        Navigator.pop(context);
                        // TODO: Implement actual transfer API call
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${widget.tenantName} transferred from Room ${widget.currentRoom} to Room $_selectedRoom',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Transfer',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TENANT VIEW SCREEN
// ─────────────────────────────────────────────
class TenantViewScreen extends StatelessWidget {
  final Booking booking;
  const TenantViewScreen({super.key, required this.booking});

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final user = booking.userId;
    final hostel = booking.hostelId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          user?.name ?? 'Tenant Details',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: const Icon(Icons.share, color: Colors.black54),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hostel Info Card
            if (hostel != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hostel Information',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hostel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hostel.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Personal Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Name', value: user?.name ?? 'N/A'),
            _DetailRow(
              label: 'Mobile Number',
              value: user?.mobileNumber.toString() ?? 'N/A',
            ),
            _DetailRow(
              label: 'Booking Reference',
              value: booking.bookingReference,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stay Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Room No', value: booking.roomNo),
            _DetailRow(label: 'Room Type', value: booking.roomType),
            _DetailRow(label: 'Share Type', value: booking.shareType),
            _DetailRow(label: 'Booking Type', value: booking.bookingType),
            _DetailRow(
              label: 'Start Date',
              value: _formatDate(booking.startDate),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Total Amount', value: '₹${booking.totalAmount}'),
            _DetailRow(
              label: 'Monthly Advance',
              value: '₹${booking.monthlyAdvance}',
            ),
            _DetailRow(label: 'Status', value: booking.status.toUpperCase()),
            const SizedBox(height: 20),
            const Text(
              'Booking Timeline',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Created At',
              value: _formatDate(booking.createdAt),
            ),
            _DetailRow(
              label: 'Last Updated',
              value: _formatDate(booking.updatedAt),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement message functionality
                },
                icon: const Icon(Icons.message, size: 20),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF80500),
                  side: const BorderSide(color: Color(0xFFF80500)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (user != null) {
                    final Uri callUri = Uri(
                      scheme: 'tel',
                      path: user.mobileNumber.toString(),
                    );
                    if (await canLaunchUrl(callUri)) {
                      await launchUrl(callUri);
                    }
                  }
                },
                icon: const Icon(Icons.call, size: 20),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TENANT EDIT SCREEN
// ─────────────────────────────────────────────
class TenantEditScreen extends StatefulWidget {
  final Booking booking;
  const TenantEditScreen({super.key, required this.booking});

  @override
  State<TenantEditScreen> createState() => _TenantEditScreenState();
}

class _TenantEditScreenState extends State<TenantEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _roomCtrl;
  late TextEditingController _roomTypeCtrl;
  late TextEditingController _shareTypeCtrl;
  late TextEditingController _totalAmountCtrl;
  late TextEditingController _advanceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.booking.userId?.name ?? '');
    _mobileCtrl = TextEditingController(
      text: widget.booking.userId?.mobileNumber.toString() ?? '',
    );
    _roomCtrl = TextEditingController(text: widget.booking.roomNo);
    _roomTypeCtrl = TextEditingController(text: widget.booking.roomType);
    _shareTypeCtrl = TextEditingController(text: widget.booking.shareType);
    _totalAmountCtrl = TextEditingController(
      text: widget.booking.totalAmount.toString(),
    );
    _advanceCtrl = TextEditingController(
      text: widget.booking.monthlyAdvance.toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _roomCtrl.dispose();
    _roomTypeCtrl.dispose();
    _shareTypeCtrl.dispose();
    _totalAmountCtrl.dispose();
    _advanceCtrl.dispose();
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
        centerTitle: true,
        title: Text(
          'Edit ${widget.booking.userId?.name ?? 'Tenant'}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _EditField(
              controller: _nameCtrl,
              hint: 'Full Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _EditField(
              controller: _mobileCtrl,
              hint: 'Mobile Number',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 12),
            _EditField(
              controller: _roomCtrl,
              hint: 'Room Number',
              icon: Icons.meeting_room_outlined,
            ),
            const SizedBox(height: 12),
            _EditField(
              controller: _roomTypeCtrl,
              hint: 'Room Type (AC/Non-AC)',
              icon: Icons.ac_unit,
            ),
            const SizedBox(height: 12),
            _EditField(
              controller: _shareTypeCtrl,
              hint: 'Share Type',
              icon: Icons.people_outline,
            ),
            const SizedBox(height: 12),
            _EditField(
              controller: _totalAmountCtrl,
              hint: 'Total Amount',
              keyboardType: TextInputType.number,
              icon: Icons.currency_rupee,
            ),
            const SizedBox(height: 12),
            _EditField(
              controller: _advanceCtrl,
              hint: 'Advance Amount',
              keyboardType: TextInputType.number,
              icon: Icons.payment,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement actual update API call
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Details updated successfully'),
                      backgroundColor: Color(0xFFE53935),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final IconData icon;

  const _EditField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFFE53935)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
      ),
    );
  }
}
