import 'package:flutter/material.dart';
import 'package:maple_crossing_application/DiscussionPage.dart';
import 'package:maple_crossing_application/EventPage.dart';
import 'package:maple_crossing_application/HomePage.dart';
import 'package:maple_crossing_application/InformationPage.dart';
import 'package:maple_crossing_application/SignupPage.dart';
import 'package:maple_crossing_application/signinPage.dart';

void main() => runApp(Signin());

//this is the setup for the home page
class LaunchScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Color.fromRGBO(254, 95, 95, 1),
          textTheme: TextTheme(
              display3: TextStyle(fontSize: 52, fontWeight: FontWeight.w800),
              display2: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              display1: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(0, 0, 0, 0.3)))),
      home: ProfileScene(),
    );
  }
}

//this adds the top and bottom nav to the application
class ProfileScene extends StatefulWidget {
  @override
  _ProfileSceneState createState() => _ProfileSceneState();
}

class _ProfileSceneState extends State<ProfileScene> {
  // current page index
  int _currentIndex = 0;
  // each page per index
  var _page = {
    0: HomePage(),
    1: DiscussionPage(),
    2: InformationPage(),
    3: EventPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _page[_currentIndex],
      //add bottom navagation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // add multiple nav items to the bottom navagation bar
        items: const <BottomNavigationBarItem>[
          // home page item
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("HOME"),
          ),
          // discussion page item
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/icons/discussion_button.png")),
            title: Text("DISCUSSIONS"),
          ),
          // resource information item
          BottomNavigationBarItem(
            icon: Icon(Icons.view_quilt),
            title: Text("INFO"),
          ),
          // events item
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/icons/events_button.png"),
              ),
              title: Text("EVENTS"))
        ],
        //set the index to the starting index
        currentIndex: _currentIndex,
        onTap: (index) => {
          setState(() {
            /* once the application is set, then application will set the state,
               * and update the page with the new current page.
               */
            _currentIndex = index;
          })
        },
        iconSize: 30,
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    var _items = {1: Signin(), 2: Signup()};

    return AppBar(
      title:
          Text("Maple Crossing", style: Theme.of(context).textTheme.headline),
      leading: PopupMenuButton<int>(
        child: Icon(
          Icons.person,
          size: 40,
        ),
        offset: Offset(0, 80),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Notification"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Profile"),
          ),
        ],
        onSelected: (index) => {
          setState(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => _items[index]));
          })
        },
      ),
    );
  }
}
