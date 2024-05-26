// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to BuyGreen!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "BuyGreen is a sustainability-focused app that helps you make eco-friendly purchasing decisions. Our app empowers you with information about products' environmental impact, CO2 emissions, energy usage, and recyclability percentage.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              "Contact us:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Email: contact@alfonso0p6.dev",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "GitHub: github.com/alfonso0p6",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
