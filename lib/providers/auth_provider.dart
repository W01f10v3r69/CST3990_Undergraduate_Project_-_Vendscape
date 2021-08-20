import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendscape/providers/location_provider.dart';
import 'package:vendscape/screens/home_screen.dart';
import 'package:vendscape/services/user_services.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String smsOtp;
  late String verificationId;
  String error = '';
  UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();

  Future<void> verifyPhone({required BuildContext context, required String number, double? latitude, double? longitude, String? address}) async {
    this.loading = true;
    notifyListeners();

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading=false;
      notifyListeners();
      await _auth.signInWithCredential(credential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading=false;
      print(e.code);
      this.error=e.toString();
      notifyListeners();
    };

    final PhoneCodeSent smsOtpSend = (String verId, int? resendToken) async {
      this.verificationId = verId;

      smsOtpDialog(context, number, latitude!, longitude!, address!);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number.toString(),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      this.error=e.toString();
      notifyListeners();
      print(e);
    }
  }

  Future<dynamic>? smsOtpDialog(BuildContext context, String number, double latitude, double longitude, String address) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('Verification Code'),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'Enter 6 digit Code received by SMS',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            ),
            content: Container(
              height: 85,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  this.smsOtp = value;
                },
              ),
            ),
            actions: [
              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsOtp);

                    final User? user = (await
                    _auth.signInWithCredential(phoneAuthCredential)).user;
                    if (locationData.selectedAddress != null) {
                      updateUser(
                          id: user!.uid,
                          number: user.phoneNumber.toString(),
                          latitude: locationData.latitude,
                          longitude: locationData.longitude,
                          address: locationData.selectedAddress.addressLine);
                    } else{
                      //create user data in firestore after successful registration

                      // var locationData;
                      _createUser(id: user!.uid,
                          number: user.phoneNumber.toString(),
                          latitude: latitude,
                          longitude: longitude,
                          address: address);
                      //Added toString to fix string error
                    }
                    // ignore: unnecessary_null_comparison
                    //back to home screen after login
                    if (user != null) {
                      Navigator.of(context).pop();
                      //don't want to come back to welcome screen after login
                      Navigator.pushReplacementNamed(context, HomeScreen.id);
                    } else {
                      print('Login Failed');
                    }
                  } catch (e) {
                    this.error = 'Invalid OTP';
                    notifyListeners();
                    print(e.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Done'),
              ),
            ],
          );
        });
  }

  void _createUser({required String id, required String number, required double latitude, required double longitude, required String address}) {
    _userServices.createUserData({
      'id': id,
      'number': number,
      'latitude' :longitude,
      'longitude' : longitude,
      'address': address,
    });
    this.loading = false;
    notifyListeners();
  }

  void updateUser({required String id, required String number, required double latitude, required double longitude, required String address}) {
    _userServices.updateUserData({
      'id': id,
      'number': number,
      'latitude' :longitude,
      'longitude' : longitude,
      'address': address,
    });
    this.loading = false;
    notifyListeners();
  }
}

// ignore: unused_element
void _createUser({required String id, String? number, double? latitude, double? longitude, String? address}) {}
