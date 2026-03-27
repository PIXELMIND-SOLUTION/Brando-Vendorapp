

import 'package:brando_vendor/model/form_details_model.dart';
import 'package:brando_vendor/provider/form/form_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


// ─────────────────────────────────────────────
//  HISTORY SCREEN
// ─────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FormDetailsProvider>();
      final hostelId = provider.formDetailsResponse?.hostelId ?? '';
      print('Fetching history for hostelId: $hostelId'); 
      if (hostelId.isNotEmpty) {
        provider.fetchFormDetails(hostelId);
      }

      print('hostelllllllllll iddddddddd $hostelId');
    });
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
              onPressed: () {},
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
      body: Consumer<FormDetailsProvider>(
        builder: (context, provider, _) {
          // ── Loading ──
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            );
          }

          // ── Error ──
          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFE53935), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // retry using hostelId from the model
                      final hostelId =
                          provider.formDetailsResponse?.hostelId ?? '';
                      if (hostelId.isNotEmpty) {
                        provider.fetchFormDetails(hostelId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ── Empty ──
          if (provider.submissions.isEmpty) {
            return const Center(
              child: Text(
                'No history found.',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
            );
          }

          // ── Group submissions by roomNo ──
          final Map<String, List<Submission>> grouped = {};
          for (final s in provider.submissions) {
            final room = s.stayDetails.roomNo;
            grouped.putIfAbsent(room, () => []).add(s);
          }

          // ── Success ──
          return Column(
            children: [
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              // Table Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 90,
                      child: Text(
                        'Date',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Name',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ),
                    Text(
                      'Icons',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              // Grouped Rows
              Expanded(
                child: ListView(
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Room No Group Label
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Color(0xFFF80500),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        ...entry.value
                            .map((s) => _HistoryRow(submission: s))
                            .toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HISTORY ROW
// ─────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final Submission submission;
  const _HistoryRow({required this.submission});

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  Future<void> _makeCall(BuildContext context) async {
    final Uri callUri =
        Uri(scheme: 'tel', path: submission.guest.mobile);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Could not launch call to ${submission.guest.mobile}'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _showTransferPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) =>
          TransferPopup(tenantName: submission.guest.name),
    );
  }

  void _navigateToView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TenantViewScreen(submission: submission)),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TenantEditScreen(submission: submission)),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) =>
          DeleteConfirmationDialog(tenantName: submission.guest.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFFE53935);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  _formatDate(submission.submittedAt),
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87),
                ),
              ),
              Expanded(
                child: Text(
                  submission.guest.name,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _makeCall(context),
                    child: const Icon(Icons.phone,
                        size: 18, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showTransferPopup(context),
                    child: const Icon(Icons.share,
                        size: 18, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _navigateToView(context),
                    child: const Icon(Icons.visibility,
                        size: 18, color: Color(0xFF970BFB)),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _navigateToEdit(context),
                    child: const Icon(Icons.edit,
                        size: 18, color: Color(0xFF174AE2)),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context),
                    child: const Icon(Icons.delete,
                        size: 18, color: iconColor),
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

// ─────────────────────────────────────────────
//  DELETE CONFIRMATION DIALOG
// ─────────────────────────────────────────────
class DeleteConfirmationDialog extends StatelessWidget {
  final String tenantName;
  const DeleteConfirmationDialog(
      {super.key, required this.tenantName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
              child: const Icon(Icons.delete_outline,
                  color: Color(0xFFE53935), size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure?',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Do you want to delete $tenantName?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13.5,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(
                          color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$tenantName deleted successfully'),
                          backgroundColor: const Color(0xFFE53935),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: const Text('Delete',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
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
  const TransferPopup({super.key, required this.tenantName});

  @override
  State<TransferPopup> createState() => _TransferPopupState();
}

class _TransferPopupState extends State<TransferPopup> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Transfer',
              style: TextStyle(
                  color: Color(0xFFF80500),
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: _RoomButton(
                        label: '201',
                        selected: _selected == 0,
                        onTap: () =>
                            setState(() => _selected = 0))),
                const SizedBox(width: 12),
                Expanded(
                    child: _RoomButton(
                        label: '202',
                        selected: _selected == 1,
                        onTap: () =>
                            setState(() => _selected = 1))),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selected != null
                    ? () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Transferred to Room ${_selected == 0 ? "201" : "202"}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  disabledBackgroundColor:
                      const Color(0xFFF80500),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Update',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoomButton(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF80500)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFFF80500)
                : const Color(0xFFDDDDDD),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TENANT VIEW SCREEN
// ─────────────────────────────────────────────
class TenantViewScreen extends StatelessWidget {
  final Submission submission;
  const TenantViewScreen({super.key, required this.submission});

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final guest = submission.guest;
    final stay = submission.stayDetails;
    final docs = submission.documents;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          guest.name,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            const Text('Details',
                style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 12),
            _DetailRow(label: 'Name', value: guest.name),
            _DetailRow(
                label: 'Mobile Number', value: guest.mobile),
            _DetailRow(
                label: 'Emergency No',
                value: guest.emergencyNumber),
            _DetailRow(label: 'Email', value: guest.email),
            _DetailRow(
                label: 'Advance', value: '${stay.advance}/-'),
            _DetailRow(label: 'Room No', value: stay.roomNo),
            _DetailRow(
                label: 'Joining Date',
                value: _formatDate(stay.joiningDate)),
            _DetailRow(label: 'Tenure', value: stay.tenure),
            _DetailRow(
                label: 'Ac / Non-ac', value: stay.roomType),
            const SizedBox(height: 24),
            const Text('Documents',
                style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                _DocumentImage(
                    url: docs.aadhar, label: 'Aadhar'),
                const SizedBox(width: 12),
                _DocumentImage(
                    url: docs.idCard, label: 'ID Card'),
                const SizedBox(width: 12),
                _DocumentImage(
                    url: docs.profileImage, label: 'Photo'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Payment History',
                style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              final Uri callUri =
                  Uri(scheme: 'tel', path: guest.mobile);
              if (await canLaunchUrl(callUri)) {
                await launchUrl(callUri);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF80500),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Call',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
          ),
          const Text(': ',
              style: TextStyle(
                  fontSize: 13.5, color: Colors.black87)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13.5, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

class _DocumentImage extends StatelessWidget {
  final String url;
  final String label;
  const _DocumentImage(
      {required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url.isNotEmpty
              ? Image.network(
                  url,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported,
          color: Colors.black38, size: 28),
    );
  }
}

// ─────────────────────────────────────────────
//  TENANT EDIT SCREEN
// ─────────────────────────────────────────────
class TenantEditScreen extends StatefulWidget {
  final Submission submission;
  const TenantEditScreen({super.key, required this.submission});

  @override
  State<TenantEditScreen> createState() =>
      _TenantEditScreenState();
}

class _TenantEditScreenState extends State<TenantEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _roomCtrl;
  late TextEditingController _joiningDateCtrl;
  late TextEditingController _tenureCtrl;
  late TextEditingController _acCtrl;
  late TextEditingController _feeCtrl;
  late TextEditingController _advanceCtrl;

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  @override
  void initState() {
    super.initState();
    final g = widget.submission.guest;
    final s = widget.submission.stayDetails;
    _nameCtrl = TextEditingController(text: g.name);
    _mobileCtrl = TextEditingController(text: g.mobile);
    _emailCtrl = TextEditingController(text: g.email);
    _roomCtrl = TextEditingController(text: s.roomNo);
    _joiningDateCtrl =
        TextEditingController(text: _formatDate(s.joiningDate));
    _tenureCtrl = TextEditingController(text: s.tenure);
    _acCtrl = TextEditingController(text: s.roomType);
    _feeCtrl = TextEditingController(text: '');
    _advanceCtrl =
        TextEditingController(text: s.advance.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _roomCtrl.dispose();
    _joiningDateCtrl.dispose();
    _tenureCtrl.dispose();
    _acCtrl.dispose();
    _feeCtrl.dispose();
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
          widget.submission.guest.name,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _EditField(controller: _nameCtrl, hint: 'Name'),
            const SizedBox(height: 12),
            _EditField(
                controller: _mobileCtrl,
                hint: 'Mobile Number',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _EditField(controller: _emailCtrl, hint: 'Email'),
            const SizedBox(height: 12),
            _EditField(controller: _roomCtrl, hint: 'Room No'),
            const SizedBox(height: 12),
            _EditField(
                controller: _joiningDateCtrl,
                hint: 'Joining Date'),
            const SizedBox(height: 12),
            _EditField(
                controller: _tenureCtrl, hint: 'Monthly'),
            const SizedBox(height: 12),
            _EditField(controller: _acCtrl, hint: 'Ac'),
            const SizedBox(height: 12),
            _EditField(
                controller: _feeCtrl,
                hint: 'Fee Amount',
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _EditField(
                controller: _advanceCtrl,
                hint: 'Advance',
                keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Details updated successfully'),
                      backgroundColor: Color(0xFFE53935),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Update',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
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

  const _EditField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style:
          const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 14, color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color(0xFFE53935), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color(0xFFE53935), width: 1.5),
        ),
      ),
    );
  }
}