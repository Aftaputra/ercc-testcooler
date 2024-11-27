import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
      selectedIconTheme: IconThemeData(size: 24),
      unselectedIconTheme: IconThemeData(size: 24),
      items: [
        BottomNavigationBarItem(
          icon: GestureDetector(
            behavior: HitTestBehavior.opaque, // Disable feedback
            child: SvgPicture.asset(
              'assets/home_${currentIndex == 0 ? 'active' : 'idle'}.svg',
              width: 24,
              height: 24,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            behavior: HitTestBehavior.opaque, // Disable feedback
            child: SvgPicture.asset(
              'assets/stats_${currentIndex == 1 ? 'active' : 'idle'}.svg',
              width: 24,
              height: 24,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            behavior: HitTestBehavior.opaque, // Disable feedback
            child: SvgPicture.asset(
              'assets/tune_${currentIndex == 2 ? 'active' : 'idle'}.svg',
              width: 24,
              height: 24,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            behavior: HitTestBehavior.opaque, // Disable feedback
            child: SvgPicture.asset(
              'assets/etc_${currentIndex == 3 ? 'active' : 'idle'}.svg',
              width: 24,
              height: 24,
            ),
          ),
          label: '',
        ),
      ],
    );
  }
}
