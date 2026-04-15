import 'package:flutter/material.dart';

class HomeShell extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const HomeShell({
    required this.selectedIndex,
    required this.onIndexChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: widget.onIndexChanged,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
