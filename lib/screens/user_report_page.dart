import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UserReportPage extends StatefulWidget {
  const UserReportPage({super.key});

  @override
  _UserReportPageState createState() => _UserReportPageState();
}

class _UserReportPageState extends State<UserReportPage> {
  List<dynamic> _forwardedScans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchForwardedScans();
  }

  Future<void> _fetchForwardedScans() async {
  try {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Token not found');

    final userData = await ApiService().getCurrentUser(token: token);
    final userCid = userData['user']['cid'];

    final allScans = await ApiService().getForwardedScans(token: token);

    final userScans = allScans
        .where((scan) => scan['user']?['cid'] == userCid)
        .toList();

    setState(() {
      _forwardedScans = userScans;
      _isLoading = false;
    });
  } catch (e) {
    print('[ERROR] $e');
    setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF116736),
        title: const Text(
          'Farmer Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white, size: 32),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _forwardedScans.isEmpty
              ? Center(child: Text("No forwarded scans found."))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _forwardedScans.length,
                  itemBuilder: (context, index) {
                    final scan = _forwardedScans[index];
                    final disease = scan['diseaseDetected'] ?? 'Unknown';
                    final imageUrl = scan['imageUrl'] ?? '';
                    final date = DateTime.tryParse(scan['date'] ?? '') ?? DateTime.now();
                    final status = scan['status'] ?? 'Unknown';

                    return _buildScanCard(disease, imageUrl, date, status);
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
    );
  }

  Widget _buildScanCard(String disease, String imageUrl, DateTime date, String status) {
  return Card(
    margin: EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disease name and status in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  disease,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == "Pending" ? Colors.orange[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == "Pending" ? Colors.orange[800] : Colors.green[800],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          SizedBox(height: 12),

          // Date
          Text(
            DateFormat('MMM dd, yyyy').format(date),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    ),
  );
}

}
