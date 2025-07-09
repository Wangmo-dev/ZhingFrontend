import 'dart:io';
import 'package:flutter/material.dart';

class RecommendationPage extends StatelessWidget {
  final String imagePath;

  const RecommendationPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF116736),
        title: const Text('Recommendations', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Show image again
              SizedBox(
                width: 250,
                height: 300,
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),

              // Placeholder for actual recommendations
              const Text(
                'Plant disease management recommendations will appear here.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF116736),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Scan Result'),
              ),
            ],
          ),
        ),
      ),

      // ✅ Bottom Navigation Bar (Index 2 - Scan)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2, // 👈 Highlight the "Scan" tab
          selectedItemColor: const Color(0xFF116736),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/homepage');
                break;
              case 1:
                Navigator.pushNamed(context, '/report');
                break;
              case 2:
                // Already on this page
                break;
              case 3:
                Navigator.pushNamed(context, '/support');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: "Report"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
            BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Support"),
          ],
        ),
      ),
    );
  }
}
