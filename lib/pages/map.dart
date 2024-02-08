import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class Map extends StatefulWidget {
  const Map({super.key});
   
  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  
  List<Marker> _markers = [];
  LatLng? tappedLocation;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // widget.onLocationSelected(tappedLocation);

              Navigator.of(context).pop(tappedLocation);
            },
          ),
          title: Text('Please select the location'),
        ),


        // ElevatedButton(
        //   onPressed: () {}, 
        //   child: Text("Confirm Location")
        //   ),

        floatingActionButton: FloatingActionButton(
            mini: false,
            onPressed: (){
              Navigator.of(context).pop(tappedLocation);
            },
            child: Container(
              padding: EdgeInsets.all(10.0), // Adjust padding to change size
              child: Icon(Icons.check),
            ),
          ),

        body: Center(
          child:  Container(
            child: Column(
              children: [
                Flexible(
                  child:  FlutterMap(
                    options: 
                    MapOptions( 
                      onTap: _handleTap ,  
                      initialCenter: LatLng(12.96332605743105, 80.24484447724926), 
                      initialZoom: 10),
                    children :[
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),

                        MarkerLayer(
                        markers: _markers,
                        ),
                    ]
                  )),
              ],
            ),
          ),
          ),
    );
  }

    _handleTap(TapPosition? position, LatLng latLng,) {
    setState(() {
      tappedLocation = latLng;
      _markers.clear(); // Clear existing markers
      _markers.add(
        Marker(
          width: 30.0,
          height: 30.0,
          point: latLng,
          child: Icon(Icons.pin_drop_outlined),
        ),
      );
    });
    print('Tapped Location - Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}');
  }

}