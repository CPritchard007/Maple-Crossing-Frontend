import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapPage extends StatefulWidget {

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

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
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(254, 95, 95, 1)
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => {
            setState((){
              Navigator.pop(context);
            }),
          }),
        ),
        body: Stack(children: <Widget>[ GoogleMap(
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
          FloatingActionButton(onPressed: () => {
            
          },
          
          )
          ]),
        ),
      );
  }
}