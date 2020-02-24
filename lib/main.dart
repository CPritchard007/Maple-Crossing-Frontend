import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color.fromRGBO(254, 95, 95, 1)),
      home: Scaffold(
        appBar: new AppBar(
          bottomOpacity: .3,
          title: Text("Maple Crossing"),
        ),
        body: buildContent(),
        bottomNavigationBar: BottomNav(),
      ),
    );
  }

  Column buildContent() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text("Border Wait Time: "),
              ),
              DropDown()
            ],
          ),
        ),
        buildBorderWaitTime(),
        Expanded(
          child: Container(
          child: Map(),
          margin: EdgeInsets.all(10),
          ),
          )
      ],
    );
  }

  Padding buildBorderWaitTime() {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              height: 180,
              margin: const EdgeInsets.all(4.0),
              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              decoration: new BoxDecoration(
                  color: Colors.red,
                  borderRadius: new BorderRadius.circular(10),
                  boxShadow: [
                    new BoxShadow(
                        blurRadius: 8, spreadRadius: 2, offset: Offset(2, 1))
                  ]),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.headset,
                    size: 50,
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                  Spacer(
                    flex: 3,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "15 MINS",
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Detroit Tunnel",
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    ),
                  )
                ],
              ),
            )),
            Expanded(
                child: Container(
              height: 180,
              margin: const EdgeInsets.all(4.0),
              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              decoration: new BoxDecoration(
                  color: Colors.green,
                  borderRadius: new BorderRadius.circular(10),
                  boxShadow: [
                    new BoxShadow(
                        blurRadius: 8, spreadRadius: 2, offset: Offset(2, 1))
                  ]),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.headset,
                    size: 50,
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                  Spacer(
                    flex: 3,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "5 MINS",
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ambasador Bridge",
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    ),
                  )
                ],
              ),
            )),
          ],
        ),
      );
  }
}

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
        BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/icons/discussion_button.png")),
            title: Text("Discussion")),
        BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/icons/events_button.png")),
            title: Text("Events"))
      ],
      currentIndex: _currentIndex,
      onTap: (index) => {
        setState(() {
          _currentIndex = index;
        })
      },
    );
  }
}

class DropDown extends StatefulWidget {
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String dropdownValue = "CAN \u2192 USA";
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 24,
      elevation: 16,
      // style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Color.fromRGBO(254, 95, 95, 1),
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['CAN \u2192 USA', 'USA \u2192 CAN']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
    );
  }
}