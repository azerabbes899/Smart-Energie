import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  _FridgePageState createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  bool isFridgeOn = false;

  // Variables to hold real-time data
  String todayConsumption = 'Loading...';
  String monthlyConsumption = 'Loading...';
  String todayCost = 'Loading...';
  String monthlyCost = 'Loading...';

  // List to store Firebase subscriptions
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  void fetchDataFromFirebase() {
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('EnergyMonitor/Fridge');

    // Listen to the Firebase data changes
    _subscriptions.add(
      dbRef.child('totalEnergy_day').onValue.listen((event) {
        if (mounted) {
          setState(() {
            todayConsumption = '${event.snapshot.value} kWh';
          });
        }
      }),
    );

    _subscriptions.add(
      dbRef.child('totalEnergy').onValue.listen((event) {
        if (mounted) {
          setState(() {
            monthlyConsumption = '${event.snapshot.value} kWh';
          });
        }
      }),
    );

    _subscriptions.add(
      dbRef.child('cost_day').onValue.listen((event) {
        if (mounted) {
          setState(() {
            todayCost = '${event.snapshot.value} DT';
          });
        }
      }),
    );

    _subscriptions.add(
      dbRef.child('cost').onValue.listen((event) {
        if (mounted) {
          setState(() {
            monthlyCost = '${event.snapshot.value} DT';
          });
        }
      }),
    );
  }

  @override
  void dispose() {
    // Cancel all active subscriptions
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
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Fridge Consumption',
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
                  SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0), // Light grey for the box
                      border: Border.all(
                        color: Colors.black,
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
                              'Fridge',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Switch(
                              value: isFridgeOn,
                              onChanged: (bool value) {
                                setState(() {
                                  isFridgeOn = value;
                                });
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
                        SizedBox(height: 15),
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
