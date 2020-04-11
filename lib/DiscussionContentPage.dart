import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiscussionContentPage extends StatelessWidget {
  ///#################################################
  ///       This is the starting location of the
  ///       full discussion page.
  ///

  DiscussionContentPage({this.id, this.question, this.tags});
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

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, size: 40),
          backgroundColor: Color.fromRGBO(254, 95, 95, 1),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateComment(id)));
          },
        ),
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
    );
  }
}

class FutureDiscussionList extends StatefulWidget {
  final id;
  FutureDiscussionList(this.id);

  @override
  _FutureDiscussionListState createState() =>
      _FutureDiscussionListState(this.id);
}

class _FutureDiscussionListState extends State<FutureDiscussionList> {
  
  final id;
  _FutureDiscussionListState(this.id);
  Future<List<Comment>> _future;
  List<Comment> currentItems = List<Comment>();
  ScrollController _scrollController = ScrollController();
  int page = 1;
  @override
  void initState() {
    super.initState();
    _future = getAvailableComments(this.id,page: page);
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        print("owwww owwww stop it!");
        page++;
        setState(() {
          getAvailableComments(id, page: page).then((val)=>currentItems.addAll(val));
        },
        );
      }
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          currentItems = snapshot.data;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, position){
                Comment item = currentItems[position];
                return buildCommentCard(item, context: context);
              },itemCount: currentItems.length,),
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

Future<List<Comment>> getAvailableComments(int id, {int page}) async {
  print("page $page");

  List<Comment> comments = new List<Comment>();
  final commentsJson = await getComments(id, page: page);
  for (final comment in commentsJson['data']) {
    comments.add(new Comment(user: comment['profile']['name'], comment: comment['comment']));
  }
  return comments;
}


Future getComments(int id, {int page}) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final response = await http.get(
      "https://cpritchar.scweb.ca/mapleCrossing/api/discussion/$id/comment?page=$page",
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


Widget buildCommentCard(Comment comment,{BuildContext context}) {
      return Card(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                  Icon(Icons.arrow_upward),
                  Container(height: 8,),
                  Container(width: 15,height: 15,decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey.withAlpha(140)
                  ),)
                ],),
              ),
              Expanded(
                              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(comment.user, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(120))),
                    Text(comment.comment, style: Theme.of(context).textTheme.body2,),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
}

class CreateComment extends StatefulWidget {
  CreateComment(this.id);
  final id;
  @override
  _CreateCommentState createState() => _CreateCommentState(id);
}

class _CreateCommentState extends State<CreateComment> {
  _CreateCommentState(this.id);
  
  final id;
  TextEditingController commentController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Color.fromRGBO(240, 240, 240, 1),
      appBar: AppBar(
        title: Text('Create Comment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(20)),
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
            TextFormField(decoration: InputDecoration(labelText: "comment"), maxLength: 250, maxLengthEnforced: true, maxLines: null,controller: commentController,),
            IconButton(
                    icon: Icon(Icons.send),
                    alignment: Alignment.centerRight,
                    onPressed: () {
                      submitComment(comment: commentController.value.text, discussionId: id);
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
          ],),
        ),
      ),
    );
  }
}

Future<void> submitComment({String comment, int discussionId}) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final response = await http.post("https://cpritchar.scweb.ca/mapleCrossing/api/comment/create",
  headers: {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.authorizationHeader: pref.getString("access_token")
  },
  body: {
    "discussion_id": "${discussionId}",
    "comment": comment,
    "user_id": "${pref.getInt("user_id")}"
  });

  if (response.statusCode == 200){
    
  } else {
    print(response.statusCode);
  }
}

