import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maple_crossing_application/MapPage.dart';
import 'package:http/http.dart' as http;



class ExchangeRate {
  final double dollar;
  
  ExchangeRate({this.dollar});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    print(double.parse(json['observations'][0]["FXUSDCAD"]["v"]));
    return ExchangeRate(
      dollar: double.parse(json['observations'][0]["FXUSDCAD"]["v"]),
    );
  }
}

Future<ExchangeRate> fetchExchange(String request) async {
  final response = await http.get(request);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return ExchangeRate.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}




class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
          children: <Widget>[
            ExchangeBar(),
            Row(children: <Widget>[
              Text("Border Wait Time", style: Theme.of(context).textTheme.title)
            ],),
            WaitTime(),
            Row(children: <Widget>[
              Text("Traffic", style: Theme.of(context).textTheme.title)
            ],),
            GoogleMaps()
          ],
      );
  }
}

class ExchangeBar extends StatefulWidget {
  @override
  _ExchangeBarState createState() => _ExchangeBarState();
}

class _ExchangeBarState extends State<ExchangeBar> {
      var _apis = {
      "Exchange": "https://www.bankofcanada.ca/valet/observations/FXUSDCAD?recent=1",
      "DWTunnel" : "",
      };
      int mon = 100;
      var exchange;
 @override
  void initState() {
    super.initState();
    exchange = fetchExchange(_apis["Exchange"]);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
              color: Colors.yellow,
              height: 25,
              child: Row(
                children: <Widget>[
                  Expanded( child: Align(child: Text("USD/CAD Exchange Rate:", style: Theme.of(context).textTheme.subtitle,), 
                  alignment: Alignment.centerLeft,)),
                  Expanded( child: Align(
                    child: FutureBuilder<ExchangeRate>(
                      future: exchange,
                      builder: (context, snapshot){
                        if(snapshot.hasData){return Text("\$${snapshot.data.dollar.toStringAsFixed(2)}");}
                        else {return Text("N/A 🚀");}
                    }) , 
                  alignment: Alignment.centerRight,))
                ],
              )
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

  @override
  Widget build(BuildContext context) {
    return Row(
                children: <Widget>[
                  Expanded(child: 
                  Container(
                    color: (side_1 >= side_2) ? Colors.green : Colors.red,
                    height: 180,
                    padding: EdgeInsets.all(8.0),
                    child: Column( children: <Widget>[
                      Align(child: Text("$side_1 Min", style: Theme.of(context).textTheme.display3,),
                       alignment: Alignment.centerLeft,),
                       Align(child: Text("$lanes_1 Lanes", style: Theme.of(context).textTheme.display2,),
                       alignment: Alignment.centerLeft,),
                       Expanded(child: Align(child: Text("Detroit Tunnel", style: Theme.of(context).textTheme.display1,), alignment: Alignment.bottomLeft,
                       ))
                    ],
                    ))),
                  Expanded(child: Container(
                    color: (side_1 < side_2)? Colors.green : Colors.red,
                    height: 180,
                    padding: EdgeInsets.all(8.0),
                    child: Column( children: <Widget>[
                      Align(child: Text("$side_2 Min", style: Theme.of(context).textTheme.display3,),
                       alignment: Alignment.centerLeft,),
                       Align(child: Text("$lanes_2 Lanes", style: Theme.of(context).textTheme.display2,),
                       alignment: Alignment.centerLeft,),
                       Expanded(child: Align(child: Text("Ambassador Bridge", style: Theme.of(context).textTheme.display1,), alignment: Alignment.bottomLeft,
                       )),
                    ],
                  )
                  ),
                  ),
                ],
              );
  }
}

class GoogleMaps extends StatefulWidget {
  @override
  _GoogleMapsState createState() => _GoogleMapsState();

  
}

class _GoogleMapsState extends State<GoogleMaps> {
 
  GoogleMapController gmc;
  String _mapStyle;

@override
    void initState() {
      super.initState();
      rootBundle.loadString('assets/styling/MapStyle.txt').then((string) {
        _mapStyle = string;
      });
    }

 void _onMapCreated(GoogleMapController controller) {
    gmc = controller;
    gmc.setMapStyle(_mapStyle);
  }

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Stack(children: <Widget>[
        GoogleMap(
        trafficEnabled: true,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(42.311180,-82.859060),
            zoom: 17
          ),
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,

        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            child: FloatingActionButton(
            onPressed: () => {
              setState((){
              Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage()));
              })},
          backgroundColor: Colors.white,
          child: Icon(Icons.crop_free, color: Colors.black, size: 32,),
          ) ,
          alignment: Alignment.bottomRight,
          ),
        ),Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 83.0),
            child: Align(alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "MyLocation",
                onPressed: () => { setState((){
                  
                })
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black,size: 32,),
              ),
            ),
          ),
      ],),
        
    );
  }
}