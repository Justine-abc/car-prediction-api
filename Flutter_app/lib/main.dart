import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  // Input Controllers
  final TextEditingController engineController = TextEditingController();
  final TextEditingController cylinderController = TextEditingController();
  final TextEditingController fuelController = TextEditingController();

  String result = "Enter details to predict CO2";
  bool isLoading = false;

  // YOUR RENDER URL
  final String apiUrl = "https://car-prediction-api.onrender.com/predict";

  Future<void> predictEmission() async {
    // 1. Validate Inputs
    if (engineController.text.isEmpty ||
        cylinderController.text.isEmpty ||
        fuelController.text.isEmpty) {
      setState(() {
        result = "Please fill in all fields.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      result = "Calculating...";
    });

    try {
      // 2. Prepare Data
      // Must match the Python "CarInput" model exactly!
      Map<String, dynamic> requestBody = {
        "engine_size": double.parse(engineController.text),
        "cylinders": int.parse(cylinderController.text),
        "fuel_consumption": double.parse(fuelController.text),
      };

      // 3. Send POST Request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // 4. Handle Response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        double co2 = data['predicted_co2'];
        setState(() {
          result = "CO2 Emissions: ${co2.toStringAsFixed(2)} g/km";
        });
      } else {
        setState(() {
          result = "Error: ${response.statusCode} - Check inputs (Ranges!)";
        });
      }
    } catch (e) {
      setState(() {
        result = "Failed to connect. Check internet.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle CO2 Predictor"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Mission: Predict Environmental Impact",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Input 1: Engine Size
            TextField(
              controller: engineController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Engine Size (L)",
                hintText: "e.g., 2.4",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings),
              ),
            ),
            const SizedBox(height: 15),

            // Input 2: Cylinders
            TextField(
              controller: cylinderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cylinders",
                hintText: "e.g., 4",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.view_module),
              ),
            ),
            const SizedBox(height: 15),

            // Input 3: Fuel Consumption
            TextField(
              controller: fuelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Fuel Consumption (L/100km)",
                hintText: "e.g., 8.5",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station),
              ),
            ),
            const SizedBox(height: 25),

            // Predict Button
            ElevatedButton(
              onPressed: isLoading ? null : predictEmission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("PREDICT CO2", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),

            // Result Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
