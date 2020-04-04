import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';

class InformationPage extends StatefulWidget {
//############################################
//
  static TextEditingController controller = new TextEditingController();
  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  Future<List<Card>> _future;
  SlidableController _controller;

  @override
  void initState() {
    super.initState();
    _future = getAllResources();
  }

  @override
  Widget build(BuildContext context) {
    //#################################
    //    I am using FutureBuilder once
    //    when the application starts.
    //    the page will store its information
    //    until the user leaves the page.
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        //if the application successfully pulled data in from the api
        if (snapshot.hasData) {
          // create a listView, this list view will allow you to build each individual item
          return ListView.builder(
            itemBuilder: (context, position) {
              // this is the reference of one resource in the list
              Card item = snapshot.data[position];
              return new Slidable(
                // controllers allow the user to store the current status of the Widget (Slidable), allowing me  to
                // manipulate it manually.
                controller: _controller,
                // how far will the slider extend to..
                actionExtentRatio: 0.25,
                child: item,
                delegate: SlidableDrawerDelegate(),
                // the slider allows you to effect [actions] and [secondaryActions] parameters. this disctates wether you want to effect
                // the left or the right side of the item as a slider. as used in this application, it is to be slid left
                secondaryActions: <Widget>[
                  //Create the 2 actions you can use on sliding
                  SlideAction(
                    child: Column(
                      children: <Widget>[
                        // DELETE
                        Expanded(
                          child: Container(
                            color: Color.fromRGBO(254, 95, 95, 1),
                            child: Center(
                              child: IconButton(
                                icon: ImageIcon(
                                  AssetImage("assets/icons/trash.png"),
                                  color: Color.fromRGBO(0, 0, 0, .5),
                                ),
                                iconSize: 60,
                                onPressed: () {
                                  //on pressed alert the user that a resource is being deleted
                                  Scaffold.of(context)
                                      .showSnackBar(new SnackBar(
                                    content: Text('pressed'),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                                },
                              ),
                            ),
                          ),
                        ),
                        // EDIT
                        Expanded(
                          child: Container(
                            color: Color.fromRGBO(130, 188, 218, 1),
                            child: Center(
                              child: IconButton(
                                icon: ImageIcon(
                                  AssetImage("assets/icons/penTool.png"),
                                  color: Color.fromRGBO(0, 0, 0, .5),
                                ),
                                iconSize: 60,
                                onPressed: () {
                                  //on pressed, alert the user that the information is being saved
                                  Scaffold.of(context)
                                      .showSnackBar(new SnackBar(
                                    content: Text('pressed'),
                                    duration: Duration(seconds: 5),
                                  ));
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            itemCount: snapshot.data.length,
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

Future<List<Card>> getAllResources() async {
  //########################################
  //  this is the primary function that pulls 
  //  for resource data. once the application
  //  has reached over 30 individual resources
  //  it will need to pull a new page of api's.

  //get a connection to the local storage
  final SharedPreferences pref = await SharedPreferences.getInstance();

  // get api responses for the resources page
  final response = await http.get(
    "https://cpritchar.scweb.ca/mapleCrossing/api/resource",
    headers: {
      HttpHeaders.acceptHeader: "application/json",
      //  get the users access token they recieved from logging into the application.
      HttpHeaders.authorizationHeader: pref.getString("access_token"),
    },
  );

  if (response.statusCode == 200) {
    //  the user successfully pulled in the api from the database, not its will convert it into a Resources object
    List<Resource> resources = new List<Resource>();
    final responseJson = json.decode(response.body);

    for (final resource in responseJson['data']) {
      print("call");
      resources.add(new Resource(
          resourceTitle: resource['title'],
          resourceText: resource['content'],
          user: "",
          favourite: false,
          id: resource['id']));
    }
    // using that list of resources, pass the information on the the builder, and create a list of functioning resource cards
    final gestureList = buildResources(resources);
    return gestureList;
  } else {
    //the application has come back with an error
    print(
        "the application has returned with error code: ${response.statusCode}");
  }
}

buildResources(List<Resource> resources) {
  //bulld resource cards
  List<Card> resourcesList = new List<Card>();
  for (final resource in resources) {
    resourcesList.add(
      new Card(
        //allow the listview to match each resource by "Resource #id"
        key: Key("resource ${resource.id}"),
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 290,
                child: Column(
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
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: SideMenu(
                    resource: resource,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  return resourcesList;
}

class SideMenu extends StatefulWidget {
// find more informaiton at _SideMenuState
  SideMenu({this.resource});
  final Resource resource;

  @override
  _SideMenuState createState() => _SideMenuState(resource);
}

class _SideMenuState extends State<SideMenu> {
  //##########################################
  //                SideMenu
  //    this builds up the two side items that
  //    allow the user to favourite an item, as
  //    as well as adding a, icon to show that
  //    the user can interact with the menu by
  //    dragging. this will not be displayed if
  //    the iser does not have the ability to 
  //    remove resources.
  //    
  _SideMenuState(this.resource);
  //store the current resource for each list item
  Resource resource;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            height: 32,
            width: 32,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 10, 50),
            child: Icon(
              Icons.chevron_right,
              size: 23,
              color: Colors.black,
            ),
          ),
          IconButton(
            //if the user has favourited this item already, the item will be removed, or the opposite
            icon: Icon(resource.favourite ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(
                () {
                  // remind the user that the item has been added/removed from your favourites
                  print(resource.favourite);
                  resource.favourite = !resource.favourite;
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: Text(resource.favourite
                        ? "Adding resource to favourites."
                        : "Removing resource to favourites"),
                    duration: Duration(seconds: 2),
                  ));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class Resource {
  final String user;
  final String resourceTitle;
  final String resourceText;
  final int id;
  bool favourite;

  Resource(
      {this.user,
      this.resourceTitle,
      this.resourceText,
      this.favourite,
      this.id});
}
