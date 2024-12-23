import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class TVPage extends StatefulWidget {
  const TVPage({super.key});

  @override
  _TVPageState createState() => _TVPageState();
}

class _TVPageState extends State<TVPage> {
  bool isTVOn = false;

  // Variables to hold real-time data
  String todayConsumption = 'Loading...';
  String monthlyConsumption = 'Loading...';
  String todayCost = 'Loading...';
  String monthlyCost = 'Loading...';
  String fullName = "User";

  // List to store Firebase subscriptions
  final List<StreamSubscription> _subscriptions = [];
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref('EnergyMonitor/SmartTV'); // Database path

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
    fetchSwitchState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    // Get the currently authenticated user
    final user = FirebaseAuth.instance.currentUser;

    // If user is logged in, fetch the fullName from Firestore
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use the current user's ID
          .get();

      if (userDoc.exists) {
        setState(() {
          fullName = userDoc['fullName'] ??
              'Guest'; // If fullName is not available, use 'Guest'
        });
      } else {
        print('User document does not exist');
      }
    } else {
      print('No user is logged in');
    }
  }

  // Fetch real-time data from Firebase
  void fetchDataFromFirebase() {
    _subscriptions.add(
      dbRef.child('totalEnergy_day').onValue.listen((event) {
        if (mounted) {
          setState(() {
            todayConsumption = '${event.snapshot.value ?? "0"} kWh';
          });
        }
      }),
    );

    _subscriptions.add(
      dbRef.child('totalEnergy').onValue.listen((event) {
        if (mounted) {
          setState(() {
            monthlyConsumption = '${event.snapshot.value ?? "0"} kWh';
          });
        }
      }),
    );

    _subscriptions.add(
      dbRef.child('cost_day').onValue.listen((event) {
        if (mounted) {
          setState(() {
            todayCost = '${event.snapshot.value ?? "0"} DT';
          });
        }
      }),
    );

    _subscriptions.add(
      dbRef.child('cost').onValue.listen((event) {
        if (mounted) {
          setState(() {
            monthlyCost = '${event.snapshot.value ?? "0"} DT';
          });
        }
      }),
    );
  }

  // Fetch the switch state from Firebase
  void fetchSwitchState() {
    _subscriptions.add(
      dbRef.child('buttonState').onValue.listen((event) {
        if (mounted) {
          setState(() {
            isTVOn = event.snapshot.value == true; // Update switch state
          });
        }
      }),
    );
  }

  // Update the switch state in Firebase
  void updateSwitchState(bool value) {
    dbRef.child('buttonState').set(value).then((_) {
      print('Switch state updated to: $value');
    }).catchError((error) {
      print('Failed to update switch state: $error');
    });
  }

  @override
  void dispose() {
    // Cancel all active subscriptions to prevent memory leaks
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5E5), // Light Orange (Top)
              Color(0xFFFFFFFF), // White (Bottom)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Back Arrow
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 28, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(
                              context); // Navigate back to the previous screen
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        'TV Consumption',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.circle, color: Colors.grey[300], size: 30),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Always save on using Electricity',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 50), // Add spacing before the box
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0), // Light grey for the box
                      border: Border.all(
                        color: Colors.black, // Black border
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Smart TV',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Switch(
                              value: isTVOn,
                              onChanged: (bool value) {
                                setState(() {
                                  isTVOn = value;
                                });
                                updateSwitchState(value); // Update Firebase
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        buildConsumptionText(
                            'Today Consumption:', todayConsumption),
                        SizedBox(height: 15),
                        buildConsumptionText(
                            'Monthly Consumption:', monthlyConsumption),
                        buildConsumptionText('Today Facture:', todayCost),
                        SizedBox(height: 15),
                        buildConsumptionText('Monthly Facture:', monthlyCost),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildConsumptionText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
