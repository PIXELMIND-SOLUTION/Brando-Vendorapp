import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/user_form_model.dart';
import 'package:brando_vendor/provider/form/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


class UserFormDetails extends StatefulWidget {
  const UserFormDetails({super.key});

  @override
  State<UserFormDetails> createState() => _UserFormDetailsState();
}

class _UserFormDetailsState extends State<UserFormDetails> {
  String? _vendorId;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    _vendorId = await SharedPreferenceHelper.getVendorId();
    if (_vendorId != null && mounted) {
      await context.read<HostelBookingProvider>().fetchBookings(_vendorId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (_vendorId != null) {
                context.read<HostelBookingProvider>().fetchBookings(_vendorId!);
              }
            },
          ),
        ],
      ),
      body: Consumer<HostelBookingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider);
          }

          if (provider.bookings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: const Color(0xFF4F46E5),
            onRefresh: () async {
              if (_vendorId != null) {
                await provider.fetchBookings(_vendorId!);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _BookingCard(
                  booking: provider.bookings[index],
                  onUpdate: () => _showUpdateDialog(
                    context,
                    provider,
                    provider.bookings[index],
                  ),
                  onDelete: () => _confirmDelete(
                    context,
                    provider,
                    provider.bookings[index].id,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(HostelBookingProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                if (_vendorId != null) provider.fetchBookings(_vendorId!);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Color(0xFFD1D5DB)),
          SizedBox(height: 16),
          Text(
            'No booking requests yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'New requests will appear here',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(
    BuildContext context,
    HostelBookingProvider provider,
    HostelBooking booking,
  ) {
    String selectedStatus = booking.status;
    String selectedPaymentStatus = booking.paymentStatus;
    final priceController =
        TextEditingController(text: booking.price.toStringAsFixed(0));
    final dateController = TextEditingController(
      text: booking.assignedDate ??
          DateTime.now().toIso8601String().substring(0, 10),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Update Booking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status dropdown
              _buildLabel('Status'),
              const SizedBox(height: 6),
              _buildDropdown(
                value: selectedStatus,
                items: const ['Requested', 'Assigned', 'Rejected'],
                onChanged: (v) => setModalState(() => selectedStatus = v!),
              ),
              const SizedBox(height: 14),

              // Payment status dropdown
              _buildLabel('Payment Status'),
              const SizedBox(height: 6),
              _buildDropdown(
                value: selectedPaymentStatus,
                items: const ['Pending', 'Paid'],
                onChanged: (v) =>
                    setModalState(() => selectedPaymentStatus = v!),
              ),
              const SizedBox(height: 14),

              // Price field
              _buildLabel('Price (₹)'),
              const SizedBox(height: 6),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Enter price'),
              ),
              const SizedBox(height: 14),

              // Assigned date
              _buildLabel('Assigned Date'),
              const SizedBox(height: 6),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: _inputDecoration('YYYY-MM-DD').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_rounded,
                      size: 18, color: Color(0xFF6B7280)),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(dateController.text) ??
                        DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setModalState(() {
                      dateController.text =
                          picked.toIso8601String().substring(0, 10);
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: Consumer<HostelBookingProvider>(
                  builder: (_, prov, __) => ElevatedButton(
                    onPressed: prov.isUpdating
                        ? null
                        : () async {
                            final req = UpdateBookingRequest(
                              status: selectedStatus,
                              paymentStatus: selectedPaymentStatus,
                              price:
                                  double.tryParse(priceController.text) ?? 0,
                              assignedDate: dateController.text,
                            );
                            await provider.updateBooking(
                              booking.id,
                              req,
                              onSuccess: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Booking updated successfully'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              },
                              onError: (msg) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(msg),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: prov.isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Update Booking',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    HostelBookingProvider provider,
    String bookingId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Booking',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to delete this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          Consumer<HostelBookingProvider>(
            builder: (_, prov, __) => ElevatedButton(
              onPressed: prov.isDeleting
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await provider.deleteBooking(
                        bookingId,
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking deleted successfully'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        onError: (msg) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        },
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: prov.isDeleting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      );

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(null),
      );

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
      );
}

// ─── Booking Card Widget ──────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final HostelBooking booking;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const _BookingCard({
    required this.booking,
    required this.onUpdate,
    required this.onDelete,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: hostel name + status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    booking.hostel.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              booking.hostel.address,
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Avatar(imageUrl: booking.profileImage),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        booking.email,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      Text(
                        booking.mobileNumber,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Room details chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Chip(label: 'Room ${booking.roomNo}',
                    icon: Icons.meeting_room_rounded),
                _Chip(label: booking.roomType, icon: Icons.ac_unit_rounded),
                _Chip(label: booking.shareType,
                    icon: Icons.people_rounded),
                _Chip(
                  label: booking.price > 0
                      ? '₹${booking.price.toStringAsFixed(0)}'
                      : 'Price TBD',
                  icon: Icons.currency_rupee_rounded,
                ),
                _PaymentBadge(status: booking.paymentStatus),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Documents row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Documents:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(width: 8),
                _DocThumb(label: 'Aadhar', url: booking.aadharCardImage),
                const SizedBox(width: 6),
                _DocThumb(label: 'PAN', url: booking.panCardImage),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUpdate,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Update'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small helper widgets ─────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      'Assigned' => (bg: const Color(0xFFD1FAE5), fg: const Color(0xFF065F46)),
      'Rejected' => (bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B)),
      _ => (bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: colors.fg)),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String status;
  const _PaymentBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFD1FAE5)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 11,
            color: isPaid
                ? const Color(0xFF065F46)
                : const Color(0xFF92400E),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPaid
                  ? const Color(0xFF065F46)
                  : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 44,
          height: 44,
          color: const Color(0xFFE5E7EB),
          child: const Icon(Icons.person_rounded,
              color: Color(0xFF9CA3AF), size: 24),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 44,
          height: 44,
          color: const Color(0xFFE5E7EB),
          child: const Icon(Icons.person_rounded,
              color: Color(0xFF9CA3AF), size: 24),
        ),
      ),
    );
  }
}

class _DocThumb extends StatelessWidget {
  final String label;
  final String url;
  const _DocThumb({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDocImage(context, label, url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC7D2FE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_rounded,
                size: 13, color: Color(0xFF4F46E5)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showDocImage(BuildContext context, String title, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) => const SizedBox(
                  height: 200,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4F46E5))),
                ),
                errorWidget: (_, __, ___) => const SizedBox(
                  height: 200,
                  child: Center(
                      child: Icon(Icons.broken_image_rounded,
                          size: 48, color: Color(0xFF9CA3AF))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}