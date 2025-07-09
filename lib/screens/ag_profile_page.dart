import '../screens/edit_agronomist_profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgronomistProfilePage2 extends StatelessWidget {
  final List<Activity> recentActivities = [
    Activity(
      title: 'Report forwarded to organization',
      description: 'Potato late blight case from Dorji Wangchuk',
      date: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Activity(
      title: 'Diagnosis completed',
      description: 'Apple scab infection for Pema Lhamo',
      date: DateTime.now().subtract(Duration(days: 1)),
    ),
    Activity(
      title: 'Field visit scheduled',
      description: 'Chhoekhar, Bumthang for crop assessment',
      date: DateTime.now().subtract(Duration(days: 3)),
    ),
  ];

  AgronomistProfilePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'My Profile',
    style: TextStyle(color: Colors.white), // 👈 text color
  ),
  backgroundColor: const Color(0xFF116736), // 👈 background color
  iconTheme: const IconThemeData(color: Colors.white), // 👈 icon color
  actions: [
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditAgronomistProfilePage(),
          ),
        );
      },
    ),
  ],
),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF116736),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tenzin Wangmo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bumthang District',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Chip(
                    label: Text('Crop Diseases Specialist'),
                    backgroundColor: Color(0xFF116736).withOpacity(0.1),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Profile Details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileDetail('Email', 'agronomist@example.com'),
                    Divider(),
                    _buildProfileDetail('Phone', '+975 17 123 456'),
                    Divider(),
                    _buildProfileDetail('District', 'Bumthang'),
                    Divider(),
                    _buildProfileDetail('Gewog', 'Chhoekhor'),
                    Divider(),
                    _buildProfileDetail('Village', 'Jakar'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Recent Activities
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Recent Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recentActivities.length,
              itemBuilder: (context, index) {
                return _buildActivityCard(recentActivities[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF116736).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Color(0xFF116736),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  DateFormat('MMM dd').format(activity.date),
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                activity.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Activity {
  final String title;
  final String description;
  final DateTime date;

  Activity({
    required this.title,
    required this.description,
    required this.date,
  });
}
