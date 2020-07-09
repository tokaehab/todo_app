import 'package:flutter/material.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final MaterialColor mycolor = const MaterialColor(0xFF88B9B6, const {
    50: const Color(0xFFAFD0CE),
    100: const Color(0xFF9FC6C4),
    200: const Color(0xFF8FBDBA),
    300: const Color(0xFF5EA19C),
    400: const Color(0xFF55918D),
    500: const Color(0xFF42706D),
    600: const Color(0xFF39605E),
    700: const Color(0xFF2F504E),
    800: const Color(0xFF26403E),
    900: const Color(0xFF1C302F)
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                fontFamily: 'Galada',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color.fromRGBO(114, 27, 122, 1),
              ),
            ),
        primaryColor: Color.fromRGBO(136, 185, 182, 1),
        primarySwatch: mycolor,
        accentColor: Color.fromRGBO(114, 27, 122, 1),
      ),
      home: AuthScreen(),
    );
  }
}
