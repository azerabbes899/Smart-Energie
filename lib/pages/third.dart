import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'tv.dart';
import 'fridge.dart';

// Add the Energy Threshold Dialog
class EnergyThresholdDialog extends StatefulWidget {
  final double currentThreshold;

  const EnergyThresholdDialog({super.key, required this.currentThreshold});

  @override
  State<EnergyThresholdDialog> createState() => _EnergyThresholdDialogState();
}

class _EnergyThresholdDialogState extends State<EnergyThresholdDialog> {
  late TextEditingController _thresholdController;

  @override
  void initState() {
    super.initState();
    _thresholdController =
        TextEditingController(text: widget.currentThreshold.toString());
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Energy Threshold'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Set your daily energy cost threshold in DT:'),
          TextField(
            controller: _thresholdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter threshold value',
              suffixText: 'DT',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newThreshold = double.tryParse(_thresholdController.text);
            if (newThreshold != null && newThreshold > 0) {
              Navigator.pop(context, newThreshold);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid positive number'),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref("EnergyMonitor");

  double totalEnergyDay = 0.0;
  double totalEnergy = 0.0;
  double costDay = 0.0;
  double cost = 0.0;
  double seuil = 3.0;

  // Real-time data variables for devices
  double smartTvConsumption = 0.0;
  double fridgeConsumption = 0.0;

  String fullName = "User";

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchDeviceData();
    _fetchUserName();
  }

  Future<void> _updateThreshold(double newThreshold) async {
    try {
      await _database.child('seuil').set(newThreshold);
      setState(() {
        seuil = newThreshold;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating threshold: $e')),
        );
      }
    }
  }

  Future<void> _showThresholdDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => EnergyThresholdDialog(currentThreshold: seuil),
    );

    if (result != null && mounted) {
      await _updateThreshold(result);
    }
  }

  void _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          fullName = userDoc['fullName'] ?? 'Guest';
        });
      } else {
        print('User document does not exist');
      }
    } else {
      print('No user is logged in');
    }
  }

  void _sendNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'alerts',
        title: 'Energy Usage Alert',
        body: 'Your energy usage today is abnormal. Please check your devices!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  void _fetchData() {
    _database.child('totalEnergy_day').onValue.listen((event) {
      setState(() {
        totalEnergyDay = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      });
    });

    _database.child('seuil').onValue.listen((event) {
      setState(() {
        seuil = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      });
    });

    _database.child('totalEnergy').onValue.listen((event) {
      setState(() {
        totalEnergy = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      });
    });

    _database.child('cost_day').onValue.listen((event) {
      double newCostDay = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      setState(() {
        costDay = newCostDay;
        if (costDay == seuil) {
          _sendNotification();
        }
      });
    });

    _database.child('cost').onValue.listen((event) {
      setState(() {
        cost = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      });
    });
  }

  void _fetchDeviceData() {
    _database.child('SmartTV/totalEnergy_day').onValue.listen((event) {
      setState(() {
        smartTvConsumption = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      });
    });

    _database.child('Fridge/totalEnergy_day').onValue.listen((event) {
      setState(() {
        fridgeConsumption = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header Section with Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, $fullName!",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Always save on using Electricity",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: _showThresholdDialog,
                        tooltip: 'Set Energy Threshold',
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Energy Usage Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Energy Usage",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.power_outlined,
                                color: Colors.grey, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              "Today",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${totalEnergyDay.toStringAsFixed(5)} kWh",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.flash_on,
                                color: Colors.grey, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              "This Month",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${totalEnergy.toStringAsFixed(5)} kWh",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[300], thickness: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Estimated Bill",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Threshold: ${seuil.toStringAsFixed(2)} DT",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.power_outlined,
                                color: Colors.grey, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              "Today",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${costDay.toStringAsFixed(5)} DT",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.attach_money,
                                color: Colors.grey, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              "This Month",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${cost.toStringAsFixed(5)} DT",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Energy Message Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: costDay >= seuil ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        costDay == seuil
                            ? "Your Energy Usage is Abnormal. You should check your devices as soon as possible!!!"
                            : "Your Energy Usage is Normal. Don't Forget To Save Energy!",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // My Devices Section
              const Text(
                "My Devices",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DeviceCard(
                    deviceName: "Smart TV",
                    consumption: smartTvConsumption,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TVPage()),
                      );
                    },
                  ),
                  DeviceCard(
                    deviceName: "Fridge",
                    consumption: fridgeConsumption,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FridgePage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final double consumption;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.consumption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              deviceName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Consuming",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${consumption.toStringAsFixed(5)} kWh",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Click for More \n       Details",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
