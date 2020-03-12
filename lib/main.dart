import 'package:flutter/material.dart';
import 'package:maple_crossing_application/DiscussionPage.dart';
import 'package:maple_crossing_application/EventPage.dart';
import 'package:maple_crossing_application/HomePage.dart';
import 'package:maple_crossing_application/InformationPage.dart';
import 'package:maple_crossing_application/SignupPage.dart';
import 'package:maple_crossing_application/signinPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(254, 95, 95, 1),
        textTheme: TextTheme(
          display3: TextStyle(fontSize: 52, fontWeight: FontWeight.w800),
          display2: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          display1: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color.fromRGBO(0, 0, 0, 0.3))
        )
      ),
      
      home: PrimaryScene(),
      );
  }
}

class PrimaryScene extends StatefulWidget {
  @override
  _PrimarySceneState createState() => _PrimarySceneState();
}

class _PrimarySceneState extends State<PrimaryScene> {
    int _currentIndex = 0;
    var _page = [
        HomePage(),
        DiscussionPage(),
        InformationPage(),
        EventPage(),
    ];
    
  @override
  Widget build(BuildContext context) {

    return Scaffold (

      appBar: buildAppBar(context),

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
    )
    );
  }

AppBar buildAppBar(BuildContext context) {
    var _items = {
      1 : Signin(),
      2 : Signup()
    };

    return AppBar(
      title: Text("Maple Crossing", style: Theme.of(context).textTheme.headline),
      leading: PopupMenuButton<int>(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white
              ),
            ),
          ),
          offset: Offset(0, 80),
          itemBuilder:  (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text("Sign in"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("Sign up"),
                ),
              ],
          onSelected: (index) => {
            setState((){
              Navigator.push(context,  MaterialPageRoute(builder: (context) => _items[index]));
            })
          },
        ),
    );
  }
}