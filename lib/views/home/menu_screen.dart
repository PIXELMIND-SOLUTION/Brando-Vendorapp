import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:brando_vendor/model/history_model.dart';
import 'package:brando_vendor/provider/history/history_provider.dart';
import 'package:brando_vendor/views/home/analysis.dart';
import 'package:brando_vendor/views/navbar/navbar_screen.dart';
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

enum ViewMode { history, joiners }

// Add a new widget for running joiners (simplified version)
class _RunningJoinerCard extends StatelessWidget {
  final Booking joiner;

  const _RunningJoinerCard({required this.joiner});

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  Future<void> _makeCall(BuildContext context) async {
    if (joiner.personalDetails != null) {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: joiner.personalDetails!.mobileNumber.toString(),
      );
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not call ${joiner.personalDetails!.mobileNumber}',
            ),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalDetails = joiner.personalDetails;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                if (personalDetails?.profileImage != null &&
                    personalDetails!.profileImage.isNotEmpty)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        personalDetails.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personalDetails?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Room: ${joiner.roomNo}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      onTap: () => _makeCall(context),
                      icon: Icons.phone,
                      color: Colors.green,
                      label: '',
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'RUNNING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinerCard extends StatelessWidget {
  final Booking joiner;

  const _JoinerCard({required this.joiner});

  String _getFormattedDate(DateTime dt) {
    return '${_getMonthName(dt.month)} ${dt.day}, ${dt.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final personalDetails = joiner.personalDetails;
    final userdata = joiner.userId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Mobile Number
            Row(
              children: [
                const Icon(Icons.phone, size: 15, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final phoneNumber =
                          (personalDetails?.mobileNumber
                                  ?.toString()
                                  .trim()
                                  .isNotEmpty ??
                              false)
                          ? personalDetails!.mobileNumber.toString()
                          : (userdata?.mobileNumber?.toString() ?? '');

                      if (phoneNumber.isNotEmpty) {
                        final Uri phoneUri = Uri(
                          scheme: 'tel',
                          path: phoneNumber,
                        );

                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        }
                      }
                    },
                    child: Text(
                      (personalDetails?.mobileNumber
                                  ?.toString()
                                  .trim()
                                  .isNotEmpty ??
                              false)
                          ? personalDetails!.mobileNumber.toString()
                          : (userdata?.mobileNumber?.toString() ?? ''),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.people_outline, size: 15, color: Colors.grey),
                const SizedBox(width: 6),
                const Text(
                  'Share Type',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFE0E0)),
                  ),
                  child: Text(
                    joiner.shareType,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE53935),
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

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? vendorId;
  final RefreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0 = Bookings, 1 = Vacancies

  List<Booking> _joiners = []; // Add this for joiners data
  bool _isLoadingJoiners = false;

  // Add these with your other variables (around line 110)
  List<String> _hostelShareTypes = [];
  String _selectedShareType = '';
  // Filter fields
  String _selectedPaymentStatus = 'all'; // all, pending, partial, paid
  String? _selectedHostelId;
  String _selectedRoomStatus = 'all';
  String _selectedRoomNo = '';

  // Data for dropdowns
  List<String> _hostels = []; // List of hostel names with IDs
  Map<String, String> _hostelIdToName = {};

  // For Vacancies tab
  List<Map<String, dynamic>> _vacancyHostels = [];
  String? _selectedVacancyHostelId;
  String? _selectedVacancyShareType;
  List<String> _vacancyShareTypes = [];
  List<Map<String, dynamic>> _vacanciesList = [];
  bool _isLoadingVacancies = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadVendorAndFetchHistory());
  }

  void _extractShareTypesForSelectedHostel(String? hostelId) {
    setState(() {
      _hostelShareTypes = [];
      _selectedShareType = '';
    });

    if (hostelId == null || hostelId.isEmpty) {
      return;
    }

    final provider = Provider.of<HistoryProvider>(context, listen: false);
    Set<String> shareTypes = {};

    for (var roomData in provider.bookings) {
      for (var booking in roomData.bookings) {
        if (booking.hostelId?.id == hostelId) {
          if (booking.shareType.isNotEmpty) {
            shareTypes.add(booking.shareType);
          }
        }
      }
    }

    final joinersList = provider.joiners ?? [];
    for (var joiner in joinersList) {
      if (joiner.hostelId?.id == hostelId) {
        if (joiner.shareType.isNotEmpty) {
          shareTypes.add(joiner.shareType);
        }
      }
    }

    setState(() {
      _hostelShareTypes = shareTypes.toList();
      _hostelShareTypes.sort();
    });
  }

  // ============================================================
  // FIX 1: In _buildJoinersList — replace ListView.builder with Column
  // The ListView inside a Column without shrinkWrap causes blank/invisible content
  // ============================================================

  // Widget _buildJoinersList(List<Booking> joiners) {
  //   // Group joiners by room number
  //   Map<String, List<Booking>> groupedByRoom = {};

  //   for (var joiner in joiners) {
  //     // FIX: Use null-safe check — roomNo can be null from API
  //     String roomKey =
  //         (joiner.roomNo == null ||
  //             joiner.roomNo.toString().isEmpty ||
  //             joiner.roomNo.toString() == 'null')
  //         ? 'Unassigned'
  //         : joiner.roomNo.toString();

  //     if (!groupedByRoom.containsKey(roomKey)) {
  //       groupedByRoom[roomKey] = [];
  //     }
  //     groupedByRoom[roomKey]!.add(joiner);
  //   }

  //   List<MapEntry<String, List<Booking>>> roomList = groupedByRoom.entries
  //       .toList();
  //   roomList.sort((a, b) {
  //     if (a.key == 'Unassigned') return 1;
  //     if (b.key == 'Unassigned') return -1;
  //     return a.key.compareTo(b.key);
  //   });

  //   // FIX: Use ListView with shrinkWrap instead of nested ListView.builder
  //   // OR wrap in Expanded + ListView at the top level
  //   return ListView.builder(
  //     // shrinkWrap: true is NOT needed here because this is the TOP-LEVEL
  //     // scrollable returned from the Expanded widget in build()
  //     itemCount: roomList.length,
  //     itemBuilder: (context, index) {
  //       String roomNo = roomList[index].key;
  //       List<Booking> roomJoiners = roomList[index].value;

  //       final firstJoiner = roomJoiners.first;
  //       final shareType = firstJoiner.shareType ?? '';
  //       final roomType = firstJoiner.roomType ?? '';

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Room Header
  //           Container(
  //             margin: const EdgeInsets.only(
  //               left: 16,
  //               right: 16,
  //               top: 8,
  //               bottom: 4,
  //             ),
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFFE53935).withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(
  //                 color: const Color(0xFFE53935).withOpacity(0.3),
  //               ),
  //             ),
  //             child: Row(
  //               children: [
  //                 Text(
  //                   roomNo == 'Unassigned'
  //                       ? 'New booking without form submit'
  //                       : 'Room $roomNo',
  //                   style: const TextStyle(
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.bold,
  //                     color: Color(0xFFE53935),
  //                   ),
  //                 ),
  //                 if (roomNo != 'Unassigned') ...[
  //                   const SizedBox(width: 8),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 8,
  //                       vertical: 2,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: const Color(0xFFE53935).withOpacity(0.3),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       shareType,
  //                       style: const TextStyle(
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w500,
  //                         color: Color(0xFFE53935),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 8,
  //                       vertical: 2,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: const Color(0xFFE53935).withOpacity(0.3),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       roomType,
  //                       style: const TextStyle(
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w500,
  //                         color: Color(0xFFE53935),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //                 const Spacer(),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 8,
  //                     vertical: 4,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFFE53935),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   child: Text(
  //                     '${roomJoiners.length} ${roomJoiners.length == 1 ? 'Joiner' : 'Joiners'}',
  //                     style: const TextStyle(
  //                       fontSize: 11,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           // List of joiners
  //           // FIX: Use Column instead of ListView.builder here (already inside ListView above)
  //           Column(
  //             children: roomJoiners.map((joiner) {
  //               if (joiner.status.toLowerCase() == 'running') {
  //                 return _HistoryRow(
  //                   booking: joiner,
  //                   onRefresh: _refreshHistory,
  //                   showTransferIcon: _shouldShowTransferIcon(joiner),
  //                   isVacated: false,
  //                 );
  //               }
  //               return _JoinerCard(joiner: joiner);
  //             }).toList(),
  //           ),

  //           const SizedBox(height: 4),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildJoinersList(List<Booking> joiners) {
    // Group joiners by room number
    Map<String, List<Booking>> groupedByRoom = {};

    for (var joiner in joiners) {
      String roomKey =
          (joiner.roomNo == null ||
              joiner.roomNo.toString().isEmpty ||
              joiner.roomNo.toString() == 'null')
          ? 'Unassigned'
          : joiner.roomNo.toString();

      if (!groupedByRoom.containsKey(roomKey)) {
        groupedByRoom[roomKey] = [];
      }
      groupedByRoom[roomKey]!.add(joiner);
    }

    List<MapEntry<String, List<Booking>>> roomList = groupedByRoom.entries
        .toList();
    roomList.sort((a, b) {
      if (a.key == 'Unassigned') return 1;
      if (b.key == 'Unassigned') return -1;
      return a.key.compareTo(b.key);
    });

    return ListView.builder(
      itemCount: roomList.length,
      itemBuilder: (context, index) {
        String roomNo = roomList[index].key;
        List<Booking> roomJoiners = roomList[index].value;

        final firstJoiner = roomJoiners.first;
        final shareType = firstJoiner.shareType ?? '';
        final roomType = firstJoiner.roomType ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE53935).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Room Header (same style as pending/partial/paid tabs) ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE53935).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      size: 18,
                      color: Color(0xFFE53935),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      roomNo == 'Unassigned'
                          ? 'New booking without form submit'
                          : 'Room $roomNo',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    if (roomNo != 'Unassigned') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE53935).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          shareType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE53935).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          roomType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (roomNo != 'Unassigned')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getRoomStatus(
                            roomJoiners.length,
                            _getShareTypeNumber(shareType),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Joiner rows inside the container ──
              Column(
                children: roomJoiners.map((joiner) {
                  if (joiner.status.toLowerCase() == 'running') {
                    return _HistoryRow(
                      booking: joiner,
                      onRefresh: _refreshHistory,
                      showTransferIcon: _shouldShowTransferIcon(joiner),
                      isVacated: false,
                    );
                  }
                  return _JoinerCard(joiner: joiner);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // FIX 2: In _applyFiltersToCombined — fix null roomNo crash
  // ============================================================

  List<RoomBookingData> _applyFiltersToCombined(
    List<RoomBookingData> bookings,
  ) {
    List<RoomBookingData> filteredBookings = [];

    for (var roomData in bookings) {
      if (roomData.roomNo == "__NEW_JOINERS__") {
        List<Booking> filteredJoiners = [];

        for (var joiner in roomData.bookings) {
          bool matches = true;

          // FIX: Null-safe roomNo comparison
          String safeRoomNo = joiner.roomNo?.toString() ?? '';

          if (_selectedRoomNo.isNotEmpty) {
            if (safeRoomNo.isNotEmpty &&
                !safeRoomNo.toLowerCase().contains(
                  _selectedRoomNo.toLowerCase(),
                )) {
              matches = false;
            }
          }

          if (matches &&
              _selectedHostelId != null &&
              _selectedHostelId!.isNotEmpty) {
            if (joiner.hostelId?.id != _selectedHostelId) {
              matches = false;
            }
          }

          if (matches && _selectedShareType.isNotEmpty) {
            if ((joiner.shareType ?? '') != _selectedShareType) {
              matches = false;
            }
          }

          if (matches && _searchQuery.isNotEmpty) {
            bool nameMatch =
                joiner.personalDetails?.name?.toLowerCase().contains(
                  _searchQuery,
                ) ??
                false;
            bool mobileMatch =
                joiner.personalDetails?.mobileNumber
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery) ??
                false;

            if (!nameMatch && !mobileMatch) {
              matches = false;
            }
          }

          if (matches) {
            filteredJoiners.add(joiner);
          }
        }

        if (filteredJoiners.isNotEmpty) {
          filteredBookings.add(
            RoomBookingData(
              roomNo: "__NEW_JOINERS__",
              totalBookings: filteredJoiners.length,
              bookings: filteredJoiners,
            ),
          );
        }
        continue;
      }

      // Regular rooms — unchanged logic
      List<Booking> filteredRoomBookings = [];

      for (var booking in roomData.bookings) {
        bool matches = true;

        if (_selectedRoomNo.isNotEmpty) {
          if (!booking.roomNo.toLowerCase().contains(
            _selectedRoomNo.toLowerCase(),
          )) {
            matches = false;
          }
        }

        if (matches &&
            _selectedHostelId != null &&
            _selectedHostelId!.isNotEmpty) {
          if (booking.hostelId?.id != _selectedHostelId) {
            matches = false;
          }
        }

        if (matches && _selectedShareType.isNotEmpty) {
          if (booking.shareType != _selectedShareType) {
            matches = false;
          }
        }

        if (matches && _searchQuery.isNotEmpty) {
          bool nameMatch =
              booking.personalDetails?.name?.toLowerCase().contains(
                _searchQuery,
              ) ??
              false;
          bool mobileMatch =
              booking.personalDetails?.mobileNumber
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false;
          bool roomMatch = booking.roomNo.toLowerCase().contains(_searchQuery);
          bool refMatch = booking.bookingReference.toLowerCase().contains(
            _searchQuery,
          );

          if (!nameMatch && !roomMatch && !refMatch && !mobileMatch) {
            matches = false;
          }
        }

        if (matches && _selectedRoomStatus != 'all') {
          if (booking.status.toLowerCase() != _selectedRoomStatus) {
            matches = false;
          }
        }

        if (matches &&
            _selectedPaymentStatus != 'all' &&
            _selectedPaymentStatus != 'new' &&
            _selectedPaymentStatus != 'vacated') {
          String currentPayment =
              booking.currentMonthPaymentStatus?.toLowerCase() ?? 'pending';
          if (currentPayment != _selectedPaymentStatus) {
            matches = false;
          }
        }

        if (matches) {
          filteredRoomBookings.add(booking);
        }
      }

      if (filteredRoomBookings.isNotEmpty) {
        filteredBookings.add(
          RoomBookingData(
            roomNo: roomData.roomNo,
            totalBookings: filteredRoomBookings.length,
            bookings: filteredRoomBookings,
          ),
        );
      }
    }

    return filteredBookings;
  }

  // ============================================================
  // FIX 3: _buildOrganizedHistoryForCombined — the nested
  // ListView.builder returns a ListView inside another ListView.
  // Change the inner one to return a Column widget instead.
  // ============================================================

  Widget _buildOrganizedHistoryForCombined(List<RoomBookingData> bookings) {
    Map<String, Map<String, List<Booking>>> organizedData = {};

    for (var roomData in bookings) {
      for (var booking in roomData.bookings) {
        if (roomData.roomNo == "__NEW_JOINERS__") {
          if (!organizedData.containsKey("__NEW_JOINERS__")) {
            organizedData["__NEW_JOINERS__"] = {};
          }
          if (!organizedData["__NEW_JOINERS__"]!.containsKey(
            "__NEW_JOINERS__",
          )) {
            organizedData["__NEW_JOINERS__"]!["__NEW_JOINERS__"] = [];
          }
          organizedData["__NEW_JOINERS__"]!["__NEW_JOINERS__"]!.add(booking);
          continue;
        }

        String hostelId = booking.hostelId?.id ?? 'unknown';
        String hostelKey =
            '$hostelId|${booking.hostelId?.name ?? 'Unknown Hostel'}|${booking.hostelId?.address ?? ''}';

        if (!organizedData.containsKey(hostelKey)) {
          organizedData[hostelKey] = {};
        }

        // FIX: null-safe roomNo
        String roomKey =
            (booking.roomNo == null ||
                booking.roomNo.toString() == 'null' ||
                booking.roomNo.toString() == 'Unassigned' ||
                booking.roomNo.toString().isEmpty)
            ? 'Unassigned'
            : booking.roomNo.toString();

        if (!organizedData[hostelKey]!.containsKey(roomKey)) {
          organizedData[hostelKey]![roomKey] = [];
        }
        organizedData[hostelKey]![roomKey]!.add(booking);
      }
    }

    List<MapEntry<String, Map<String, List<Booking>>>> hostelList =
        organizedData.entries.toList();

    // FIX: Use CustomScrollView with SliverList so everything scrolls together
    return CustomScrollView(
      slivers: [
        for (var hostelEntry in hostelList)
          ..._buildHostelSliver(hostelEntry.key, hostelEntry.value),
      ],
    );
  }

  // Helper that returns slivers for one hostel section
  List<Widget> _buildHostelSliver(
    String hostelKey,
    Map<String, List<Booking>> roomsMap,
  ) {
    // New Joiners section
    if (hostelKey == "__NEW_JOINERS__") {
      final joinersList = roomsMap["__NEW_JOINERS__"] ?? [];
      return [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.person_add,
                  size: 16,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'New Joiners',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${joinersList.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // FIX: SliverList instead of nested ListView
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final joiner = joinersList[index];
            if (joiner.status.toLowerCase() == 'running') {
              return _HistoryRow(
                booking: joiner,
                onRefresh: _refreshHistory,
                showTransferIcon: _shouldShowTransferIcon(joiner),
                isVacated: false,
              );
            }
            return _JoinerCard(joiner: joiner);
          }, childCount: joinersList.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ];
    }

    // Regular hostel section
    return [
      SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          color: Colors.grey.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.business, size: 16, color: Color(0xFFE53935)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _parseHostelName(hostelKey),
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${roomsMap.length} Room${roomsMap.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final roomEntry = roomsMap.entries.elementAt(index);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE53935).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFE53935).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.meeting_room,
                        size: 18,
                        color: Color(0xFFE53935),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        roomEntry.key == 'Unassigned'
                            ? 'Unassigned'
                            : 'Room ${roomEntry.key}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      if (roomEntry.key != 'Unassigned' &&
                          roomEntry.value.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE53935).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            roomEntry.value.first.shareType ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE53935).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            roomEntry.value.first.roomType ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getRoomStatus(
                            roomEntry.value.length,
                            _getShareTypeNumber(
                              roomEntry.value.first.shareType ?? '',
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bookings list
                Column(
                  children: roomEntry.value.map((booking) {
                    return _HistoryRow(
                      booking: booking,
                      onRefresh: _refreshHistory,
                      showTransferIcon: _shouldShowTransferIcon(booking),
                      isVacated: false,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }, childCount: roomsMap.length),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ];
  }

  Widget _buildVacanciesUI(HistoryProvider provider) {
    // Fetch hostels when the tab is first shown
    if (_vacancyHostels.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchHostelsForVacancies();
      });
    }

    return Column(
      children: [
        // Hostel Dropdown
        if (_vacancyHostels.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Hostel Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedVacancyHostelId,
                        isExpanded: true,
                        hint: const Text(
                          'Select Hostel',
                          style: TextStyle(fontSize: 13),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Select Hostel',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          ..._vacancyHostels.map((hostel) {
                            return DropdownMenuItem<String>(
                              value: hostel['id'].toString(),
                              child: Text(
                                hostel['name'],
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedVacancyHostelId = value;
                            _selectedVacancyShareType = null;
                            _vacancyShareTypes = [];
                            _vacanciesList = [];
                          });
                          if (value != null) {
                            _fetchShareTypesForVacancyHostel(value);
                          }
                        },
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Share Type Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedVacancyShareType,
                        isExpanded: true,
                        hint: const Text(
                          'Share Type',
                          style: TextStyle(fontSize: 13),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'All Types',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          ..._vacancyShareTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedVacancyShareType = value;
                          });
                          if (_selectedVacancyHostelId != null) {
                            _fetchVacancies(_selectedVacancyHostelId!, value);
                          }
                        },
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Vacancies List
        Expanded(
          child: _isLoadingVacancies
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE53935)),
                )
              : _vacanciesList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 64,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedVacancyHostelId == null
                            ? 'Select a hostel to view vacancies'
                            : 'No vacancies available',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vacanciesList.length,
                  itemBuilder: (context, index) {
                    final room = _vacanciesList[index];
                    int vacancy = room['vacancies'] ?? 0;
                    int occupied = room['occupiedBeds'] ?? 0;
                    int total = room['totalCapacity'] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: vacancy > 0
                              ? const Color(0xFF4CAF50).withOpacity(0.3)
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Room Number Container
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: vacancy > 0
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                room['roomNo'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: vacancy > 0
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Room Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFE53935,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        room['shareType'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFE53935),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: vacancy > 0
                                            ? const Color(
                                                0xFF4CAF50,
                                              ).withOpacity(0.1)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$occupied/$total Occupied',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: vacancy > 0
                                              ? const Color(0xFF4CAF50)
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Room ${room['roomNo']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Vacancy Status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: vacancy > 0
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : const Color(0xFF9E9E9E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: vacancy > 0
                                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                                    : const Color(0xFF9E9E9E).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  vacancy > 0 ? '$vacancy' : '0',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: vacancy > 0
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  vacancy > 0
                                      ? vacancy == 1
                                            ? 'Vacancy'
                                            : 'Vacancies'
                                      : 'Full',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: vacancy > 0
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Add these helper methods to fetch data for vacancies

  Future<void> _fetchHostelsForVacancies() async {
    if (vendorId == null) return;

    setState(() {
      _isLoadingVacancies = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://187.127.146.52:2003/api/Admin/hostels/vendor/$vendorId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final hostels = data['hostels'] as List;
          setState(() {
            _vacancyHostels = hostels.map((hostel) {
              return {
                'id': hostel['_id'],
                'name': hostel['name'],
                'sharings': hostel['sharings'] ?? [],
              };
            }).toList();
            _isLoadingVacancies = false;
          });
        } else {
          setState(() {
            _isLoadingVacancies = false;
          });
        }
      } else {
        setState(() {
          _isLoadingVacancies = false;
        });
      }
    } catch (e) {
      print('Error fetching hostels: $e');
      setState(() {
        _isLoadingVacancies = false;
      });
    }
  }

  Future<void> _fetchShareTypesForVacancyHostel(String hostelId) async {
    setState(() {
      _isLoadingVacancies = true;
      _vacancyShareTypes = [];
    });

    try {
      // Find the hostel from our list
      final hostel = _vacancyHostels.firstWhere(
        (h) => h['id'] == hostelId,
        orElse: () => {},
      );

      if (hostel.isNotEmpty) {
        final sharings = hostel['sharings'] as List;
        final shareTypes = sharings
            .map((s) => s['shareType'] as String)
            .toSet()
            .toList();

        setState(() {
          _vacancyShareTypes = shareTypes;
          _isLoadingVacancies = false;
        });
      } else {
        setState(() {
          _isLoadingVacancies = false;
        });
      }
    } catch (e) {
      print('Error fetching share types: $e');
      setState(() {
        _isLoadingVacancies = false;
      });
    }
  }

  Future<void> _fetchVacancies(String hostelId, String? shareType) async {
    setState(() {
      _isLoadingVacancies = true;
    });

    try {
      String url =
          'http://187.127.146.52:2003/api/vendors/hostels/$hostelId/vacancies';
      if (shareType != null && shareType.isNotEmpty) {
        url += '?shareType=${Uri.encodeComponent(shareType)}';
      }

      print("lllllllllllllll$url");

      final response = await http.get(Uri.parse(url));
      print("lllllllllllllll${response.statusCode}");
      print("lllllllllllllll${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final vacancies = data['data']['vacancies'] as List? ?? [];
          setState(() {
            _vacanciesList = vacancies.map((room) {
              return {
                'roomNo': room['roomNo'],
                'shareType': room['shareType'],
                'totalCapacity': room['totalCapacity'],
                'occupiedBeds': room['occupiedBeds'],
                'vacancies': room['vacancies'],
                'status': room['status'],
              };
            }).toList();
            _isLoadingVacancies = false;
          });
        } else {
          setState(() {
            _vacanciesList = [];
            _isLoadingVacancies = false;
          });
        }
      } else {
        setState(() {
          _vacanciesList = [];
          _isLoadingVacancies = false;
        });
      }
    } catch (e) {
      print('Error fetching vacancies: $e');
      setState(() {
        _vacanciesList = [];
        _isLoadingVacancies = false;
      });
    }
  }

  // ============================================================
  // FIX 4: In _extractHostels — also extract from joiners list
  // so the hostel dropdown is populated for joiners too
  // ============================================================

  void _extractHostels(List<RoomBookingData> bookings) {
    Set<String> hostelSet = {};

    for (var roomData in bookings) {
      for (var booking in roomData.bookings) {
        String hostelId = booking.hostelId?.id ?? 'unknown';
        String hostelName = booking.hostelId?.name ?? 'Unknown Hostel';
        String hostelKey = '$hostelId|$hostelName';
        hostelSet.add(hostelKey);
      }
    }

    // FIX: Also extract from joiners
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    for (var joiner in (provider.joiners ?? [])) {
      String hostelId = joiner.hostelId?.id ?? 'unknown';
      String hostelName = joiner.hostelId?.name ?? 'Unknown Hostel';
      if (hostelId != 'unknown') {
        hostelSet.add('$hostelId|$hostelName');
      }
    }

    setState(() {
      _hostels = hostelSet.toList();
      _hostels.sort((a, b) {
        String nameA = a.split('|').length > 1 ? a.split('|')[1] : '';
        String nameB = b.split('|').length > 1 ? b.split('|')[1] : '';
        return nameA.compareTo(nameB);
      });

      _hostelIdToName = {};
      for (var hostel in _hostels) {
        List<String> parts = hostel.split('|');
        if (parts.length >= 2) {
          _hostelIdToName[parts[0]] = parts[1];
        }
      }
    });
  }

  // ============================================================
  // FIX 5: In _shouldShowTransferIcon — null-safe roomNo check
  // ============================================================

  bool _shouldShowTransferIcon(Booking booking) {
    String shareType = (booking.shareType ?? '').toLowerCase();
    String roomNo = booking.roomNo?.toString() ?? '';

    if (shareType.contains('bhk') ||
        shareType.contains('rk') ||
        roomNo == 'Unassigned' ||
        roomNo == 'null' ||
        roomNo.isEmpty) {
      return false;
    }
    return true;
  }

  // Add this helper method to display individual joiner cards
  Widget _buildJoinerCard(Booking joiner) {
    // For joiners with room number, show room-specific card
    if (joiner.roomNo != null &&
        joiner.roomNo!.isNotEmpty &&
        joiner.roomNo != 'null') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                ),
                child: ClipOval(
                  child:
                      joiner.personalDetails?.profileImage != null &&
                          joiner.personalDetails!.profileImage.isNotEmpty
                      ? Image.network(
                          joiner.personalDetails!.profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      joiner.personalDetails?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room: ${joiner.roomNo} | ${joiner.shareType}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hostel: ${joiner.hostelId?.name ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: joiner.status.toLowerCase() == 'running'
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  joiner.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: joiner.status.toLowerCase() == 'running'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // For joiners without room number (pending assignment)
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 30,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      joiner.personalDetails?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Room not assigned yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hostel: ${joiner.hostelId?.name ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
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
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSimpleShareTypeList() {
    // Sample data for demonstration
    final List<Map<String, dynamic>> roomData = [
      {'roomNo': '101', 'shareType': '2S', 'vacancy': 3},
      {'roomNo': '102', 'shareType': '2S', 'vacancy': 3},
      {'roomNo': '103', 'shareType': '2S', 'vacancy': 3},
      // Add more rooms as needed
    ];

    // If you want to filter based on actual data from your provider
    // You can use the filtered bookings data
    final provider = Provider.of<HistoryProvider>(context, listen: false);

    // Alternative: Extract real room data from bookings
    List<Map<String, dynamic>> realRoomData = [];

    if (_selectedHostelId != null && _selectedShareType.isNotEmpty) {
      // Group rooms by room number from actual bookings
      Map<String, int> roomCounts = {};
      Map<String, String> roomShareTypes = {};

      for (var roomData in provider.bookings) {
        for (var booking in roomData.bookings) {
          if (booking.hostelId?.id == _selectedHostelId &&
              booking.shareType == _selectedShareType) {
            String roomNo = booking.roomNo;
            if (roomNo.isNotEmpty && roomNo != 'Unassigned') {
              roomCounts[roomNo] = (roomCounts[roomNo] ?? 0) + 1;
              roomShareTypes[roomNo] = booking.shareType;
            }
          }
        }
      }

      // Add joiners data as well
      final joinersList = provider.joiners ?? [];
      for (var joiner in joinersList) {
        if (joiner.hostelId?.id == _selectedHostelId &&
            joiner.shareType == _selectedShareType) {
          String roomNo = joiner.roomNo;
          if (roomNo.isNotEmpty && roomNo != 'Unassigned') {
            roomCounts[roomNo] = (roomCounts[roomNo] ?? 0) + 1;
            roomShareTypes[roomNo] = joiner.shareType;
          }
        }
      }

      // Convert to list and calculate vacancies based on share type number
      for (var entry in roomCounts.entries) {
        int shareNumber = _getShareTypeNumber(_selectedShareType);
        int currentTenants = entry.value;
        int vacancies = shareNumber - currentTenants;

        realRoomData.add({
          'roomNo': entry.key,
          'shareType': _selectedShareType,
          'currentTenants': currentTenants,
          'vacancy': vacancies > 0 ? vacancies : 0,
          'status': currentTenants >= shareNumber
              ? 'Full'
              : '${vacancies} Vacanc${vacancies == 1 ? 'y' : 'ies'}',
        });
      }

      // Sort by room number
      realRoomData.sort((a, b) => a['roomNo'].compareTo(b['roomNo']));
    }

    // Use realRoomData if available, otherwise use sample data
    final displayData = realRoomData.isNotEmpty ? realRoomData : roomData;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: displayData.length,
      itemBuilder: (context, index) {
        final room = displayData[index];
        String vacancyText = room['vacancy'].toString();
        String statusText =
            room['status'] ??
            '$vacancyText Vacanc${vacancyText == '1' ? 'y' : 'ies'}';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Room Number Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    room['roomNo'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Room Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room['shareType'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (room.containsKey('currentTenants'))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${room['currentTenants']} Booked',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Room ${room['roomNo']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Vacancy Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: room['vacancy'] > 0
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : const Color(0xFF9E9E9E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: room['vacancy'] > 0
                        ? const Color(0xFF4CAF50).withOpacity(0.3)
                        : const Color(0xFF9E9E9E).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  room['vacancy'] > 0
                      ? '${room['vacancy']} Vacanc${room['vacancy'] == 1 ? 'y' : 'ies'}'
                      : 'Full',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: room['vacancy'] > 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  void _showFilterDialog() {
    String tempRoomNo = _selectedRoomNo;
    String tempRoomStatus = _selectedRoomStatus;

    TextEditingController roomNoController = TextEditingController(
      text: _selectedRoomNo,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.filter_list_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Filter Bookings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Room Number Filter
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: roomNoController,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Room Number',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                hintText: 'Enter room number',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.meeting_room,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: tempRoomNo.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          roomNoController.clear();
                                          setDialogState(() {
                                            tempRoomNo = '';
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setDialogState(() {
                                  tempRoomNo = value;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Room Status Filter
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: tempRoomStatus,
                              decoration: InputDecoration(
                                labelText: 'Room Status',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                prefixIcon: Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text('All Status'),
                                ),
                                DropdownMenuItem(
                                  value: 'running',
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF4CAF50),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Running'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'completed',
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF9E9E9E),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Completed'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'cancelled',
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE53935),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Cancelled'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  tempRoomStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setDialogState(() {
                                  tempRoomNo = '';
                                  tempRoomStatus = 'all';
                                  roomNoController.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE53935),
                                side: const BorderSide(
                                  color: Color(0xFFE53935),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedRoomNo = tempRoomNo;
                                  _selectedRoomStatus = tempRoomStatus;
                                });
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Filters applied successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<RoomBookingData> _applyFilters(List<RoomBookingData> bookings) {
    List<RoomBookingData> filteredBookings = [];

    for (var roomData in bookings) {
      List<Booking> filteredRoomBookings = [];

      for (var booking in roomData.bookings) {
        bool matches = true;

        // Room Number filter
        if (_selectedRoomNo.isNotEmpty) {
          if (!booking.roomNo.toLowerCase().contains(
            _selectedRoomNo.toLowerCase(),
          )) {
            matches = false;
          }
        }

        // Hostel filter
        if (matches && _selectedHostelId != null) {
          if (booking.hostelId?.id != _selectedHostelId) {
            matches = false;
          }
        }

        // Search text filter (name, mobile, room, reference)
        if (matches && _searchQuery.isNotEmpty) {
          bool nameMatch =
              booking.personalDetails?.name?.toLowerCase().contains(
                _searchQuery,
              ) ??
              false;
          bool mobileMatch =
              booking.personalDetails?.mobileNumber
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false;
          bool roomMatch = booking.roomNo.toLowerCase().contains(_searchQuery);
          bool refMatch = booking.bookingReference.toLowerCase().contains(
            _searchQuery,
          );

          if (!nameMatch && !roomMatch && !refMatch && !mobileMatch) {
            matches = false;
          }
        }

        // Room status filter
        if (matches && _selectedRoomStatus != 'all') {
          if (booking.status.toLowerCase() != _selectedRoomStatus) {
            matches = false;
          }
        }
        if (_selectedPaymentStatus != 'vacated') {
          if (booking.status.toLowerCase() == 'completed') {
            matches = false;
          }
        }
        // Payment status filter (from tab bar)
        if (matches && _selectedPaymentStatus != 'all') {
          String currentPayment =
              booking.currentMonthPaymentStatus?.toLowerCase() ?? 'pending';
          if (currentPayment != _selectedPaymentStatus) {
            matches = false;
          }
        }

        if (matches) {
          filteredRoomBookings.add(booking);
        }
      }

      if (filteredRoomBookings.isNotEmpty) {
        filteredBookings.add(
          RoomBookingData(
            roomNo: roomData.roomNo,
            totalBookings: filteredRoomBookings.length,
            bookings: filteredRoomBookings,
          ),
        );
      }
    }

    return filteredBookings;
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

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Bookings History'];

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

      for (int i = 0; i < headers.length; i++) {
        final cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.red,
          fontColorHex: ExcelColor.white,
        );
      }

      int rowIndex = 1;

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
            booking.personalDetails?.name ?? 'Unknown',
          );

          sheetObject
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            booking.personalDetails?.mobileNumber.toString() ?? 'N/A',
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

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/bookings_history_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final File file = File(filePath);

      List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
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

  // Update the existing _buildJoinersList method to handle both designs

  // Add this method to filter vacated (completed) bookings
  List<RoomBookingData> _filterVacatedBookings(List<RoomBookingData> bookings) {
    List<RoomBookingData> vacatedBookings = [];

    for (var roomData in bookings) {
      List<Booking> vacatedRoomBookings = [];

      for (var booking in roomData.bookings) {
        // Only include bookings with status 'completed'
        if (booking.status.toLowerCase() == 'completed') {
          // Apply other filters (hostel, search, room number)
          bool matches = true;

          // Room Number filter
          if (_selectedRoomNo.isNotEmpty) {
            if (!booking.roomNo.toLowerCase().contains(
              _selectedRoomNo.toLowerCase(),
            )) {
              matches = false;
            }
          }

          // Hostel filter
          if (matches && _selectedHostelId != null) {
            if (booking.hostelId?.id != _selectedHostelId) {
              matches = false;
            }
          }

          // Search text filter
          if (matches && _searchQuery.isNotEmpty) {
            bool nameMatch =
                booking.personalDetails?.name?.toLowerCase().contains(
                  _searchQuery,
                ) ??
                false;
            bool mobileMatch =
                booking.personalDetails?.mobileNumber
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery) ??
                false;
            bool roomMatch = booking.roomNo.toLowerCase().contains(
              _searchQuery,
            );
            bool refMatch = booking.bookingReference.toLowerCase().contains(
              _searchQuery,
            );

            if (!nameMatch && !roomMatch && !refMatch && !mobileMatch) {
              matches = false;
            }
          }

          if (matches) {
            vacatedRoomBookings.add(booking);
          }
        }
      }

      if (vacatedRoomBookings.isNotEmpty) {
        vacatedBookings.add(
          RoomBookingData(
            roomNo: roomData.roomNo,
            totalBookings: vacatedRoomBookings.length,
            bookings: vacatedRoomBookings,
          ),
        );
      }
    }

    return vacatedBookings;
  }

  List<Booking> _filterNewBookings(List<RoomBookingData> bookings) {
    List<Booking> newBookings = [];

    for (var roomData in bookings) {
      for (var booking in roomData.bookings) {
        // Check isNew field - it's a boolean true/false
        if (booking.isNew == true) {
          // Apply filters (hostel, share type, search, room number)
          bool matches = true;

          // Room Number filter
          if (_selectedRoomNo.isNotEmpty) {
            if (!booking.roomNo.toLowerCase().contains(
              _selectedRoomNo.toLowerCase(),
            )) {
              matches = false;
            }
          }

          // Hostel filter
          if (matches &&
              _selectedHostelId != null &&
              _selectedHostelId!.isNotEmpty) {
            if (booking.hostelId?.id != _selectedHostelId) {
              matches = false;
            }
          }

          // Share type filter
          if (matches && _selectedShareType.isNotEmpty) {
            if ((booking.shareType ?? '') != _selectedShareType) {
              matches = false;
            }
          }

          // Search text filter (name, mobile, room, reference)
          if (matches && _searchQuery.isNotEmpty) {
            bool nameMatch =
                booking.personalDetails?.name?.toLowerCase().contains(
                  _searchQuery,
                ) ??
                false;
            bool mobileMatch =
                booking.personalDetails?.mobileNumber
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery) ??
                false;
            bool roomMatch = booking.roomNo.toLowerCase().contains(
              _searchQuery,
            );
            bool refMatch = booking.bookingReference.toLowerCase().contains(
              _searchQuery,
            );

            if (!nameMatch && !roomMatch && !refMatch && !mobileMatch) {
              matches = false;
            }
          }

          if (matches) {
            newBookings.add(booking);
          }
        }
      }
    }

    return newBookings;
  }
  // // Add this method to build vacated history UI
  // Widget _buildVacatedHistory(List<RoomBookingData> bookings) {
  //   // Organize by hostel -> room bookings
  //   Map<String, List<RoomBookingData>> organizedData = {};

  //   for (var roomData in bookings) {
  //     for (var booking in roomData.bookings) {
  //       String hostelId = booking.hostelId?.id ?? 'unknown';
  //       String hostelKey =
  //           '$hostelId|${booking.hostelId?.name ?? 'Unknown Hostel'}|${booking.hostelId?.address ?? ''}';

  //       if (!organizedData.containsKey(hostelKey)) {
  //         organizedData[hostelKey] = [];
  //       }

  //       // Use a consistent key for unassigned rooms
  //       String roomKey =
  //           (booking.roomNo == null ||
  //               booking.roomNo == 'Unassigned' ||
  //               booking.roomNo.isEmpty)
  //           ? 'Unassigned'
  //           : booking.roomNo;

  //       // Check if roomData already exists for this room key
  //       bool roomExists = false;
  //       for (var existingRoom in organizedData[hostelKey]!) {
  //         String existingRoomKey =
  //             (existingRoom.roomNo == null ||
  //                 existingRoom.roomNo == 'Unassigned' ||
  //                 existingRoom.roomNo.isEmpty)
  //             ? 'Unassigned'
  //             : existingRoom.roomNo;
  //         if (existingRoomKey == roomKey) {
  //           roomExists = true;
  //           existingRoom.bookings.add(booking);
  //           existingRoom.totalBookings = existingRoom.bookings.length;
  //           break;
  //         }
  //       }

  //       if (!roomExists) {
  //         List<Booking> copiedBookings = [booking];
  //         String displayRoomNo =
  //             (booking.roomNo == null ||
  //                 booking.roomNo == 'Unassigned' ||
  //                 booking.roomNo.isEmpty)
  //             ? 'Unassigned'
  //             : booking.roomNo;
  //         organizedData[hostelKey]!.add(
  //           RoomBookingData(
  //             roomNo: displayRoomNo,
  //             totalBookings: copiedBookings.length,
  //             bookings: copiedBookings,
  //           ),
  //         );
  //       }
  //     }
  //   }

  //   // Convert to list for building
  //   List<MapEntry<String, List<RoomBookingData>>> hostelList = organizedData
  //       .entries
  //       .toList();

  //   return ListView.builder(
  //     itemCount: hostelList.length,
  //     itemBuilder: (context, hostelIndex) {
  //       String hostelKey = hostelList[hostelIndex].key;
  //       List<RoomBookingData> roomList = hostelList[hostelIndex].value;

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Hostel Header for Vacated section
  //           Container(
  //             width: double.infinity,
  //             color: Colors.grey.shade100,
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //             child: Row(
  //               children: [
  //                 const Icon(
  //                   Icons.business,
  //                   size: 16,
  //                   color: Color(0xFF9E9E9E),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     _parseHostelName(hostelKey),
  //                     style: const TextStyle(
  //                       color: Color(0xFF9E9E9E),
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 8,
  //                     vertical: 2,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF9E9E9E).withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   child: Text(
  //                     'VACATED',
  //                     style: const TextStyle(
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.w500,
  //                       color: Color(0xFF9E9E9E),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           // Rooms under this hostel
  //           for (var roomData in roomList)
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Room Header
  //                 if (roomData.roomNo != 'Unassigned' &&
  //                     roomData.roomNo.isNotEmpty)
  //                   Container(
  //                     width: double.infinity,
  //                     color: const Color(0xFFF5F5F5),
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 16,
  //                       vertical: 6,
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         const Icon(
  //                           Icons.meeting_room,
  //                           size: 14,
  //                           color: Color(0xFF9E9E9E),
  //                         ),
  //                         const SizedBox(width: 6),
  //                         Text(
  //                           'Room ${roomData.roomNo}',
  //                           style: const TextStyle(
  //                             color: Color(0xFF9E9E9E),
  //                             fontWeight: FontWeight.w500,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 8),
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 4,
  //                             vertical: 2,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             color: const Color(0xFF9E9E9E).withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           child: Text(
  //                             '${roomData.totalBookings}',
  //                             style: const TextStyle(
  //                               fontSize: 9,
  //                               fontWeight: FontWeight.w500,
  //                               color: Color(0xFF9E9E9E),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                 // Bookings for this room - using simplified card for vacated tenants
  //                 for (var booking in roomData.bookings)
  //                   _VacatedHistoryCard(booking: booking),
  //               ],
  //             ),

  //           const SizedBox(height: 8),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildVacatedHistory(List<RoomBookingData> bookings) {
    // Organize by hostel -> room bookings
    Map<String, List<RoomBookingData>> organizedData = {};

    for (var roomData in bookings) {
      for (var booking in roomData.bookings) {
        String hostelId = booking.hostelId?.id ?? 'unknown';
        String hostelKey =
            '$hostelId|${booking.hostelId?.name ?? 'Unknown Hostel'}|${booking.hostelId?.address ?? ''}';

        if (!organizedData.containsKey(hostelKey)) {
          organizedData[hostelKey] = [];
        }

        // Use a consistent key for unassigned rooms
        String roomKey =
            (booking.roomNo == null ||
                booking.roomNo == 'Unassigned' ||
                booking.roomNo.isEmpty)
            ? 'Unassigned'
            : booking.roomNo;

        // Check if roomData already exists for this room key
        bool roomExists = false;
        for (var existingRoom in organizedData[hostelKey]!) {
          String existingRoomKey =
              (existingRoom.roomNo == null ||
                  existingRoom.roomNo == 'Unassigned' ||
                  existingRoom.roomNo.isEmpty)
              ? 'Unassigned'
              : existingRoom.roomNo;
          if (existingRoomKey == roomKey) {
            roomExists = true;
            existingRoom.bookings.add(booking);
            existingRoom.totalBookings = existingRoom.bookings.length;
            break;
          }
        }

        if (!roomExists) {
          List<Booking> copiedBookings = [booking];
          String displayRoomNo =
              (booking.roomNo == null ||
                  booking.roomNo == 'Unassigned' ||
                  booking.roomNo.isEmpty)
              ? 'Unassigned'
              : booking.roomNo;
          organizedData[hostelKey]!.add(
            RoomBookingData(
              roomNo: displayRoomNo,
              totalBookings: copiedBookings.length,
              bookings: copiedBookings,
            ),
          );
        }
      }
    }

    // Convert to list for building
    List<MapEntry<String, List<RoomBookingData>>> hostelList = organizedData
        .entries
        .toList();

    return ListView.builder(
      itemCount: hostelList.length,
      itemBuilder: (context, hostelIndex) {
        String hostelKey = hostelList[hostelIndex].key;
        List<RoomBookingData> roomList = hostelList[hostelIndex].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hostel Header for Vacated section
            Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 16,
                    color: Color(0xFF9E9E9E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _parseHostelName(hostelKey),
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E9E9E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'VACATED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rooms under this hostel
            for (var roomData in roomList)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Header
                  if (roomData.roomNo != 'Unassigned' &&
                      roomData.roomNo.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFF5F5F5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.meeting_room,
                            size: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Room ${roomData.roomNo}',
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9E9E9E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${roomData.totalBookings}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bookings for this room - USING HISTORY ROW instead of VacatedHistoryCard
                  for (var booking in roomData.bookings)
                    _HistoryRow(
                      booking: booking,
                      onRefresh: _refreshHistory,
                      showTransferIcon:
                          false, // Don't show transfer for vacated tenants
                      isVacated: true,
                    ),
                ],
              ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = title == 'Bookings' ? 0 : 1;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE53935) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
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
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
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
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildTab('Bookings', _selectedTabIndex == 0),
                    _buildTab('Vacancies', _selectedTabIndex == 1),
                  ],
                ),
              ),

              // Payment Status Tab Bar
              if (_selectedTabIndex == 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildPaymentStatusTab('all', 'All'),
                        _buildPaymentStatusTab('new', 'New'),

                        _buildPaymentStatusTab('pending', 'Pending'),
                        _buildPaymentStatusTab('partial', 'Partial'),
                        _buildPaymentStatusTab('paid', 'Paid'),
                        _buildPaymentStatusTab('vacated', 'Vacated'),
                      ],
                    ),
                  ),
                ),

                // Horizontal Hostel List
                // Hostel and Share Type Dropdowns in same row
                if (_hostels.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Hostel Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedHostelId ?? 'all',
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFE53935),
                                  size: 20,
                                ),
                                hint: const Text(
                                  'Hostel',
                                  style: TextStyle(fontSize: 13),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All Hostels',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ..._hostels.map((hostelKey) {
                                    final parts = hostelKey.split('|');
                                    final hostelId = parts[0];
                                    final hostelName = parts.length > 1
                                        ? parts[1]
                                        : 'Unknown';
                                    return DropdownMenuItem(
                                      value: hostelId,
                                      child: Text(
                                        hostelName,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    if (value == 'all') {
                                      _selectedHostelId = null;
                                      _hostelShareTypes =
                                          []; // Clear share types
                                      _selectedShareType =
                                          ''; // Reset share type
                                    } else {
                                      _selectedHostelId = value;
                                      _extractShareTypesForSelectedHostel(
                                        value,
                                      ); // Extract share types for this hostel
                                    }
                                  });
                                },
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Share Type Dropdown
                        // Expanded(
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 4,
                        //       vertical: 2,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(color: Colors.grey.shade300),
                        //     ),
                        //     child: DropdownButtonHideUnderline(
                        //       child: DropdownButton<String>(
                        //         value: _selectedShareType.isEmpty
                        //             ? null
                        //             : _selectedShareType,
                        //         isExpanded: true,
                        //         icon: const Icon(
                        //           Icons.arrow_drop_down,
                        //           color: Color(0xFFE53935),
                        //           size: 20,
                        //         ),
                        //         hint: const Text(
                        //           'Share Type',
                        //           style: TextStyle(fontSize: 13),
                        //         ),
                        //         items: [
                        //           const DropdownMenuItem(
                        //             value: 'all',
                        //             child: Text(
                        //               'All Types',
                        //               style: TextStyle(fontSize: 13),
                        //             ),
                        //           ),
                        //           ..._hostelShareTypes.map((type) {
                        //             return DropdownMenuItem(
                        //               value: type,
                        //               child: Text(
                        //                 type,
                        //                 style: const TextStyle(fontSize: 13),
                        //               ),
                        //             );
                        //           }).toList(),
                        //         ],
                        //         onChanged: (value) {
                        //           setState(() {
                        //             _selectedShareType = value == 'all'
                        //                 ? ''
                        //                 : (value ?? '');
                        //           });
                        //           // Add your functionality here when share type is selected
                        //           print('Selected share type: $value');
                        //         },
                        //         dropdownColor: Colors.white,
                        //         style: const TextStyle(
                        //           color: Colors.black87,
                        //           fontSize: 13,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                // Search Bar with Filter Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Search by name, mobile, room or reference...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFFE53935),
                              size: 18,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE53935),
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   decoration: BoxDecoration(
              //     color: Colors.grey.shade100,
              //     borderRadius: BorderRadius.circular(30),
              //   ),
              //   child: Row(
              //     children: [
              //       _buildTab('Bookings', _selectedTabIndex == 0),
              //       _buildTab('Vacancies', _selectedTabIndex == 1),
              //     ],
              //   ),
              // ),

              // Update the build method where you check for _selectedPaymentStatus (around line 430-500)
              // Replace the condition for showing joiners and add condition for vacated:
              Expanded(
                child: RefreshIndicator(
                  key: RefreshIndicatorKey,
                  color: const Color(0xFFE53935),
                  onRefresh: _refreshHistory,
                  child: Consumer<HistoryProvider>(
                    builder: (context, provider, _) {
                      // if (provider.isLoading) {
                      //   return const Center(
                      //     child: CircularProgressIndicator(
                      //       color: Color(0xFFE53935),
                      //     ),
                      //   );
                      // }

                      // if (provider.hasError) {
                      //   return Center(
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         const Icon(
                      //           Icons.error_outline,
                      //           color: Color(0xFFE53935),
                      //           size: 48,
                      //         ),
                      //         const SizedBox(height: 12),
                      //         Text(
                      //           provider.errorMessage,
                      //           textAlign: TextAlign.center,
                      //           style: const TextStyle(
                      //             color: Colors.black54,
                      //             fontSize: 14,
                      //           ),
                      //         ),
                      //         const SizedBox(height: 16),
                      //         ElevatedButton(
                      //           onPressed: () {
                      //             if (vendorId != null && vendorId!.isNotEmpty) {
                      //               provider.fetchHistory(vendorId!);
                      //             }
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor: const Color(0xFFE53935),
                      //             foregroundColor: Colors.white,
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(8),
                      //             ),
                      //           ),
                      //           child: const Text('Retry'),
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      // }

                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE53935),
                          ),
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
                                  if (vendorId != null &&
                                      vendorId!.isNotEmpty) {
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

                      // ========== CHECK FOR VACANCIES TAB FIRST ==========
                      if (_selectedTabIndex == 1) {
                        // Show Vacancies UI
                        return _buildVacanciesUI(provider);
                      }

                      // Extract hostels when data is loaded
                      if (_hostels.isEmpty && provider.bookings.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _extractHostels(provider.bookings);
                        });
                      }

                      // Show joiners when "New" tab is selected
                      if (_selectedPaymentStatus == 'new') {
                        final newBookings = _filterNewBookings(
                          provider.bookings,
                        );
                        if (newBookings.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_add_disabled,
                                  size: 64,
                                  color: Colors.black26,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No pending join requests.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return _buildJoinersList(newBookings);
                      }

                      // Show vacated bookings when "Vacated" tab is selected
                      if (_selectedPaymentStatus == 'vacated') {
                        // Filter bookings with status 'completed'
                        final vacatedBookings = _filterVacatedBookings(
                          provider.bookings,
                        );

                        if (vacatedBookings.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  size: 64,
                                  color: Colors.black26,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No vacated tenants found.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return _buildVacatedHistory(vacatedBookings);
                      }

                      // FOR "ALL" TAB - Combine joiners with regular bookings
                      if (_selectedPaymentStatus == 'all') {
                        print("llllllllllll$_selectedPaymentStatus");
                        final joinersList = provider.joiners ?? [];
                        final regularBookings = provider.bookings;

                        // Create a combined list by converting joiners to match the structure
                        List<RoomBookingData> combinedBookings = List.from(
                          regularBookings,
                        );

                        if (joinersList.isNotEmpty) {
                          // Add joiners as a special "New Joiners" room
                          combinedBookings.add(
                            RoomBookingData(
                              roomNo: "__NEW_JOINERS__",
                              totalBookings: joinersList.length,
                              bookings: joinersList,
                            ),
                          );
                        }

                        // Filter based on other criteria (hostel, search, etc.)
                        final filteredCombined = _applyFiltersToCombined(
                          combinedBookings,
                        );

                        if (filteredCombined.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: Colors.black26,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No data available',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return _buildOrganizedHistoryForCombined(
                          filteredCombined,
                        );
                      }

                      // Check if a share type is selected
                      if (_selectedShareType.isNotEmpty) {
                        return _buildSimpleShareTypeList();
                      }

                      final filteredBookings = _applyFilters(provider.bookings);

                      if (filteredBookings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.filter_alt_off,
                                size: 64,
                                color: Colors.black26,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No results found',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedHostelId = null;
                                    _searchQuery = '';
                                    _selectedRoomStatus = 'all';
                                    _selectedPaymentStatus = 'all';
                                    _selectedRoomNo = '';
                                    _selectedShareType =
                                        ''; // Also reset share type
                                  });
                                },
                                child: const Text(
                                  'Clear filters',
                                  style: TextStyle(color: Color(0xFFE53935)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildOrganizedHistory(filteredBookings);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusTab(String status, String label) {
    final isSelected = _selectedPaymentStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPaymentStatus = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE53935) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizedHistory(List<RoomBookingData> bookings) {
    // Organize by hostel -> room bookings
    Map<String, Map<String, List<Booking>>> organizedData = {};

    for (var roomData in bookings) {
      for (var booking in roomData.bookings) {
        String hostelId = booking.hostelId?.id ?? 'unknown';
        String hostelKey =
            '$hostelId|${booking.hostelId?.name ?? 'Unknown Hostel'}|${booking.hostelId?.address ?? ''}';

        if (!organizedData.containsKey(hostelKey)) {
          organizedData[hostelKey] = {};
        }

        // Use a consistent key for unassigned rooms
        String roomKey =
            (booking.roomNo == null ||
                booking.roomNo == 'Unassigned' ||
                booking.roomNo.isEmpty)
            ? 'Unassigned'
            : booking.roomNo;

        if (!organizedData[hostelKey]!.containsKey(roomKey)) {
          organizedData[hostelKey]![roomKey] = [];
        }
        organizedData[hostelKey]![roomKey]!.add(booking);
      }
    }

    // Convert to list for building
    List<MapEntry<String, Map<String, List<Booking>>>> hostelList =
        organizedData.entries.toList();

    return ListView.builder(
      itemCount: hostelList.length,
      itemBuilder: (context, hostelIndex) {
        String hostelKey = hostelList[hostelIndex].key;
        Map<String, List<Booking>> roomsMap = hostelList[hostelIndex].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hostel Header
            Container(
              width: double.infinity,
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 16,
                    color: Color(0xFFE53935),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _parseHostelName(hostelKey),
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${roomsMap.length} Room${roomsMap.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rooms under this hostel - EACH ROOM IN ITS OWN CONTAINER
            for (var roomEntry in roomsMap.entries)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE53935).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFE53935).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.meeting_room,
                            size: 18,
                            color: const Color(0xFFE53935),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            roomEntry.key == 'Unassigned'
                                ? 'Unassigned'
                                : 'Room ${roomEntry.key}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                            ),
                          ),
                          if (roomEntry.key != 'Unassigned' &&
                              roomEntry.value.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE53935,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                roomEntry.value.first.shareType,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE53935,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                roomEntry.value.first.roomType,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _getRoomStatus(
                                roomEntry.value.length,
                                _getShareTypeNumber(
                                  roomEntry.value.first.shareType,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bookings for this room
                    Column(
                      children: roomEntry.value.map((booking) {
                        return _HistoryRow(
                          booking: booking,
                          onRefresh: _refreshHistory,
                          showTransferIcon: _shouldShowTransferIcon(booking),
                          isVacated: false,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // Helper method to extract number from share type (e.g., "2 Sharing" -> 2)
  int _getShareTypeNumber(String shareType) {
    try {
      // Try to parse the first number found in the string
      final numbers = RegExp(r'\d+').allMatches(shareType);
      if (numbers.isNotEmpty) {
        return int.parse(numbers.first.group(0)!);
      }
    } catch (e) {
      // If parsing fails, return default 2
    }
    return 2; // Default to 2 sharing
  }

  String _getRoomStatus(int currentTenants, int shareType) {
    if (currentTenants == 0) {
      return '${shareType} Vacancies';
    } else if (currentTenants < shareType) {
      final vacancies = shareType - currentTenants;
      return '$vacancies ${vacancies == 1 ? 'Vacancy' : 'Vacancies'}';
    } else {
      return 'Full';
    }
  }

  String _parseHostelName(String hostelKey) {
    List<String> parts = hostelKey.split('|');
    return parts.length > 1 ? parts[1] : 'Unknown Hostel';
  }

  String _parseHostelAddress(String hostelKey) {
    List<String> parts = hostelKey.split('|');
    return parts.length > 2 ? parts[2] : '';
  }
}

class _HistoryRow extends StatefulWidget {
  final Booking booking;
  final VoidCallback onRefresh;
  final bool showTransferIcon;
  final bool isVacated;

  const _HistoryRow({
    required this.booking,
    required this.onRefresh,
    this.showTransferIcon = true,
    required this.isVacated,
  });

  @override
  State<_HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<_HistoryRow> {
  bool _isProcessing = false;

  String _getFormattedDate(DateTime dt) {
    return '${_getMonthName(dt.month)} ${dt.day}';
  }

  bool _isEditingPaymentAmount = false;
  bool _isProcessingPayment = false;

  late TextEditingController _paymentAmountController;
  late TextEditingController _advanceController;
  late TextEditingController _rentController;
  late TextEditingController _dateController;
  bool _isEditingAdvance = false;
  bool _isEditingRent = false;
  bool _isEditingDate = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _advanceController = TextEditingController(
      text: widget.booking.monthlyAdvance.toString(),
    );
    _rentController = TextEditingController(
      text: widget.booking.totalAmount.toString(),
    );
    _dateController = TextEditingController(
      text: _getFormattedDate(widget.booking.startDate),
    );
    _paymentAmountController = TextEditingController(); // Add this
  }

  void _updateAdvance(String value) {
    final newAmount = double.tryParse(value);
    if (newAmount != null &&
        newAmount > 0 &&
        newAmount != widget.booking.monthlyAdvance) {
      // Call API to update
      _callUpdateAdvanceAPI(newAmount);
    }
    setState(() => _isEditingAdvance = false);
  }

  Future<void> _updateStartDate(DateTime newDate) async {
    // Call your API to update start date
    setState(() {});
  }

  void _updateRent(String value) {
    final newAmount = double.tryParse(value);
    if (newAmount != null &&
        newAmount > 0 &&
        newAmount != widget.booking.totalAmount) {
      // Call API to update
      _callUpdateRentAPI(newAmount);
    }
    setState(() => _isEditingRent = false);
  }

  void _showPaymentOptionsModal() {
    final currentRemaining = widget.booking.currentMonthRemainingAmount ?? 0;
    final currentAmount =
        double.tryParse(_paymentAmountController.text) ?? currentRemaining;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String selectedPaymentType = 'full';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Payment Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Full Payment Option
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedPaymentType = 'full';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: selectedPaymentType == 'full'
                                    ? const Color(0xFFE53935).withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedPaymentType == 'full'
                                      ? const Color(0xFFE53935)
                                      : Colors.grey.shade300,
                                  width: selectedPaymentType == 'full' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'full',
                                    groupValue: selectedPaymentType,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedPaymentType = value!;
                                      });
                                    },
                                    activeColor: const Color(0xFFE53935),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Full Payment',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Mark as fully paid',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selectedPaymentType == 'full')
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Partial Payment Option
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedPaymentType = 'partial';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: selectedPaymentType == 'partial'
                                    ? const Color(0xFFE53935).withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedPaymentType == 'partial'
                                      ? const Color(0xFFE53935)
                                      : Colors.grey.shade300,
                                  width: selectedPaymentType == 'partial'
                                      ? 2
                                      : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'partial',
                                    groupValue: selectedPaymentType,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedPaymentType = value!;
                                      });
                                    },
                                    activeColor: const Color(0xFFE53935),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Partial Payment',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Mark as partial payment',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selectedPaymentType == 'partial')
                                    const Icon(
                                      Icons.edit,
                                      color: Color(0xFFFF9800),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(height: 1, color: Colors.grey.shade200),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                                _processPayment(
                                  selectedPaymentType,
                                  currentAmount,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _processPayment(String paymentType, dynamic amount) async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      String status;

      if (paymentType == 'full') {
        status = 'paid';
      } else {
        status = 'partial';
      }

      final payload = {
        'amount': amount,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'status': status,
      };

      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/addmonthlypaymnet/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'paid'
                    ? 'Full payment of ₹${amount.toStringAsFixed(2)} completed! ✨'
                    : 'Partial payment of ₹${amount.toStringAsFixed(2)} added! ✨',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          widget.onRefresh();
        }
      } else {
        String errorMessage = 'Failed to process payment';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore parse error
        }
        throw Exception(errorMessage);
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
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _updatePaymentAmount(String value) {
    final newAmount = double.tryParse(value);
    if (newAmount != null &&
        newAmount > 0 &&
        newAmount != widget.booking.totalAmount) {
      _updatePaymentAmountAPI(newAmount);
    }
    setState(() => _isEditingPaymentAmount = false);
  }

  Future<void> _deleteBooking() async {
    setState(() => _isProcessing = true);

    try {
      print("llllllllllllllll${widget.booking.id}");
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/updatebookingreq/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'completed'}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking marked as completed successfully! ✨'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Refresh the history data
          widget.onRefresh();
        }
      } else {
        String errorMessage = 'Failed to update booking';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore parse error
        }
        throw Exception(errorMessage);
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to mark ${widget.booking.personalDetails?.name ?? 'this tenant'}\'s booking as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejoinTenant() async {
    setState(() => _isProcessing = true);

    try {
      final response = await http.patch(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/bookings/${widget.booking.id}/rejoin',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tenant rejoined successfully! ✨'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Refresh the history data
          widget.onRefresh();

          // Navigate back to history screen if needed
          Navigator.pop(context);
        }
      } else {
        String errorMessage = 'Failed to rejoin tenant';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore parse error
        }
        throw Exception(errorMessage);
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showRejoinConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Re-Join'),
        content: Text(
          'Are you sure you want to rejoin ${widget.booking.personalDetails?.name ?? 'this tenant'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _rejoinTenant();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text('Re-Join'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePaymentAmountAPI(double newAmount) async {
    setState(() => _isProcessing = true);

    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/update-booking-total-amount/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'totalAmount': newAmount}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment amount updated successfully! ✨'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          widget.onRefresh();
        }
      } else {
        throw Exception('Failed to update payment amount');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _callUpdateAdvanceAPI(double newAmount) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/update-monthly-advance/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': newAmount}),
      );
      if (response.statusCode == 200) {
        widget.onRefresh();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _callUpdateRentAPI(double newAmount) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/update-booking-total-amount/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'totalAmount': newAmount}),
      );
      if (response.statusCode == 200) {
        widget.onRefresh();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _updateAllChanges() {
    // Get current values
    final currentAdvance = widget.booking.monthlyAdvance;
    final currentRent = widget.booking.totalAmount;
    final currentStartDate = widget.booking.startDate;

    final newAdvance = double.tryParse(_advanceController.text);
    final newRent = double.tryParse(_rentController.text);

    // Build payload with only changed fields
    Map<String, dynamic> payload = {};

    if (newRent != null && newRent > 0 && newRent != currentRent) {
      payload['totalAmount'] = newRent;
    }

    if (newAdvance != null && newAdvance > 0 && newAdvance != currentAdvance) {
      payload['monthlyAdvance'] = newAdvance;
    }

    if (_selectedDate != null && _selectedDate != currentStartDate) {
      payload['startDate'] = _selectedDate!.toIso8601String().split('T')[0];
    }

    // If nothing changed, just exit edit mode
    if (payload.isEmpty) {
      setState(() {
        _isEditingAdvance = false;
        _isEditingRent = false;
      });
      return;
    }

    // Direct update without dialog
    _saveAllChangesWithPayload(payload);
  }

  Future<void> _saveAllChangesWithPayload(Map<String, dynamic> payload) async {
    setState(() => _isProcessing = true);

    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/bookings/${widget.booking.id}/details',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Updated successfully! ✨'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          setState(() {
            _isEditingAdvance = false;
            _isEditingRent = false;
          });

          // Refresh the data
          widget.onRefresh();
        }
      } else {
        String errorMessage = 'Failed to update';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore parse error
        }
        throw Exception(errorMessage);
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveAllChanges() async {
    setState(() => _isProcessing = true);

    try {
      final currentAdvance = widget.booking.monthlyAdvance;
      final currentRent = widget.booking.totalAmount;
      final currentStartDate = widget.booking.startDate;

      final newAdvance = double.tryParse(_advanceController.text);
      final newRent = double.tryParse(_rentController.text);

      // Parse the date from the date picker (you'll need to store the selected date)
      // For now, using existing date - you'll need to add a variable to store picked date
      final newStartDate = _selectedDate ?? currentStartDate;

      // Build the payload with only changed fields
      Map<String, dynamic> payload = {};

      if (newRent != null && newRent > 0 && newRent != currentRent) {
        payload['totalAmount'] = newRent;
      }

      if (newAdvance != null &&
          newAdvance > 0 &&
          newAdvance != currentAdvance) {
        payload['monthlyAdvance'] = newAdvance;
      }

      if (_selectedDate != null && _selectedDate != currentStartDate) {
        payload['startDate'] = _selectedDate!.toIso8601String().split('T')[0];
      }

      // If nothing changed, just exit edit mode
      if (payload.isEmpty) {
        setState(() {
          _isEditingAdvance = false;
          _isEditingRent = false;
          _isProcessing = false;
        });
        return;
      }

      // Call the API
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/bookings/${widget.booking.id}/details',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Updated successfully! ✨'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          setState(() {
            _isEditingAdvance = false;
            _isEditingRent = false;
          });

          // Refresh the data
          widget.onRefresh();
        }
      } else {
        // Try to parse error message
        String errorMessage = 'Failed to update';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore parse error
        }
        throw Exception(errorMessage);
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getNextMonthDate() {
    DateTime nextMonth = DateTime(
      widget.booking.startDate.year,
      widget.booking.startDate.month + 1,
      widget.booking.startDate.day,
    );
    return '${_getMonthName(nextMonth.month)} ${nextMonth.day}, ${nextMonth.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
      case 'active':
        return const Color(0xFF43A047);
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
        return const Color(0xFF43A047);
      case 'pending':
      case 'due':
        return const Color(0xFFFB8C00);
      case 'partial':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getPaymentStatusBg(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xFFE8F5E9);
      case 'pending':
      case 'due':
        return const Color(0xFFFFF8E1);
      case 'partial':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  @override
  void dispose() {
    _advanceController.dispose();
    _rentController.dispose();
    _dateController.dispose();
    _paymentAmountController.dispose(); // Add this
    super.dispose();
  }

  String _getRemainingAmount() {
    final paymentHistory = widget.booking.paymentHistory;
    if (paymentHistory.isEmpty) return '₹${widget.booking.totalAmount}';

    for (var payment in paymentHistory.reversed) {
      if (payment.status.toLowerCase() == 'pending') {
        if (widget.booking.currentMonthPaymentStatus?.toLowerCase() == 'paid') {
          return 'No Due';
        }
        return 'Due: ₹${widget.booking.totalAmount}';
      } else if (payment.status.toLowerCase() == 'partial') {
        if (payment.remainingAmount > 0) {
          return 'Due: ₹${payment.remainingAmount}';
        }
      }
    }

    bool allPaid = paymentHistory.every(
      (p) => p.status.toLowerCase() == 'paid',
    );
    if (allPaid) {
      if (widget.booking.currentMonthPaymentStatus?.toLowerCase() != 'paid') {
        return 'Next: ₹${widget.booking.monthlyAdvance}';
      }
      return 'No Due';
    }

    return '₹${widget.booking.totalAmount}';
  }

  bool get _isCurrentMonthPaid {
    return widget.booking.currentMonthPaymentStatus?.toLowerCase() == 'paid';
  }

  bool get _isUnassignedRoom {
    return widget.booking.roomNo == 'Unassigned' ||
        widget.booking.roomNo == null ||
        widget.booking.roomNo.isEmpty;
  }

  Future<void> _makeCall() async {
    if (widget.booking.personalDetails != null) {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: widget.booking.personalDetails!.mobileNumber.toString(),
      );
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not call ${widget.booking.personalDetails!.mobileNumber}',
              ),
              backgroundColor: const Color(0xFFE53935),
            ),
          );
        }
      }
    } else if (widget.booking.userId != null) {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: widget.booking.userId!.mobileNumber.toString(),
      );
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not call ${widget.booking.userId!.mobileNumber}',
              ),
              backgroundColor: const Color(0xFFE53935),
            ),
          );
        }
      }
    }
  }

  void _showTransferPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => TransferPopup(
        tenantName: widget.booking.personalDetails?.name ?? 'Tenant',
        currentRoom: widget.booking.roomNo,
        bookingId: widget.booking.id,
        onTransferComplete: widget.onRefresh,
        hostelId: widget.booking.hostelId?.id ?? '',
      ),
    );
  }

  void _navigateToView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TenantViewScreen(
          booking: widget.booking,
          onUpdate: widget.onRefresh,
        ),
      ),
    );
  }

  void _showUpdateConfirmation() {
    // Get current values
    final currentAdvance = widget.booking.monthlyAdvance;
    final currentRent = widget.booking.totalAmount;

    final newAdvance = double.tryParse(_advanceController.text);
    final newRent = double.tryParse(_rentController.text);

    // Build changes list
    final List<Map<String, String>> changes = [];

    if (newAdvance != null && newAdvance > 0 && newAdvance != currentAdvance) {
      changes.add({
        'field': 'Monthly Advance',
        'old': '₹${currentAdvance.toStringAsFixed(0)}',
        'new': '₹${newAdvance.toStringAsFixed(0)}',
      });
    }

    if (newRent != null && newRent > 0 && newRent != currentRent) {
      changes.add({
        'field': 'Total Rent',
        'old': '₹${currentRent.toStringAsFixed(0)}',
        'new': '₹${newRent.toStringAsFixed(0)}',
      });
    }

    if (changes.isEmpty) {
      // No changes, just exit edit mode
      setState(() {
        _isEditingAdvance = false;
        _isEditingRent = false;
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.update_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Confirm Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Are you sure you want to update?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Changes List
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Changes to be applied:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...changes
                        .map(
                          (change) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFE0E0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  change['field']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            change['old']!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 16,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFE53935,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            change['new']!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),

              // Divider
              Container(height: 1, color: Colors.grey.shade200),

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          _saveAllChanges();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Yes, Update',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions() {
    // Get the current payment history
    final paymentHistory = widget.booking.paymentHistory;

    if (paymentHistory.isEmpty) {
      _navigateToAddFirstPayment();
      return;
    }

    // Get the latest pending/partial payment
    PaymentHistory? currentPayment;

    if (paymentHistory.isNotEmpty) {
      // Case: only one element
      if (paymentHistory.length == 1) {
        final payment = paymentHistory.first;

        if (payment.status.toLowerCase() == 'pending' ||
            payment.status.toLowerCase() == 'partial') {
          currentPayment = payment;
        }
      } else {
        // Case: multiple elements
        for (int i = 0; i < paymentHistory.length; i++) {
          final payment = paymentHistory[i];
          final status = payment.status.toLowerCase();

          // If current item is partial, select it immediately
          if (status == 'partial') {
            currentPayment = payment;
            break;
          }

          // If current is paid and next is pending, select next pending
          if (status == 'paid' && i + 1 < paymentHistory.length) {
            final nextPayment = paymentHistory[i + 1];

            if (nextPayment.status.toLowerCase() == 'pending') {
              currentPayment = nextPayment;
              break;
            }
          }

          // If current itself is pending, select it
          if (status == 'pending') {
            currentPayment = payment;
            break;
          }
        }
      }
    }

    if (currentPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All payments are completed'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      return;
    }

    final paymentToEdit = currentPayment;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Payment Option',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () =>
                                _processCompletePayment(context, paymentToEdit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
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
                              'Complete Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // In _showPaymentOptions method, replace the Partial Payment button onPressed:
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                              ); // Close the options bottom sheet
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => PartialPayment(
                                  booking: widget.booking,
                                  payment: paymentToEdit,
                                  onUpdate: widget.onRefresh,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
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
                              'Partial Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToAddFirstPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFirstPaymentScreen(
          booking: widget.booking,
          onUpdate: widget.onRefresh,
        ),
      ),
    );
  }

  void _showPartialPaymentDialog(BuildContext parentContext) {
    TextEditingController amountController = TextEditingController();
    double maxAmount = widget.booking.totalAmount.toDouble();

    for (var payment in widget.booking.paymentHistory.reversed) {
      if (payment.status.toLowerCase() == 'partial' &&
          payment.remainingAmount > 0) {
        maxAmount = payment.remainingAmount.toDouble();
        break;
      }
    }

    showDialog(
      context: parentContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Partial Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Maximum amount: ₹${maxAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.currency_rupee),
                      hintText: 'Enter amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    double amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0 || amount > maxAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            amount <= 0
                                ? 'Please enter a valid amount'
                                : 'Amount cannot exceed ₹${maxAmount.toStringAsFixed(2)}',
                          ),
                          backgroundColor: const Color(0xFFE53935),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    Navigator.pop(parentContext);
                    _processPartialPayment(amount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                  ),
                  child: const Text('Pay'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processCompletePayment(
    BuildContext parentContext,
    PaymentHistory paymentToEdit,
  ) async {
    setState(() => _isProcessing = true);
    try {
      double remainingAmount = widget.booking.totalAmount.toDouble();
      for (var payment in widget.booking.paymentHistory.reversed) {
        if (payment.status.toLowerCase() == 'partial' &&
            payment.remainingAmount > 0) {
          remainingAmount = payment.remainingAmount.toDouble();
          break;
        }
      }
      final payload = {
        'amount': remainingAmount,
        'status': 'paid',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'remainingAmount': 0,
      };
      final response = await http.put(
        // Uri.parse(
        //   'http://187.127.146.52:2003/api/vendors/addmonthlypaymnet/${widget.booking.id}',
        // ),
        Uri.parse(
          "http://187.127.146.52:2003/api/vendors/updatemonthlypaymnet/${widget.booking.id}/${paymentToEdit.id}",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment completed successfully! ✨'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(parentContext);
          widget.onRefresh();
        }
      } else {
        throw Exception('Failed to process payment');
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processPartialPayment(double amount) async {
    setState(() => _isProcessing = true);
    try {
      double remainingAmount = widget.booking.totalAmount.toDouble() - amount;
      for (var payment in widget.booking.paymentHistory.reversed) {
        if (payment.status.toLowerCase() == 'partial' &&
            payment.remainingAmount > 0) {
          remainingAmount = payment.remainingAmount.toDouble() - amount;
          break;
        }
      }
      final payload = {
        'amount': amount,
        'status': 'partial',
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Partial payment of ₹${amount.toStringAsFixed(2)} added successfully! ✨',
              ),
              backgroundColor: Colors.green,
            ),
          );
          widget.onRefresh();
        }
      } else {
        throw Exception('Failed to process payment');
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Helper to build action button
  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  // Widget for Unassigned Room
  Widget _buildUnassignedRoomCard() {
    final personalDetails = widget.booking.personalDetails;
    final paymentStatus = widget.booking.currentMonthPaymentStatus ?? 'N/A';
    final paymentStatusColor = _getPaymentStatusColor(paymentStatus);
    final paymentStatusBg = _getPaymentStatusBg(paymentStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                if (personalDetails?.profileImage != null &&
                    personalDetails!.profileImage.isNotEmpty)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE53935),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        personalDetails.profileImage,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFFE53935),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(width: 10),

                // Name + joining date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.userId?.mobileNumber.toString() ??
                            'Unknown',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Joining date: ${_getFormattedDate(widget.booking.startDate)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons (Call, View only - no transfer for unassigned)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(Icons.phone, Colors.green, _makeCall),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const _DashedDivider(),
            const SizedBox(height: 10),

            // Simple Info Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ROOM UNASSIGNED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(
                  label: paymentStatus.toUpperCase(),
                  dotColor: paymentStatusColor,
                  bgColor: paymentStatusBg,
                  textColor: paymentStatusColor,
                  fontSize: 11,
                  dotSize: 6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show unassigned room card if room is unassigned
    if (_isUnassignedRoom) {
      return _buildUnassignedRoomCard();
    }

    final personalDetails = widget.booking.personalDetails;
    final paymentStatus = widget.booking.currentMonthPaymentStatus ?? 'N/A';
    final paymentStatusColor = _getPaymentStatusColor(paymentStatus);
    final paymentStatusBg = _getPaymentStatusBg(paymentStatus);

    // Check if payment is pending (not paid)
    final bool isPending = !_isCurrentMonthPaid;

    // return Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(16),
    //     border: Border.all(
    //       // ← ADD THIS
    //       color: Colors.grey.shade200,
    //       width: 1,
    //     ),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.06),
    //         blurRadius: 8,
    //         offset: const Offset(0, 2),
    //       ),
    //     ],
    //   ),
    //   child: Padding(
    //     padding: const EdgeInsets.all(14),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         // ── Header ──
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             // Avatar
    //             if (personalDetails?.profileImage != null &&
    //                 personalDetails!.profileImage.isNotEmpty)
    //               Column(
    //                 children: [
    //                   // Action buttons (Call, Transfer, View) horizontally
    //                   Row(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       _buildActionButton(
    //                         Icons.phone,
    //                         Colors.green,
    //                         _makeCall,
    //                       ),
    //                       if (widget.showTransferIcon)
    //                         _buildActionButton(
    //                           Icons.swap_horiz,
    //                           Colors.blue,
    //                           _showTransferPopup,
    //                         ),
    //                       _buildActionButton(
    //                         Icons.delete_outline,
    //                         const Color.fromARGB(255, 251, 11, 11),
    //                         _navigateToView,
    //                       ),
    //                     ],
    //                   ),
    //                   Container(
    //                     width: 40,
    //                     height: 40,
    //                     decoration: BoxDecoration(
    //                       shape: BoxShape.circle,
    //                       border: Border.all(
    //                         color: const Color(0xFFE53935),
    //                         width: 2,
    //                       ),
    //                       boxShadow: [
    //                         BoxShadow(
    //                           color: Colors.black.withOpacity(0.1),
    //                           blurRadius: 8,
    //                           offset: const Offset(0, 2),
    //                         ),
    //                       ],
    //                     ),
    //                     child: ClipOval(
    //                       child: Image.network(
    //                         personalDetails.profileImage,
    //                         fit: BoxFit.cover,
    //                         loadingBuilder: (context, child, loadingProgress) {
    //                           if (loadingProgress == null) return child;
    //                           return Center(
    //                             child: CircularProgressIndicator(
    //                               color: const Color(0xFFE53935),
    //                               value:
    //                                   loadingProgress.expectedTotalBytes != null
    //                                   ? loadingProgress.cumulativeBytesLoaded /
    //                                         loadingProgress.expectedTotalBytes!
    //                                   : null,
    //                             ),
    //                           );
    //                         },
    //                         errorBuilder: (context, error, stackTrace) {
    //                           return Container(
    //                             color: Colors.grey.shade200,
    //                             child: const Icon(
    //                               Icons.person,
    //                               size: 50,
    //                               color: Colors.grey,
    //                             ),
    //                           );
    //                         },
    //                       ),
    //                     ),
    //                   ),
    //                   Text(
    //                     personalDetails?.name ?? 'Unknown',
    //                     style: const TextStyle(
    //                       fontSize: 15,
    //                       fontWeight: FontWeight.w700,
    //                       color: Colors.black87,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             Container(
    //               height: 60,
    //               child: const VerticalDivider(
    //                 color: Colors.grey,
    //                 thickness: 1,
    //               ),
    //             ),

    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   // Date
    //                   Row(
    //                     children: [
    //                       const Text(
    //                         'D',
    //                         style: TextStyle(
    //                           fontSize: 11,
    //                           color: Color(0xFF9E9E9E),
    //                         ),
    //                       ),
    //                       const SizedBox(width: 4),
    //                       Container(
    //                         padding: const EdgeInsets.symmetric(
    //                           horizontal: 8,
    //                           vertical: 3,
    //                         ),
    //                         decoration: BoxDecoration(
    //                           border: Border.all(
    //                             color: Color(0xFF9E9E9E),
    //                             width: 1,
    //                           ),
    //                           borderRadius: BorderRadius.circular(6),
    //                         ),
    //                         child: Text(
    //                           _getFormattedDate(widget.booking.startDate),
    //                           style: const TextStyle(
    //                             fontSize: 11,
    //                             color: Color(0xFF9E9E9E),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),

    //                   const SizedBox(height: 6),

    //                   // Advance
    //                   Row(
    //                     children: [
    //                       const Text(
    //                         'A',
    //                         style: TextStyle(
    //                           fontSize: 11,
    //                           color: Color(0xFF9E9E9E),
    //                         ),
    //                       ),
    //                       const SizedBox(width: 4),
    //                       Container(
    //                         padding: const EdgeInsets.symmetric(
    //                           horizontal: 8,
    //                           vertical: 3,
    //                         ),
    //                         decoration: BoxDecoration(
    //                           border: Border.all(
    //                             color: Color(0xFF9E9E9E),
    //                             width: 1,
    //                           ),
    //                           borderRadius: BorderRadius.circular(6),
    //                         ),
    //                         child: Text(
    //                           '${widget.booking.monthlyAdvance}',
    //                           style: const TextStyle(
    //                             fontSize: 11,
    //                             color: Color(0xFF9E9E9E),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),

    //                   const SizedBox(height: 6),

    //                   // Rent
    //                   Row(
    //                     children: [
    //                       const Text(
    //                         'R',
    //                         style: TextStyle(
    //                           fontSize: 11,
    //                           color: Color(0xFF9E9E9E),
    //                         ),
    //                       ),
    //                       const SizedBox(width: 4),
    //                       Container(
    //                         padding: const EdgeInsets.symmetric(
    //                           horizontal: 8,
    //                           vertical: 3,
    //                         ),
    //                         decoration: BoxDecoration(
    //                           border: Border.all(
    //                             color: Color(0xFF9E9E9E),
    //                             width: 1,
    //                           ),
    //                           borderRadius: BorderRadius.circular(6),
    //                         ),
    //                         child: Text(
    //                           '${widget.booking.totalAmount}',
    //                           style: const TextStyle(
    //                             fontSize: 11,
    //                             color: Color(0xFF9E9E9E),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),

    //             Container(
    //               height: 60,
    //               child: const VerticalDivider(
    //                 color: Colors.grey,
    //                 thickness: 1,
    //               ),
    //             ),

    //             // Name + joining date
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     'PAID',
    //                     style: const TextStyle(
    //                       fontSize: 11,
    //                       color: Color(0xFF9E9E9E),
    //                     ),
    //                   ),

    //                   Text(
    //                     '${widget.booking.totalAmount}',
    //                     style: const TextStyle(
    //                       fontSize: 11,
    //                       color: Color(0xFF9E9E9E),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),

    //             Container(
    //               height: 60,
    //               child: const VerticalDivider(
    //                 color: Colors.grey,
    //                 thickness: 1,
    //               ),
    //             ),

    //             // Name + joining date
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     'PAID',
    //                     style: const TextStyle(
    //                       fontSize: 11,
    //                       color: Color(0xFF9E9E9E),
    //                     ),
    //                   ),

    //                   Text(
    //                     '${widget.booking.totalAmount}',
    //                     style: const TextStyle(
    //                       fontSize: 11,
    //                       color: Color(0xFF9E9E9E),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),

    //             if (isPending)
    //               Expanded(
    //                 child: ElevatedButton(
    //                   onPressed: _isProcessing ? null : _showPaymentOptions,
    //                   style: ElevatedButton.styleFrom(
    //                     backgroundColor: const Color(0xFFE53935),
    //                     foregroundColor: Colors.white,
    //                     padding: const EdgeInsets.symmetric(vertical: 10),
    //                     shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(8),
    //                     ),
    //                     elevation: 0,
    //                   ),
    //                   child: _isProcessing
    //                       ? const SizedBox(
    //                           height: 18,
    //                           width: 18,
    //                           child: CircularProgressIndicator(
    //                             strokeWidth: 2,
    //                             valueColor: AlwaysStoppedAnimation<Color>(
    //                               Colors.white,
    //                             ),
    //                           ),
    //                         )
    //                       : const Text(
    //                           'Update',
    //                           style: TextStyle(
    //                             fontSize: 13,
    //                             fontWeight: FontWeight.w600,
    //                           ),
    //                         ),
    //                 ),
    //               ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Section
                    if (personalDetails?.profileImage != null &&
                        personalDetails!.profileImage.isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Action buttons (Call, Transfer, View)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActionButton(
                                Icons.phone,
                                Colors.green,
                                _makeCall,
                              ),
                              if (widget.showTransferIcon)
                                _buildActionButton(
                                  Icons.swap_horiz,
                                  Colors.blue,
                                  _showTransferPopup,
                                ),
                              if (widget.showTransferIcon)
                                _buildActionButton(
                                  Icons.delete_outline,
                                  const Color.fromARGB(255, 251, 11, 11),
                                  _showDeleteConfirmation,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE53935),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap:
                                  _navigateToView, // Fixed: Direct reference (no arrow function needed)
                              child: ClipOval(
                                child: Image.network(
                                  personalDetails.profileImage,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: const Color(0xFFE53935),
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            personalDetails?.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                    Container(
                      height: 120,
                      child: const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),

                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date (with date picker)
                          Row(
                            children: [
                              const Text(
                                'D',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _selectedDate ??
                                          widget.booking.startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        _selectedDate = pickedDate;
                                        _dateController.text =
                                            _getFormattedDate(pickedDate);
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _selectedDate != null
                                            ? const Color(0xFFE53935)
                                            : const Color(0xFF9E9E9E),
                                        width: _selectedDate != null ? 1.5 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 10,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _selectedDate != null
                                                ? _getFormattedDate(
                                                    _selectedDate!,
                                                  )
                                                : _getFormattedDate(
                                                    widget.booking.startDate,
                                                  ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: _selectedDate != null
                                                  ? const Color(0xFFE53935)
                                                  : const Color(0xFF9E9E9E),
                                              fontWeight: _selectedDate != null
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Advance (inline editable)
                          Row(
                            children: [
                              const Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _isEditingAdvance
                                    ? TextField(
                                        controller: _advanceController,
                                        autofocus: true,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                              width: 1.5,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                          isDense: true,
                                        ),
                                        onSubmitted: _updateAdvance,
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isEditingAdvance = true;
                                            _advanceController.text = widget
                                                .booking
                                                .monthlyAdvance
                                                .toString();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFF9E9E9E),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.edit,
                                                size: 10,
                                                color: Color(0xFF9E9E9E),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${widget.booking.monthlyAdvance}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF9E9E9E),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Rent (inline editable)
                          Row(
                            children: [
                              const Text(
                                'R',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _isEditingRent
                                    ? TextField(
                                        controller: _rentController,
                                        autofocus: true,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                              width: 1.5,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                          isDense: true,
                                        ),
                                        onSubmitted: _updateRent,
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isEditingRent = true;
                                            _rentController.text = widget
                                                .booking
                                                .totalAmount
                                                .toString();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFF9E9E9E),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.edit,
                                                size: 10,
                                                color: Color(0xFF9E9E9E),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${widget.booking.totalAmount}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF9E9E9E),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Small Update Button below R
                          Center(
                            child: SizedBox(
                              width: 60,
                              height: 28,
                              child: ElevatedButton(
                                onPressed: _isProcessing
                                    ? null
                                    : _updateAllChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Update',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 120,
                      child: const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),

                    // Paid Status Section
                    SizedBox(
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // const Text(
                          //   'PAID',
                          //   style: TextStyle(
                          //     fontSize: 11,
                          //     color: Color.fromARGB(255, 0, 0, 0),
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          // Text(
                          //   '${widget.booking.totalAmount}',
                          //   style: const TextStyle(
                          //     fontSize: 11,
                          //     color: Color(0xFF9E9E9E),
                          //   ),
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                          // if (!widget.isVacated)
                          //   Padding(
                          //     padding: const EdgeInsets.only(left: 8),
                          //     child: SizedBox(
                          //       width: 60,
                          //       child: _isEditingPaymentAmount
                          //           ? TextField(
                          //               controller: _paymentAmountController,
                          //               autofocus: true,
                          //               keyboardType: TextInputType.number,
                          //               textAlign: TextAlign.center,
                          //               style: const TextStyle(
                          //                 fontSize: 13,
                          //                 fontWeight: FontWeight.w600,
                          //                 color: Colors.black,
                          //               ),
                          //               decoration: InputDecoration(
                          //                 border: OutlineInputBorder(
                          //                   borderRadius: BorderRadius.circular(
                          //                     8,
                          //                   ),
                          //                   borderSide: const BorderSide(
                          //                     color: Color(0xFFE53935),
                          //                   ),
                          //                 ),
                          //                 enabledBorder: OutlineInputBorder(
                          //                   borderRadius: BorderRadius.circular(
                          //                     8,
                          //                   ),
                          //                   borderSide: const BorderSide(
                          //                     color: Color(0xFFE53935),
                          //                   ),
                          //                 ),
                          //                 focusedBorder: OutlineInputBorder(
                          //                   borderRadius: BorderRadius.circular(
                          //                     8,
                          //                   ),
                          //                   borderSide: const BorderSide(
                          //                     color: Color(0xFFE53935),
                          //                     width: 1.5,
                          //                   ),
                          //                 ),
                          //                 contentPadding:
                          //                     const EdgeInsets.symmetric(
                          //                       horizontal: 4,
                          //                       vertical: 10,
                          //                     ),
                          //                 isDense: true,
                          //               ),
                          //               onSubmitted: _updatePaymentAmount,
                          //             )
                          //           : GestureDetector(
                          //               onTap: () {
                          //                 setState(() {
                          //                   _isEditingPaymentAmount = true;
                          //                   _paymentAmountController.text =
                          //                       widget.booking.totalAmount
                          //                           .toString();
                          //                 });
                          //               },
                          //               child: Container(
                          //                 padding: const EdgeInsets.symmetric(
                          //                   vertical: 10,
                          //                 ),
                          //                 decoration: BoxDecoration(
                          //                   color: Colors.white,
                          //                   borderRadius: BorderRadius.circular(
                          //                     8,
                          //                   ),
                          //                   border: Border.all(
                          //                     color: Colors.black,
                          //                     width: 1,
                          //                   ),
                          //                 ),
                          //                 child: Center(
                          //                   child: Row(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment.center,
                          //                     children: [
                          //                       const Icon(
                          //                         Icons.edit,
                          //                         size: 12,
                          //                         color: Colors.black54,
                          //                       ),
                          //                       const SizedBox(width: 4),
                          //                       Text(
                          //                         '${widget.booking.totalAmount}',
                          //                         style: const TextStyle(
                          //                           fontSize: 13,
                          //                           fontWeight: FontWeight.w600,
                          //                           color: Colors.black87,
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //     ),
                          //   ),

                          // if (!widget.isVacated)
                          //   Padding(
                          //     padding: const EdgeInsets.only(left: 8),
                          //     child: SizedBox(
                          //       width: 60,
                          //       child: ElevatedButton(
                          //         onPressed: _isProcessing
                          //             ? null
                          //             : _showUpdateConfirmation,
                          //         style: ElevatedButton.styleFrom(
                          //           backgroundColor: const Color(0xFFE53935),
                          //           foregroundColor: Colors.white,
                          //           padding: const EdgeInsets.symmetric(
                          //             vertical: 10,
                          //           ),
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(8),
                          //           ),
                          //           elevation: 0,
                          //           minimumSize: const Size(0, 40),
                          //         ),
                          //         child: _isProcessing
                          //             ? const SizedBox(
                          //                 height: 18,
                          //                 width: 18,
                          //                 child: CircularProgressIndicator(
                          //                   strokeWidth: 2,
                          //                   valueColor:
                          //                       AlwaysStoppedAnimation<Color>(
                          //                         Colors.white,
                          //                       ),
                          //                 ),
                          //               )
                          //             : const Text(
                          //                 'Update',
                          //                 style: TextStyle(
                          //                   fontSize: 13,
                          //                   fontWeight: FontWeight.w600,
                          //                 ),
                          //               ),
                          //       ),
                          //     ),
                          //   ),
                          if (!widget.isVacated) ...[
                            // Show remaining amount in editable field if partial payment exists
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SizedBox(
                                width: 60,
                                child: _isEditingPaymentAmount
                                    ? TextField(
                                        controller: _paymentAmountController,
                                        autofocus: true,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE53935),
                                              width: 1.5,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 10,
                                              ),
                                          isDense: true,
                                        ),
                                        onSubmitted: _updatePaymentAmount,
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isEditingPaymentAmount = true;
                                            _paymentAmountController.text =
                                                (widget
                                                            .booking
                                                            .currentMonthRemainingAmount ??
                                                        widget
                                                            .booking
                                                            .totalAmount)
                                                    .toString();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.edit,
                                                  size: 12,
                                                  color: Colors.black54,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  (widget
                                                              .booking
                                                              .currentMonthRemainingAmount ??
                                                          widget
                                                              .booking
                                                              .totalAmount)
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            // Update/Payment Button
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SizedBox(
                                width: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final paymentStatus =
                                        widget.booking.currentMonthPaymentStatus
                                            ?.toLowerCase() ??
                                        'pending';
                                    final remainingAmount =
                                        widget
                                            .booking
                                            .currentMonthRemainingAmount ??
                                        0;
                                    final currentAmount =
                                        double.tryParse(
                                          _paymentAmountController.text,
                                        ) ??
                                        remainingAmount;

                                    if (paymentStatus == 'paid') {
                                      // Already paid - do nothing
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Payment already completed',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else if (remainingAmount > 0 ||
                                        currentAmount > 0) {
                                      // Has amount - show payment options modal
                                      _showPaymentOptionsModal();
                                    } else {
                                      // No amount - show update confirmation
                                      _showUpdateConfirmation();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: () {
                                      final paymentStatus =
                                          widget
                                              .booking
                                              .currentMonthPaymentStatus
                                              ?.toLowerCase() ??
                                          'pending';
                                      if (paymentStatus == 'paid') {
                                        return Colors.green;
                                      }
                                      return const Color(0xFFE53935);
                                    }(),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    minimumSize: const Size(0, 40),
                                  ),
                                  child: _isProcessingPayment
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          () {
                                            final paymentStatus =
                                                widget
                                                    .booking
                                                    .currentMonthPaymentStatus
                                                    ?.toLowerCase() ??
                                                'pending';
                                            final remainingAmount =
                                                widget
                                                    .booking
                                                    .currentMonthRemainingAmount ??
                                                0;

                                            if (paymentStatus == 'paid') {
                                              return 'PAID';
                                            } else if (remainingAmount > 0) {
                                              return 'PAY';
                                            } else {
                                              return 'Update';
                                            }
                                          }(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],

                          if (widget.isVacated)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SizedBox(
                                width: 90,
                                child: ElevatedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : _showRejoinConfirmation, // Changed to show confirmation
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE53935),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    minimumSize: const Size(0, 40),
                                  ),
                                  child: _isProcessing
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Re-Join',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color dotColor;
  final Color bgColor;
  final Color textColor;
  final double fontSize;
  final double dotSize;

  const _StatusBadge({
    required this.label,
    required this.dotColor,
    required this.bgColor,
    required this.textColor,
    required this.fontSize,
    required this.dotSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            (constraints.constrainWidth() / 6).floor(),
            (index) => Container(
              width: 3,
              height: 1,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
            ),
          ),
        );
      },
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

// Updated ActionButton with label
class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final String label;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
          'Add First Payment - ${widget.booking.personalDetails?.name ?? 'Tenant'}',
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

// Add this new widget for vacated history cards
class _VacatedHistoryCard extends StatelessWidget {
  final Booking booking;

  const _VacatedHistoryCard({required this.booking});

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final personalDetails = booking.personalDetails;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar or Icon
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: ClipOval(
                child:
                    personalDetails?.profileImage != null &&
                        personalDetails!.profileImage.isNotEmpty
                    ? Image.network(
                        personalDetails.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 25,
                            color: Colors.grey.shade400,
                          );
                        },
                      )
                    : Icon(
                        Icons.person_outline,
                        size: 25,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    personalDetails?.name ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📞 ${personalDetails?.mobileNumber ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Room: ${booking.roomNo} | ${booking.shareType}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'VACATED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            'Payment Details - ${widget.booking.personalDetails?.name ?? 'Tenant'}',
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
          'Edit Payment - ${widget.booking.personalDetails?.name ?? 'Tenant'}',
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

class PartialPayment extends StatefulWidget {
  final Booking booking;
  final PaymentHistory payment;
  final VoidCallback onUpdate;

  const PartialPayment({
    super.key,
    required this.booking,
    required this.payment,
    required this.onUpdate,
  });

  @override
  State<PartialPayment> createState() => _PartialPaymentState();
}

class _PartialPaymentState extends State<PartialPayment>
    with SingleTickerProviderStateMixin {
  late TextEditingController _amountCtrl;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  double _getRemainingAmount() {
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

    if (widget.payment.status.toLowerCase() == 'pending' && remaining == 0) {
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
    double amount = double.tryParse(_amountCtrl.text) ?? 0;
    double currentRemaining = _getRemainingAmount();

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

    double remainingAmount = currentRemaining - amount;

    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {
        'amount': amount,
        'status': "partial",
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
                'Partial payment of ₹${_formatAmount(amount)} updated! ✨',
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
        String errorMsg = 'Failed to update payment';
        try {
          final errorResponse = jsonDecode(response.body);
          errorMsg = errorResponse['message'] ?? errorMsg;
        } catch (e) {
          // Ignore parse error
        }
        throw Exception(errorMsg);
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

    // Don't show modal if payment is already completed
    if (widget.payment.status.toLowerCase() == 'paid' &&
        displayRemaining == 0) {
      return Container();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Partial Payment - ${widget.booking.personalDetails?.name ?? 'Tenant'}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Due Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.currency_rupee,
                          color: Color(0xFFE53935),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Amount Due',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_formatAmount(displayRemaining)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Enter amount field with button on the right
                const Text(
                  'Enter Payment Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
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
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF80500),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Max: ₹${_formatAmount(displayRemaining)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'Min: ₹1',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Success Animation Overlay
          if (_animationController.isAnimating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// class TransferPopup extends StatefulWidget {
//   final String tenantName;
//   final String currentRoom;
//   final String bookingId;
//   final VoidCallback onTransferComplete;

//   const TransferPopup({
//     super.key,
//     required this.tenantName,
//     required this.currentRoom,
//     required this.bookingId,
//     required this.onTransferComplete,
//   });

//   @override
//   State<TransferPopup> createState() => _TransferPopupState();
// }

// class _TransferPopupState extends State<TransferPopup> {
//   final TextEditingController _roomController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _roomController.dispose();
//     super.dispose();
//   }

//   Future<void> _transferRoom() async {
//     final newRoomNo = _roomController.text.trim();

//     if (newRoomNo.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a room number'),
//           backgroundColor: Color(0xFFE53935),
//         ),
//       );
//       return;
//     }

//     if (newRoomNo == widget.currentRoom) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('New room number is same as current room'),
//           backgroundColor: Color(0xFFE53935),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.put(
//         Uri.parse(
//           'http://187.127.146.52:2003/api/vendors/changebookingroomno/${widget.bookingId}',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'roomNo': newRoomNo}),
//       );

//       if (response.statusCode == 200) {
//         if (mounted) {
//           Navigator.pop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 '${widget.tenantName} transferred from Room ${widget.currentRoom} to Room $newRoomNo',
//               ),
//               backgroundColor: Colors.green,
//             ),
//           );
//           // Refresh the history
//           widget.onTransferComplete();
//         }
//       } else {
//         throw Exception('Failed to transfer room');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error transferring room: $e'),
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
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Transfer Room',
//               style: TextStyle(
//                 color: Color(0xFFF80500),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 20,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${widget.tenantName} - Current Room: ${widget.currentRoom}',
//               style: const TextStyle(color: Colors.black54, fontSize: 13),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Enter New Room Number',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _roomController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: 'Enter room number',
//                 hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
//                 prefixIcon: const Icon(
//                   Icons.meeting_room,
//                   size: 20,
//                   color: Color(0xFFE53935),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(
//                     color: Color(0xFFE0E0E0),
//                     width: 1,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(
//                     color: Color(0xFFE53935),
//                     width: 1.5,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _transferRoom,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFF80500),
//                   disabledBackgroundColor: const Color(0xFFCCCCCC),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white,
//                           ),
//                         ),
//                       )
//                     : const Text(
//                         'Transfer',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class TransferPopup extends StatefulWidget {
  final String tenantName;
  final String currentRoom;
  final String bookingId;
  final String hostelId;
  final VoidCallback onTransferComplete;

  const TransferPopup({
    super.key,
    required this.tenantName,
    required this.currentRoom,
    required this.bookingId,
    required this.hostelId,
    required this.onTransferComplete,
  });

  @override
  State<TransferPopup> createState() => _TransferPopupState();
}

class _TransferPopupState extends State<TransferPopup> {
  String? _selectedRoomType;
  String? _selectedShareType;
  String? _selectedRoomNo;
  String? _selectedBookingType; // 'monthly' or 'daily'
  List<Map<String, dynamic>> _sharings = [];
  List<String> _roomTypes = [];
  Map<String, List<String>> _shareTypesByRoomType = {};
  Map<String, List<String>> _roomNumbersByShareType = {};
  Map<String, Map<String, dynamic>> _pricingInfo =
      {}; // Store monthlyPrice and dailyPrice
  bool _isLoadingRooms = true;
  bool _isTransferring = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRoomData();
  }

  Future<void> _fetchRoomData() async {
    setState(() {
      _isLoadingRooms = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://187.127.146.52:2003/api/admin/hostel-room-sharing/${widget.hostelId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final sharings = List<Map<String, dynamic>>.from(
            data['sharings'] ?? [],
          );
          _sharings = sharings;

          // Extract room types
          final types = sharings
              .map((s) => s['type'] as String)
              .toSet()
              .toList();
          _roomTypes = types;

          // Build nested structure: Room Type -> Share Type -> Room Numbers
          for (var sharing in sharings) {
            final roomType = sharing['type'] as String;
            final shareType = sharing['shareType'] as String;
            final roomNumbers = List<String>.from(sharing['roomNumbers'] ?? []);
            final monthlyPrice = sharing['monthlyPrice'];
            final dailyPrice = sharing['dailyPrice'];

            // Store pricing info
            final pricingKey = '$roomType|$shareType';
            _pricingInfo[pricingKey] = {
              'monthlyPrice': monthlyPrice,
              'dailyPrice': dailyPrice,
            };

            // Share types by room type
            if (!_shareTypesByRoomType.containsKey(roomType)) {
              _shareTypesByRoomType[roomType] = [];
            }
            if (!_shareTypesByRoomType[roomType]!.contains(shareType)) {
              _shareTypesByRoomType[roomType]!.add(shareType);
            }

            // Room numbers by share type
            final shareKey = '$roomType|$shareType';
            if (!_roomNumbersByShareType.containsKey(shareKey)) {
              _roomNumbersByShareType[shareKey] = [];
            }
            _roomNumbersByShareType[shareKey]!.addAll(roomNumbers);
          }

          setState(() {
            _isLoadingRooms = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load rooms';
            _isLoadingRooms = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load rooms. Please try again.';
          _isLoadingRooms = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
        _isLoadingRooms = false;
      });
    }
  }

  double? _getMonthlyPrice() {
    if (_selectedRoomType != null && _selectedShareType != null) {
      final key = '${_selectedRoomType!}|${_selectedShareType!}';
      final price = _pricingInfo[key]?['monthlyPrice'];
      if (price is int) return price.toDouble();
      if (price is double) return price;
      if (price is String) return double.tryParse(price);
    }
    return null;
  }

  double? _getDailyPrice() {
    if (_selectedRoomType != null && _selectedShareType != null) {
      final key = '${_selectedRoomType!}|${_selectedShareType!}';
      final price = _pricingInfo[key]?['dailyPrice'];
      if (price is int) return price.toDouble();
      if (price is double) return price;
      if (price is String) return double.tryParse(price);
    }
    return null;
  }

  double? _getSelectedTotalAmount() {
    if (_selectedBookingType == 'monthly') {
      return _getMonthlyPrice();
    } else if (_selectedBookingType == 'daily') {
      return _getDailyPrice();
    }
    return null;
  }

  void _resetSelections() {
    setState(() {
      _selectedShareType = null;
      _selectedRoomNo = null;
      _selectedBookingType = null;
    });
  }

  Future<void> _transferRoom() async {
    if (_selectedRoomNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room number'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (_selectedRoomType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select room type'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (_selectedShareType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select share type'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (_selectedBookingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select booking type (Monthly/Daily)'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (_selectedRoomNo == widget.currentRoom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New room number is same as current room'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    final totalAmount = _getSelectedTotalAmount();
    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get price for selected room'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() {
      _isTransferring = true;
    });

    try {
      final payload = {
        'roomNo': _selectedRoomNo,
        'roomType': _selectedRoomType,
        'shareType': _selectedShareType,
        'totalAmount': totalAmount,
        'bookingType': _selectedBookingType,
      };

      print('Transfer payload: $payload'); // For debugging

      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/changebookingroomno/${widget.bookingId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.tenantName} transferred from Room ${widget.currentRoom} to Room $_selectedRoomNo ($_selectedBookingType)',
              ),
              backgroundColor: Colors.green,
            ),
          );
          widget.onTransferComplete();
        }
      } else {
        // Try to parse error message
        String errorMessage = 'Failed to transfer room';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore parse error
        }
        throw Exception(errorMessage);
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
          _isTransferring = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthlyPrice = _getMonthlyPrice();
    final dailyPrice = _getDailyPrice();
    final selectedTotalAmount = _getSelectedTotalAmount();

    // Check if daily booking is available
    final bool isDailyAvailable = dailyPrice != null && dailyPrice > 0;
    final bool isMonthlyAvailable = monthlyPrice != null && monthlyPrice > 0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SingleChildScrollView(
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

              if (_isLoadingRooms)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Color(0xFFE53935)),
                )
              else if (_error != null)
                Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE53935),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchRoomData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Room Type Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Room Type',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedRoomType,
                          hint: const Text('Select AC or Non-AC'),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.ac_unit,
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
                          items: _roomTypes.map<DropdownMenuItem<String>>((
                            type,
                          ) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    type == 'AC'
                                        ? Icons.ac_unit
                                        : Icons.thermostat,
                                    size: 16,
                                    color: const Color(0xFFE53935),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(type),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRoomType = value;
                              _selectedShareType = null;
                              _selectedRoomNo = null;
                              _selectedBookingType = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Share Type Dropdown
                    if (_selectedRoomType != null &&
                        _shareTypesByRoomType.containsKey(_selectedRoomType) &&
                        _shareTypesByRoomType[_selectedRoomType]!
                            .isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Share Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedShareType,
                            hint: const Text('Select share type'),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.people_outline,
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
                            items: _shareTypesByRoomType[_selectedRoomType]!
                                .map<DropdownMenuItem<String>>((shareType) {
                                  return DropdownMenuItem<String>(
                                    value: shareType,
                                    child: Text(shareType),
                                  );
                                })
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedShareType = value;
                                _selectedRoomNo = null;
                                _selectedBookingType = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Room Number Dropdown
                    if (_selectedRoomType != null &&
                        _selectedShareType != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Room Number',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedRoomNo,
                            hint: const Text('Select room number'),
                            decoration: InputDecoration(
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
                            items: () {
                              final shareKey =
                                  '${_selectedRoomType!}|${_selectedShareType!}';
                              final roomNumbers =
                                  _roomNumbersByShareType[shareKey] ?? [];
                              return roomNumbers
                                  .where((room) => room != widget.currentRoom)
                                  .map<DropdownMenuItem<String>>((room) {
                                    return DropdownMenuItem<String>(
                                      value: room,
                                      child: Text(room),
                                    );
                                  })
                                  .toList();
                            }(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRoomNo = value;
                                _selectedBookingType = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Booking Type Selection (Monthly/Daily) - Only at bottom
                    if (_selectedRoomNo != null &&
                        (isMonthlyAvailable || isDailyAvailable)) ...[
                      Container(
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
                              'Select Booking Type',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isMonthlyAvailable && isDailyAvailable) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedBookingType = 'monthly';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _selectedBookingType == 'monthly'
                                              ? const Color(0xFFE53935)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color:
                                                _selectedBookingType ==
                                                    'monthly'
                                                ? const Color(0xFFE53935)
                                                : Colors.grey.shade300,
                                            width:
                                                _selectedBookingType ==
                                                    'monthly'
                                                ? 0
                                                : 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.calendar_month,
                                              color:
                                                  _selectedBookingType ==
                                                      'monthly'
                                                  ? Colors.white
                                                  : const Color(0xFF4CAF50),
                                              size: 28,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Monthly',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color:
                                                    _selectedBookingType ==
                                                        'monthly'
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₹${monthlyPrice?.toStringAsFixed(2) ?? '0'}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    _selectedBookingType ==
                                                        'monthly'
                                                    ? Colors.white
                                                    : const Color(0xFF4CAF50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedBookingType = 'daily';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedBookingType == 'daily'
                                              ? const Color(0xFFE53935)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color:
                                                _selectedBookingType == 'daily'
                                                ? const Color(0xFFE53935)
                                                : Colors.grey.shade300,
                                            width:
                                                _selectedBookingType == 'daily'
                                                ? 0
                                                : 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.today,
                                              color:
                                                  _selectedBookingType ==
                                                      'daily'
                                                  ? Colors.white
                                                  : const Color(0xFFFF9800),
                                              size: 28,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Daily',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color:
                                                    _selectedBookingType ==
                                                        'daily'
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₹${dailyPrice?.toStringAsFixed(2) ?? '0'}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    _selectedBookingType ==
                                                        'daily'
                                                    ? Colors.white
                                                    : const Color(0xFFFF9800),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (isMonthlyAvailable) ...[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBookingType = 'monthly';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _selectedBookingType == 'monthly'
                                        ? const Color(0xFFE53935)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _selectedBookingType == 'monthly'
                                          ? const Color(0xFFE53935)
                                          : Colors.grey.shade300,
                                      width: _selectedBookingType == 'monthly'
                                          ? 0
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: _selectedBookingType == 'monthly'
                                            ? Colors.white
                                            : const Color(0xFF4CAF50),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Monthly Booking',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color:
                                                    _selectedBookingType ==
                                                        'monthly'
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Total Amount: ₹${monthlyPrice?.toStringAsFixed(2) ?? '0'}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    _selectedBookingType ==
                                                        'monthly'
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_selectedBookingType == 'monthly')
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else if (isDailyAvailable) ...[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBookingType = 'daily';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _selectedBookingType == 'daily'
                                        ? const Color(0xFFE53935)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _selectedBookingType == 'daily'
                                          ? const Color(0xFFE53935)
                                          : Colors.grey.shade300,
                                      width: _selectedBookingType == 'daily'
                                          ? 0
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.today,
                                        color: _selectedBookingType == 'daily'
                                            ? Colors.white
                                            : const Color(0xFFFF9800),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Daily Booking',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color:
                                                    _selectedBookingType ==
                                                        'daily'
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Total Amount: ₹${dailyPrice?.toStringAsFixed(2) ?? '0'}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    _selectedBookingType ==
                                                        'daily'
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_selectedBookingType == 'daily')
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      (_isLoadingRooms ||
                          _isTransferring ||
                          _selectedBookingType == null)
                      ? null
                      : _transferRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF80500),
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isTransferring
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
      ),
    );
  }
}

// class TenantViewScreen extends StatelessWidget {
//   final Booking booking;
//   final VoidCallback onUpdate;

//   const TenantViewScreen({
//     super.key,
//     required this.booking,
//     required this.onUpdate,
//   });

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   String _formatDateFromString(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (e) {
//       return dateStr.split('T')[0];
//     }
//   }

//   Color _getPaymentStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'paid':
//         return const Color(0xFF4CAF50);
//       case 'pending':
//         return const Color(0xFFFF9800);
//       case 'overdue':
//         return const Color(0xFFE53935);
//       default:
//         return const Color(0xFF9E9E9E);
//     }
//   }

//   void _navigateToEditPayment(BuildContext context, PaymentHistory payment) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditPaymentScreen(
//           booking: booking,
//           payment: payment,
//           onUpdate: () {
//             // Trigger refresh after update
//             onUpdate();
//             // Pop back to history screen after update
//             Navigator.pop(context);
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }

//   void _navigateToAddFirstPayment(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddFirstPaymentScreen(
//           booking: booking,
//           onUpdate: () {
//             // Trigger refresh after update
//             onUpdate();
//             // Pop back to history screen after update
//             Navigator.pop(context);
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final user = booking.userId;
//     final personalInfo = booking.personalDetails;

//     final hostel = booking.hostelId;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           personalInfo?.name ?? 'Tenant Details',
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (hostel != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF5F5),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFFFE0E0)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Hostel Information',
//                       style: TextStyle(
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       hostel.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       hostel.address,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 20),
//             const Text(
//               'Personal Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Name', value: personalInfo?.name ?? 'N/A'),
//             _DetailRow(
//               label: 'Mobile Number',
//               value: personalInfo?.mobileNumber.toString() ?? 'N/A',
//             ),
//             _DetailRow(
//               label: 'Emergency Number',
//               value: personalInfo?.emergencyNumber.toString() ?? 'N/A',
//             ),
//             _DetailRow(
//               label: 'Booking Reference',
//               value: booking.bookingReference,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Stay Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Room No', value: booking.roomNo),
//             _DetailRow(label: 'Room Type', value: booking.roomType),
//             _DetailRow(label: 'Share Type', value: booking.shareType),
//             _DetailRow(label: 'Booking Type', value: booking.bookingType),
//             _DetailRow(
//               label: 'Start Date',
//               value: _formatDate(booking.startDate),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Payment Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Total Amount', value: '₹${booking.totalAmount}'),
//             _DetailRow(label: 'Advance', value: '₹${booking.monthlyAdvance}'),
//             _DetailRow(label: 'Status', value: booking.status.toUpperCase()),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _getPaymentStatusColor(
//                   booking.currentMonthPaymentStatus,
//                 ).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: _getPaymentStatusColor(
//                     booking.currentMonthPaymentStatus,
//                   ).withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     booking.currentMonthPaymentStatus?.toLowerCase() == 'paid'
//                         ? Icons.check_circle
//                         : Icons.pending,
//                     color: _getPaymentStatusColor(
//                       booking.currentMonthPaymentStatus,
//                     ),
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Current Month Payment Status',
//                           style: TextStyle(fontSize: 12, color: Colors.black54),
//                         ),
//                         Text(
//                           booking.currentMonthPaymentStatus?.toUpperCase() ??
//                               'N/A',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: _getPaymentStatusColor(
//                               booking.currentMonthPaymentStatus,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Payment History Section
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 const Text(
//                   'Payment History',
//                   style: TextStyle(
//                     color: Color(0xFFE53935),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const Spacer(),
//                 // Show Add First Payment button only when payment history is empty
//                 if (booking.paymentHistory.isEmpty)
//                   IconButton(
//                     onPressed: () => _navigateToAddFirstPayment(context),
//                     icon: const Icon(
//                       Icons.add_circle_outline,
//                       color: Color(0xFF4CAF50),
//                       size: 28,
//                     ),
//                     tooltip: 'Add First Payment',
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             if (booking.paymentHistory.isEmpty)
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xFFEEEEEE)),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(
//                         Icons.payment_outlined,
//                         size: 48,
//                         color: Colors.black26,
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         'No payment records found',
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Tap the + button to add first payment',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color(0xFFEEEEEE)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     // Payment History Header
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFFFF5F5),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: const Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Date',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Amount',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Status',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Remaining',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 40),
//                         ],
//                       ),
//                     ),
//                     // Payment History List
//                     ...booking.paymentHistory.map((payment) {
//                       return Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                         decoration: const BoxDecoration(
//                           border: Border(
//                             top: BorderSide(color: Color(0xFFEEEEEE)),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 _formatDateFromString(payment.date),
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 '₹${payment.amount}',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF4CAF50),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 2,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: payment.status == 'paid'
//                                       ? Colors.green.withOpacity(0.1)
//                                       : Colors.orange.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   payment.status.toUpperCase(),
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w600,
//                                     color: payment.status == 'paid'
//                                         ? Colors.green
//                                         : Colors.orange,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 payment.remainingAmount > 0
//                                     ? '₹${payment.remainingAmount}'
//                                     : '₹0',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: payment.remainingAmount > 0
//                                       ? const Color(0xFFE53935)
//                                       : Colors.green,
//                                 ),
//                               ),
//                             ),
//                             // Edit Button - Only show if payment status is not 'paid'
//                             if (payment.status.toLowerCase() != 'paid')
//                               IconButton(
//                                 onPressed: () =>
//                                     _navigateToEditPayment(context, payment),
//                                 icon: const Icon(
//                                   Icons.edit,
//                                   color: Color(0xFFFF9800),
//                                   size: 20,
//                                 ),
//                                 constraints: const BoxConstraints(),
//                                 padding: EdgeInsets.zero,
//                                 splashRadius: 20,
//                               )
//                             else
//                               const SizedBox(width: 40),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 20),
//             const Text(
//               'Booking Timeline',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(
//               label: 'Created At',
//               value: _formatDate(booking.createdAt),
//             ),
//             _DetailRow(
//               label: 'Last Updated',
//               value: _formatDate(booking.updatedAt),
//             ),
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;
//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 13.5,
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 13.5,
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TenantViewScreen extends StatelessWidget {
//   final Booking booking;
//   final VoidCallback onUpdate;

//   const TenantViewScreen({
//     super.key,
//     required this.booking,
//     required this.onUpdate,
//   });

//   String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

//   String _formatDateFromString(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (e) {
//       return dateStr.split('T')[0];
//     }
//   }

//   Color _getPaymentStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'paid':
//         return const Color(0xFF4CAF50);
//       case 'pending':
//         return const Color(0xFFFF9800);
//       case 'overdue':
//         return const Color(0xFFE53935);
//       default:
//         return const Color(0xFF9E9E9E);
//     }
//   }

//   void _navigateToEditPayment(BuildContext context, PaymentHistory payment) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditPaymentScreen(
//           booking: booking,
//           payment: payment,
//           onUpdate: () {
//             onUpdate();
//             Navigator.pop(context);
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }

//   void _navigateToAddFirstPayment(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddFirstPaymentScreen(
//           booking: booking,
//           onUpdate: () {
//             onUpdate();
//             Navigator.pop(context);
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }

//   void _showEditTotalAmountDialog(BuildContext context) {
//     final TextEditingController amountController = TextEditingController(
//       text: booking.totalAmount.toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           return AlertDialog(
//             title: const Text('Edit Total Amount'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Enter new total amount for this booking',
//                   style: TextStyle(fontSize: 13, color: Colors.black54),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.currency_rupee, size: 20),
//                     hintText: 'Enter amount',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   final newAmount = double.tryParse(
//                     amountController.text.trim(),
//                   );
//                   if (newAmount == null || newAmount <= 0) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please enter a valid amount'),
//                         backgroundColor: Color(0xFFE53935),
//                       ),
//                     );
//                     return;
//                   }
//                   Navigator.pop(context);
//                   await _updateTotalAmount(context, newAmount);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                 ),
//                 child: const Text('Update'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _showEditMonthlyAdvanceDialog(BuildContext context) {
//     final TextEditingController amountController = TextEditingController(
//       text: booking.monthlyAdvance.toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           return AlertDialog(
//             title: const Text('Edit Monthly Advance'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Enter new monthly advance amount for this booking',
//                   style: TextStyle(fontSize: 13, color: Colors.black54),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.currency_rupee, size: 20),
//                     hintText: 'Enter amount',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   final newAmount = double.tryParse(
//                     amountController.text.trim(),
//                   );
//                   if (newAmount == null || newAmount <= 0) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please enter a valid amount'),
//                         backgroundColor: Color(0xFFE53935),
//                       ),
//                     );
//                     return;
//                   }
//                   Navigator.pop(context);
//                   await _updateMonthlyAdvance(context, newAmount);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                 ),
//                 child: const Text('Update'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _updateTotalAmount(
//     BuildContext context,
//     double newAmount,
//   ) async {
//     try {
//       final response = await http.put(
//         Uri.parse(
//           'http://187.127.146.52:2003/api/vendors/update-booking-total-amount/${booking.id}',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'totalAmount': newAmount}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Total amount updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => NavbarScreen(initialIndex: 1),
//           ),
//         );
//         // onUpdate();
//       } else {
//         throw Exception('Failed to update total amount');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: const Color(0xFFE53935),
//         ),
//       );
//     }
//   }

//   Future<void> _updateMonthlyAdvance(
//     BuildContext context,
//     double newAmount,
//   ) async {
//     try {
//       final response = await http.put(
//         Uri.parse(
//           'http://187.127.146.52:2003/api/vendors/update-monthly-advance/${booking.id}',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'amount': newAmount}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Monthly advance updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => NavbarScreen(initialIndex: 1),
//           ),
//         );
//         // onUpdate();
//       } else {
//         throw Exception('Failed to update monthly advance');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: const Color(0xFFE53935),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final personalInfo = booking.personalDetails;
//     final hostel = booking.hostelId;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           personalInfo?.name ?? 'Tenant Details',
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (hostel != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF5F5),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFFFE0E0)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Hostel Information',
//                       style: TextStyle(
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       hostel.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       hostel.address,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 20),
//             const Text(
//               'Personal Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // User Image - Display above name
//             if (personalInfo?.profileImage != null &&
//                 personalInfo!.profileImage.isNotEmpty)
//               Center(
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: const Color(0xFFE53935),
//                       width: 2,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: ClipOval(
//                     child: Image.network(
//                       personalInfo.profileImage,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Center(
//                           child: CircularProgressIndicator(
//                             color: const Color(0xFFE53935),
//                             value: loadingProgress.expectedTotalBytes != null
//                                 ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                 : null,
//                           ),
//                         );
//                       },
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           color: Colors.grey.shade200,
//                           child: const Icon(
//                             Icons.person,
//                             size: 50,
//                             color: Colors.grey,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Center(
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey.shade200,
//                     border: Border.all(
//                       color: const Color(0xFFE53935),
//                       width: 2,
//                     ),
//                   ),
//                   child: const Icon(Icons.person, size: 50, color: Colors.grey),
//                 ),
//               ),

//             const SizedBox(height: 16),

//             _DetailRow(label: 'Name', value: personalInfo?.name ?? 'N/A'),
//             _DetailRow(
//               label: 'Mobile Number',
//               value: personalInfo?.mobileNumber.toString() ?? 'N/A',
//             ),
//             _DetailRow(
//               label: 'Emergency Number',
//               value: personalInfo?.emergencyNumber.toString() ?? 'N/A',
//             ),
//             _DetailRow(
//               label: 'Booking Reference',
//               value: booking.bookingReference,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Stay Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(label: 'Room No', value: booking.roomNo),
//             _DetailRow(label: 'Room Type', value: booking.roomType),
//             _DetailRow(label: 'Share Type', value: booking.shareType),
//             _DetailRow(label: 'Booking Type', value: booking.bookingType),
//             _DetailRow(
//               label: 'Start Date',
//               value: _formatDate(booking.startDate),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Payment Details',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // Total Amount Row with Edit Icon
//             _DetailRowWithEdit(
//               label: 'Total Amount',
//               value: '₹${booking.totalAmount}',
//               onEdit: () => _showEditTotalAmountDialog(context),
//             ),

//             // Monthly Advance Row with Edit Icon
//             _DetailRowWithEdit(
//               label: 'Monthly Advance',
//               value: '₹${booking.monthlyAdvance}',
//               onEdit: () => _showEditMonthlyAdvanceDialog(context),
//             ),

//             // Monthly Advance Row with Edit Icon
//             _DetailRow(
//               label: 'Remaining Advance',
//               value: '₹${booking.remainingMonthlyAdvance}',
//             ),

//             _DetailRow(label: 'Status', value: booking.status.toUpperCase()),

//             // Monthly Advance Status Row
//             _DetailRow(
//               label: 'Advance Status',
//               value: booking.monthlyAdvanceStatus?.toUpperCase() ?? 'N/A',
//               valueColor: booking.monthlyAdvanceStatus?.toLowerCase() == 'paid'
//                   ? Colors.green
//                   : Colors.orange,
//             ),

//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _getPaymentStatusColor(
//                   booking.currentMonthPaymentStatus,
//                 ).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: _getPaymentStatusColor(
//                     booking.currentMonthPaymentStatus,
//                   ).withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     booking.currentMonthPaymentStatus?.toLowerCase() == 'paid'
//                         ? Icons.check_circle
//                         : Icons.pending,
//                     color: _getPaymentStatusColor(
//                       booking.currentMonthPaymentStatus,
//                     ),
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Current Month Payment Status',
//                           style: TextStyle(fontSize: 12, color: Colors.black54),
//                         ),
//                         Text(
//                           booking.currentMonthPaymentStatus?.toUpperCase() ??
//                               'N/A',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: _getPaymentStatusColor(
//                               booking.currentMonthPaymentStatus,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Payment History Section
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 const Text(
//                   'Payment History',
//                   style: TextStyle(
//                     color: Color(0xFFE53935),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const Spacer(),
//                 if (booking.paymentHistory.isEmpty)
//                   IconButton(
//                     onPressed: () => _navigateToAddFirstPayment(context),
//                     icon: const Icon(
//                       Icons.add_circle_outline,
//                       color: Color(0xFF4CAF50),
//                       size: 28,
//                     ),
//                     tooltip: 'Add First Payment',
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             if (booking.paymentHistory.isEmpty)
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xFFEEEEEE)),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(
//                         Icons.payment_outlined,
//                         size: 48,
//                         color: Colors.black26,
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         'No payment records found',
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Tap the + button to add first payment',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color(0xFFEEEEEE)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFFFF5F5),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: const Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Date',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Amount',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Status',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Remaining',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 40),
//                         ],
//                       ),
//                     ),

//                     // ...booking.paymentHistory.map((payment) {
//                     //   return Container(
//                     //     padding: const EdgeInsets.symmetric(
//                     //       horizontal: 16,
//                     //       vertical: 12,
//                     //     ),
//                     //     decoration: const BoxDecoration(
//                     //       border: Border(
//                     //         top: BorderSide(color: Color(0xFFEEEEEE)),
//                     //       ),
//                     //     ),
//                     //     child: Row(
//                     //       children: [
//                     //         Expanded(
//                     //           flex: 2,
//                     //           child: Text(
//                     //             _formatDateFromString(payment.date),
//                     //             style: const TextStyle(
//                     //               fontSize: 12,
//                     //               color: Colors.black87,
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         Expanded(
//                     //           flex: 2,
//                     //           child: Text(
//                     //             '₹${payment.amount}',
//                     //             style: const TextStyle(
//                     //               fontSize: 12,
//                     //               fontWeight: FontWeight.w600,
//                     //               color: Color(0xFF4CAF50),
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         Expanded(
//                     //           flex: 2,
//                     //           child: Container(
//                     //             padding: const EdgeInsets.symmetric(
//                     //               horizontal: 8,
//                     //               vertical: 4,
//                     //             ),
//                     //             decoration: BoxDecoration(
//                     //               color: payment.status == 'paid'
//                     //                   ? Colors.green.withOpacity(0.1)
//                     //                   : Colors.orange.withOpacity(0.1),
//                     //               borderRadius: BorderRadius.circular(12),
//                     //             ),
//                     //             child: Text(
//                     //               payment.status.toUpperCase(),
//                     //               textAlign: TextAlign.center,
//                     //               style: TextStyle(
//                     //                 fontSize: 11,
//                     //                 fontWeight: FontWeight.w600,
//                     //                 color: payment.status == 'paid'
//                     //                     ? Colors.green
//                     //                     : Colors.orange,
//                     //               ),
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         Expanded(
//                     //           flex: 2,
//                     //           child: Text(
//                     //             payment.remainingAmount > 0
//                     //                 ? '₹${payment.remainingAmount}'
//                     //                 : '₹0',
//                     //             style: TextStyle(
//                     //               fontSize: 12,
//                     //               fontWeight: FontWeight.w600,
//                     //               color: payment.remainingAmount > 0
//                     //                   ? const Color(0xFFE53935)
//                     //                   : Colors.green,
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         if (payment.status.toLowerCase() != 'paid')
//                     //           IconButton(
//                     //             onPressed: () =>
//                     //                 _navigateToEditPayment(context, payment),
//                     //             icon: const Icon(
//                     //               Icons.edit,
//                     //               color: Color(0xFFFF9800),
//                     //               size: 20,
//                     //             ),
//                     //             constraints: const BoxConstraints(),
//                     //             padding: EdgeInsets.zero,
//                     //             splashRadius: 20,
//                     //           )
//                     //         else
//                     //           const SizedBox(width: 40),
//                     //       ],
//                     //     ),
//                     //   );
//                     // }).toList(),

//                     // In the Payment History section, replace the payment history list with this:
//                     ...booking.paymentHistory.map((payment) {
//                       return Column(
//                         children: [
//                           // Main payment row
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             decoration: const BoxDecoration(
//                               border: Border(
//                                 top: BorderSide(color: Color(0xFFEEEEEE)),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     _formatDateFromString(payment.date),
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     '₹${payment.amount}',
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF4CAF50),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: payment.status == 'paid'
//                                           ? Colors.green.withOpacity(0.1)
//                                           : Colors.orange.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Text(
//                                       payment.status.toUpperCase(),
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w600,
//                                         color: payment.status == 'paid'
//                                             ? Colors.green
//                                             : Colors.orange,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     payment.remainingAmount > 0
//                                         ? '₹${payment.remainingAmount}'
//                                         : '₹0',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: payment.remainingAmount > 0
//                                           ? const Color(0xFFE53935)
//                                           : Colors.green,
//                                     ),
//                                   ),
//                                 ),
//                                 if (payment.status.toLowerCase() != 'paid')
//                                   IconButton(
//                                     onPressed: () => _navigateToEditPayment(
//                                       context,
//                                       payment,
//                                     ),
//                                     icon: const Icon(
//                                       Icons.edit,
//                                       color: Color(0xFFFF9800),
//                                       size: 20,
//                                     ),
//                                     constraints: const BoxConstraints(),
//                                     padding: EdgeInsets.zero,
//                                     splashRadius: 20,
//                                   )
//                                 else
//                                   const SizedBox(width: 40),
//                               ],
//                             ),
//                           ),

//                           // Partial Details Section - Show if partialDetails array is not empty
//                           if (payment.partialDetails != null &&
//                               payment.partialDetails.isNotEmpty)
//                             Container(
//                               padding: const EdgeInsets.only(
//                                 left: 40,
//                                 right: 16,
//                                 bottom: 12,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Divider(
//                                     height: 1,
//                                     color: Color(0xFFEEEEEE),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   const Text(
//                                     'Partial Payments',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFFFF9800),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   ...payment.partialDetails.map((partial) {
//                                     return Container(
//                                       margin: const EdgeInsets.only(bottom: 6),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 8,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFFFF5F5),
//                                         borderRadius: BorderRadius.circular(8),
//                                         border: Border.all(
//                                           color: const Color(0xFFFFE0E0),
//                                         ),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             width: 3,
//                                             height: 20,
//                                             decoration: BoxDecoration(
//                                               color: const Color(0xFFE53935),
//                                               borderRadius:
//                                                   BorderRadius.circular(2),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   _formatDateFromString(
//                                                     partial.date,
//                                                   ),
//                                                   style: const TextStyle(
//                                                     fontSize: 11,
//                                                     color: Colors.black54,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 2),
//                                                 Text(
//                                                   'Amount: ₹${partial.amount}',
//                                                   style: const TextStyle(
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Colors.black87,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 8,
//                                               vertical: 3,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: const Color(
//                                                 0xFFFF9800,
//                                               ).withOpacity(0.1),
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                             child: const Text(
//                                               'PARTIAL',
//                                               style: TextStyle(
//                                                 fontSize: 9,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Color(0xFFFF9800),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 20),
//             const Text(
//               'Booking Timeline',
//               style: TextStyle(
//                 color: Color(0xFFE53935),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _DetailRow(
//               label: 'Created At',
//               value: _formatDate(booking.createdAt),
//             ),
//             _DetailRow(
//               label: 'Last Updated',
//               value: _formatDate(booking.updatedAt),
//             ),
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//     );
//   }
// }

class TenantViewScreen extends StatefulWidget {
  final Booking booking;
  final VoidCallback onUpdate;

  const TenantViewScreen({
    super.key,
    required this.booking,
    required this.onUpdate,
  });

  @override
  State<TenantViewScreen> createState() => _TenantViewScreenState();
}

class _TenantViewScreenState extends State<TenantViewScreen> {
  String? _selectedMonthFilter;
  List<String> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _extractAvailableMonths();
  }

  void _extractAvailableMonths() {
    Set<String> months = {};

    for (var payment in widget.booking.paymentHistory) {
      try {
        final date = DateTime.parse(payment.date);
        final monthYear = '${_getMonthName(date.month)} ${date.year}';
        months.add(monthYear);
      } catch (e) {
        // Handle date parsing error
      }
    }

    setState(() {
      _availableMonths = months.toList();
      // Sort months chronologically
      _availableMonths.sort((a, b) {
        final aParts = a.split(' ');
        final bParts = b.split(' ');
        final aMonth = _getMonthNumber(aParts[0]);
        final bMonth = _getMonthNumber(bParts[0]);
        final aYear = int.parse(aParts[1]);
        final bYear = int.parse(bParts[1]);

        if (aYear != bYear) return aYear.compareTo(bYear);
        return aMonth.compareTo(bMonth);
      });
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[monthName] ?? 1;
  }

  List<PaymentHistory> _getFilteredPayments() {
    if (_selectedMonthFilter == null) {
      return widget.booking.paymentHistory;
    }

    return widget.booking.paymentHistory.where((payment) {
      try {
        final date = DateTime.parse(payment.date);
        final monthYear = '${_getMonthName(date.month)} ${date.year}';
        return monthYear == _selectedMonthFilter;
      } catch (e) {
        return false;
      }
    }).toList();
  }

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
          booking: widget.booking,
          payment: payment,
          onUpdate: () {
            widget.onUpdate();
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
          booking: widget.booking,
          onUpdate: () {
            widget.onUpdate();
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showEditTotalAmountDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController(
      text: widget.booking.totalAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Total Amount'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter new total amount for this booking',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newAmount = double.tryParse(
                    amountController.text.trim(),
                  );
                  if (newAmount == null || newAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                        backgroundColor: Color(0xFFE53935),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  await _updateTotalAmount(context, newAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditMonthlyAdvanceDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController(
      text: widget.booking.monthlyAdvance.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Monthly Advance'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter new monthly advance amount for this booking',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newAmount = double.tryParse(
                    amountController.text.trim(),
                  );
                  if (newAmount == null || newAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                        backgroundColor: Color(0xFFE53935),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  await _updateMonthlyAdvance(context, newAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateTotalAmount(
    BuildContext context,
    double newAmount,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/update-booking-total-amount/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'totalAmount': newAmount}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Total amount updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavbarScreen(initialIndex: 1),
          ),
        );
      } else {
        throw Exception('Failed to update total amount');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _updateMonthlyAdvance(
    BuildContext context,
    double newAmount,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://187.127.146.52:2003/api/vendors/update-monthly-advance/${widget.booking.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': newAmount}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monthly advance updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavbarScreen(initialIndex: 1),
          ),
        );
      } else {
        throw Exception('Failed to update monthly advance');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalInfo = widget.booking.personalDetails;
    final hostel = widget.booking.hostelId;
    final filteredPayments = _getFilteredPayments();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          personalInfo?.name ?? 'Tenant Details',
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

            // User Image
            if (personalInfo?.profileImage != null &&
                personalInfo!.profileImage.isNotEmpty)
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE53935),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      personalInfo.profileImage,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFFE53935),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: const Color(0xFFE53935),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 16),

            // _DetailRow(label: 'Name', value: personalInfo?.name ?? 'N/A'),
            // Name field - Locked TextField (read-only)
            TextField(
              controller: TextEditingController(
                text: personalInfo?.name ?? 'N/A',
              ),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            // _DetailRow(
            //   label: 'Mobile Number',
            //   value: personalInfo?.mobileNumber.toString() ?? 'N/A',
            // ),
            // Mobile Number field - Locked TextField (read-only)
            const SizedBox(height: 16),

            TextField(
              controller: TextEditingController(
                text: personalInfo?.mobileNumber.toString() ?? 'N/A',
              ),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            // _DetailRow(
            //   label: 'Emergency Number',
            //   value: personalInfo?.emergencyNumber.toString() ?? 'N/A',
            // ),
            // _DetailRow(
            //   label: 'Booking Reference',
            //   value: widget.booking.bookingReference,
            // ),
            // Emergency Number field - Locked TextField (read-only)
            const SizedBox(height: 16),

            TextField(
              controller: TextEditingController(
                text: personalInfo?.emergencyNumber.toString() ?? 'N/A',
              ),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Emergency Number',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.emergency_outlined,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            // Booking Reference field - Locked TextField (read-only)
            TextField(
              controller: TextEditingController(
                text: widget.booking.bookingReference,
              ),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Booking Reference',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.receipt_outlined,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
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
            // _DetailRow(label: 'Room No', value: widget.booking.roomNo),
            // _DetailRow(label: 'Room Type', value: widget.booking.roomType),
            // _DetailRow(label: 'Share Type', value: widget.booking.shareType),
            // _DetailRow(
            //   label: 'Booking Type',
            //   value: widget.booking.bookingType,
            // ),
            // _DetailRow(
            //   label: 'Start Date',
            //   value: _formatDate(widget.booking.startDate),
            // ),

            // Room No field - Locked TextField (read-only)
            TextField(
              controller: TextEditingController(text: widget.booking.roomNo),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Room No',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.meeting_room_outlined,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            // Room Type field - Locked TextField (read-only)
            TextField(
              controller: TextEditingController(text: widget.booking.roomType),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Room Type',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.bed_outlined,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            // Share Type field - Locked TextField (read-only)
            TextField(
              controller: TextEditingController(text: widget.booking.shareType),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Share Type',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.people_outline,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            // Booking Type field - Locked TextField (read-only)
            TextField(
              controller: TextEditingController(
                text: widget.booking.bookingType,
              ),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Booking Type',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.event_available_outlined,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            // Start Date field - Locked TextField (read-only)
            TextField(
              controller: TextEditingController(
                text: _formatDate(widget.booking.startDate),
              ),
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Start Date',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFFE53935),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Two API images in a row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "http://187.127.146.52:2003/uploads/1778829157259.jpg"
                            .toString(), // Replace with your first API image URL
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFFE53935),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "http://187.127.146.52:2003/uploads/1778829157259.jpg"
                            .toString(), // Replace with your first API image URL
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFFE53935),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            const Text(
              'Payment Details',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            _DetailRowWithEdit(
              label: 'Total Amount',
              value: '₹${widget.booking.totalAmount}',
              onEdit: () => _showEditTotalAmountDialog(context),
            ),
            _DetailRowWithEdit(
              label: 'Advance',
              value: '₹${widget.booking.monthlyAdvance}',
              onEdit: () => _showEditMonthlyAdvanceDialog(context),
            ),
            _DetailRow(
              label: 'Remaining Advance',
              value: '₹${widget.booking.remainingMonthlyAdvance}',
            ),
            _DetailRow(
              label: 'Status',
              value: widget.booking.status.toUpperCase(),
            ),
            _DetailRow(
              label: 'Advance Status',
              value:
                  widget.booking.monthlyAdvanceStatus?.toUpperCase() ?? 'N/A',
              valueColor:
                  widget.booking.monthlyAdvanceStatus?.toLowerCase() == 'paid'
                  ? Colors.green
                  : Colors.orange,
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(
                  widget.booking.currentMonthPaymentStatus,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getPaymentStatusColor(
                    widget.booking.currentMonthPaymentStatus,
                  ).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.booking.currentMonthPaymentStatus?.toLowerCase() ==
                            'paid'
                        ? Icons.check_circle
                        : Icons.pending,
                    color: _getPaymentStatusColor(
                      widget.booking.currentMonthPaymentStatus,
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
                          widget.booking.currentMonthPaymentStatus
                                  ?.toUpperCase() ??
                              'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getPaymentStatusColor(
                              widget.booking.currentMonthPaymentStatus,
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
                if (widget.booking.paymentHistory.isEmpty)
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

            // Month Filter Chips
            if (_availableMonths.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // "All" chip
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedMonthFilter == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMonthFilter = null;
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: const Color(0xFFE53935),
                      labelStyle: TextStyle(
                        color: _selectedMonthFilter == null
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedMonthFilter == null
                              ? const Color(0xFFE53935)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Month chips
                    ..._availableMonths.map((month) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(month),
                          selected: _selectedMonthFilter == month,
                          onSelected: (selected) {
                            setState(() {
                              _selectedMonthFilter = selected ? month : null;
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: const Color(0xFFE53935),
                          labelStyle: TextStyle(
                            color: _selectedMonthFilter == month
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedMonthFilter == month
                                  ? const Color(0xFFE53935)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (widget.booking.paymentHistory.isEmpty)
              Center(
                child: Container(
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
                ),
              )
            else if (filteredPayments.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.filter_alt_off,
                        size: 48,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No payments found for $_selectedMonthFilter',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedMonthFilter = null;
                          });
                        },
                        child: const Text(
                          'Clear filter',
                          style: TextStyle(color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
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

                    ...filteredPayments.map((payment) {
                      return Column(
                        children: [
                          Container(
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
                                if (payment.status.toLowerCase() != 'paid')
                                  IconButton(
                                    onPressed: () => _navigateToEditPayment(
                                      context,
                                      payment,
                                    ),
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
                          ),

                          if (payment.partialDetails != null &&
                              payment.partialDetails.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.only(
                                left: 40,
                                right: 16,
                                bottom: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFFEEEEEE),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Partial Payments',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF9800),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...payment.partialDetails.map((partial) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF5F5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFFFE0E0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 3,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE53935),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _formatDateFromString(
                                                    partial.date,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Amount: ₹${partial.amount}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFFF9800,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'PARTIAL',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFF9800),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                        ],
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
              value: _formatDate(widget.booking.createdAt),
            ),
            _DetailRow(
              label: 'Last Updated',
              value: _formatDate(widget.booking.updatedAt),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// New Detail Row with Edit Icon
class _DetailRowWithEdit extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;
  final Color? valueColor;

  const _DetailRowWithEdit({
    required this.label,
    required this.value,
    required this.onEdit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              style: TextStyle(
                fontSize: 13.5,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18, color: Color(0xFFFF9800)),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

// Updated Detail Row with optional value color
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

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
              style: TextStyle(
                fontSize: 13.5,
                color: valueColor ?? Colors.black87,
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
