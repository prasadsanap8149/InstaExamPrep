import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Oops Image
              /* Image.asset(
                'assets/images/oops_offline.png',
                // Use a placeholder or your custom offline image
                height: 200,
                width: 200,
              ),*/
              const Icon(
                Icons.signal_wifi_connected_no_internet_4_rounded,
                color: Colors.red,
                size: 50.0,
              ),
              const SizedBox(height: 20),
              // "Oops! You're Offline" Text
              const Text(
                "Oops! You're Offline",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subtitle Text
              const Text(
                "It seems like you're not connected to the internet. Please check your connection and try again.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Retry Button
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              // Troubleshoot Button
              TextButton(
                onPressed: () {
                  // Add navigation or troubleshooting logic
                },
                child: const Text(
                  "Troubleshoot",
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
