import 'package:water/componants/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:water/pages/select_page.dart';
import 'package:water/pages/about_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //navigate bottom bar
  int _selectedIndex = 0;

  bool isStarted = false;
  void navigateBottomBar(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }
  //pages to display
  final List<Widget> _pages = [
    // Home page
    SelectPage(),
    // About Page
    const About(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
        body: _pages[_selectedIndex],
    );
  }
}