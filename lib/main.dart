import 'package:flutter/material.dart';
import 'pages/start_menu.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartGame(),
    );
  }
}
