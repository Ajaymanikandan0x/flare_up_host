import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flare_up_host/features/location/presentation/screens/location_screen.dart';
import 'package:flutter/material.dart';

import '../../features/events/presentation/screens/add_event.dart';
import '../../features/home/presentation/screens/home.dart';
import '../theme/app_palette.dart';

class AppNav extends StatefulWidget {
  const AppNav({super.key});

  @override
  State<AppNav> createState() => _AppNavState();
}

class _AppNavState extends State<AppNav> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  late PageController pageController;

  final List<Widget> _pages = [
    const HostHome(),
    const AddEventScreen(),
    const LocationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            tabIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CircleNavBar(
        activeIcons: [
          Icon(Icons.home,
              color: Theme.of(context).colorScheme.secondary, size: 24),
          Icon(Icons.add,
              color: Theme.of(context).colorScheme.secondary, size: 24),
          Icon(Icons.chat,
              color: Theme.of(context).colorScheme.secondary, size: 24),
        ],
        inactiveIcons: [
          Text("Home",
              style: TextStyle(
                  color: isDark ? AppPalette.darkText : AppPalette.lightText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          Text("Add",
              style: TextStyle(
                  color: isDark ? AppPalette.darkText : AppPalette.lightText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          Text("Chat",
              style: TextStyle(
                  color: isDark ? AppPalette.darkText : AppPalette.lightText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
        gradient: AppPalette.primaryGradient,
        height: 65,
        circleWidth: 55,
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
        },
        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1, top: 8),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        shadowColor: AppPalette.gradient2.withOpacity(0.3),
        elevation: 8,
        color: AppPalette.gradient2,
      ),
    );
  }
}
