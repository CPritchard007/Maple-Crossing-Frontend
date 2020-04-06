import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maple_crossing_application/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class DiscussionContentPage extends StatelessWidget {
  ///#################################################
  ///       This is the starting location of the
  ///       full discussion page.
  ///

  final String question;
  final List<String> tags;
  final int id;
  final colors = {
    0: [169, 59, 63],
    1: [234, 161, 48],
    2: [40, 114, 123],
    3: [87, 176, 170],
    4: [126, 108, 167],
    5: [38, 70, 53]
  };
  /// information passed on from the applications discussion page
  DiscussionContentPage({this.id, this.question, this.tags});

  @override
  Widget build(BuildContext context) {
    /// list of tags that will be used on the head of the page
    List<Container> tagList = List<Container>();
    Random ran = new Random(colors.length);

    for (String tag in tags) {
      final color = colors[ran.nextInt(colors.length)];
      tagList.add(
        new Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Text(
            tag,
            style: TextStyle(color: Colors.white),
          ),
          decoration: BoxDecoration(
              color: Color.fromRGBO(color[0], color[1], color[2], 1),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(50)),
        ),
      );
    }

    return buildMaterial(child: Scaffold(
        floatingActionButton: FloatingActionButton(child: Icon(Icons.add, size: 40), backgroundColor: Color.fromRGBO(254, 95, 95, 1),
        onPressed: (){
          setState(){
            
          }
        },),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Align(
                        child: Text(
                          question,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        children: tagList,
                      ),
                    )
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
                ],
              ),
            ),
            FutureDiscussionList(id),
          ],
        ),
      ),
    );
  }
}

class FutureDiscussionList extends StatefulWidget {
  final id;
  FutureDiscussionList(this.id);
  
  @override
  _FutureDiscussionListState createState() => _FutureDiscussionListState(this.id);
  
}

class _FutureDiscussionListState extends State<FutureDiscussionList> {
  final id;
  _FutureDiscussionListState(this.id);
  
  Future<List<Card>> _future;  
  @override
  void initState() {
    super.initState();
        _future = getAvailableComments(this.id);

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: ListView(
                children: snapshot.data,
              ),
            ),
          );
        } else {
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(
                value: null,
              ),
            ),
          );
        }
      },
    );
  }
}

class Comment {
  final String comment, user;
  Comment({this.comment, this.user});
}
Future<List<Card>> getAvailableComments(id) async {
  List<Comment> comments = new List<Comment>();

  final commentsJson = await getComments(id);
  for (final comment in commentsJson['data']) {
    final user = await getUser(comment['user_id']);
    comments.add(new Comment(user: user.username, comment: comment['comment']));
  }
  return buildCommentCards(comments);
}

List<Card> buildCommentCards(List<Comment> comments) {
  final List<Card> cards = new List<Card>();
  for (final comment in comments) {
    print(comment.comment);
    cards.add(
      new Card(
        child: Container(
          height: 80,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(comment.user),
              Text(comment.comment),
            ],
          ),
        ),
      ),
    );
  }
  return cards;
}

Future getComments(int id) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final response = await http.get(
      "https://cpritchar.scweb.ca/mapleCrossing/api/discussion/$id/comment",
      headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: pref.getString("access_token")
      });

  if (response.statusCode == 200) {
    print("recieving comments...");
    final responseJson = json.decode(response.body);
    return responseJson;
  } else {
      print("unable to grab comments on error: ${response.statusCode}");

  }
}

Future<User> getUser(int id) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final response = await http.get(
    "https://cpritchar.scweb.ca/mapleCrossing/api/user/$id",
    headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: pref.getString("access_token")
    },
  );
  if (response.statusCode == 200) {
    final responseJson = json.decode(response.body);
    print("grabbing users");
    return new User(
        firstName: responseJson['first_name'],
        lastName: responseJson['last_name'],
        email: responseJson['email'],
        username: responseJson['name']);
  } else {
    print("unable to grab user on error: ${response.statusCode}");
  }
}
