import 'package:flutter/material.dart';
import 'package:maple_crossing_application/DiscussionPage.dart';
import 'package:maple_crossing_application/EventPage.dart';
import 'package:maple_crossing_application/HomePage.dart';
import 'package:maple_crossing_application/InformationPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(254, 95, 95, 1)
      ),
      home: BottomNav()
      );
  }
}

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
    int _currentIndex = 0;
    var _page = [
        HomePage(),
        DiscussionPage(),
        InformationPage(),
        EventPage(),
    ];
    
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50)
            ),
          ),
        ),
        title: Text("Maple Crossing"),
      ),

      body: _page[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(

      type: BottomNavigationBarType.fixed,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("HOME")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarms),
            title: Text("DISCUSSIONS")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessible_forward),
            title: Text("INFO")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            title: Text("EVENTS")
          )
        ],

        currentIndex: _currentIndex,
        
        onTap: (index) => {
          setState((){
            _currentIndex = index;
          })
        },
    ));
  }
}

