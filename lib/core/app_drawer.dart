import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final currentPath =
        GoRouter.of(context).routeInformationProvider.value.uri.path;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[600],
            ),
            accountName: Text(user?.name ?? 'Guest'),
            accountEmail: Text(user?.email ?? '-'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'G',
                style: TextStyle(fontSize: 24, color: Colors.blue[600]),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: currentPath == '/',
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentPath != '/') {
                context.go('/');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.meeting_room),
            title: const Text('Rooms'),
            selected: currentPath.startsWith('/rooms'),
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
              if (!currentPath.startsWith('/rooms')) {
                context.go('/rooms');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.nfc),
            title: const Text('NFC Verification'),
            selected: currentPath == '/nfc',
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentPath != '/nfc') {
                context.go('/nfc');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: const Text('Active Sessions'),
            onTap: () {
              Navigator.pop(context);
              context.go('/rooms');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ref.read(authProvider.notifier).state = null;
              Navigator.pop(context);
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
