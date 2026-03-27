import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    int currentIndex = 0;
    if (location.startsWith('/matches')) currentIndex = 1;
    if (location.startsWith('/teams') || location.startsWith('/players')) currentIndex = 2;
    if (location.startsWith('/tournaments')) currentIndex = 3;
    if (location.startsWith('/settings')) currentIndex = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/matches');
              break;
            case 2:
              context.go('/teams');
              break;
            case 3:
              context.go('/tournaments');
              break;
            case 4:
              // context.go('/settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.nflGold,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.scoreboard), label: 'Partidos'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Equipos'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Torneos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
