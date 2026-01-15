class User {
  final String id;
  final String name;
  final String email;
  final String dept;
  final String role; // ADMIN, HOD, STAFF, FACULTY

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.dept,
      required this.role});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id']?.toString() ?? '',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        dept: j['department'] ?? j['dept'] ?? '', // Backend sends 'department'
        role: j['role'] ?? '',
      );
}

class Room {
  final String id;
  final String name;
  final String type; // CLASSROOM | LAB | SEMINAR
  final String dept;
  final int capacity;
  final String status; // FREE | OCCUPIED | SCHEDULED

  Room(
      {required this.id,
      required this.name,
      required this.type,
      required this.dept,
      required this.capacity,
      required this.status});

  factory Room.fromJson(Map<String, dynamic> j) => Room(
        id: j['id'],
        name: j['name'],
        type: j['type'],
        dept: j['dept'],
        capacity: j['capacity'],
        status: j['status'] ?? 'FREE',
      );
}

class TimetableSlot {
  final String id;
  final String day;
  final String start;
  final String end;
  final String roomId;
  final String staffId;
  final String subject;

  TimetableSlot(
      {required this.id,
      required this.day,
      required this.start,
      required this.end,
      required this.roomId,
      required this.staffId,
      required this.subject});

  factory TimetableSlot.fromJson(Map<String, dynamic> j) => TimetableSlot(
        id: j['id'],
        day: j['day'],
        start: j['start_time'],
        end: j['end_time'],
        roomId: j['room_id'],
        staffId: j['staff_id'],
        subject: j['subject'],
      );
}

class Session {
  final String id;
  final String roomId;
  final String staffId;
  final DateTime start;
  final DateTime? end;
  final String status;
  final String initiatedBy;

  Session(
      {required this.id,
      required this.roomId,
      required this.staffId,
      required this.start,
      this.end,
      required this.status,
      required this.initiatedBy});
}
