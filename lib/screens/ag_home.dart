import 'package:flutter/material.dart';

class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          selectedItemColor: Color(0xFF116736),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/homepage');
                break;
              case 1:
                Navigator.pushNamed(
                  context,
                  '/report',
                ); // Make sure you have this route defined!
                break;
              case 2:
                Navigator.pushNamed(context, '/scan'); // 🔥 Define in routes
                break;
              // case 3:
              //   Navigator.pushNamed(context, '/alert'); // 🔥 Define in routes
              //   break;
              case 3:
                Navigator.pushNamed(context, '/support'); // 🔥 Define in routes
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: "Report"),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: "Scan",
            ),
            // BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Alert"),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent),
              label: "Support",
            ),
          ],
        ),
      ),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70, // 👈 Makes AppBar taller (default is 56)
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Image.asset('assets/logo.png', height: 50),
              const Spacer(),

              // Profile Icon 👉 Wrap with GestureDetector
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushNamed(
              //       context,
              //       '/a_data',
              //     ); // 👈 Make sure '/profile' is defined in your routes
              //   },
              //   child: const Icon(
              //     Icons.notes_outlined,
              //     size: 34,
              //     color: Colors.black87,
              //   ),
              // ),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/a_agronomist_profile',
                  ); // 👈 Make sure '/profile' is defined in your routes
                },
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: 34,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(width: 16),

              // Logout Icon 👉 Wrap with GestureDetector
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                  // 👆 Navigates to login and clears the previous stack so user can't come back after logout
                },
                child: const Icon(
                  Icons.logout_outlined,
                  size: 32,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image and Text
            Stack(
              children: [
                Image.asset(
                  'assets/banner.png',
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16, // 👈 Move to top
                  right: 16, // 👈 Move to right
                  child: Container(
                    width: 180, // 👈 Give fixed width so it wraps nicely
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AI-Powered Plant Health.  Spot Diseases Early. Grow Stronger!',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign:
                          TextAlign
                              .right, // 👈 Align text to right inside container
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Diagnose Section
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 16),
              child: const Text(
                'Diagnose Your Plants in 3 Easy Steps',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_camera, color: Color(0xFF116736)),
                    title: Text('Scan infected plants'),
                  ),
                  ListTile(
                    leading: Icon(Icons.visibility, color: Color(0xFF116736)),
                    title: Text('Get scan result'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.tips_and_updates,
                      color: Color(0xFF116736),
                    ),
                    title: Text('Get detail suggestions'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Popular Crop Disease Section
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 16),
              child: const Text(
                'Popular In Crop Disease',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 30, right: 16),
                children: [
                  cropCard('assets/tomato.png', 'Tomato Blight'),
                  cropCard('assets/wheat.png', 'Wheat rust'),
                  cropCard('assets/cabbage.png', 'Corn Leaf Spot'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cropCard(String imagePath, String title) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
