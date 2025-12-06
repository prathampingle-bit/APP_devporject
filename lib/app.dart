import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';
import 'features/rooms/room_list_page.dart';
import 'features/rooms/room_detail_page.dart';

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    GoRoute(path: '/rooms', builder: (c, s) => const RoomListPage()),
    GoRoute(
        path: '/rooms/:id',
        builder: (c, s) => RoomDetailPage(roomId: s.location.split('/').last)),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Room Manager',
      theme: ThemeData(primarySwatch: Colors.indigo),
      routerConfig: _router,
    );
  }
}
