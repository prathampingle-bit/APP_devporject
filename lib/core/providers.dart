import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_api.dart';
import 'models.dart';

final authProvider = StateProvider<User?>((ref) => null);

final roomsProvider = FutureProvider.autoDispose<List<Room>>((ref) async {
  final api = mockApi;
  return api.getRooms();
});

final roomDetailProvider = FutureProvider.family.autoDispose<Room?, String>((ref, id) async {
  return mockApi.getRoom(id);
});

final timetableProvider = FutureProvider.family.autoDispose<List<TimetableSlot>, String?>((ref, roomId) async {
  return mockApi.getTimetable(roomId: roomId);
});

final activeSessionsProvider = FutureProvider.autoDispose<List<Session>>((ref) async {
  return mockApi.getActiveSessions();
});
