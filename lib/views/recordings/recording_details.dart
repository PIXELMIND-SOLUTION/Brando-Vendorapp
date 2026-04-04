import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RecordingDetails extends StatefulWidget {
  const RecordingDetails({super.key});

  @override
  State<RecordingDetails> createState() => _RecordingDetailsState();
}

class _RecordingDetailsState extends State<RecordingDetails>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];

  final List<Map<String, dynamic>> _videos = [
    {
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'thumbnail': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
      'duration': '02:45',
      'title': 'Front Door - Motion Alert',
      'time': '08:32 AM',
      'date': 'Today',
      'camera': 'CAM 01',
      'size': '45.2 MB',
      'isNew': true,
    },
    {
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'thumbnail': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
      'duration': '01:12',
      'title': 'Backyard - Activity Detected',
      'time': '11:15 AM',
      'date': 'Today',
      'camera': 'CAM 03',
      'size': '18.7 MB',
      'isNew': true,
    },
    {
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'thumbnail': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
      'duration': '05:00',
      'title': 'Garage - Scheduled Recording',
      'time': '06:00 PM',
      'date': 'Yesterday',
      'camera': 'CAM 02',
      'size': '92.1 MB',
      'isNew': false,
    },
    {
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      'thumbnail': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
      'duration': '00:58',
      'title': 'Side Gate - Alert',
      'time': '09:44 PM',
      'date': 'Yesterday',
      'camera': 'CAM 04',
      'size': '12.3 MB',
      'isNew': false,
    },
  ];

  final List<Map<String, dynamic>> _images = [
    {
      'path': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      'time': '07:22 AM',
      'date': 'Today',
      'camera': 'CAM 01',
      'label': 'Snapshot',
    },
    {
      'path': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=400&q=80',
      'time': '10:05 AM',
      'date': 'Today',
      'camera': 'CAM 02',
      'label': 'Motion',
    },
    {
      'path': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&q=80',
      'time': '01:30 PM',
      'date': 'Today',
      'camera': 'CAM 03',
      'label': 'Alert',
    },
    {
      'path': 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=400&q=80',
      'time': '03:48 PM',
      'date': 'Today',
      'camera': 'CAM 04',
      'label': 'Snapshot',
    },
    {
      'path': 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=400&q=80',
      'time': '05:10 PM',
      'date': 'Today',
      'camera': 'CAM 01',
      'label': 'Motion',
    },
    {
      'path': 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=400&q=80',
      'time': '08:55 PM',
      'date': 'Today',
      'camera': 'CAM 02',
      'label': 'Alert',
    },
  ];

  // Camera colors for differentiation
  final Map<String, Color> _cameraColors = {
    'CAM 01': const Color(0xFF00E5FF),
    'CAM 02': const Color(0xFFFF6B35),
    'CAM 03': const Color(0xFF7CFC00),
    'CAM 04': const Color(0xFFFF3CAC),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(),
            _buildStatsBar(),
            _buildFilterChips(),
            _buildTabBar(),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildVideosTab(),
              _buildImagesTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0E1A),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child:
                const Icon(Icons.more_vert, color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Recording Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1F35),
                    Color(0xFF0A0E1A),
                  ],
                ),
              ),
            ),
            // Grid pattern overlay
            CustomPaint(painter: _GridPainter()),
            // Glowing orb
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E5FF).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Live indicator row
            Positioned(
              top: 56,
              left: 20,
              child: Row(
                children: [
                  _liveChip(),
                  const SizedBox(width: 10),
                  _recordingCountChip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFFF3B30).withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordingCountChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: const Text(
        '4 Cameras Active',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1C2136),
              const Color(0xFF161B2E),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withOpacity(0.07), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('24', 'Videos', const Color(0xFF00E5FF)),
            _divider(),
            _statItem('86', 'Photos', const Color(0xFFFF6B35)),
            _divider(),
            _statItem('12.4 GB', 'Storage', const Color(0xFF7CFC00)),
            _divider(),
            _statItem('30 Days', 'Retention', const Color(0xFFFF3CAC)),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 28, color: Colors.white.withOpacity(0.08));
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, bottom: 4),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = _selectedFilter == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF00E5FF),
                              Color(0xFF006DFF),
                            ],
                          )
                        : null,
                    color: selected
                        ? null
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      color:
                          selected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0A0E1A),
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13),
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF006DFF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.videocam_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Videos'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.photo_library_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Images'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _videos.length,
      itemBuilder: (_, i) => _VideoCard(
        video: _videos[i],
        cameraColor:
            _cameraColors[_videos[i]['camera']] ?? const Color(0xFF00E5FF),
        index: i,
      ),
    );
  }

  Widget _buildImagesTab() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ImageCard(
                image: _images[i],
                cameraColor: _cameraColors[_images[i]['camera']] ??
                    const Color(0xFF00E5FF),
              ),
              childCount: _images.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF006DFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006DFF).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon:
            const Icon(Icons.download_rounded, color: Colors.white),
        label: const Text(
          'Export All',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Video Card
// ────────────────────────────────────────────────────────────
class _VideoCard extends StatefulWidget {
  final Map<String, dynamic> video;
  final Color cameraColor;
  final int index;

  const _VideoCard({
    required this.video,
    required this.cameraColor,
    required this.index,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video['videoUrl']),
    )..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Video / Thumbnail area ──────────────────────────
          GestureDetector(
            onTap: _togglePlay,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  // Video player or network thumbnail
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: _initialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : Image.network(
                            widget.video['thumbnail'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : Container(
                                        height: 200,
                                        color: const Color(0xFF1C2136),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: progress.expectedTotalBytes !=
                                                    null
                                                ? progress
                                                        .cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes!
                                                : null,
                                            color: widget.cameraColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: const Color(0xFF1C2136),
                              child: Icon(Icons.broken_image_outlined,
                                  color: widget.cameraColor.withOpacity(0.4),
                                  size: 40),
                            ),
                          ),
                  ),

                  // Dark scrim for overlay readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.45),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Play / Pause button centre
                  Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isPlaying ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2),
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Camera badge top-left
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: widget.cameraColor.withOpacity(0.4),
                            width: 1),
                      ),
                      child: Text(
                        widget.video['camera'],
                        style: TextStyle(
                          color: widget.cameraColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Duration badge top-right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: Colors.white70, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            widget.video['duration'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // NEW badge bottom-left
                  if (widget.video['isNew'])
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                  // Video progress bar at bottom when playing
                  if (_initialized && _isPlaying)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: EdgeInsets.zero,
                        colors: VideoProgressColors(
                          playedColor: widget.cameraColor,
                          bufferedColor:
                              widget.cameraColor.withOpacity(0.3),
                          backgroundColor:
                              Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Info section ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoChip(
                        Icons.access_time_rounded,
                        '${widget.video['date']} · ${widget.video['time']}',
                        Colors.white38),
                    const Spacer(),
                    _infoChip(Icons.storage_rounded,
                        widget.video['size'], Colors.white38),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _actionBtn(Icons.play_circle_outline_rounded, 'Play',
                        widget.cameraColor, _togglePlay),
                    const SizedBox(width: 8),
                    _actionBtn(
                        Icons.share_outlined, 'Share', Colors.white38, () {}),
                    const SizedBox(width: 8),
                    _actionBtn(Icons.download_outlined, 'Save',
                        Colors.white38, () {}),
                    const Spacer(),
                    _actionBtn(Icons.delete_outline_rounded, '',
                        Colors.redAccent, () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: label.isEmpty
            ? const EdgeInsets.all(7)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final Map<String, dynamic> image;
  final Color cameraColor;

  const _ImageCard({required this.image, required this.cameraColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1322),
                    ),
                    child: Image.network(
                      image['path'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                                  color: const Color(0xFF1C2136),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                      color: cameraColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1C2136),
                        child: Icon(Icons.broken_image_outlined,
                            color: cameraColor.withOpacity(0.35), size: 32),
                      ),
                    ),
                  ),
                  // Label badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _labelColor(image['label']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _labelColor(image['label']).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        image['label'].toUpperCase(),
                        style: TextStyle(
                          color: _labelColor(image['label']),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  // Camera badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        image['camera'],
                        style: TextStyle(
                          color: cameraColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Expand icon
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.open_in_full_rounded,
                          color: Colors.white70, size: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom info
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 10, color: Colors.white38),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    image['time'],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.download_outlined,
                      size: 15, color: cameraColor.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _labelColor(String label) {
    switch (label) {
      case 'Motion':
        return const Color(0xFFFF6B35);
      case 'Alert':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF00E5FF);
    }
  }
}

class _GridPainter extends CustomPainter {
  final double opacity;
  _GridPainter({this.opacity = 0.08});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 0.5;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}