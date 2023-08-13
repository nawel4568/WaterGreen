import 'package:flutter/material.dart';
import 'package:water/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:water/pages/home_page.dart';

import 'models/home.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MaterialColor mycolor = MaterialColor(0xFF689F38, <int, Color>{
      50: Color(0xFFF1F8E9),
      100: Color(0xFFDCEDC8),
      200: Color(0xFFC5E1A5),
      300: Color(0xFFAED581),
      400: Color(0xFF9CCC65),
      500: Color(0xFF8BC34A),
      600: Color(0xFF7CB342),
      700: Color(0xFF689F38),
      800: Color(0xFF558B2F),
      900: Color(0xFF33691E),
    },
    );

    return ChangeNotifierProvider(
      create: (context) => HumidityHome(),
      builder: (context, child) =>
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: mycolor),
            home: const HomePage(),
          ),
    );
  }
}