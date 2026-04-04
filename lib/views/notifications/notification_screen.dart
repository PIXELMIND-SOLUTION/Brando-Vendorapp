import 'dart:convert';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationModel {
  final String id;
  final String message;
  final String type;
  bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      message: json['message'],
      type: json['type'],
      read: json['read'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const String _baseUrl = 'http://31.97.206.144:2003/api/vendors';

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vendorId = await SharedPreferenceHelper.getVendorId();
      final token = await SharedPreferenceHelper.getToken();

      if (vendorId == null) {
        setState(() {
          _errorMessage = 'Vendor ID not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );


      
      print('Response status code for get allllllll notifications ${response.statusCode}');
            print('Response  bodddddddyyyyyyyy for gett allllllllll notifications ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List list = data['notifications'] ?? [];
          setState(() {
            _notifications =
                list.map((e) => NotificationModel.fromJson(e)).toList();
          });
        } else {
          setState(() => _errorMessage = 'Failed to load notifications.');
        }
      } else {
        setState(() => _errorMessage = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Deletes a single notification by its ID
  Future<void> _deleteSingle(String id) async {
    try {
      final vendorId = await SharedPreferenceHelper.getVendorId();
      final token = await SharedPreferenceHelper.getToken();

      final response = await http.delete(
        Uri.parse('$_baseUrl/deletenotifications/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'notifications': [id]}),
      );

      print('Response status code for delete notifications ${response.statusCode}');
            print('Response  bodddddddyyyyyyyy for delete notifications ${response.body}');


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() => _notifications.removeWhere((n) => n.id == id));
          _showSnackBar('Notification deleted.', isError: false);
        } else {
          _showSnackBar('Failed to delete notification.');
          _fetchNotifications(); // re-sync on failure
        }
      } else {
        _showSnackBar('Server error: ${response.statusCode}');
        _fetchNotifications();
      }
    } catch (e) {
      _showSnackBar('Network error. Please try again.');
      _fetchNotifications();
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'error':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: Icon(Icons.arrow_back_ios)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_rounded,
                size: 70, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final color = _typeColor(notification.type);

          return Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_rounded, color: Colors.white, size: 26),
                  SizedBox(height: 4),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (_) async {
              await _deleteSingle(notification.id);
              return false; 
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(_typeIcon(notification.type),
                          color: color, size: 26),
                    ),
                    if (!notification.read)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: notification.read
                        ? FontWeight.w400
                        : FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notification.type,
                          style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Direct delete button on the trailing side
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 22),
                  tooltip: 'Delete',
                  onPressed: () => _deleteSingle(notification.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}