import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final Map<String, bool> joinedGroups = {
    'Potato Growers': false,
    'Rice Cultivators': false,
    'Maize Farmers': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Community Groups',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF116736),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join a Crop Group',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildGroupCard(
                    context,
                    title: 'Potato Growers',
                    imageAsset: 'assets/potato.jpg',
                    route: '/groupP',
                  ),
                  _buildGroupCard(
                    context,
                    title: 'Rice Cultivators',
                    imageAsset: 'assets/rice.jpeg',
                    route: '/groupR',
                  ),
                  _buildGroupCard(
                    context,
                    title: 'Maize Farmers',
                    imageAsset: 'assets/maize.jpeg',
                    route: '/groupM',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 3),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required String title,
    required String imageAsset,
    required String route,
  }) {
    final isJoined = joinedGroups[title] ?? false;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageAsset,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (!isJoined) {
                      setState(() => joinedGroups[title] = true);
                    } else {
                      Navigator.pushNamed(context, route);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF116736),
                  ),
                  child: Text(
                    isJoined ? 'View Posts' : 'Join',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
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
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
        BottomNavigationBarItem(
          icon: Icon(Icons.support_agent),
          label: "Support",
        ),
      ],
    );
  }
}
