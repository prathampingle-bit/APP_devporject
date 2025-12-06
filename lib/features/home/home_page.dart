import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(user?.name ?? 'Guest'),
                accountEmail: Text(user?.email ?? '-')),
            ListTile(
                title: const Text('Rooms'),
                onTap: () => Navigator.of(context).pushNamed('/rooms')),
            ListTile(
                title: const Text('Active Sessions'),
                onTap: () => Navigator.of(context).pushNamed('/rooms')),
          ],
        ),
      ),
      body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Welcome, ${user?.name ?? 'Guest'}'),
        const SizedBox(height: 16),
        ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/rooms'),
            child: const Text('View Rooms'))
      ])),
    );
  }
}
