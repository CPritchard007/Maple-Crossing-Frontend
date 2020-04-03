import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InformationPage extends StatefulWidget {
  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  Future<List<GestureDetector>> _future;

  @override
  void initState() {
    super.initState();
    _future = getAllResources();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data,
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              value: null,
            ),
          );
        }
      },
    );
  }
}

Future<List<GestureDetector>> getAllResources() async {
  print("starting to gather resources");
  final SharedPreferences pref = await SharedPreferences.getInstance();
  print("gathered preferences");
  final response = await http.get(
    "https://cpritchar.scweb.ca/mapleCrossing/api/resource",
    headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: pref.getString("access_token"),
    },
  );
  print("pulled responses from api");

  if (response.statusCode == 200) {
    List<Resource> resources = new List<Resource>();
    final responseJson = json.decode(response.body);

    for (final resource in responseJson['data']) {
      print("call");
      resources.add(new Resource(
          resourceTitle: resource['title'],
          resourceText: resource['content'],
          user: "",
          favourite: false));
    }
    print(resources[0].resourceText);
    final gestureList = buildResources(resources);
    print(gestureList);
    return gestureList;
  } else {
    print(
        "the application has returned with error code: ${response.statusCode}");
  }
}

buildResources(List<Resource> resources) {
  List<GestureDetector> resourcesList = new List<GestureDetector>();
  for (final resource in resources) {
    resourcesList.add(
      new GestureDetector(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${resource.resourceTitle}',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Text(
                          '${resource.resourceText}',
                        )),
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 23,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  return resourcesList;
}

class Resource {
  final String user;
  final String resourceTitle;
  final String resourceText;
  final bool favourite;
  Resource({this.user, this.resourceTitle, this.resourceText, this.favourite});
}
