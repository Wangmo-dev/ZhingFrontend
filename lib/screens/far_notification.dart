import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationMessage {
  final String message;
  final DateTime date;
  final String sender; // Agronomist name or "Agronomist"
  final String? meetingSchedule; // Optional meeting date/time

  NotificationMessage({
    required this.message,
    required this.date,
    required this.sender,
    this.meetingSchedule,
  });
}

class NotificationPage extends StatelessWidget {
  final List<NotificationMessage> notifications = [
    NotificationMessage(
      message: "Your forwarded issue has been reviewed. Avoid spraying for the next 3 days.",
      date: DateTime.now().subtract(Duration(hours: 2)),
      sender: "Agronomist",
    ),
    NotificationMessage(
      message: "Please meet me at the Gewog Center for inspection.",
      date: DateTime.now().subtract(Duration(days: 1)),
      sender: "Agronomist",
      meetingSchedule: "July 2, 2025 at 10:00 AM",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), 
        // automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
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
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "Notifications from Agronomist",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ...notifications.map((notification) => Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.message,
                                style: TextStyle(fontSize: 16),
                              ),
                              if (notification.meetingSchedule != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 18,
                                          color: Colors.deepOrangeAccent),
                                      SizedBox(width: 6),
                                      Text(
                                        "Meeting: ${notification.meetingSchedule}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrangeAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 10),
                              Text(
                                "From: ${notification.sender}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy – hh:mm a')
                                    .format(notification.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
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
            //   Navigator.pushNamed(context, '/alert'); // Here is the current page
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
