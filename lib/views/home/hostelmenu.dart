import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HostelBookingScreen extends StatefulWidget {
  const HostelBookingScreen({super.key});

  @override
  State<HostelBookingScreen> createState() => _HostelBookingScreenState();
}

class _HostelBookingScreenState extends State<HostelBookingScreen> {
  // API Endpoint
  final String apiUrl =
      'http://187.127.146.52:2003/api/vendors/vendor-bookingswithroomsno/6a04467a977db537414fb49a';

  // State variables
  bool isLoading = true;
  String errorMessage = '';

  // Data from API
  List<dynamic> allData = []; // data array
  List<dynamic> joiners = []; // joiners array
  List<dynamic> hostels = []; // unique hostels list
  int totalRooms = 0;
  Map<String, dynamic> summary = {};

  // Selected filters
  String selectedTab = 'ALL'; // ALL, NEW, PENDING, PARTIAL, PAID, VACATED
  String selectedHostelId = 'ALL';

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            allData = List.from(responseData['data'] ?? []);
            joiners = List.from(responseData['joiners'] ?? []);
            totalRooms = responseData['totalRooms'] ?? 0;
            summary = responseData['summary'] ?? {};

            // Extract unique hostels from the data
            extractUniqueHostels();

            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  void extractUniqueHostels() {
    Set<String> hostelIds = {};
    List<dynamic> uniqueHostels = [];

    // Extract from data array
    for (var room in allData) {
      for (var booking in room['bookings'] ?? []) {
        if (booking['hostelId'] != null && booking['hostelId']['_id'] != null) {
          String hostelId = booking['hostelId']['_id'];
          if (!hostelIds.contains(hostelId)) {
            hostelIds.add(hostelId);
            uniqueHostels.add({
              '_id': hostelId,
              'name': booking['hostelId']['name'] ?? 'Unknown',
            });
          }
        }
      }
    }

    // Also extract from joiners
    for (var joiner in joiners) {
      if (joiner['hostelId'] != null && joiner['hostelId']['_id'] != null) {
        String hostelId = joiner['hostelId']['_id'];
        if (!hostelIds.contains(hostelId)) {
          hostelIds.add(hostelId);
          uniqueHostels.add({
            '_id': hostelId,
            'name': joiner['hostelId']['name'] ?? 'Unknown',
          });
        }
      }
    }

    hostels = uniqueHostels;
  }

  // Filter data based on selected tab and hostel
  List<dynamic> getFilteredRooms() {
    List<dynamic> filteredRooms = [];

    // First filter by tab
    if (selectedTab == 'ALL') {
      filteredRooms = List.from(allData);
    } else if (selectedTab == 'NEW') {
      // NEW means only joiners array - convert joiners to room format
      return convertJoinersToRooms();
    } else if (selectedTab == 'VACATED') {
      // Filter rooms where status is vacated
      filteredRooms = allData.where((room) {
        bool hasVacatedBooking = false;
        for (var booking in room['bookings'] ?? []) {
          if (booking['status'] == 'vacated') {
            hasVacatedBooking = true;
            break;
          }
        }
        return hasVacatedBooking;
      }).toList();
    } else {
      // PENDING, PARTIAL, PAID - based on currentMonthPaymentStatus
      filteredRooms = allData
          .map((room) {
            Map<String, dynamic> newRoom = Map.from(room);
            List<dynamic> filteredBookings = (room['bookings'] ?? []).where((
              booking,
            ) {
              String paymentStatus =
                  booking['currentMonthPaymentStatus'] ?? 'pending';
              if (selectedTab == 'PENDING') {
                return paymentStatus == 'pending';
              } else if (selectedTab == 'PARTIAL') {
                return paymentStatus == 'partial';
              } else if (selectedTab == 'PAID') {
                return paymentStatus == 'paid';
              }
              return false;
            }).toList();
            newRoom['bookings'] = filteredBookings;
            return newRoom;
          })
          .where((room) => (room['bookings'] ?? []).isNotEmpty)
          .toList();
    }

    // Then filter by hostel
    if (selectedHostelId != 'ALL' && filteredRooms.isNotEmpty) {
      filteredRooms = filteredRooms.where((room) {
        for (var booking in room['bookings'] ?? []) {
          if (booking['hostelId'] != null &&
              booking['hostelId']['_id'] == selectedHostelId) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    return filteredRooms;
  }

  // Convert joiners to room format for NEW tab
  List<dynamic> convertJoinersToRooms() {
    Map<String, Map<String, dynamic>> roomMap = {};

    for (var joiner in joiners) {
      String roomNo = joiner['roomNo'] ?? 'Unassigned';

      if (!roomMap.containsKey(roomNo)) {
        roomMap[roomNo] = {
          'roomNo': roomNo,
          'totalBookings': 0,
          'bookings': [],
          'totalMembers': 0,
          'availableBeds': 0,
          'maxCapacity': 2,
        };
      }

      roomMap[roomNo]!['bookings'].add(joiner);
      roomMap[roomNo]!['totalBookings'] = roomMap[roomNo]!['bookings'].length;
      roomMap[roomNo]!['totalMembers'] = roomMap[roomNo]!['bookings'].length;
      roomMap[roomNo]!['availableBeds'] =
          (roomMap[roomNo]!['maxCapacity'] as int) -
          roomMap[roomNo]!['bookings'].length;
    }

    return roomMap.values.toList();
  }

  // Search filter
  String searchQuery = '';

  List<dynamic> getSearchedAndFilteredRooms() {
    List<dynamic> filtered = getFilteredRooms();

    if (searchQuery.isEmpty) {
      return filtered;
    }

    return filtered.where((room) {
      // Search by room number
      if (room['roomNo'].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      )) {
        return true;
      }

      // Search by booking personal details
      for (var booking in room['bookings'] ?? []) {
        String name = booking['personalDetails']?['name'] ?? '';
        String mobile =
            booking['personalDetails']?['mobileNumber']?.toString() ?? '';
        String bookingRef = booking['bookingReference'] ?? '';

        if (name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            mobile.contains(searchQuery) ||
            bookingRef.toLowerCase().contains(searchQuery.toLowerCase())) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  // Get status color based on payment status
  Color getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'partial':
        return Colors.blue;
      case 'vacated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Format date
  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Hostel Booking Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchBookings),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchBookings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabButton('ALL'),
                        _buildTabButton('NEW'),
                        _buildTabButton('PENDING'),
                        _buildTabButton('PARTIAL'),
                        _buildTabButton('PAID'),
                        _buildTabButton('VACATED'),
                      ],
                    ),
                  ),
                ),

                // Horizontal Hostel List
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildHostelChip('ALL', 'ALL'),
                      ...hostels.map(
                        (hostel) => _buildHostelChip(
                          hostel['name'] ?? 'Unknown',
                          hostel['_id'],
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by Room No, Name, Mobile or Booking ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),

                // Rooms List
                Expanded(
                  child: getSearchedAndFilteredRooms().isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hotel_class,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No bookings found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: getSearchedAndFilteredRooms().length,
                          itemBuilder: (context, index) {
                            final room = getSearchedAndFilteredRooms()[index];
                            return _buildRoomCard(room);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildHostelChip(String label, String hostelId) {
    final isSelected = selectedHostelId == hostelId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedHostelId = selected ? hostelId : 'ALL';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final roomNo = room['roomNo'] ?? 'N/A';
    final totalMembers = room['totalMembers'] ?? 0;
    final availableBeds = room['availableBeds'] ?? 0;
    final maxCapacity = room['maxCapacity'] ?? 2;
    final bookings = room['bookings'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.meeting_room,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room $roomNo',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalMembers member${totalMembers != 1 ? 's' : ''} • '
                          '$availableBeds bed${availableBeds != 1 ? 's' : ''} available • '
                          'Max $maxCapacity',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: availableBeds > 0
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    availableBeds > 0 ? '${availableBeds} Available' : 'Full',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: availableBeds > 0
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bookings List
          ...bookings.map((booking) => _buildBookingCard(booking)),

          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No bookings in this room',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final personalDetails = booking['personalDetails'] ?? {};
    final name = personalDetails['name'] ?? 'N/A';
    final mobile = personalDetails['mobileNumber']?.toString() ?? 'N/A';
    final emergencyNumber =
        personalDetails['emergencyNumber']?.toString() ?? 'N/A';
    final profileImage = personalDetails['profileImage'];
    final bookingRef = booking['bookingReference'] ?? 'N/A';
    final bookingType = booking['bookingType'] ?? 'N/A';
    final totalAmount = booking['totalAmount'] ?? 0;
    final monthlyAdvance = booking['monthlyAdvance'] ?? 0;
    final status = booking['status'] ?? 'N/A';
    final paymentStatus = booking['currentMonthPaymentStatus'] ?? 'pending';
    final startDate = booking['startDate'];
    final shareType = booking['shareType'] ?? 'N/A';
    final roomType = booking['roomType'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(
                              profileImage,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📱 $mobile',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(paymentStatus),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // Booking Details
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildDetailChip(Icons.confirmation_num, 'Ref: $bookingRef'),
              _buildDetailChip(
                Icons.calendar_today,
                'From: ${formatDate(startDate)}',
              ),
              _buildDetailChip(Icons.bed, '$shareType • $roomType'),
              _buildDetailChip(Icons.currency_rupee, '₹$totalAmount'),
              _buildDetailChip(Icons.money, 'Advance: ₹$monthlyAdvance'),
              _buildDetailChip(Icons.payment, 'Booked: $bookingType'),
            ],
          ),

          const SizedBox(height: 8),

          // Status Row
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusIndicator(
                  'Booking',
                  status,
                  status == 'running' ? Colors.green : Colors.red,
                ),
                _buildStatusIndicator(
                  'Emergency',
                  emergencyNumber,
                  Colors.orange,
                ),
                _buildStatusIndicator(
                  'Monthly Adv',
                  booking['monthlyAdvanceStatus'] ?? 'N/A',
                  booking['monthlyAdvanceStatus'] == 'paid'
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
          ),

          // Documents Section (if available)
          if (booking['documents'] != null &&
              ((booking['documents']['aadhar'] ?? []).isNotEmpty ||
                  (booking['documents']['idCard'] ?? []).isNotEmpty))
            const SizedBox(height: 8),
          if (booking['documents'] != null &&
              ((booking['documents']['aadhar'] ?? []).isNotEmpty ||
                  (booking['documents']['idCard'] ?? []).isNotEmpty))
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if ((booking['documents']['aadhar'] ?? []).isNotEmpty)
                    _buildDocumentChip(
                      'Aadhar',
                      (booking['documents']['aadhar'] as List).length,
                    ),
                  if ((booking['documents']['idCard'] ?? []).isNotEmpty)
                    _buildDocumentChip(
                      'ID Card',
                      (booking['documents']['idCard'] as List).length,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentChip(String title, int count) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            '$title ($count)',
            style: TextStyle(fontSize: 11, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }
}
