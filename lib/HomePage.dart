import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
          children: <Widget>[
            buildExchangeBar(),
            Row(children: <Widget>[
              Expanded(child: Align(child: Text("Border Wait Time"), alignment: Alignment.centerLeft,),),
              Expanded(child: Align(child: DropDown(), alignment: Alignment.centerRight,),),
            ],),
            WaitTime(),
            Row(children: <Widget>[
              Text("Traffic")
            ],),
            GoogleMaps()

          ],
    );
  }
}

Container buildExchangeBar() {
    int mun = 100;
    return Container(
              color: Colors.yellow,
              height: 30,
              child: Row(
                children: <Widget>[
                  Expanded( child: Align(child: Text("Exchange Rate:"), 
                  alignment: Alignment.centerLeft,)),
                  Expanded( child: Align(child: Text("\$${mun}"), 
                  alignment: Alignment.centerRight,))
                ],
              )
            );
  }


class DropDown extends StatefulWidget {
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}


class WaitTime extends StatefulWidget {
  
  @override
  _WaitTimeState createState() => _WaitTimeState();
}

class _WaitTimeState extends State<WaitTime> {
  int _waitTimeDiff = 1;
  @override
  Widget build(BuildContext context) {
    return Row(
                children: <Widget>[
                  Expanded(child: 
                  (_waitTimeDiff > 0) ? Container(
                    color: Colors.green,
                    height: 250,
                  ) : Container(
                    color: Colors.red,
                    height: 250,
                  ),
                  ),
                  
                  Expanded(child: 
                  (_waitTimeDiff < 0) ? Container(
                    color: Colors.green,
                    height: 250,
                  ) : Container(
                    color: Colors.red,
                    height: 250,
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
      child: GoogleMap(trafficEnabled: true,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(42.311180,-82.859060),
            zoom: 17
          ),
          mapType: MapType.normal,
          
        
        ),
    );
  }
}