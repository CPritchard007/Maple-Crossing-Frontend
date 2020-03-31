import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maple_crossing_application/DiscussionContentPage.dart';
import 'package:maple_crossing_application/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<GestureDetector>> getAvailableDiscussions(BuildContext context) async {

  SharedPreferences pref = await SharedPreferences.getInstance();
  final accessToken = pref.getString("access_token");
  final discussions = await getDiscussions(accessToken);
  List<GestureDetector> cards = new List<GestureDetector>();
  for (final discussion in discussions['data']) {
    final user = await getUserByID(discussion['user_id'], accessToken);
    cards.add(
      GestureDetector(onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => DiscussionContentPage(id: discussion['id'],question: discussion['question'],)));
      },child: buildCards(user.username, discussion['question']),)
    );
  }
  return cards;
}

Future getDiscussions(final token) async {
  final response =
      await http.get("https://cpritchar.scweb.ca/mapleCrossing/api/discussion", headers: {
        HttpHeaders.acceptHeader : "application/json",
        HttpHeaders.contentTypeHeader : "x-www-form-urlencoded",
        HttpHeaders.authorizationHeader : token
      });
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print(
        "unable to retrieve user data at status code: ${response.statusCode}");
    return null;
  }
}

Future<User> getUserByID(int userId, final token) async {
  final response = await http
      .get("https://cpritchar.scweb.ca/mapleCrossing/api/user/$userId", headers: {
          HttpHeaders.acceptHeader : "application/json",
          HttpHeaders.contentTypeHeader : "x-www-form-urlencoded",
          HttpHeaders.authorizationHeader : token
      });

  if (response.statusCode == 200) {
    final responseJson = json.decode(response.body);
    return new User(
        firstName: responseJson['first_name'],
        lastName: responseJson['last_name'],
        email: responseJson['email'],
        username: responseJson['name']);
  }
  
}

Card buildCards(String username, String question) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(username, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(question, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
          )
        ],
      ),
    ),
  );
}

class DiscussionPage extends StatefulWidget {
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAvailableDiscussions(context),
      builder: (context, snapshot) 
      {
        if(snapshot.hasData){
        return ListView(children: snapshot.data,);  
        } else {
          return Container(
          child: Center(child: CircularProgressIndicator(value: null,),),);
        }
      },
    );
  }
}

class DiscussionItem {
  final String username;
  final String question;
  final List<String> tags;
  DiscussionItem({this.username, this.question, this.tags});
}
