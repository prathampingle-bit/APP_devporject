import 'dart:async';
import 'models.dart';
import 'mock_api.dart';

/// API Service for session management
/// In production, replace mockApi calls with actual HTTP requests using Dio
class ApiService {
  final MockApi _mockApi = mockApi;

  /// Get active session for a specific room
  Future<Session?> getActiveSession(String roomId) async {
    final sessions = await _mockApi.getActiveSessions();
    try {
      return sessions.firstWhere((s) => s.roomId == roomId);
    } catch (e) {
      return null;
    }
  }

  /// Start a new session
  Future<Session> startSession({
    required String roomId,
    required String staffId,
    String initiatedBy = 'MANUAL',
  }) async {
    return await _mockApi.startSession(
      roomId: roomId,
      staffId: staffId,
      initiatedBy: initiatedBy,
    );
  }

  /// End an active session
  Future<Session?> endSession(String sessionId) async {
    return await _mockApi.endSession(sessionId);
  }

  /// Get room details
  Future<Room?> getRoomById(String roomId) async {
    return await _mockApi.getRoom(roomId);
  }

  /// Get timetable for a room
  Future<List<TimetableSlot>> getRoomTimetable(String roomId) async {
    return await _mockApi.getTimetable(roomId: roomId);
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    return await _mockApi.getUserById(userId);
  }
}

final apiService = ApiService();
