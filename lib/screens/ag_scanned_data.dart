import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

class SuperAdminPage extends StatefulWidget {
  const SuperAdminPage({super.key});
  @override
  _AdminScanPageState createState() => _AdminScanPageState();
}

class _AdminScanPageState extends State<SuperAdminPage> {
  List<dynamic> allScans = [];
  List<dynamic> filteredScans = [];
  String selectedDisease = 'All';

  @override
  void initState() {
    super.initState();
    fetchScans();
  }

  Future<void> fetchScans() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.131.104:3000/api/scans'));

      if (response.statusCode == 200) {
        setState(() {
          allScans = json.decode(response.body);
          filteredScans = allScans;
        });
      } else {
        throw Exception('Failed to load scans');
      }
    } catch (e) {
      print("Error fetching scans: $e");
    }
  }

  void filterScans(String disease) {
    setState(() {
      selectedDisease = disease;
      filteredScans = (disease == 'All')
          ? allScans
          : allScans.where((scan) => scan['diseaseDetected'] == disease).toList();
    });
  }

  Future<void> downloadExcel() async {
    final dio = Dio();
    final String url = selectedDisease == 'All'
        ? 'https://zhingscanserver.onrender.com/api/scans/export'
        : 'https://zhingscanserver.onrender.com/api/scans/export?disease=$selectedDisease';

    try {
      if (await Permission.manageExternalStorage.request().isGranted) {
        String fileName = 'scans_${selectedDisease.replaceAll(" ", "_")}.xlsx';
        String dirPath = '/storage/emulated/0/Download';
        String filePath = '$dirPath/$fileName';

        final response = await dio.download(url, filePath);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel downloaded to $filePath')),
          );
          OpenFile.open(filePath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: ${response.statusCode}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Excel Download Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading Excel: $e')),
      );
    }
  }

  Future<void> downloadImagesByDisease() async {
    final permissionStatus = await Permission.manageExternalStorage.request();
    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
      return;
    }

    final scans = selectedDisease == 'All'
        ? allScans
        : allScans.where((scan) => scan['diseaseDetected'] == selectedDisease).toList();

    for (var scan in scans) {
      try {
        final imageUrl = scan['imageUrl'];
        final disease = (scan['diseaseDetected'] ?? 'Unknown').replaceAll(' ', '_');

        final dirPath = '/storage/emulated/0/Download/$disease';
        final dir = Directory(dirPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final fileName = imageUrl.split('/').last.split('?').first;
          final filePath = '$dirPath/$fileName';

          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        } else {
          print('Failed to download image: $imageUrl');
        }
      } catch (e) {
        print('Image download error: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Images downloaded into disease-wise folders.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> diseases = [
      'All',
      ...{for (var scan in allScans) scan['diseaseDetected']?.toString() ?? 'Unknown'}
    ];

    return Scaffold(
      // appBar: AppBar(title: const Text('All Scanned Reports')),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'All Scanned Reports',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Filter by Disease: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedDisease,
                      items: diseases.map((disease) {
                        return DropdownMenuItem<String>(
                          value: disease,
                          child: Text(disease),
                        );
                      }).toList(),
                      onChanged: (val) => filterScans(val!),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'images') {
                          downloadImagesByDisease();
                        } else {
                          downloadExcel();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'excel', child: Text('Download as Excel')),
                        const PopupMenuItem(value: 'images', child: Text('Download Images')),
                      ],
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Image')),
                  DataColumn(label: Text('Disease')),
                ],
                rows: filteredScans.map((scan) {
                  return DataRow(cells: [
                    DataCell(
                      Image.network(
                        scan['imageUrl'] ?? '',
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    DataCell(Text(scan['diseaseDetected'] ?? 'Unknown')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}