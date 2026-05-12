import 'dart:convert';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/helper/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─── Models ──────────────────────────────────────────────────────────────────

class PersonalDetails {
  final String name;
  final String mobileNumber;
  final String emergencyNumber;
  final String profileImage;

  PersonalDetails({
    required this.name,
    required this.mobileNumber,
    required this.emergencyNumber,
    required this.profileImage,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) =>
      PersonalDetails(
        name: json['name'] ?? '',
        mobileNumber: json['mobileNumber'] ?? '',
        emergencyNumber: json['emergencyNumber'] ?? '',
        profileImage: json['profileImage'] ?? '',
      );
}

class HostelInfo {
  final String id;
  final String name;

  HostelInfo({required this.id, required this.name});

  factory HostelInfo.fromJson(Map<String, dynamic> json) =>
      HostelInfo(id: json['id'] ?? '', name: json['name'] ?? '');
}

class Member {
  final String userId;
  final PersonalDetails personalDetails;
  final HostelInfo hostel;
  final double totalBookedAmount;
  final double paidAmount;
  final double pendingAmount;
  final String status;

  Member({
    required this.userId,
    required this.personalDetails,
    required this.hostel,
    required this.totalBookedAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    userId: json['userId'] ?? '',
    personalDetails: PersonalDetails.fromJson(json['personalDetails'] ?? {}),
    hostel: HostelInfo.fromJson(json['hostel'] ?? {}),
    totalBookedAmount: (json['totalBookedAmount'] ?? 0).toDouble(),
    paidAmount: (json['paidAmount'] ?? 0).toDouble(),
    pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
    status: json['status'] ?? '',
  );
}

class DashboardData {
  final double totalAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final int totalMembers;
  final int paidMembersCount;
  final int pendingMembersCount;
  final List<Member> paidMembers;
  final List<Member> pendingMembers;

  DashboardData({
    required this.totalAmount,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
    required this.totalMembers,
    required this.paidMembersCount,
    required this.pendingMembersCount,
    required this.paidMembers,
    required this.pendingMembers,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    totalPaidAmount: (json['totalPaidAmount'] ?? 0).toDouble(),
    totalPendingAmount: (json['totalPendingAmount'] ?? 0).toDouble(),
    totalMembers: json['totalMembers'] ?? 0,
    paidMembersCount: json['paidMembersCount'] ?? 0,
    pendingMembersCount: json['pendingMembersCount'] ?? 0,
    paidMembers: (json['paidMembers'] as List<dynamic>? ?? [])
        .map((e) => Member.fromJson(e))
        .toList(),
    pendingMembers: (json['pendingMembers'] as List<dynamic>? ?? [])
        .map((e) => Member.fromJson(e))
        .toList(),
  );
}

// ─── API Service ─────────────────────────────────────────────────────────────

class VendorApiService {
  static const String _baseUrl = '${ApiConstant.baseUrl}';

  static Future<DashboardData> fetchDashboard(String vendorId) async {
    final uri = Uri.parse('$_baseUrl/vendordashboard/$vendorId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return DashboardData.fromJson(json['data']);
      }
      throw Exception('API returned success: false');
    } else {
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    }
  }
}

// ─── Theme ───────────────────────────────────────────────────────────────────

class AppTheme {
  static const Color bg = Color(0xFF0F0F14);
  static const Color surface = Color(0xFF1A1A24);
  static const Color surfaceElevated = Color(0xFF22222F);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentGlow = Color(0x336C63FF);
  static const Color success = Color(0xFF2ECC71);
  static const Color successBg = Color(0x1A2ECC71);
  static const Color warning = Color(0xFFFF6B35);
  static const Color warningBg = Color(0x1AFF6B35);
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color border = Color(0xFF2A2A3A);
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class Analysis extends StatefulWidget {
  final String vendorId;

  const Analysis({super.key, this.vendorId = 'YOUR_VENDOR_ID'});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> with TickerProviderStateMixin {
  DashboardData? _data;
  bool _isLoading = true;
  String? _error;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadDashboard();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final vendor = await SharedPreferenceHelper.getVendorId();
      final data = await VendorApiService.fetchDashboard(vendor.toString());
      setState(() {
        _data = data;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 102, 102, 102),
      body: SafeArea(
        child: _isLoading
            ? _buildLoader()
            : _error != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  // ── Loader ────────────────────────────────────────────────────────────────

  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppTheme.warning,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _PillButton(label: 'Retry', onTap: _loadDashboard),
          ],
        ),
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────────────────────

  Widget _buildContent() {
    final d = _data!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        color: AppTheme.accent,
        backgroundColor: AppTheme.surface,
        onRefresh: _loadDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _RevenueCard(data: d),
                  const SizedBox(height: 16),
                  _MemberStatsRow(data: d),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Paid Members',
                    count: d.paidMembersCount,
                    color: AppTheme.success,
                  ),
                  const SizedBox(height: 12),
                  ...d.paidMembers.map((m) => _MemberCard(member: m)),
                  if (d.paidMembers.isEmpty)
                    _EmptyState(label: 'No paid members'),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Pending Members',
                    count: d.pendingMembersCount,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(height: 12),
                  ...d.pendingMembers.map((m) => _MemberCard(member: m)),
                  if (d.pendingMembers.isEmpty)
                    _EmptyState(label: 'No pending members'),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.bg,
      elevation: 0,
      floating: true,
      pinned: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentGlow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppTheme.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendor Dashboard',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Revenue & Members',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loadDashboard,
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── Revenue Card ─────────────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final DashboardData data;
  const _RevenueCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final paidPct = data.totalAmount > 0
        ? data.totalPaidAmount / data.totalAmount
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surface, AppTheme.surfaceElevated],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Revenue',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGlow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(paidPct * 100).toStringAsFixed(0)}% collected',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_fmt(data.totalAmount)}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, color: AppTheme.border),
                FractionallySizedBox(
                  widthFactor: paidPct.clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.success, Color(0xFF27AE60)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AmountChip(
                  label: 'Paid',
                  amount: data.totalPaidAmount,
                  color: AppTheme.success,
                  bgColor: AppTheme.successBg,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AmountChip(
                  label: 'Pending',
                  amount: data.totalPendingAmount,
                  color: AppTheme.warning,
                  bgColor: AppTheme.warningBg,
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _AmountChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${_fmt(amount)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

// ─── Member Stats Row ─────────────────────────────────────────────────────────

class _MemberStatsRow extends StatelessWidget {
  final DashboardData data;
  const _MemberStatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Total',
            value: data.totalMembers.toString(),
            icon: Icons.groups_rounded,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'Paid',
            value: data.paidMembersCount.toString(),
            icon: Icons.how_to_reg_rounded,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'Pending',
            value: data.pendingMembersCount.toString(),
            icon: Icons.person_outline_rounded,
            color: AppTheme.warning,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Member Card ──────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final Member member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final isPaid = member.status == 'paid';
    final statusColor = isPaid ? AppTheme.success : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              _Avatar(imageUrl: member.personalDetails.profileImage),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.personalDetails.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        _StatusBadge(status: member.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 11,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.personalDetails.mobileNumber,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 11,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.hostel.name,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppTheme.border),
          const SizedBox(height: 12),
          // Amounts row
          Row(
            children: [
              _AmountInfo(
                label: 'Booked',
                value: member.totalBookedAmount,
                color: AppTheme.textSecondary,
              ),
              _divider(),
              _AmountInfo(
                label: 'Paid',
                value: member.paidAmount,
                color: AppTheme.success,
              ),
              _divider(),
              _AmountInfo(
                label: 'Pending',
                value: member.pendingAmount,
                color: AppTheme.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 28,
    color: AppTheme.border,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppTheme.surfaceElevated,
            child: const Icon(
              Icons.person,
              color: AppTheme.textSecondary,
              size: 22,
            ),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppTheme.surfaceElevated,
              child: const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'paid';
    final color = isPaid ? AppTheme.success : AppTheme.warning;
    final icon = isPaid ? Icons.check_rounded : Icons.schedule_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            isPaid ? 'Paid' : 'Pending',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountInfo extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _AmountInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '₹${_fmt(value)}',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      ),
    );
  }
}

// ─── Pill Button ──────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fmt(double amount) {
  if (amount >= 100000) {
    return '${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return amount.toStringAsFixed(0);
}
