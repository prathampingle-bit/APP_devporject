import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/mock_api.dart';
import '../../core/models.dart';

class RoomDetailPage extends ConsumerWidget {
  final String roomId;
  const RoomDetailPage({required this.roomId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomDetailProvider(roomId));
    final timetableAsync = ref.watch(timetableProvider(roomId));

    return Scaffold(
      appBar: AppBar(title: const Text('Room Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            roomAsync.when(
                data: (r) => r == null
                    ? const Text('Not found')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('${r.dept} • ${r.type} • ${r.capacity} seats'),
                          const SizedBox(height: 12),
                          Row(children: [
                            ElevatedButton(
                                onPressed: () async {
                                  // Start manual session (uses mock api)
                                  final user = ref.read(authProvider);
                                  if (user == null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Login first')));
                                    return;
                                  }
                                  final s = await mockApi.startSession(
                                      roomId: r.id,
                                      staffId: user.id,
                                      initiatedBy: 'MANUAL');
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Session started: ${s.id}')));
                                  // refresh providers
                                  ref.invalidate(roomDetailProvider(r.id));
                                  ref.invalidate(activeSessionsProvider);
                                },
                                child: const Text('Start Session')),
                            const SizedBox(width: 8),
                            ElevatedButton(
                                onPressed: () async {
                                  final sessions =
                                      await mockApi.getActiveSessions();
                                  Session? active;
                                  try {
                                    active = sessions
                                        .firstWhere((s) => s.roomId == roomId);
                                  } catch (e) {
                                    active = null;
                                  }
                                  if (active == null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('No active session')));
                                    return;
                                  }
                                  await mockApi.endSession(active.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Session ended')));
                                  ref.invalidate(roomDetailProvider(roomId));
                                  ref.invalidate(activeSessionsProvider);
                                },
                                child: const Text('End Session')),
                          ])
                        ],
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e')),
            const SizedBox(height: 20),
            const Text('Today\'s Timetable',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            timetableAsync.when(
                data: (slots) => Column(
                    children: slots
                        .map((s) => ListTile(
                            title: Text(s.subject),
                            subtitle: Text('${s.day} ${s.start}-${s.end}')))
                        .toList()),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'))
          ],
        ),
      ),
    );
  }
}
