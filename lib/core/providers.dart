import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_api.dart';
import 'models.dart';
import 'api_service.dart';
import 'auth_api.dart';
import 'auth_controller.dart';

// Auth
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(api: authApi);
});

// Data providers
final roomsProvider = FutureProvider.autoDispose<List<Room>>((ref) async {
  final api = mockApi;
  return api.getRooms();
});

final roomDetailProvider =
    FutureProvider.family.autoDispose<Room?, String>((ref, id) async {
  return apiService.getRoomById(id);
});

final timetableProvider = FutureProvider.family
    .autoDispose<List<TimetableSlot>, String>((ref, roomId) async {
  return apiService.getRoomTimetable(roomId);
});

final activeSessionsProvider =
    FutureProvider.autoDispose<List<Session>>((ref) async {
  return mockApi.getActiveSessions();
});

// Live session provider for specific room
final liveSessionProvider =
    FutureProvider.family.autoDispose<Session?, String>((ref, roomId) async {
  return apiService.getActiveSession(roomId);
});

// Staff details provider
final staffDetailsProvider =
    FutureProvider.family.autoDispose<User?, String>((ref, staffId) async {
  return apiService.getUserById(staffId);
});

// Auto-refresh timer provider for live updates
final autoRefreshProvider =
    StreamProvider.family<int, int>((ref, intervalSeconds) {
  return Stream.periodic(
    Duration(seconds: intervalSeconds),
    (count) => count,
  );
});
