import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'directory/directory_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'map_view/map_view_screen.dart';
import 'settings/settings_screen.dart';

/// ──────────────────────────────────────────────────────────────
/// Home Shell (Main Navigation)
///
/// Contains BottomNavigationBar with 4 tabs:
///   1. Directory - Browse all listings
///   2. My Listings - CRUD for user's own listings
///   3. Map View - All listings on Google Maps
///   4. Settings - Profile, preferences, sign out
///
/// How BottomNavigationBar state is preserved:
///   - Uses IndexedStack to keep all screens alive in memory
///   - When switching tabs, previous screens retain their state
///     (scroll position, search query, form inputs, etc.)
///   - Without IndexedStack, screens would be recreated on each
///     tab switch, losing state and re-fetching data
///   - The _currentIndex state variable tracks the active tab
/// ──────────────────────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DirectoryScreen(),
    MyListingsScreen(),
    MapViewScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves state of all child screens
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Directory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'My Listings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}