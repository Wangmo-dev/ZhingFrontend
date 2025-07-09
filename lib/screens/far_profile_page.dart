import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), 
        // automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0), // <-- Add padding here
          child: Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFF116736),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0), // <-- Add padding to the logout button
            child: IconButton(
              icon: Icon(Icons.logout),
              color: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF116736),
                child: Text(
                  'DD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Dechok Dema',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Farmer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Full Name'),
              subtitle: Text('Dechok Dema'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Address'),
              subtitle: Text('dechok@example.com'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Dzongkhag'),
              subtitle: Text('Bumthang'),
            ),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text('Gewog'),
              subtitle: Text('Chhoekhor'),
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                // Navigate to change password screen
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 0),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    return Container(
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
        currentIndex: selectedIndex,
        selectedItemColor: Color(0xFF116736),
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
            // case 3:
            //   Navigator.pushNamed(context, '/alert');
            //   break;
            case 3:
              Navigator.pushNamed(context, '/support');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          // BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Alert"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Support"),
        ],
      ),
    );
  }
}
