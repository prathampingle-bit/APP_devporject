import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/providers.dart';
import '../../core/api_service.dart';
import '../../core/models.dart';
import '../../core/app_drawer.dart';

class RoomDetailPage extends ConsumerStatefulWidget {
  final String roomId;
  const RoomDetailPage({required this.roomId, super.key});

  @override
  ConsumerState<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends ConsumerState<RoomDetailPage> {
  Timer? _refreshTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-refresh every 5 seconds for live updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        ref.invalidate(liveSessionProvider(widget.roomId));
        ref.invalidate(roomDetailProvider(widget.roomId));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomDetailProvider(widget.roomId));
    final sessionAsync = ref.watch(liveSessionProvider(widget.roomId));
    final timetableAsync = ref.watch(timetableProvider(widget.roomId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Live Classroom Control',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(liveSessionProvider(widget.roomId));
          ref.invalidate(roomDetailProvider(widget.roomId));
          ref.invalidate(timetableProvider(widget.roomId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Live Status Header Card
              roomAsync.when(
                data: (room) => room == null
                    ? _buildErrorCard('Room not found')
                    : _LiveStatusHeader(
                        room: room,
                        session: sessionAsync.value,
                      ),
                loading: () => _buildLoadingCard(),
                error: (e, _) => _buildErrorCard('Error: $e'),
              ),
              const SizedBox(height: 16),

              // 2. Live Session Panel (only when LIVE)
              sessionAsync.when(
                data: (session) {
                  if (session != null && session.status == 'ACTIVE') {
                    return _LiveSessionPanel(
                      session: session,
                      roomId: widget.roomId,
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              if (sessionAsync.value != null &&
                  sessionAsync.value!.status == 'ACTIVE')
                const SizedBox(height: 16),

              // 3. Session Control Buttons
              roomAsync.when(
                data: (room) => room == null
                    ? const SizedBox.shrink()
                    : _SessionControls(
                        room: room,
                        session: sessionAsync.value,
                        roomId: widget.roomId,
                        isLoading: _isLoading,
                        onLoadingChanged: (loading) {
                          setState(() => _isLoading = loading);
                        },
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // 4. Today's Schedule Timeline
              timetableAsync.when(
                data: (slots) => _TodayScheduleTimeline(
                  slots: slots,
                  activeSession: sessionAsync.value,
                ),
                loading: () => _buildLoadingCard(),
                error: (e, _) => _buildErrorCard('Error loading schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 1. Live Status Header Card
class _LiveStatusHeader extends StatelessWidget {
  final Room room;
  final Session? session;

  const _LiveStatusHeader({required this.room, this.session});

  @override
  Widget build(BuildContext context) {
    final isLive = session?.status == 'ACTIVE';
    final status =
        isLive ? 'LIVE' : (room.status == 'OCCUPIED' ? 'LIVE' : room.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLive
              ? [Colors.red.shade50, Colors.orange.shade50]
              : [Colors.white, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLive ? Colors.red.shade300 : Colors.blue.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isLive
                ? Colors.red.withOpacity(0.2)
                : Colors.blue.withOpacity(0.1),
            blurRadius: isLive ? 20 : 15,
            spreadRadius: isLive ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glass effect overlay
          if (isLive)
            Positioned.fill(
              child: _PulsingBorder(
                color: Colors.red.shade400,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.business,
                                label: room.dept,
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.meeting_room,
                                label: room.type,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: status, isLive: isLive),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Capacity: ${room.capacity} seats',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isLive;

  const _StatusBadge({required this.status, required this.isLive});

  Color _getStatusColor() {
    if (isLive) return Colors.red;
    switch (status) {
      case 'FREE':
        return Colors.green;
      case 'SCHEDULED':
        return Colors.blue;
      case 'OCCUPIED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(isLive ? 0.9 : 1.0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isLive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.6 * value),
                      blurRadius: 12 * value,
                      spreadRadius: 2 * value,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8 * value),
                        blurRadius: 8 * value,
                        spreadRadius: 2 * value,
                      ),
                    ],
                  ),
                ),
              if (isLive) const SizedBox(width: 8),
              Text(
                isLive ? 'LIVE' : status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PulsingBorder extends StatefulWidget {
  final Color color;

  const _PulsingBorder({required this.color});

  @override
  State<_PulsingBorder> createState() => __PulsingBorderState();
}

class __PulsingBorderState extends State<_PulsingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.color.withOpacity(0.3 + (_controller.value * 0.4)),
              width: 2 + (_controller.value * 2),
            ),
          ),
        );
      },
    );
  }
}

/// 2. Live Session Panel
class _LiveSessionPanel extends ConsumerWidget {
  final Session session;
  final String roomId;

  const _LiveSessionPanel({required this.session, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffDetailsProvider(session.staffId));

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade700, Colors.orange.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPatternPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record,
                                size: 12, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'SESSION LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _LiveClock(startTime: session.start),
                    ],
                  ),
                  const SizedBox(height: 20),
                  staffAsync.when(
                    data: (staff) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SessionInfoRow(
                          icon: Icons.person,
                          label: 'Teacher',
                          value: staff?.name ?? 'Unknown',
                        ),
                        const SizedBox(height: 12),
                        _SessionInfoRow(
                          icon: Icons.business,
                          label: 'Department',
                          value: staff?.dept ?? 'N/A',
                        ),
                        const SizedBox(height: 12),
                        _SessionInfoRow(
                          icon: Icons.book,
                          label: 'Session ID',
                          value: session.id.substring(0, 8),
                        ),
                        const SizedBox(height: 12),
                        _SessionInfoRow(
                          icon: Icons.access_time,
                          label: 'Started',
                          value: _formatTime(session.start),
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (_, __) => const Text(
                      'Error loading staff info',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _SessionInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SessionInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveClock extends StatefulWidget {
  final DateTime startTime;

  const _LiveClock({required this.startTime});

  @override
  State<_LiveClock> createState() => __LiveClockState();
}

class __LiveClockState extends State<_LiveClock> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateElapsed();
        });
      }
    });
  }

  void _updateElapsed() {
    _elapsed = DateTime.now().difference(widget.startTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$hours:$minutes:$seconds',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. Session Control Buttons
class _SessionControls extends ConsumerWidget {
  final Room room;
  final Session? session;
  final String roomId;
  final bool isLoading;
  final Function(bool) onLoadingChanged;

  const _SessionControls({
    required this.room,
    this.session,
    required this.roomId,
    required this.isLoading,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = session?.status == 'ACTIVE';
    final isReserved = room.status == 'SCHEDULED';

    return AnimatedScale(
      scale: isLoading ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLive)
            _AnimatedButton(
              onPressed: isReserved || isLoading
                  ? null
                  : () => _startSession(context, ref),
              label: 'Start Session',
              icon: Icons.play_circle_filled,
              color: Colors.green,
              isEnabled: !isReserved && !isLoading,
            )
          else
            _AnimatedButton(
              onPressed: isLoading ? null : () => _endSession(context, ref),
              label: 'End Session',
              icon: Icons.stop_circle,
              color: Colors.red,
              isEnabled: !isLoading,
            ),
          if (isReserved && !isLive)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This room is reserved for a scheduled class',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    onLoadingChanged(true);
    try {
      await apiService.startSession(
        roomId: roomId,
        staffId: user.id,
        initiatedBy: 'MANUAL',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Session started successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Refresh all providers
      ref.invalidate(liveSessionProvider(roomId));
      ref.invalidate(roomDetailProvider(roomId));
      ref.invalidate(activeSessionsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      onLoadingChanged(false);
    }
  }

  Future<void> _endSession(BuildContext context, WidgetRef ref) async {
    if (session == null) return;

    onLoadingChanged(true);
    try {
      await apiService.endSession(session!.id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Session ended successfully'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Refresh all providers
      ref.invalidate(liveSessionProvider(roomId));
      ref.invalidate(roomDetailProvider(roomId));
      ref.invalidate(activeSessionsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      onLoadingChanged(false);
    }
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color color;
  final bool isEnabled;

  const _AnimatedButton({
    this.onPressed,
    required this.label,
    required this.icon,
    required this.color,
    this.isEnabled = true,
  });

  @override
  State<_AnimatedButton> createState() => __AnimatedButtonState();
}

class __AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => _controller.forward() : null,
      onTapUp: widget.isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: widget.isEnabled ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isEnabled ? widget.color : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: widget.isEnabled ? 4 : 0,
            shadowColor: widget.color.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 24),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4. Today's Schedule Timeline
class _TodayScheduleTimeline extends StatelessWidget {
  final List<TimetableSlot> slots;
  final Session? activeSession;

  const _TodayScheduleTimeline({
    required this.slots,
    this.activeSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.calendar_today,
                      color: Colors.blue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Today\'s Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (slots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No classes scheduled today',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _TimelineItem(
                  slot: slots[index],
                  isActive:
                      false, // You can add logic to check if slot is current
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends ConsumerWidget {
  final TimetableSlot slot;
  final bool isActive;

  const _TimelineItem({
    required this.slot,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffDetailsProvider(slot.staffId));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
            if (isActive)
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red,
                      Colors.red.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? Colors.red.shade200 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        slot.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${slot.start} - ${slot.end}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                staffAsync.when(
                  data: (staff) => Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        staff?.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        slot.day,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('Error'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
