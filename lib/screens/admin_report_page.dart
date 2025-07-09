import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allScans = [];
  List<dynamic> _filteredScans = [];
  bool _isLoading = true;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Token not found');

      final me = await _apiService.getCurrentUser(token: token);
      final String myDzongkhag = me['user']['dzongkhag'];

      final allScans = await _apiService.getForwardedScans(token: token);
      final filtered = allScans.where((scan) {
        final user = scan['user'];
        return user != null && user['dzongkhag'] == myDzongkhag;
      }).toList();

      setState(() {
        _allScans = filtered;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Failed to load scans: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
  if (_selectedStatus == 'All') {
    _filteredScans = [..._allScans];
  } else {
    _filteredScans = _allScans.where((scan) {
      final status = scan['status']?.toLowerCase();
      if (_selectedStatus.toLowerCase() == 'pending') {
        return status == 'sent_to_admin' || status == 'pending';
      }
      return status == _selectedStatus.toLowerCase();
    }).toList();
  }
}

  void _forwardReport(dynamic scan) {
    setState(() {
      scan['status'] = 'forwarded';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report forwarded')),
    );
  }

  void _showCommentOptions(dynamic scan) {
    final farmerName = scan['user']?['name'] ?? 'Farmer';

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Contact $farmerName'),
        children: [
          ListTile(
            leading: Icon(Icons.call, color: Colors.green),
            title: Text('Call farmer'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $farmerName...')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.message, color: Colors.green),
            title: Text('Send message'),
            onTap: () {
              Navigator.pop(context);
              _showMessageDialog(farmerName);
            },
          ),
          ListTile(
            leading: Icon(Icons.schedule, color: Colors.green),
            title: Text('Schedule visit'),
            onTap: () {
              Navigator.pop(context);
              _scheduleVisit(farmerName);
            },
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(String name) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message $name'),
        content: TextField(
          controller: _controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Type your message here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to $name')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  void _scheduleVisit(String name) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final scheduledDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visit scheduled with $name for ${DateFormat.yMMMd().add_jm().format(scheduledDateTime)}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Forwarded Reports',
    style: TextStyle(color: Colors.white), // 👈 white title
  ),
  backgroundColor: const Color(0xFF116736), // 👈 green background
  iconTheme: const IconThemeData(color: Colors.white), // 👈 white icons
  actions: [
    PopupMenuButton<String>(
      icon: const Icon(Icons.filter_alt), // 👈 now white due to iconTheme
      onSelected: (String value) {
        setState(() {
          _selectedStatus = value;
          _applyFilter();
        });
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'All', child: Text('All')),
        PopupMenuItem(value: 'pending', child: Text('Pending')),
        PopupMenuItem(value: 'forwarded', child: Text('Forwarded')),
      ],
    ),
  ],
),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredScans.isEmpty
              ? Center(child: Text('No reports found.'))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _filteredScans.length,
                  itemBuilder: (context, index) {
                    final scan = _filteredScans[index];
                    final user = scan['user'] ?? {};
                    final name = user['cid'] ?? 'Unknown';
                    final imageUrl = scan['imageUrl'] ?? '';
                    final disease = scan['diseaseDetected'] ?? 'N/A';
                    final dzongkhag = user['dzongkhag'] ?? 'Unknown';
                    final gewog = user['gewog'] ?? 'Unknown';
                    final status = scan['status'] ?? 'pending';
                    final date = DateTime.tryParse(scan['date'] ?? '') ?? DateTime.now();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Text(name[0].toUpperCase(), style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('$dzongkhag, $gewog', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                                Spacer(),
                                Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: status == 'sent_to_admin'
        ? Colors.red[100]
        : status == 'pending'
            ? Colors.orange[100]
            : Colors.green[100],
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    status == 'sent_to_admin'
        ? 'Pending'
        : status[0].toUpperCase() + status.substring(1),
    style: TextStyle(
      color: status == 'sent_to_admin'
          ? Colors.red[800]
          : status == 'pending'
              ? Colors.orange[800]
              : Colors.green[800],
      fontSize: 12,
    ),
  ),
),


                              ],
                            ),
                            SizedBox(height: 16),
                            Text(disease, style: TextStyle(fontSize: 16)),
                            SizedBox(height: 12),
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
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('MMM dd, yyyy').format(date),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.send, color: Colors.green),
                                      onPressed: status != 'forwarded'
                                          ? () => _forwardReport(scan)
                                          : null,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.message, color: Colors.green),
                                      onPressed: () => _showCommentOptions(scan),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
    currentIndex: 1, // 👈 Highlight the "Report" tab
    selectedItemColor: const Color(0xFF116736),
    unselectedItemColor: Colors.grey,
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/homepage');
          break;
        case 1:
          // Already on this page
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
),

    );
    
  }
}
