import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class TenantModel {
  final String date;
  final String name;
  final String phone;
  final String mobileNumber;
  final String emergencyNo;
  final String email;
  final String advance;
  final String roomNo;
  final String joiningDate;
  final String tenure;
  final String acNonAc;

  const TenantModel({
    required this.date,
    required this.name,
    required this.phone,
    required this.mobileNumber,
    required this.emergencyNo,
    required this.email,
    required this.advance,
    required this.roomNo,
    required this.joiningDate,
    required this.tenure,
    required this.acNonAc,
  });
}

// ─────────────────────────────────────────────
//  HISTORY SCREEN
// ─────────────────────────────────────────────
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<TenantModel> historyItems = const [
    TenantModel(
      date: '12/2/2026',
      name: 'Narasimha varma',
      phone: '+919098909890',
      mobileNumber: '9098909890',
      emergencyNo: '9098909890',
      email: 'Narasimha Varma',
      advance: '1,000/-',
      roomNo: '101',
      joiningDate: '13/12/2025',
      tenure: 'Monthly',
      acNonAc: 'AC',
    ),
    TenantModel(
      date: '12/2/2026',
      name: 'Narasimha varma',
      phone: '+919098909890',
      mobileNumber: '9098909890',
      emergencyNo: '9098909890',
      email: 'Narasimha Varma',
      advance: '1,000/-',
      roomNo: '101',
      joiningDate: '13/12/2025',
      tenure: 'Monthly',
      acNonAc: 'AC',
    ),
    TenantModel(
      date: '12/2/2026',
      name: 'Narasimha varma',
      phone: '+919098909890',
      mobileNumber: '9098909890',
      emergencyNo: '9098909890',
      email: 'Narasimha Varma',
      advance: '1,000/-',
      roomNo: '101',
      joiningDate: '13/12/2025',
      tenure: 'Monthly',
      acNonAc: 'AC',
    ),
  ];

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
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          // Group Label
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '101',
              style: const TextStyle(
                color: Color(0xFFF80500),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          // History Rows
          ...historyItems
              .map((item) => _HistoryRow(item: item))
              .toList(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HISTORY ROW
// ─────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final TenantModel item;
  const _HistoryRow({required this.item});

  Future<void> _makeCall(BuildContext context) async {
    final Uri callUri = Uri(scheme: 'tel', path: item.phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch call to ${item.phone}'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _showTransferPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => TransferPopup(tenantName: item.name),
    );
  }

  void _navigateToView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TenantViewScreen(tenant: item)),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TenantEditScreen(tenant: item)),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => DeleteConfirmationDialog(tenantName: item.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFFE53935);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(item.date,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87)),
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Call
                  GestureDetector(
                    onTap: () => _makeCall(context),
                    child: const Icon(Icons.phone, size: 18, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  // Share → Transfer popup
                  GestureDetector(
                    onTap: () => _showTransferPopup(context),
                    child: const Icon(Icons.share, size: 18, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  // View
                  GestureDetector(
                    onTap: () => _navigateToView(context),
                    child: const Icon(Icons.visibility,
                        size: 18, color: Color(0xFF970BFB)),
                  ),
                  const SizedBox(width: 6),
                  // Edit
                  GestureDetector(
                    onTap: () => _navigateToEdit(context),
                    child: const Icon(Icons.edit, size: 18, color: Color(0xFF174AE2)),
                  ),
                  const SizedBox(width: 6),
                  // Delete
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context),
                    child: const Icon(Icons.delete, size: 18, color: iconColor),
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
  const DeleteConfirmationDialog({super.key, required this.tenantName});

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
            // Trash icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
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
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Delete button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
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
//  TRANSFER POPUP  (Image 1)
// ─────────────────────────────────────────────
class TransferPopup extends StatefulWidget {
  final String tenantName;
  const TransferPopup({super.key, required this.tenantName});

  @override
  State<TransferPopup> createState() => _TransferPopupState();
}

class _TransferPopupState extends State<TransferPopup> {
  int? _selected; // null = none, 0 = 201, 1 = 202

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Transfer',
              style: TextStyle(
                color: Color(0xFFF80500),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _RoomButton(label: '201', selected: _selected == 0, onTap: () => setState(() => _selected = 0))),
                const SizedBox(width: 12),
                Expanded(child: _RoomButton(label: '202', selected: _selected == 1, onTap: () => setState(() => _selected = 1))),
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
                        fontSize: 15, fontWeight: FontWeight.w600)),
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
          color:
              selected ? const Color(0xFFF80500) : const Color(0xFFF5F5F5),
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
//  TENANT VIEW SCREEN  (Image 2)
// ─────────────────────────────────────────────
class TenantViewScreen extends StatelessWidget {
  final TenantModel tenant;
  const TenantViewScreen({super.key, required this.tenant});

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
          tenant.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            // Details section
            const Text(
              'Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Name', value: tenant.name),
            _DetailRow(label: 'Mobile Number', value: tenant.mobileNumber),
            _DetailRow(label: 'Emergency No', value: tenant.emergencyNo),
            _DetailRow(label: 'Email', value: tenant.email),
            _DetailRow(label: 'Advance', value: tenant.advance),
            _DetailRow(label: 'Room No', value: tenant.roomNo),
            _DetailRow(label: 'Joining Date', value: tenant.joiningDate),
            _DetailRow(label: 'Tenure', value: tenant.tenure),
            _DetailRow(label: 'Ac / Non-ac', value: tenant.acNonAc),
            const SizedBox(height: 24),
            // Documents section
            const Text(
              'Documents',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _DocumentPlaceholder(),
                const SizedBox(width: 12),
                _DocumentPlaceholder(),
                const SizedBox(width: 12),
                _DocumentPlaceholder(),
              ],
            ),
            const SizedBox(height: 24),
            // Payment History section
            const Text(
              'Payment History',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
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
                  Uri(scheme: 'tel', path: tenant.phone);
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
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': ',
              style: TextStyle(fontSize: 13.5, color: Colors.black87)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TENANT EDIT SCREEN  (Image 3)
// ─────────────────────────────────────────────
class TenantEditScreen extends StatefulWidget {
  final TenantModel tenant;
  const TenantEditScreen({super.key, required this.tenant});

  @override
  State<TenantEditScreen> createState() => _TenantEditScreenState();
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

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.tenant.name);
    _mobileCtrl =
        TextEditingController(text: widget.tenant.mobileNumber);
    _emailCtrl =
        TextEditingController(text: widget.tenant.email);
    _roomCtrl =
        TextEditingController(text: widget.tenant.roomNo);
    _joiningDateCtrl =
        TextEditingController(text: widget.tenant.joiningDate);
    _tenureCtrl =
        TextEditingController(text: widget.tenant.tenure);
    _acCtrl = TextEditingController(text: widget.tenant.acNonAc);
    _feeCtrl = TextEditingController(text: '');
    _advanceCtrl =
        TextEditingController(text: widget.tenant.advance);
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
          widget.tenant.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            _EditField(controller: _tenureCtrl, hint: 'Monthly'),
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
                      content: Text('Details updated successfully'),
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
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 14, color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
      ),
    );
  }
}