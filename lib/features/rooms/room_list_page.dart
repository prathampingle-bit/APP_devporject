import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class RoomListPage extends ConsumerWidget {
  const RoomListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: roomsAsync.when(
        data: (rooms) => ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (c, i) => ListTile(
            title: Text(rooms[i].name),
            subtitle: Text('${rooms[i].dept} • ${rooms[i].type} • ${rooms[i].capacity} seats'),
            trailing: _statusBadge(rooms[i].status),
            onTap: () => Navigator.of(context).pushNamed('/rooms/${rooms[i].id}'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color c = status == 'OCCUPIED' ? Colors.red : (status == 'SCHEDULED' ? Colors.orange : Colors.green);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)), child: Text(status, style: const TextStyle(color: Colors.white)));
  }
}
