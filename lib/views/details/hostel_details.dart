import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brando_vendor/model/create_hostel_model.dart';


class HostelDetails extends StatefulWidget {
  final Hostel hostel;
  final String? qrUrl;

  const HostelDetails({
    super.key,
    required this.hostel,
    this.qrUrl,
  });

  @override
  State<HostelDetails> createState() => _HostelDetailsState();
}

class _HostelDetailsState extends State<HostelDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _showDailyPrice = false;

  // ── helpers ──────────────────────────────────────────────────────────
  bool get _isAc {
    final types = widget.hostel.type.map((t) => t.trim().toUpperCase()).toList();
    if (types.any((t) => t == 'NON-AC' || t == 'NON AC')) return false;
    return types.contains('AC');
  }

  List<SharingOption> get _sharings {
    if (widget.hostel.sharings.isNotEmpty) return widget.hostel.sharings;
    final rooms = widget.hostel.rooms;
    if (rooms == null) return [];
    return _isAc
        ? (rooms.ac.isNotEmpty ? rooms.ac : rooms.nonAc)
        : (rooms.nonAc.isNotEmpty ? rooms.nonAc : rooms.ac);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── open map ──────────────────────────────────────────────────────────
  Future<void> _openMap() async {
    final lat = widget.hostel.latitude;
    final lng = widget.hostel.longitude;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── open whatsapp ─────────────────────────────────────────────────────
  Future<void> _openWhatsApp(String phone) async {
    final msg = Uri.encodeComponent('Hello, I am interested in your hostel.');
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── QR full-screen dialog ─────────────────────────────────────────────
  void _showQrFullscreen() {
    if (widget.qrUrl == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Scan QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.hostel.name,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.qrUrl!,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 220,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.qr_code, size: 80, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.qrUrl!));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR URL copied!'), backgroundColor: Colors.green),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.copy, size: 14, color: Color(0xFFE53935)),
                  SizedBox(width: 6),
                  Text('Copy URL',
                      style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close',
                    style: TextStyle(color: Colors.black54))),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hostel = widget.hostel;
    final sharings = _sharings;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── Hero image app-bar ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
                actions: [
                  if (widget.qrUrl != null)
                    GestureDetector(
                      onTap: _showQrFullscreen,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.qr_code_2,
                            color: Color(0xFFE53935), size: 22),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(fit: StackFit.expand, children: [
                    // Image carousel / single image
                    hostel.images.isNotEmpty
                        ? _ImageCarousel(images: hostel.images)
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.apartment,
                                size: 80, color: Colors.grey)),
                    // Gradient overlay at bottom
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Bottom-left badge
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: _TypeBadge(isAc: _isAc, typeLabel: hostel.type.join(' / ')),
                    ),
                  ]),
                ),
              ),

              // ── Body content ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Name + rating row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(hostel.name,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.amber.shade200)),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 3),
                                Text('${hostel.rating}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Address
                      Row(children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Color(0xFFE53935)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(hostel.address,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // ── Info tiles row ───────────────────────────
                      Row(children: [
                        _InfoTile(
                            icon: Icons.currency_rupee,
                            label: 'Advance',
                            value:
                                '₹${hostel.monthlyAdvance.toStringAsFixed(0)}'),
                        const SizedBox(width: 8),
                        _InfoTile(
                            icon: Icons.my_location,
                            label: 'Lat / Lng',
                            value:
                                '${hostel.latitude.toStringAsFixed(4)}, ${hostel.longitude.toStringAsFixed(4)}'),
                      ]),

                      const SizedBox(height: 20),

                      // ── QR Code card ─────────────────────────────
                      if (widget.qrUrl != null) ...[
                        _SectionTitle(title: 'QR Code', icon: Icons.qr_code),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _showQrFullscreen,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(children: [
                              // QR thumbnail
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.qrUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.qr_code,
                                        size: 40,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Hostel QR Code',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      const Text(
                                          'Tap to view full size or share with guests.',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54)),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.zoom_in,
                                                  size: 13,
                                                  color: Colors.white),
                                              SizedBox(width: 4),
                                              Text('View Full Size',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                    ]),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Pricing ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionTitle(
                              title: 'Pricing', icon: Icons.attach_money),
                          // Monthly / Daily toggle
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.grey.shade300),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ToggleChip(
                                    label: 'Monthly',
                                    selected: !_showDailyPrice,
                                    onTap: () => setState(
                                        () => _showDailyPrice = false),
                                  ),
                                  _ToggleChip(
                                    label: 'Daily',
                                    selected: _showDailyPrice,
                                    onTap: () => setState(
                                        () => _showDailyPrice = true),
                                  ),
                                ]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (sharings.isEmpty)
                        const Text('No pricing info available.',
                            style: TextStyle(
                                color: Colors.black45, fontSize: 13))
                      else
                        _PricingGrid(
                          sharings: sharings,
                          showDaily: _showDailyPrice,
                          isAc: _isAc,
                        ),

                      const SizedBox(height: 20),

                      // ── Action Buttons ────────────────────────────
                      _SectionTitle(title: 'Contact', icon: Icons.contact_phone),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        _ContactBtn(
                          icon: Icons.call,
                          label: 'Call',
                          color: const Color(0xFF4CAF50),
                          onTap: () async {
                            final uri =
                                Uri(scheme: 'tel', path: '9961593179');
                            if (await canLaunchUrl(uri))
                              await launchUrl(uri);
                          },
                        ),
                        _ContactBtn(
                          icon: Icons.chat_bubble_outline,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () => _openWhatsApp('919961593179'),
                        ),
                        _ContactBtn(
                          icon: Icons.map_outlined,
                          label: 'Directions',
                          color: const Color(0xFF2196F3),
                          onTap: _openMap,
                        ),
                      ]),

                      const SizedBox(height: 30),
                    ],
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

// ─────────────────────────────────────────────
// IMAGE CAROUSEL (hero images)
// ─────────────────────────────────────────────
class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  const _ImageCarousel({required this.images});
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      PageView.builder(
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (_, i) => Image.network(
          widget.images[i],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image,
                  size: 60, color: Colors.grey)),
        ),
      ),
      if (widget.images.length > 1)
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${_page + 1}/${widget.images.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ),
    ]);
  }
}

// ─────────────────────────────────────────────
// TYPE BADGE
// ─────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final bool isAc;
  final String typeLabel;
  const _TypeBadge({required this.isAc, required this.typeLabel});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(typeLabel,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 6),
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isAc ? Colors.blue.shade700 : Colors.orange.shade700,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(isAc ? 'AC' : 'Non-AC',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16, color: const Color(0xFFE53935)),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
      ]);
}

// ─────────────────────────────────────────────
// INFO TILE
// ─────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: const Color(0xFFE53935)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black45)),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]),
            ),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────
// PRICING GRID
// ─────────────────────────────────────────────
class _PricingGrid extends StatelessWidget {
  final List<SharingOption> sharings;
  final bool showDaily;
  final bool isAc;
  const _PricingGrid(
      {required this.sharings,
      required this.showDaily,
      required this.isAc});

  double? _price(SharingOption s) {
    if (showDaily) {
      return s.dailyPrice ?? s.acDailyPrice ?? s.nonAcDailyPrice;
    } else {
      return s.monthlyPrice ?? s.acMonthlyPrice ?? s.nonAcMonthlyPrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.3),
      itemCount: sharings.length,
      itemBuilder: (_, i) {
        final s = sharings[i];
        final price = _price(s);
        final color = isAc ? Colors.blue.shade700 : const Color(0xFFE53935);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.75)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.shareType,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  price != null
                      ? '₹${price.toStringAsFixed(0)}'
                      : '—',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(showDaily ? '/day' : '/mo',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 9)),
              ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// TOGGLE CHIP (Monthly / Daily)
// ─────────────────────────────────────────────
class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE53935)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      selected ? Colors.white : Colors.black54)),
        ),
      );
}

// ─────────────────────────────────────────────
// CONTACT BUTTON
// ─────────────────────────────────────────────
class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}