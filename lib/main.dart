import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maple_crossing_application/DiscussionPage.dart';
import 'package:maple_crossing_application/EventPage.dart';
import 'package:maple_crossing_application/HomePage.dart';
import 'package:maple_crossing_application/InformationPage.dart';
import 'package:maple_crossing_application/profile.dart';
import 'package:maple_crossing_application/signinPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Const.dart';


void main() {
  runApp(LoadScreen());
}

class LoadScreen extends StatelessWidget {
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
      home: FutureBuilder(
        future: checkLocalProfileData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data) {
            
            return LaunchScene();
          } else {
            return SignIn();
          }
        },
      ),
    );
  }
}

Future<bool> checkLocalProfileData() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  print(pref.getString("refresh_token") != null
      ? "refresh token:\t🟢"
      : "refresh token:\t🔴");
  print(pref.getString("access_token") != null
      ? "access token:\t🟢"
      : "access token:\t🔴");
  print(pref.getInt("expires_in") != null
      ? "expires in:\t🟢"
      : "expires in:\t🔴");
  if (pref.getString("refresh_token") == null ||
      pref.getString("access_token") == null ||
      pref.getInt("expires_in") == null ||
      pref.getInt("expires_in") <= 86400) {
    return false;
  } else {
    getNewCredentials();
    return true;
  }
}

Future<bool> getNewCredentials() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  final response = await http
      .post("https://cpritchar.scweb.ca/mapleCrossing/oauth/token", headers: {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
  }, body: {
    'grant_type': "refresh_token",
    'client_id': Const.CLIENT_ID,
    'client_secret': Const.CLIENT_SECRET,
    'refresh_token': pref.getString("refresh_token"),
  });

  final jsonResponse = json.decode(response.body);
  pref.setString('access_token', "Bearer " + jsonResponse['access_token']);
  pref.setString('refresh_token', jsonResponse['refresh_token']);
  pref.setInt('expires_in', jsonResponse['expires_in']);

  print("reset all local values...");
}

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
    var _items = {1: profilePage(), 2: profilePage()};
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
          setState(
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => _items[index]),
              );
            },
          )
        },
      ),
    );
  }
}
