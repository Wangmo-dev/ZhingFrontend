import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int unreadCount = 2; // Initial unread count (can be fetched later)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Image.asset('assets/logo.png', height: 50),
              const Spacer(),

              // 🔔 Notification icon with badge
              Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(context, '/f_alert');
                      setState(() {
                        unreadCount = 0; // Mark notifications as read
                      });
                    },
                    child: const Icon(
                      Icons.notifications_none,
                      size: 30,
                      color: Colors.black87,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/f_profile');
                },
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: 34,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
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

      // 🌿 Home page content
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Banner section
            Stack(
              children: [
                Image.asset(
                  'assets/banner.png',
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 180,
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
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 30, right: 16),
              child: Text(
                'Diagnose Your Plants in 3 Easy Steps',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
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

            const Padding(
              padding: EdgeInsets.only(left: 30, right: 16),
              child: Text(
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

            const SizedBox(height: 20),
          ],
        ),
      ),

      // 📱 Bottom navigation bar
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
                Navigator.pushNamed(context, '/scan');
                break;
              case 3:
                Navigator.pushNamed(context, '/support');
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
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent),
              label: "Support",
            ),
          ],
        ),
      ),
    );
  }

  static Widget cropCard(String imagePath, String title) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
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
