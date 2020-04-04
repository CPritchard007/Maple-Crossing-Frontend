import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController searchController = new TextEditingController();

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<User>(
        future: getUser(),
        builder: (context, snapshot) {
         if(snapshot.hasData){
          return ListView(
            children: <Widget>[
              Text("${snapshot.data.firstName} ${snapshot.data.lastName}"),
              Row(
                children: <Widget>[
                  Text("Username: "),
                  Text(snapshot.data.username)
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Email: "),
                  Text(snapshot.data.email)
                ],
              ),

            ],
          );
         } else {
           return Container();
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
  print("name: ${jsonRequest['first_name']} ${jsonRequest['last_name']}");
  print("name: ${jsonRequest['name']}");
  print("name: ${jsonRequest['email']}");
  print(request.statusCode);
  return new User(firstName: jsonRequest['first_name'], lastName: jsonRequest['last_name'], email: jsonRequest['email'], username: jsonRequest['name']);
}

class User {
  String firstName, lastName, username, email;
  User({String firstName, String lastName, String username, String email}) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.username = username;
    this.email = email;
  }
}
