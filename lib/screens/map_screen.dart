// import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:vendscape/providers/auth_provider.dart';
import 'package:vendscape/providers/location_provider.dart';
import 'package:vendscape/screens/home_screen.dart';
import 'package:vendscape/screens/login_screen.dart';

class MapScreen extends StatefulWidget {
  static const String id = 'map-screen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng currentLocation;
  late GoogleMapController _mapController;
  bool _locating = false;
  bool _loggedIn = false;
  late User user;

  @override
  void initState() {
    // Check if user is logged in or not while opening the map screen
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    // User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      user = FirebaseAuth.instance.currentUser!;
      // _loggedIn = true;
    });
    if (user!=null) {
      setState(() {
        _loggedIn = true;
        // user = FirebaseAuth.instance.currentUser!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    final _auth = Provider.of<AuthProvider>(context);

    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
    });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 14.4746,
            ),
            zoomControlsEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(1.5, 20.8),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            mapToolbarEnabled: true,
            onCameraMove: (CameraPosition position) {
              setState(() {
                _locating = true;
              });
              locationData.onCameraMove(position);
            },
            onMapCreated: onCreated,
            onCameraIdle: () {
              setState(() {
                _locating = false;
              });
              locationData.getMoveCamera();
            },
          ),
          Center(
            child: Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 45),
              child: Image.asset('images/marker.png', color: Colors.black,),
            ),
          ),
          Center(
            child: SpinKitPulse(
              color: Colors.black54,
              size: 100.0,
            ),
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _locating
                      ? LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.location_searching_rounded, color: Theme.of(context).primaryColor,),
                        label: Flexible(
                          child: Text(
                            _locating
                                ? 'Locating...'
                                : locationData.selectedAddress.featureName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      _locating
                          ? 'Locating...'
                          : locationData.selectedAddress.addressLine,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width-40, //40 is padding from both sides 20/20
                      child: AbsorbPointer(
                        absorbing: _locating ? true : false,
                        child: FlatButton(
                            onPressed: (){
                              if (_loggedIn==false) {
                                Navigator.pushNamed(context, LoginScreen.id);
                              }else{
                                _auth.updateUser(
                                  id: user.uid,
                                  number: user.phoneNumber.toString(),
                                  latitude: locationData.latitude,
                                  longitude: locationData.longitude,
                                  address: locationData.selectedAddress.addressLine
                                );
                                Navigator.pushNamed(context, HomeScreen.id);
                              }
                            },
                            color: _locating ? Colors.grey : Theme.of(context).primaryColor,
                            child: Text('CONFIRM LOCATION', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

//got current lat and long
