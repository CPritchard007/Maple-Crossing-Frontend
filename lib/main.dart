import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(254, 95, 95, 1)
      ),
      home: Scaffold(
        appBar: AppBar(

        ),
        body: Row(

        ),
        bottomNavigationBar: BottomNav(),
      ),
    );
  }
}

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text("Home")
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage("assets/icons/discussion_button.png")),
          title: Text("Discussion")
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage("assets/icons/events_button.png")),
          title: Text("Events")
        )
      ],
      currentIndex: _currentIndex,
      onTap: (index) => {
        setState(() {
          _currentIndex = index;
        })
      },
    );
  }
}