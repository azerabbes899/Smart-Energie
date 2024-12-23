import 'package:energie_project/pages/third.dart';
import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 40), // Spacing from the top
          // Image Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              'assets/image2.png',
              width: MediaQuery.of(context).size.width *
                  0.9, // Responsive image size
            ),
          ),
          // Text Section
          Column(
            children: [
              Text(
                "Make Life Easy",
                style: TextStyle(
                  fontSize: 26, // Larger text
                  fontWeight: FontWeight.bold, // Bold font
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "With ",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: "SmartEnergy",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Control all your electricity usage safely and easily",
                style: TextStyle(
                  fontSize: 12, // Regular description text
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 10, 10, 10),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Button Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdPage()),
                );
                // Add functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                minimumSize: const Size(200, 50), // Fixed size for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // Bold button text
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
