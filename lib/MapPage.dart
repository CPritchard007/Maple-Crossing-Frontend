import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'main.dart';
class MapPage extends StatefulWidget {

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  GoogleMapController gmc;
  String _mapStyle;
  bool _trafficEnabled = true;

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
    return buildMaterial(child: Scaffold(
        body: Stack(children: <Widget>[ GoogleMap(
              trafficEnabled: _trafficEnabled,
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
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 93.0),
            child: Align(alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "Minimize",
                onPressed: () => { setState((){
                  Navigator.pop(context);
                })
              },
              backgroundColor: Colors.white,
              child: ImageIcon(AssetImage("assets/icons/Shrink.png"), color: Colors.black,size: 32,),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 163.0),
            child: Align(alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "Location",
                onPressed: () => { setState((){

                })
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black ,size: 32,),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 233.0),
            child: Align(alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "ToggleTraffic",
                onPressed: () => { setState((){
                _trafficEnabled = !_trafficEnabled;

                })
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.directions_car, color: (_trafficEnabled)? Colors.green : Colors.black ,size: 32,),
              ),
            ),
          ),

          ]),
        ),
      );
  }
}