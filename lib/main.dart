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
  //######################
  //  ( ▷ ) Starting Scene
  runApp(LoadScreen());
}

class LoadScreen extends StatelessWidget {
  //######################################
  //    The Application will load the
  //    default scene, including the
  //    default theme data. after this
  //    is added, the application will
  //    check if the application contains
  //    the users refresh_token, or if
  //    the user needs to sign in.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          backgroundColor: Color.fromRGBO(240, 240, 240, 1),
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
            //the user has joined into the application previously,
            //this will move the user straight to the home page.
            return Scene();
          } else {
            //the user has not signed in yet, so the user is sent to
            //the user signin page.
            return SignIn();
          }
        },
      ),
    );
  }
  //######################################
}

Future<bool> checkLocalProfileData() async {
  //########################################
  //     does the user need to log in?
  SharedPreferences pref = await SharedPreferences.getInstance();

  // the application has the users refresh token already?
  print(pref.getString("refresh_token") != null
      ? "refresh token:\t🟢" // YES
      : "refresh token:\t🔴"); // NO
  // the applcation has a current access token?
  print(pref.getString("access_token") != null
      ? "access token:\t🟢" // YES
      : "access token:\t🔴"); // NO
  // the application has a current expired_in date?
  print(pref.getInt("expires_in") != null
      ? "expires in:\t🟢" // YES
      : "expires in:\t🔴"); // NO
  // Print the answer to the console and return to LoadScreen()
  if (pref.getString("refresh_token") == null ||
      pref.getString("access_token") == null ||
      pref.getInt("expires_in") == null ||
      pref.getInt("expires_in") <= 86400) {
    return false;
  } else {
    // refresh new files for the user
    getNewCredentials();
    return true;
  }
}

Future<bool> getNewCredentials() async {
  //####################################
  //    refresh the local values in my phone
  //   the application must use the current refresh_token
  //   and generate a new refresh_token, access_token and
  //   expiration_date each time you log into the application.

  SharedPreferences pref = await SharedPreferences.getInstance();
  // make a call to the user auth token api, to refresh the data
  final response = await http
      .post("https://cpritchar.scweb.ca/mapleCrossing/oauth/token", headers: {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
  }, body: {
    'grant_type': "refresh_token",
    'client_id': Const.CLIENT_ID,
    'client_secret': Const.CLIENT_SECRET,
    'refresh_token': pref.getString("refresh_token"),
  });
  if (response.statusCode == 200) {
    //############################
    //  decode the information to
    //  allow my application to
    //  parse it into the applications
    //  SharePreferences (local storage).
    final jsonResponse = json.decode(response.body);
    pref.setString('access_token', "Bearer ${jsonResponse['access_token']}");
    pref.setString('refresh_token', jsonResponse['refresh_token']);
    pref.setInt('expires_in', jsonResponse['expires_in']);
  } else {
    // the application has an error, this shouldnt be called.
    print("invalid response from application: ${response.statusCode}");
  }

  //####################################
}

class Scene extends StatefulWidget {
  @override
  _SceneState createState() => _SceneState();
}

class _SceneState extends State<Scene> {
  int _currentIndex = 0;

  var _page = {
    0: HomePage(),
    1: DiscussionPage(),
    2: InformationPage(),
    3: EventPage(),
  };

  @override
  Widget build(BuildContext context) {
    //####################################
    //   this is a scene that is used for
    //   every page. this builds the
    //   applications bottomNav that calls
    //   each page once it is pressed.

    return Scaffold(
      appBar: buildAppBar(context, _currentIndex),
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
          setState(
            () {
              /* once the application is set, then application will set the state,
               * and update the page with the new current page.
               */
              _currentIndex = index;
            },
          ),
        },
        iconSize: 30,
      ),
    );
    //######################################
  }

  AppBar buildAppBar(BuildContext context, int currentIndex) {
    //########################################################
    //   the application needs a new appbar for each page,
    //   in this way I can update it via the current index
    //   of the bottom nav using a switch. and case.
    var _items = {1: ProfilePage(), 2: ProfilePage()};
    switch (currentIndex) {
      case 1:
        return AppBar(
          title: Container(
            margin: const EdgeInsets.all(8.0),
            child: TextField(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {},
              color: Colors.white,
              iconSize: 40,
            ),
          ],
        );
        break;
      case 3:
        return AppBar();
        break;
      case 0:
      case 2:
      default:
        return AppBar(
          title: Text("Maple Crossing",
              style: Theme.of(context).textTheme.headline),
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
}
