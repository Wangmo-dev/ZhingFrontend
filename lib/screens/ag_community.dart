import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPage2 extends StatefulWidget {
  const CommunityPage2({super.key});

  @override
  State<CommunityPage2> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage2> {
  final Map<String, bool> joinedGroups = {
    'Potato Growers': false,
    'Rice Cultivators': false,
    'Maize Farmers': false,
  };

  final List<Map<String, dynamic>> userCommunities = [];

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCommunityDialog(context),
        backgroundColor: const Color(0xFF116736),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
                  ...userCommunities.map((community) {
                    return _buildUserGroupCard(
                      context,
                      title: community['title'],
                      imagePath: community['imagePath'],
                    );
                  }).toList(),
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

  Widget _buildUserGroupCard(
    BuildContext context, {
    required String title,
    required String imagePath,
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
            child: Image.file(
              File(imagePath),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing posts for $title')),
                      );
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

  void _showAddCommunityDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    String? _imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add New Community'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Community Name'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setStateDialog(() => _imagePath = image.path);
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Choose Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF116736),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (_imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Image selected',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty && _imagePath != null) {
                    setState(() {
                      userCommunities.add({
                        'title': name,
                        'imagePath': _imagePath!,
                      });
                      joinedGroups[name] = false;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF116736),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        });
      },
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
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Support"),
      ],
    );
  }
}
