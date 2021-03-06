import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendscape/providers/auth_provider.dart';
import 'package:vendscape/providers/location_provider.dart';
import 'package:vendscape/screens/map_screen.dart';
import 'package:vendscape/screens/onboarding_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome-screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    bool _validPhoneNumber = false;
    var _phoneNumberController = TextEditingController();

    void showBottomSheet(context) {
      showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter myState) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: auth.error == 'Invalid OTP' ? true : false,
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              auth.error,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'LOGIN',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Enter Your Phone Number To Proceed',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        prefixText: '+234',
                        labelText: '10 digit number',
                      ),
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      controller: _phoneNumberController,
                      onChanged: (value) {
                        if (value.length == 10) {
                          myState(() {
                            _validPhoneNumber = true;
                          });
                        } else {
                          myState(() {
                            _validPhoneNumber = false;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: _validPhoneNumber ? false : true,
                            child: FlatButton(
                                onPressed: () {
                                  myState((){
                                    auth.loading=true;
                                  });
                                  String number = '+234${_phoneNumberController.text}';
                                  auth.verifyPhone(context: context, number: number).then((value) {
                                    _phoneNumberController.clear();
                                  });
                                },
                                color: _validPhoneNumber
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                child: auth.loading ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ) : Text(
                                  _validPhoneNumber ? 'CONTINUE'
                                      : 'ENTER PHONE NUMBER',
                                  style: TextStyle(color: Colors.white),
                                ),

                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
               ),
            );
          },
        ),
      ).whenComplete((){
        // this.loading = false;
        // notifyListeners();
        auth.loading = false;
        _phoneNumberController.clear();
      });
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              right: 0.0,
              top: 10.0,
              child: FlatButton(
                child: Text(
                  'SKIP',
                  style: TextStyle(color: Colors.lightBlue),
                ),
                onPressed: () {},
              ),
            ),
            Column(
              children: [
                Expanded(child: OnboardingScreen()),
                Text(
                  'Ready to Order From The Nearest Vendor?',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  color: Colors.lightBlue,
                  child: locationData.loading ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ) : Text('Set Delivery Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    setState(() {
                    });
                    await locationData.getCurrentPosition();
                    if (locationData.permissionAllowed == true) {
                      Navigator.pushReplacementNamed(context, MapScreen.id);
                      setState(() {
                        locationData.loading = false;
                      });
                    } else {
                      print('Permission Not Allowed');
                      setState(() {
                        locationData.loading = false;
                      });
                    }
                  },
                ),
                FlatButton(
                  child: RichText(
                      text: TextSpan(
                          text: 'Already a Customer ? ',
                          style: TextStyle(color: Colors.grey),
                          children: [
                        TextSpan(
                            text: 'Login',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue))
                      ],
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      auth.screen = 'Login';
                    });
                    showBottomSheet(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
