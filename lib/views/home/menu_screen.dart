import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/history_model.dart';
import 'package:brando_vendor/provider/history/history_provider.dart';
import 'package:brando_vendor/widgets/app_back_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? vendorId;
  final RefreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadVendorAndFetchHistory());
  }

  Future<void> _loadVendorAndFetchHistory() async {
    print('MenuScreen: Starting to load vendor ID');

    if (!mounted) return;

    try {
      vendorId = await SharedPreferenceHelper.getVendorId();
      print('MenuScreen: Vendor ID retrieved - $vendorId');

      if (vendorId != null && vendorId!.isNotEmpty) {
        print('MenuScreen: Calling fetchHistory with vendorId: $vendorId');

        final provider = Provider.of<HistoryProvider>(context, listen: false);
        if (provider != null) {
          await provider.fetchHistory(vendorId!);
          print('MenuScreen: fetchHistory completed');
        } else {
          print('MenuScreen: HistoryProvider not found in context');
        }
      } else {
        print('MenuScreen: Vendor ID is null or empty');
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
      print('MenuScreen: Error loading vendor ID - $e');
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

  Future<void> _refreshHistory() async {
    if (vendorId != null && vendorId!.isNotEmpty) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      await provider.fetchHistory(vendorId!);
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final provider = Provider.of<HistoryProvider>(context, listen: false);

      if (provider.bookings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No data to export'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
        return;
      }

      // Create Excel file
      var excel = Excel.createExcel();

      // Create sheet
      Sheet sheetObject = excel['Bookings History'];

      // Define headers
      List<String> headers = [
        'Room No',
        'Date',
        'Name',
        'Mobile Number',
        'Booking Reference',
        'Amount',
        'Status',
        'Room Type',
        'Share Type',
        'Booking Type',
        'Start Date',
        'End Date',
        'Monthly Advance',
        'Current Month Payment',
      ];

      // Add headers to sheet with styling
      for (int i = 0; i < headers.length; i++) {
        final cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);

        // Apply header style
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.red,
          fontColorHex: ExcelColor.white,
        );
      }

      int rowIndex = 1;

      // Add data to sheet
      for (var roomData in provider.bookings) {
        for (var booking in roomData.bookings) {
          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            roomData.roomNo,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            _formatDate(booking.startDate),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.userId?.name ?? 'Unknown',
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.userId?.mobileNumber.toString() ?? 'N/A',
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.bookingReference,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
              )
              .value = DoubleCellValue(
            booking.totalAmount.toDouble(),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.status.toUpperCase(),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.roomType,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.shareType,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.bookingType,
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            _formatDate(booking.startDate),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex),
              )
              .value = DoubleCellValue(
            booking.monthlyAdvance.toDouble(),
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.currentMonthPaymentStatus?.toUpperCase() ?? 'N/A',
          );

          rowIndex++;
        }
      }

      // Save file to temporary directory
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/bookings_history_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final File file = File(filePath);

      // Encode and save
      List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);

        // Share the file using share_plus (works without storage permission)
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Bookings History Export',
          subject: 'Bookings History Report',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel file exported and shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to encode Excel file');
      }
    } catch (e) {
      print('Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting file: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

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
            // Refresh Button
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  _refreshHistory();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  elevation: 0,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Export Button
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: _exportToExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  elevation: 0,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.download, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Export',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          key: RefreshIndicatorKey,
          color: const Color(0xFFE53935),
          onRefresh: _refreshHistory,
          child: Consumer<HistoryProvider>(
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
                  Expanded(
                    child: ListView(
                      children: provider.bookings.map((roomData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    color: const Color(0xFFF80500),
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
                                .map(
                                  (booking) => _HistoryRow(
                                    booking: booking,
                                    onRefresh: _refreshHistory,
                                  ),
                                )
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
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final Booking booking;
  final VoidCallback onRefresh;
  const _HistoryRow({required this.booking, required this.onRefresh});

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

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'overdue':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
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
        onTransferComplete: onRefresh,
      ),
    );
  }

  void _navigateToView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TenantViewScreen(booking: booking, onUpdate: onRefresh),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Amount Column - Fixed width
              SizedBox(
                width: 70,
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
              const SizedBox(width: 8),

              // Name and Details Column - Expanded with proper constraints
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Reference and Payment Status Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Ref: ${booking.bookingReference}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black45,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPaymentStatusColor(
                              booking.currentMonthPaymentStatus,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Payment Status : ${booking.currentMonthPaymentStatus?.toUpperCase() ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _getPaymentStatusColor(
                                booking.currentMonthPaymentStatus,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status Badge - Fixed width
              SizedBox(
                width: 65,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Action Buttons - Fixed width
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    onTap: () => _makeCall(context),
                    icon: Icons.phone,
                    color: Colors.green,
                    size: 18,
                  ),
                  _ActionButton(
                    onTap: () => _showTransferPopup(context),
                    icon: Icons.swap_horiz,
                    color: Colors.blue,
                    size: 18,
                  ),
                  _ActionButton(
                    onTap: () => _navigateToView(context),
                    icon: Icons.visibility,
                    color: const Color(0xFF970BFB),
                    size: 18,
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

// ActionButton
class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

// Screen for adding first payment (when payment history is empty)
class AddFirstPaymentScreen extends StatefulWidget {
  final Booking booking;
  final VoidCallback onUpdate;

  const AddFirstPaymentScreen({
    super.key,
    required this.booking,
    required this.onUpdate,
  });

  @override
  State<AddFirstPaymentScreen> createState() => _AddFirstPaymentScreenState();
}

class _AddFirstPaymentScreenState extends State<AddFirstPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _totalAmountCtrl;
  late TextEditingController _amountCtrl;
  String paymentType = "full";
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _totalAmountCtrl = TextEditingController(
      text: widget.booking.totalAmount.toString(),
    );
    _amountCtrl = TextEditingController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _totalAmountCtrl.dispose();
    _amountCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccessAnimation() {
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      _animationController.reset();
    });
  }

  Future<void> _addPayment() async {
    double amount;
    double totalAmount = widget.booking.totalAmount.toDouble();
    double remainingAmount = 0;

    if (paymentType == "partial") {
      amount = double.tryParse(_amountCtrl.text) ?? 0;

      if (amount <= 0 || amount > totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter valid partial amount'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
        return;
      }

      remainingAmount = totalAmount - amount;
    } else {
      amount = totalAmount;
      remainingAmount = 0;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {
        'amount': amount,
        'status': paymentType == "full" ? "paid" : "partial",
        'date': DateTime.now().toIso8601String().split('T')[0],
        'remainingAmount': remainingAmount,
      };

      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/addmonthlypaymnet/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        _showSuccessAnimation();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                paymentType == "full"
                    ? 'Full payment added successfully! ✨'
                    : 'Partial payment of ₹$amount added successfully! ✨',
              ),
              backgroundColor: Colors.green,
            ),
          );

          widget.onUpdate();

          Future.delayed(const Duration(milliseconds: 1600), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        throw Exception('Failed to add payment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding payment: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          'Add First Payment - ${widget.booking.userId?.name ?? 'Tenant'}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Info Card
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF5F5), Color(0xFFFFE0E0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE53935),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFE53935),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'First Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This is the first payment for this booking. No payment history exists yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                _ViewField(
                  controller: _totalAmountCtrl,
                  hint: 'Total Amount',
                  keyboardType: TextInputType.number,
                  icon: Icons.currency_rupee,
                  enabled: false,
                ),
                const SizedBox(height: 32),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Payment Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<String>(
                          value: "full",
                          groupValue: paymentType,
                          onChanged: (value) {
                            setState(() {
                              paymentType = value!;
                            });
                          },
                        ),
                        const Text("Full Payment"),
                        const SizedBox(width: 24),
                        Radio<String>(
                          value: "partial",
                          groupValue: paymentType,
                          onChanged: (value) {
                            setState(() {
                              paymentType = value!;
                            });
                          },
                        ),
                        const Text("Partial Payment"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (paymentType == "partial")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter Paid Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              prefixIcon: const Icon(
                                Icons.currency_rupee,
                                size: 20,
                                color: Color(0xFFE53935),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE53935),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Max: ₹${widget.booking.totalAmount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF80500),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Add Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Success Animation Overlay
          if (_animationController.isAnimating)
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Added!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Successfully processed',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// // Screen for editing existing payment
// class EditPaymentScreen extends StatefulWidget {
//   final Booking booking;
//   final PaymentHistory payment;
//   final VoidCallback onUpdate;

//   const EditPaymentScreen({
//     super.key,
//     required this.booking,
//     required this.payment,
//     required this.onUpdate,
//   });

//   @override
//   State<EditPaymentScreen> createState() => _EditPaymentScreenState();
// }

// class _EditPaymentScreenState extends State<EditPaymentScreen>
//     with SingleTickerProviderStateMixin {
//   late TextEditingController _remainingAmountCtrl;
//   late TextEditingController _amountCtrl;
//   String paymentType = "";
//   bool _isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _remainingAmountCtrl = TextEditingController(
//       text: widget.payment.remainingAmount.toString(),
//     );
//     _amountCtrl = TextEditingController();

//     // Set initial payment type based on existing payment
//     if (widget.payment.status.toLowerCase() == 'paid') {
//       paymentType = "full";
//     } else {
//       paymentType = "partial";
//     }

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
//     );
//   }

//   @override
//   void dispose() {
//     _remainingAmountCtrl.dispose();
//     _amountCtrl.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _showSuccessAnimation() {
//     _animationController.forward();
//     Future.delayed(const Duration(milliseconds: 1500), () {
//       _animationController.reset();
//     });
//   }

//   Future<void> _updatePayment() async {
//     double amount;
//     double remainingAmount = 0;

//     if (paymentType == "partial") {
//       amount = double.tryParse(_amountCtrl.text) ?? 0;

//       if (amount <= 0 || amount > widget.payment.remainingAmount) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Enter valid partial amount (Max: ₹${widget.payment.remainingAmount})',
//             ),
//             backgroundColor: const Color(0xFFE53935),
//           ),
//         );
//         return;
//       }

//       remainingAmount = widget.payment.remainingAmount - amount;
//     } else {
//       amount = widget.payment.remainingAmount;
//       remainingAmount = 0;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final payload = {
//         'amount': amount,
//         'status': paymentType == "full" ? "paid" : "partial",
//         'date': DateTime.now().toIso8601String().split('T')[0],
//         'remainingAmount': remainingAmount,
//       };

//       final response = await http.put(
//         Uri.parse(
//           'http://187.127.146.52:2003/api/vendors/updatemonthlypaymnet/${widget.booking.id}/${widget.payment.id}',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode == 200) {
//         _showSuccessAnimation();

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 paymentType == "full"
//                     ? 'Payment completed successfully! ✨'
//                     : 'Partial payment of ₹$amount updated! ✨',
//               ),
//               backgroundColor: Colors.green,
//             ),
//           );

//           widget.onUpdate();

//           Future.delayed(const Duration(milliseconds: 1600), () {
//             if (mounted) Navigator.pop(context);
//           });
//         }
//       } else {
//         throw Exception('Failed to update payment');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error updating payment: $e'),
//             backgroundColor: const Color(0xFFE53935),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Don't show edit screen if payment status is paid
//     if (widget.payment.status.toLowerCase() == 'paid') {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: const BackButton(color: Colors.black),
//           centerTitle: true,
//           title: Text(
//             'Payment Details - ${widget.booking.userId?.name ?? 'Tenant'}',
//             style: const TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.w600,
//               fontSize: 18,
//             ),
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.check_circle, color: Colors.green, size: 80),
//               const SizedBox(height: 16),
//               const Text(
//                 'Payment Already Completed',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'This payment has been fully paid (₹${widget.payment.amount})',
//                 style: const TextStyle(fontSize: 14, color: Colors.black54),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Go Back'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           'Edit Payment - ${widget.booking.userId?.name ?? 'Tenant'}',
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Column(
//               children: [
//                 // Current Payment Status Card
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: widget.payment.status.toLowerCase() == 'paid'
//                           ? [Colors.green.shade50, Colors.green.shade100]
//                           : [Colors.orange.shade50, Colors.orange.shade100],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: widget.payment.status.toLowerCase() == 'paid'
//                           ? Colors.green
//                           : Colors.orange,
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: widget.payment.status.toLowerCase() == 'paid'
//                               ? Colors.green.withOpacity(0.2)
//                               : Colors.orange.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           widget.payment.status.toLowerCase() == 'paid'
//                               ? Icons.check_circle
//                               : Icons.pending,
//                           color: widget.payment.status.toLowerCase() == 'paid'
//                               ? Colors.green
//                               : Colors.orange,
//                           size: 30,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Current Payment Status',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               widget.payment.status.toUpperCase(),
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color:
//                                     widget.payment.status.toLowerCase() ==
//                                         'paid'
//                                     ? Colors.green
//                                     : Colors.orange,
//                               ),
//                             ),
//                             if (widget.payment.remainingAmount > 0) ...[
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Remaining: ₹${widget.payment.remainingAmount.toStringAsFixed(2)}',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFFE53935),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 _ViewField(
//                   controller: _remainingAmountCtrl,
//                   hint: 'Remaining Amount',
//                   keyboardType: TextInputType.number,
//                   icon: Icons.currency_rupee,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 32),

//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Update Payment",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Only show complete payment option if status is not paid
//                     if (widget.payment.status.toLowerCase() != 'paid') ...[
//                       Row(
//                         children: [
//                           Radio<String>(
//                             value: "full",
//                             groupValue: paymentType,
//                             onChanged: (value) {
//                               setState(() {
//                                 paymentType = value!;
//                               });
//                             },
//                           ),
//                           const Text("Complete Payment"),
//                           const SizedBox(width: 24),
//                           Radio<String>(
//                             value: "partial",
//                             groupValue: paymentType,
//                             onChanged: (value) {
//                               setState(() {
//                                 paymentType = value!;
//                               });
//                             },
//                           ),
//                           const Text("Partial Payment"),
//                         ],
//                       ),
//                     ] else ...[
//                       const Row(
//                         children: [
//                           Text(
//                             "Payment is already completed",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.green,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                     const SizedBox(height: 16),
//                     if (paymentType == "partial")
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Enter Additional Payment Amount',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: _amountCtrl,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: 'Enter amount',
//                               prefixIcon: const Icon(
//                                 Icons.currency_rupee,
//                                 size: 20,
//                                 color: Color(0xFFE53935),
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xFFE53935),
//                                   width: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Max: ₹${widget.payment.remainingAmount}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     if (paymentType == "full" &&
//                         widget.payment.status.toLowerCase() != 'paid')
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               color: Colors.blue.shade700,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'This will mark the payment as complete with full amount of ₹${widget.payment.remainingAmount}',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.blue.shade700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _updatePayment,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF80500),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2.5,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                         : const Text(
//                             'Update Payment',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//           // Success Animation Overlay
//           if (_animationController.isAnimating)
//             Center(
//               child: ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.green.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.check_circle,
//                           color: Colors.green,
//                           size: 60,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Payment Updated!',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Successfully processed',
//                         style: TextStyle(fontSize: 14, color: Colors.black54),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// Screen for editing existing payment
class EditPaymentScreen extends StatefulWidget {
  final Booking booking;
  final PaymentHistory payment;
  final VoidCallback onUpdate;

  const EditPaymentScreen({
    super.key,
    required this.booking,
    required this.payment,
    required this.onUpdate,
  });

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _totalAmountCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _remainingAmountCtrl;
  String paymentType = "";
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  double _getRemainingAmount() {
    // Handle different types for remainingAmount
    double remaining = 0.0;

    if (widget.payment.remainingAmount != null) {
      if (widget.payment.remainingAmount is int) {
        remaining = (widget.payment.remainingAmount as int).toDouble();
      } else if (widget.payment.remainingAmount is double) {
        remaining = widget.payment.remainingAmount as double;
      } else if (widget.payment.remainingAmount is String) {
        remaining =
            double.tryParse(widget.payment.remainingAmount as String) ?? 0.0;
      } else if (widget.payment.remainingAmount is num) {
        remaining = (widget.payment.remainingAmount as num).toDouble();
      }
    }

    // If status is PENDING and remaining is 0, use total booking amount
    if (widget.payment.status.toLowerCase() == 'pending' && remaining == 0) {
      // Get total amount from booking
      if (widget.booking.totalAmount != null) {
        if (widget.booking.totalAmount is int) {
          remaining = (widget.booking.totalAmount as int).toDouble();
        } else if (widget.booking.totalAmount is double) {
          remaining = widget.booking.totalAmount as double;
        } else if (widget.booking.totalAmount is String) {
          remaining =
              double.tryParse(widget.booking.totalAmount as String) ?? 0.0;
        } else if (widget.booking.totalAmount is num) {
          remaining = (widget.booking.totalAmount as num).toDouble();
        }
      }
    }

    return remaining;
  }

  double _getTotalAmount() {
    double total = 0.0;

    if (widget.booking.totalAmount != null) {
      if (widget.booking.totalAmount is int) {
        total = (widget.booking.totalAmount as int).toDouble();
      } else if (widget.booking.totalAmount is double) {
        total = widget.booking.totalAmount as double;
      } else if (widget.booking.totalAmount is String) {
        total = double.tryParse(widget.booking.totalAmount as String) ?? 0.0;
      } else if (widget.booking.totalAmount is num) {
        total = (widget.booking.totalAmount as num).toDouble();
      }
    }

    return total;
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    if (amount is int) return amount.toString();
    if (amount is double) return amount.toStringAsFixed(2);
    if (amount is String) {
      final parsed = double.tryParse(amount);
      return parsed != null ? parsed.toStringAsFixed(2) : '0';
    }
    if (amount is num) return amount.toString();
    return '0';
  }

  @override
  void initState() {
    super.initState();

    double remaining = _getRemainingAmount();
    double total = _getTotalAmount();

    _totalAmountCtrl = TextEditingController(text: _formatAmount(total));
    _remainingAmountCtrl = TextEditingController(
      text: _formatAmount(remaining),
    );
    _amountCtrl = TextEditingController();

    // Set initial payment type based on existing payment
    if (widget.payment.status.toLowerCase() == 'paid') {
      paymentType = "full";
    } else {
      paymentType = "partial";
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _totalAmountCtrl.dispose();
    _remainingAmountCtrl.dispose();
    _amountCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccessAnimation() {
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      _animationController.reset();
    });
  }

  Future<void> _updatePayment() async {
    double amount;
    double remainingAmount = 0;

    double currentRemaining = _getRemainingAmount();

    if (paymentType == "partial") {
      amount = double.tryParse(_amountCtrl.text) ?? 0;

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
        return;
      }

      if (amount > currentRemaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount cannot exceed remaining amount of ₹${_formatAmount(currentRemaining)}',
            ),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
        return;
      }

      remainingAmount = currentRemaining - amount;
    } else {
      // Complete payment
      amount = currentRemaining;
      remainingAmount = 0;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("lllllllllllllll$amount");
      print("lllllllllllllll$currentRemaining");

      print("lllllllllllllll$remainingAmount");
      print("lllllllllllllll${widget.booking.totalAmount}");

      if (currentRemaining > 0 &&
          widget.booking.totalAmount != currentRemaining) {
        final payload = {'remainingAmount': amount};

        final response = await http.put(
          Uri.parse(
            'http://187.127.146.52:2003/api/vendors/updatemonthlypaymnet/${widget.booking.id}/${widget.payment.id}',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          _showSuccessAnimation();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  paymentType == "full"
                      ? 'Payment completed successfully! ✨'
                      : 'Partial payment of ₹${_formatAmount(amount)} updated! ✨',
                ),
                backgroundColor: Colors.green,
              ),
            );

            widget.onUpdate();

            Future.delayed(const Duration(milliseconds: 1600), () {
              if (mounted) Navigator.pop(context);
            });
          }
        } else {
          // Try to parse error response
          String errorMsg = 'Failed to update payment';
          try {
            final errorResponse = jsonDecode(response.body);
            errorMsg = errorResponse['message'] ?? errorMsg;
          } catch (e) {
            // Ignore parse error
          }
          throw Exception(errorMsg);
        }
      } else {
        final payload = {
          'amount': amount,
          'status': paymentType == "full" ? "paid" : "partial",
          'date': DateTime.now().toIso8601String().split('T')[0],
          'remainingAmount': remainingAmount,
        };

        final response = await http.put(
          Uri.parse(
            'http://187.127.146.52:2003/api/vendors/updatemonthlypaymnet/${widget.booking.id}/${widget.payment.id}',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          _showSuccessAnimation();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  paymentType == "full"
                      ? 'Payment completed successfully! ✨'
                      : 'Partial payment of ₹${_formatAmount(amount)} updated! ✨',
                ),
                backgroundColor: Colors.green,
              ),
            );

            widget.onUpdate();

            Future.delayed(const Duration(milliseconds: 1600), () {
              if (mounted) Navigator.pop(context);
            });
          }
        } else {
          // Try to parse error response
          String errorMsg = 'Failed to update payment';
          try {
            final errorResponse = jsonDecode(response.body);
            errorMsg = errorResponse['message'] ?? errorMsg;
          } catch (e) {
            // Ignore parse error
          }
          throw Exception(errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayRemaining = _getRemainingAmount();
    double totalAmount = _getTotalAmount();
    bool isPendingWithZero =
        widget.payment.status.toLowerCase() == 'pending' &&
        (widget.payment.remainingAmount == null ||
            (widget.payment.remainingAmount is int &&
                widget.payment.remainingAmount == 0) ||
            (widget.payment.remainingAmount is double &&
                widget.payment.remainingAmount == 0) ||
            (widget.payment.remainingAmount is String &&
                double.tryParse(widget.payment.remainingAmount) == 0));

    // Don't show edit screen if payment status is paid and remaining is 0
    if (widget.payment.status.toLowerCase() == 'paid' &&
        displayRemaining == 0) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          centerTitle: true,
          title: Text(
            'Payment Details - ${widget.booking.userId?.name ?? 'Tenant'}',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Payment Already Completed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This payment has been fully paid',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Edit Payment - ${widget.booking.userId?.name ?? 'Tenant'}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Current Payment Status Card
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isPendingWithZero
                          ? [Colors.red.shade50, Colors.red.shade100]
                          : (widget.payment.status.toLowerCase() == 'paid'
                                ? [Colors.green.shade50, Colors.green.shade100]
                                : [
                                    Colors.orange.shade50,
                                    Colors.orange.shade100,
                                  ]),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPendingWithZero
                          ? Colors.red
                          : (widget.payment.status.toLowerCase() == 'paid'
                                ? Colors.green
                                : Colors.orange),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isPendingWithZero
                              ? Colors.red.withOpacity(0.2)
                              : (widget.payment.status.toLowerCase() == 'paid'
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPendingWithZero
                              ? Icons.error_outline
                              : (widget.payment.status.toLowerCase() == 'paid'
                                    ? Icons.check_circle
                                    : Icons.pending),
                          color: isPendingWithZero
                              ? Colors.red
                              : (widget.payment.status.toLowerCase() == 'paid'
                                    ? Colors.green
                                    : Colors.orange),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPendingWithZero
                                  ? 'Payment Required'
                                  : 'Current Payment Status',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPendingWithZero
                                  ? 'PENDING - NO PAYMENT YET'
                                  : widget.payment.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPendingWithZero
                                    ? Colors.red
                                    : (widget.payment.status.toLowerCase() ==
                                              'paid'
                                          ? Colors.green
                                          : Colors.orange),
                              ),
                            ),
                            if (displayRemaining > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Amount Due: ₹${_formatAmount(displayRemaining)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ],
                            if (isPendingWithZero) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Total Booking Amount: ₹${_formatAmount(totalAmount)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _ViewField(
                  controller: _totalAmountCtrl,
                  hint: 'Total Amount',
                  keyboardType: TextInputType.number,
                  icon: Icons.currency_rupee,
                  enabled: false,
                ),
                const SizedBox(height: 16),

                _ViewField(
                  controller: _remainingAmountCtrl,
                  hint: 'Due Amount',
                  keyboardType: TextInputType.number,
                  icon: Icons.currency_rupee,
                  enabled: false,
                ),
                const SizedBox(height: 32),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Update Payment",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.payment.status.toLowerCase() != 'paid') ...[
                      Row(
                        children: [
                          Radio<String>(
                            value: "full",
                            groupValue: paymentType,
                            onChanged: (value) {
                              setState(() {
                                paymentType = value!;
                              });
                            },
                          ),
                          const Text("Complete Payment"),
                          const SizedBox(width: 24),
                          Radio<String>(
                            value: "partial",
                            groupValue: paymentType,
                            onChanged: (value) {
                              setState(() {
                                paymentType = value!;
                              });
                            },
                          ),
                          const Text("Partial Payment"),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (paymentType == "partial")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter Payment Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              prefixIcon: const Icon(
                                Icons.currency_rupee,
                                size: 20,
                                color: Color(0xFFE53935),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE53935),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Max: ₹${_formatAmount(displayRemaining)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Min: ₹1',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    if (paymentType == "full" &&
                        widget.payment.status.toLowerCase() != 'paid')
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This will mark the payment as complete with full amount of ₹${_formatAmount(displayRemaining)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updatePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF80500),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Update Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Success Animation Overlay
          if (_animationController.isAnimating)
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Updated!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Successfully processed',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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

class TransferPopup extends StatefulWidget {
  final String tenantName;
  final String currentRoom;
  final String bookingId;
  final VoidCallback onTransferComplete;

  const TransferPopup({
    super.key,
    required this.tenantName,
    required this.currentRoom,
    required this.bookingId,
    required this.onTransferComplete,
  });

  @override
  State<TransferPopup> createState() => _TransferPopupState();
}

class _TransferPopupState extends State<TransferPopup> {
  final TextEditingController _roomController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _transferRoom() async {
    final newRoomNo = _roomController.text.trim();

    if (newRoomNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room number'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (newRoomNo == widget.currentRoom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New room number is same as current room'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/changebookingroomno/${widget.bookingId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomNo': newRoomNo}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.tenantName} transferred from Room ${widget.currentRoom} to Room $newRoomNo',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the history
          widget.onTransferComplete();
        }
      } else {
        throw Exception('Failed to transfer room');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error transferring room: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              'Enter New Room Number',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter room number',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.meeting_room,
                  size: 20,
                  color: Color(0xFFE53935),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE53935),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _transferRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80500),
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Transfer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TenantViewScreen extends StatelessWidget {
  final Booking booking;
  final VoidCallback onUpdate;

  const TenantViewScreen({
    super.key,
    required this.booking,
    required this.onUpdate,
  });

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  String _formatDateFromString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr.split('T')[0];
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'overdue':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _navigateToEditPayment(BuildContext context, PaymentHistory payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPaymentScreen(
          booking: booking,
          payment: payment,
          onUpdate: () {
            // Trigger refresh after update
            onUpdate();
            // Pop back to history screen after update
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _navigateToAddFirstPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFirstPaymentScreen(
          booking: booking,
          onUpdate: () {
            // Trigger refresh after update
            onUpdate();
            // Pop back to history screen after update
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(
                  booking.currentMonthPaymentStatus,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getPaymentStatusColor(
                    booking.currentMonthPaymentStatus,
                  ).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    booking.currentMonthPaymentStatus?.toLowerCase() == 'paid'
                        ? Icons.check_circle
                        : Icons.pending,
                    color: _getPaymentStatusColor(
                      booking.currentMonthPaymentStatus,
                    ),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Month Payment Status',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          booking.currentMonthPaymentStatus?.toUpperCase() ??
                              'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getPaymentStatusColor(
                              booking.currentMonthPaymentStatus,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Payment History Section
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Payment History',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Show Add First Payment button only when payment history is empty
                if (booking.paymentHistory.isEmpty)
                  IconButton(
                    onPressed: () => _navigateToAddFirstPayment(context),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF4CAF50),
                      size: 28,
                    ),
                    tooltip: 'Add First Payment',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (booking.paymentHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.payment_outlined,
                      size: 48,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No payment records found',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add first payment',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Payment History Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Remaining',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                          SizedBox(width: 40),
                        ],
                      ),
                    ),
                    // Payment History List
                    ...booking.paymentHistory.map((payment) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatDateFromString(payment.date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${payment.amount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: payment.status == 'paid'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  payment.status.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: payment.status == 'paid'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                payment.remainingAmount > 0
                                    ? '₹${payment.remainingAmount}'
                                    : '₹0',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: payment.remainingAmount > 0
                                      ? const Color(0xFFE53935)
                                      : Colors.green,
                                ),
                              ),
                            ),
                            // Edit Button - Only show if payment status is not 'paid'
                            if (payment.status.toLowerCase() != 'paid')
                              IconButton(
                                onPressed: () =>
                                    _navigateToEditPayment(context, payment),
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFFFF9800),
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                splashRadius: 20,
                              )
                            else
                              const SizedBox(width: 40),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

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

class _ViewField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final IconData icon;
  final bool enabled;

  const _ViewField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        fontSize: 14,
        color: enabled ? Colors.black87 : Colors.black54,
      ),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
    );
  }
}
