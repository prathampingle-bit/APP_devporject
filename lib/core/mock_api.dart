import 'dart:async';
import 'package:uuid/uuid.dart';
import 'models.dart';

const _uuid = Uuid();

class MockApi {
  // in-memory stores
  final Map<String, User> _users = {};
  final Map<String, Room> _rooms = {};
  final Map<String, TimetableSlot> _slots = {};
  final Map<String, Session> _sessions = {};

  MockApi() {
    _seed();
  }

  void _seed() {
    final admin = User(
      id: 'u_admin',
      name: 'Admin User',
      email: 'admin@inst.edu',
      dept: 'Admin',
      role: 'ADMIN',
    );
    final staff = User(
      id: 'u_staff',
      name: 'Prof. Ramesh',
      email: 'ramesh@inst.edu',
      dept: 'CSE',
      role: 'STAFF',
    );
    _users[admin.id] = admin;
    _users[staff.id] = staff;

    _rooms['r_101'] = Room(
      id: 'r_101',
      name: 'CSE-Classroom-1',
      type: 'CLASSROOM',
      dept: 'CSE',
      capacity: 60,
      status: 'FREE',
    );
    _rooms['r_201'] = Room(
      id: 'r_201',
      name: 'CSE-Lab-1',
      type: 'LAB',
      dept: 'CSE',
      capacity: 30,
      status: 'FREE',
    );

    final s1 = TimetableSlot(
      id: 't1',
      day: 'MONDAY',
      start: '09:00',
      end: '10:00',
      roomId: 'r_101',
      staffId: 'u_staff',
      subject: 'DSA',
    );
    _slots[s1.id] = s1;
  }

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _users.values.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<List<Room>> getRooms({String? dept, String? type}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _rooms.values.toList();
    if (dept != null) list = list.where((r) => r.dept == dept).toList();
    if (type != null) list = list.where((r) => r.type == type).toList();
    return list;
  }

  Future<Room?> getRoom(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rooms[id];
  }

  Future<List<TimetableSlot>> getTimetable({String? roomId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _slots.values.toList();
    if (roomId != null) list = list.where((s) => s.roomId == roomId).toList();
    return list;
  }

  Future<Session> startSession({
    required String roomId,
    required String staffId,
    String initiatedBy = 'MANUAL',
  }) async {
    final id = _uuid.v4();
    final session = Session(
      id: id,
      roomId: roomId,
      staffId: staffId,
      start: DateTime.now(),
      status: 'ACTIVE',
      initiatedBy: initiatedBy,
    );
    _sessions[id] = session;
    _rooms[roomId] = Room(
      id: _rooms[roomId]!.id,
      name: _rooms[roomId]!.name,
      type: _rooms[roomId]!.type,
      dept: _rooms[roomId]!.dept,
      capacity: _rooms[roomId]!.capacity,
      status: 'OCCUPIED',
    );
    return session;
  }

  Future<Session?> endSession(String sessionId) async {
    final s = _sessions[sessionId];
    if (s == null) return null;
    final ended = Session(
      id: s.id,
      roomId: s.roomId,
      staffId: s.staffId,
      start: s.start,
      end: DateTime.now(),
      status: 'ENDED',
      initiatedBy: s.initiatedBy,
    );
    _sessions[sessionId] = ended;
    _rooms[s.roomId] = Room(
      id: _rooms[s.roomId]!.id,
      name: _rooms[s.roomId]!.name,
      type: _rooms[s.roomId]!.type,
      dept: _rooms[s.roomId]!.dept,
      capacity: _rooms[s.roomId]!.capacity,
      status: 'FREE',
    );
    return ended;
  }

  Future<List<Session>> getActiveSessions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions.values.where((s) => s.status == 'ACTIVE').toList();
  }

  Future<User?> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _users[userId];
  }
}

final mockApi = MockApi();
