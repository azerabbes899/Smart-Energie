import 'package:energie_project/pages/login.dart';
import 'package:flutter/material.dart';


class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute content
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          const SizedBox(height: 40), // Spacing from the top
          // Logo and Title at the top left
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.power,
                    color: Colors.amber[700], size: 35), // Larger icon
                const SizedBox(width: 8),
                Text(
                  "SmartEnergy",
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontSize: 28, // Bigger text
                    fontWeight: FontWeight.w900, // Extra bold
                  ),
                ),
              ],
            ),
          ),
          // Center Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              'assets/image1.png',
              width: MediaQuery.of(context).size.width * 0.9, // Larger image
            ),
          ),
          // Center Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                // Add functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                minimumSize: const Size(200, 50), // Fixed width and height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Connect Device",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // Make text bold
                ),
              ),
            ),
          ),
          const SizedBox(height: 40), // Bottom spacing
        ],
      ),
    );
  }
}
