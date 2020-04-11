import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController emailController, nameController, usernameController;
  bool isEditing = false;
  Color lockedColor = Color.fromRGBO(254, 95, 95, 1);
  Color unlockedColor = Colors.white;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = new TextEditingController();
    nameController = new TextEditingController();
    usernameController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 240, 240, 1),
      appBar: AppBar(
          actions: !isEditing
              ? <Widget>[
                  GestureDetector(
                    onTap: () {
                      isEditing = true;
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 5),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Edit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ]
              : <Widget>[
                  GestureDetector(
                    onTap: () {
                      updateProfile(
                          name: nameController.value.text,
                          email: emailController.value.text,
                          username: usernameController.value.text);
                          isEditing = false;
                    },
                    child: Container( 
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 5),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      isEditing = false;
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 5),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ]),
      body: FutureBuilder(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            emailController.value = TextEditingValue(text: snapshot.data.email);
            nameController.value = TextEditingValue(
                text: '${snapshot.data.firstName} ${snapshot.data.lastName}');
            usernameController.value =
                TextEditingValue(text: snapshot.data.username);

            return Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(254, 95, 95, 1),
                          border: Border.all(
                            color: Color.fromRGBO(250, 250, 250, .3),
                          ),
                        ),
                        width: 100,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(2),
                        child: Text(
                          "NAME",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(254, 95, 95, 1),
                          border: Border.all(
                            color: Color.fromRGBO(250, 250, 250, .3),
                          ),
                        ),
                        width: 250,
                        height: 35,
                        child: TextField(
                          style: TextStyle(fontSize: 14, color: Colors.white),
                          controller: nameController,
                          enabled: isEditing,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(254, 95, 95, 1),
                          border: Border.all(
                            color: Color.fromRGBO(250, 250, 250, .3),
                          ),
                        ),
                        width: 100,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(2),
                        child: Text(
                          "USERNAME",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(254, 95, 95, 1),
                          border: Border.all(
                            color: Color.fromRGBO(250, 250, 250, .3),
                          ),
                        ),
                        width: 250,
                        height: 35,
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: TextField(
                          style: TextStyle(fontSize: 14, color: Colors.white),
                          controller: usernameController,
                          enabled: isEditing,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(254, 95, 95, 1),
                          border: Border.all(
                            color: Color.fromRGBO(250, 250, 250, .3),
                          ),
                        ),
                        width: 100,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(2),
                        child: Text(
                          "EMAIL",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(254, 95, 95, 1),
                          border: Border.all(
                            color: Color.fromRGBO(250, 250, 250, .3),
                          ),
                        ),
                        width: 250,
                        height: 35,
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: TextField(
                          enabled: isEditing,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                          controller: emailController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  value: null,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

Future<User> getUser() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final request = await http.get(
    "https://cpritchar.scweb.ca/mapleCrossing/api/user",
    headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: pref.getString("access_token"),
    },
  );
  final jsonRequest = json.decode(request.body);
  print(request.statusCode);
  return new User(
      firstName: jsonRequest['first_name'],
      lastName: jsonRequest['last_name'],
      email: jsonRequest['email'],
      username: jsonRequest['name'],
      id: jsonRequest['id']);
}

class User {
  User({this.firstName, this.lastName, this.username, this.email, this.id});
  final String firstName, lastName, username, email;
  final id;
}

updateProfile({String name, String username, String email}) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final response = await http.post(
      "https://cpritchar.scweb.ca/mapleCrossing/api/user/${pref.getInt("user_id")}",
      headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: pref.getString("access_token"),
      },
      body: {
        "name": username,
        "first_name": name.split(" ")[0],
        "last_name": name.split(" ")[1],
        "email": email
      });

  if (response.statusCode == 200) {
    print("updated successfully");
  } else {
    print("error ${response.statusCode}");
  }
}
