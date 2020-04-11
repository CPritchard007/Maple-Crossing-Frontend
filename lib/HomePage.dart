import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:maple_crossing_application/MapPage.dart';
import 'package:http/http.dart' as http;

var _apis = {
  "Exchange":
      "https://www.bankofcanada.ca/valet/observations/FXUSDCAD?recent=1",
  "DWTunnel": "https://api.dwtunnel.com/api/traffic/conditionspublic",
  "DWBridge": ""
};

///  converts exchange rate json to an object
class ExchangeRate {
  final double dollar;
  ExchangeRate({this.dollar});
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      dollar: double.parse(json['observations'][0]["FXUSDCAD"]["v"]),
    );
  }
}

/// awaits the recieving of json data to the application
Future<ExchangeRate> fetchExchange(String request) async {
  final response = await http.get(request);

  if (response.statusCode == 200) {
    /// If the server did return a 200 response,
    /// then parse the JSON.
    return ExchangeRate.fromJson(json.decode(response.body));
  } else {
    /// If the server recieves another response,
    /// then throw an exception.
    print('failed to load data');
    return null;
  }
}

/// awaits json data from the tunnel api
class Tunnel {
  final int minutesTo;
  final int minutesFrom;
  final int lanesTo;
  final int lanesFrom;
  Tunnel({this.minutesTo, this.minutesFrom, this.lanesTo, this.lanesFrom});

  ///save json data as tunnel object
  factory Tunnel.fromJson(json) {
    return Tunnel(
      minutesTo: int.parse((json[0]['DetailsTravelTime']).substring(2)),
      minutesFrom: int.parse((json[1]['DetailsTravelTime']).substring(2)),
      lanesTo: json[0]['CarLaneCount'],
      lanesFrom: json[1]['CarLaneCount'],
    );
  }
}

///call for the retrieval of json data
Future<Tunnel> fetchTunnel(String request) async {
  final response = await http.get(request);

  if (response.statusCode == 200) {
    /// If the server did return a 200 response,
    /// then parse the JSON.
    return Tunnel.fromJson(json.decode(response.body));
  } else {
    /// If the server recieves another response,
    /// then throw an exception.
    print("unexpected");
    return null;
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ///     USD/CAD Exchange rate              $*.**
        ExchangeBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            children: <Widget>[
              Text("Border Wait Time", style: Theme.of(context).textTheme.title)
            ],
          ),
        ),

        ///    displays the wait time of the ambasador bridge and Detroit tunnel
        WaitTime(),

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            children: <Widget>[
              Text("Traffic", style: Theme.of(context).textTheme.title)
            ],
          ),
        ),
        Expanded(child: GoogleMaps(false))
      ],
    );
  }
}

class ExchangeBar extends StatefulWidget {
  @override
  _ExchangeBarState createState() => _ExchangeBarState();
}

class _ExchangeBarState extends State<ExchangeBar> {
  var exchange;
  @override
  void initState() {
    super.initState();

    ///before the widget starts, fetch the exchange data from the api
    exchange = fetchExchange(_apis["Exchange"]);
  }

  @override
  Widget build(BuildContext context) {
    ///create the exchange rate banner at the top of the application
    return Container(
      color: Colors.yellow,
      height: 25,
      child: Row(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Align(
                child: Text(
                  "USD/CAD Exchange Rate:",
                  style: Theme.of(context).textTheme.caption,
                ),
                alignment: Alignment.centerLeft,
              )),
          Expanded(
              child: Align(
            child: FutureBuilder<ExchangeRate>(
              future: exchange,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(
                      "\$${snapshot.data.dollar.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.body1,
                    ),
                  );
                } else {
                  return Text(
                    "|",
                    style: Theme.of(context).textTheme.body1,
                  );
                }
              },
            ),
            alignment: Alignment.centerRight,
          ))
        ],
      ),
    );
  }
}

class WaitTime extends StatefulWidget {
  @override
  _WaitTimeState createState() => _WaitTimeState();
}

class _WaitTimeState extends State<WaitTime> {
  int side_1 = 5;
  int side_2 = 15;

  int lanes_1 = 0;
  int lanes_2 = 0;

  var tunnel;
  @override
  void initState() {
    super.initState();
    tunnel = fetchTunnel(_apis["DWTunnel"]);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
                color: (side_1 >= side_2) ? Colors.green : Colors.red,
                height: 180,
                padding: EdgeInsets.all(8.0),
                child: FutureBuilder<Tunnel>(
                  future: tunnel,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      side_1 = snapshot.data.minutesTo;
                      return Column(
                        children: <Widget>[
                          Align(
                            child: Text(
                              "${snapshot.data.minutesTo.toString()} Min",
                              style: Theme.of(context).textTheme.display1,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Align(
                            child: Text(
                              "${snapshot.data.lanesTo} Lanes",
                              style: Theme.of(context).textTheme.headline,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Expanded(
                              child: Align(
                            child: Text(
                              "Detroit Tunnel",
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            alignment: Alignment.bottomLeft,
                          ))
                        ],
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Align(
                            child: Text(
                              "- Min",
                              style: Theme.of(context).textTheme.display1,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Align(
                            child: Text(
                              "- Lanes",
                              style: Theme.of(context).textTheme.headline,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Expanded(
                              child: Align(
                            child: Text(
                              "Detroit Tunnel",
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            alignment: Alignment.bottomLeft,
                          ))
                        ],
                      );
                    }
                  },
                ))),
        Expanded(
          child: Container(
            color: (side_1 < side_2) ? Colors.green : Colors.red,
            height: 180,
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Align(
                  child: Text(
                    "$side_2 Min",
                    style: Theme.of(context).textTheme.display1,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Align(
                  child: Text(
                    "$lanes_2 Lanes",
                    style: Theme.of(context).textTheme.headline,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Expanded(
                    child: Align(
                  child: Text(
                    "Ambassador Bridge",
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  alignment: Alignment.bottomLeft,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GoogleMaps extends StatefulWidget {
  GoogleMaps(this.isLarge);
  bool isLarge = false;

  @override
  _GoogleMapsState createState() => _GoogleMapsState(isLarge);
}

class _GoogleMapsState extends State<GoogleMaps> {
  _GoogleMapsState(this.isLarge);
  bool isLarge;
  BitmapDescriptor sourceIcon;

  Completer<GoogleMapController> _controller = Completer();
  String _mapStyle;
  LocationData currentLocation;
  Location location;
  CameraPosition cameraPosition =
      CameraPosition(target: LatLng(15, 14), zoom: 10);

  CameraPosition initialCameraPosition = CameraPosition(target: LatLng(0, 0));

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/styling/MapStyle.txt').then((string) {
      _mapStyle = string;
    });
  }

  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 17.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
        children: <Widget>[
          GoogleMap(
            trafficEnabled: true,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              controller.setMapStyle(_mapStyle);
            },
            myLocationEnabled: false,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () => {
                  setState(() {
                    Navigator.push(context,
                       isLarge? Navigator.pop(context) : Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage())));
                  })
                },
                child: isLarge? ImageIcon(AssetImage("assets/icons/Shrink.png"), color: Colors.black,) : Icon(Icons.crop_free, color: Colors.black,),
              ),
              alignment: Alignment.bottomRight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 83.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: "MyLocation",
                onPressed: _currentLocation,
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
    );
  }
}
