import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maple_crossing_application/DiscussionContentPage.dart';
import 'package:maple_crossing_application/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


//###########################################
//      Main page that is displayed
//      for Discussions
class DiscussionPage extends StatefulWidget {

  static TextEditingController controller = new TextEditingController();
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  Future<List<GestureDetector>> _future;
  @override
  void initState() {
    super.initState();
    _future = getAvailableDiscussions(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureListView(future: _future);
  }
}

class FutureListView extends StatelessWidget {
  const FutureListView({
    Key key,
    @required Future<List<GestureDetector>> future,
  }) : _future = future, super(key: key);

  final Future<List<GestureDetector>> _future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        print(snapshot.hasData);
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data,
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
    );
  }
}

Future<List<GestureDetector>> getAvailableDiscussions(
    BuildContext context) async {
  //##################################################
  //         Wait for discussion information
  SharedPreferences pref = await SharedPreferences.getInstance();
  final accessToken = pref.getString("access_token");
  final discussions = await getDiscussions(accessToken);

  final List<GestureDetector> cards = new List<GestureDetector>();

  //##################################################
  //##################################################
  //    For each discussion found in the appliation,
  //    display it as a card.
  for (DiscussionItem discussion in discussions) {
    // getUserByID(userId: discussion['user_id'], token: accessToken).then((value)=>  user = value.username );
    //allow the discussion card to be clickable using a gesture detector
    final user =
        await getUserByID(userId: discussion.userId, token: accessToken);
        print(discussion.tags);
    cards.add(
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiscussionContentPage(
                id: discussion.id,
                question: discussion.question,
                
                tags: discussion.tags,
              ),
            ),
          );
        },
        child: buildCards(
          username: user.username,
          question: discussion.question,
          tags: discussion.tags,
        ),
      ),
    );
  }
  return cards;
}

Future<List<DiscussionItem>> getDiscussions(final token) async {
  //############################################################
  //          get informaiton from the discussions api
  final response = await http.get(
    "https://cpritchar.scweb.ca/mapleCrossing/api/discussion",
    headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: token
    },
  );
  List<DiscussionItem> discussions = List<DiscussionItem>();

  if (response.statusCode == 200) {
    print("discussions ${response.statusCode}");
    final responseJson = json.decode(response.body);
    for (final discussion in responseJson['data']) {
      print("new Discussion");
      discussions.add(new DiscussionItem(
          id: discussion['id'],
          userId: discussion['user_id'],
          question: discussion['question'],
          tags: discussion['tags'].toString().split(',')));
    }
    return discussions;
  } else {
    print(
        "unable to retrieve discussion data at status code: ${response.statusCode}");
  }
}

Future<User> getUserByID({int userId, final token}) async {
  //#####################################################
  //       get the user id using the id pulled from
  //       the maple crossing api, as well as using
  //       the current users access token for easy
  //       access.
  final response = await http.get(
    "https://cpritchar.scweb.ca/mapleCrossing/api/user/$userId",
    headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: token
    },
  );

  if (response.statusCode == 200) {
    //####################################
    //  if the api returns a value of 200
    //  the application will build a user
    //  and return it to the
    //  getAvailableDiscissions function
    print("users ${response.statusCode}");
    final responseJson = json.decode(response.body);
    return new User(
        firstName: responseJson['first_name'],
        lastName: responseJson['last_name'],
        email: responseJson['email'],
        username: responseJson['name']);
    //####################################
  } else {
    print('user came back with error type: ${response.statusCode}');
  }
}

Card buildCards({String username, String question, List<String> tags}) {
  //####################################################################
  // Building the Discussion cards that will populate the discussions  #
  //                                                                   #
  //        ###########################################                #
  //        #  username                             ✔️ #                #
  //        #  this is where the quesiton will be     #                #
  //        #                                         #                #
  //        #  ( tag ) ( tag ) ( tag )              ★ #                #
  //        ###########################################                #
  //                                                                   #
  //####################################################################
  List<Container> tagsList = List<Container>();
  int index = 0;
  for (final tag in tags) {
    if (index == 4)
      break;
    else
      index++;
    tagsList.add(
      new Container(
        margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
        child: Text(
          tag,
          style: TextStyle(color: Colors.black),
        ),
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.grey,
            )),
      ),
    );
  }
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              username,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              question,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Wrap(
                children: tagsList,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  //##################################################################
}

class DiscussionItem {
  final int id;
  final int userId;
  final String question;
  final List<String> tags;
  DiscussionItem({this.id, this.userId, this.question, this.tags});
}

buildCreationPage(){
  return Container();
}