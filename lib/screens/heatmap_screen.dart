import 'package:flutter/material.dart';

class HeatmapScreen extends StatelessWidget {
  const HeatmapScreen({super.key});

  // TEMP: local / placeholder URL
  static const String heatmapUrl =
      "https://nexuspay-heatmap-api.onrender.com/heatmap/world";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fraud Heatmap"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 6.0,
          child: Image.network(
            heatmapUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                "Unable to load heatmap",
                style: TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}