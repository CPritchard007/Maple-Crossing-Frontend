import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiscussionContentPage extends StatelessWidget {
  final String question;
  final List<String> tags;
  final int id;
  DiscussionContentPage({this.id, this.question, this.tags});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color.fromRGBO(254, 95, 95, 1)),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Align(
                      child: Text(
                        question,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    FutureBuilder(
                      future: getTags(id),
                      builder: (context, snapshot) {
                        List<Container> containers = new List<Container>();
                        if (snapshot.hasData) {
                          Random ran = new Random();
                          final colors = {
                            0: [169, 59, 63],
                            1: [234, 161, 48],
                            2: [40, 114, 123],
                            3: [87, 176, 170],
                            4: [126, 108, 167],
                            5: [38, 70, 53]
                          };

                          for (final tag in snapshot.data) {
                            final color = colors[ran.nextInt(colors.length)];
                            containers.add(
                              new Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: Text(tag, style: TextStyle(color: Colors.white),),
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Color.fromRGBO(
                                      color[0], color[1], color[2], 1),
                                ),
                              ),
                            );
                          }
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              children: containers,
                            ),
                          );
                        } else {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: CircularProgressIndicator(
                                value: null,
                              ),                             
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0,
                          color: Colors.black,
                          style: BorderStyle.solid)),
                  color: Colors.white,
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, -2),
                      spreadRadius: 4,
                      blurRadius: 5,
                    )
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<String>> getTags(int id) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final response = await http.get(
      "https://cpritchar.scweb.ca/mapleCrossing/api/discussion/$id",
      headers: {
        HttpHeaders.acceptHeader: "applciation/json",
        HttpHeaders.contentTypeHeader: "x-wwww-form-urlencoded",
        HttpHeaders.authorizationHeader: pref.getString("access_token")
      });

  if (response.statusCode == 200) {
    final responseJson = json.decode(response.body);
    final List<String> tags = responseJson['tags'].toString().split(",");
    return tags;
  } else {}
}
