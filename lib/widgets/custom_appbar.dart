import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;

  CustomAppBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _getAppBarIcon(),
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 241, 243, 247),
      toolbarHeight: 72.0,
    );
  }

Widget _getAppBarIcon() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 12.0), // Biar lebih ke kiri
      child: Image.asset(
        _getAssetPath(), // Panggil method buat dapetin path
        height: 36, // Sesuaikan dengan height di Figma
      ),
    ),
  );
}

String _getAssetPath() {
  switch (currentIndex) {
    case 0:
      return 'assets/db_appbar.png';
    case 1:
      return 'assets/sts_appbar.png';
    case 2:
      return 'assets/tune_appbar.png';
    case 3:
      return ''; // Kasih path lain kalau ada
    default:
      return '';
  }
}


  // Widget _getAppBarTitle() {
  //   switch (currentIndex) {
  //     case 0:
  //       return Text('Dashboard');
  //     case 1:
  //       return Text('Stats');
  //     case 2:
  //       return Text('Tune');
  //     case 3:
  //       return Text('Etc');
  //     default:
  //       return Text('Page');
  //   }
  // }

  @override
  Size get preferredSize => Size.fromHeight(72.0);
}
