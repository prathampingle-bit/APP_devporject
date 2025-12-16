import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const NavigationWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  static BottomNavigationBar buildBottomNavBar(
      BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0097A7),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/rooms');
            break;
          case 2:
            context.go('/nfc');
            break;
          case 3:
            // Reports or other section
            context.go('/');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.meeting_room),
          label: 'Rooms',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.nfc),
          label: 'NFC',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
