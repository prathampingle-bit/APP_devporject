import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/login_page.dart';
import 'features/auth/access_denied_page.dart';
import 'features/home/home_page.dart';
import 'features/rooms/room_list_page.dart';
import 'features/rooms/room_detail_page.dart';
import 'features/nfc/nfc_verification_page.dart';
import 'core/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  String? guardRole(String location) {
    final role = auth.role;
    if (role == null) return null;
    final path = Uri.parse(location).path;
    if (path == '/login') return null;
    if (path.startsWith('/admin')) {
      return role == 'ADMIN' ? null : '/access-denied';
    }
    if (path.startsWith('/reports')) {
      return role == 'ADMIN' ? null : '/access-denied';
    }
    if (path.startsWith('/department')) {
      return (role == 'ADMIN' || role == 'HOD') ? null : '/access-denied';
    }
    if (path.startsWith('/rooms') || path.startsWith('/live-session')) {
      return (role == 'ADMIN' || role == 'HOD' || role == 'FACULTY')
          ? null
          : '/access-denied';
    }
    return null;
  }

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = auth.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login';

      if (!isAuth && !loggingIn) return '/login';
      if (isAuth && loggingIn) return '/';

      final roleRedirect = guardRole(state.location);
      return roleRedirect;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(
          path: '/access-denied', builder: (c, s) => const AccessDeniedPage()),
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/rooms', builder: (c, s) => const RoomListPage()),
      GoRoute(
          path: '/rooms/:id',
          builder: (c, s) => RoomDetailPage(roomId: s.pathParameters['id']!)),
      GoRoute(path: '/nfc', builder: (c, s) => const NfcVerificationPage()),
    ],
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      ref.read(authControllerProvider.notifier).loadSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Room Manager',
      theme: ThemeData(primarySwatch: Colors.indigo),
      routerConfig: router,
    );
  }
}
