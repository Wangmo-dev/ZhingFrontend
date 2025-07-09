// lib/screens/super_admin_page.dart
import 'dart:convert';
import 'dart:io' show Directory, File; // mobile / desktop only
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html; // web

class SuperAdminPage extends StatefulWidget {
  const SuperAdminPage({super.key});

  @override
  State<SuperAdminPage> createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  /* ------------------------------------------------------------------ */
  final Dio _dio = Dio();

  List<dynamic> allScans = [];
  List<dynamic> filteredScans = [];
  String selectedDisease = 'All';
  /* ------------------------------------------------------------------ */

  @override
  void initState() {
    super.initState();
    fetchScans();
  }

  /* ─────────────── Fetch scans from backend ─────────────── */
  Future<void> fetchScans() async {
    try {
      final res = await http.get(
        Uri.parse('https://zhingscanserver.onrender.com/api/scans'),
      );

      if (res.statusCode == 200) {
        setState(() {
          allScans = jsonDecode(res.body);
          filteredScans = allScans;
        });
      } else {
        throw Exception('Failed to load scans');
      }
    } catch (e) {
      debugPrint('Error fetching scans: $e');
    }
  }

  /* ─────────────── Filter dropdown ─────────────── */
  void filterScans(String disease) {
    setState(() {
      selectedDisease = disease;
      filteredScans =
          (disease == 'All')
              ? allScans
              : allScans
                  .where((scan) => scan['diseaseDetected'] == disease)
                  .toList();
    });
  }

  /* ─────────────── Download Excel ─────────────── */
  Future<void> downloadExcel() async {
    final url =
        (selectedDisease == 'All')
            ? 'https://zhingscanserver.onrender.com/api/scans/export'
            : 'https://zhingscanserver.onrender.com/api/scans/export?disease=$selectedDisease';

    final fileName =
        'scans_${selectedDisease.replaceAll(" ", "_")}.xlsx'.toLowerCase();

    if (kIsWeb) {
      // launch in new tab; browser handles save‑dialog
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start download')),
        );
      }
      return;
    }

    // Android / desktop
    if (!await Permission.manageExternalStorage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    final dirPath = '/storage/emulated/0/Download';
    final filePath = '$dirPath/$fileName';

    try {
      final res = await _dio.download(url, filePath);
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Excel saved to $filePath')));
        }
        await OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excel download error: $e')));
    }
  }

  /* ─────────────── Download ZIP (images bundled) ─────────────── */
  Future<void> downloadZipByDisease() async {
    final base = 'https://zhingscanserver.onrender.com/api/scans/export-zip';
    final url =
        (selectedDisease == 'All') ? base : '$base?disease=$selectedDisease';

    final zipName = '${selectedDisease}_images.zip'.replaceAll(' ', '_');

    if (kIsWeb) {
      // trigger browser download via hidden <a>
      final anchor =
          html.AnchorElement(href: url)
            ..download = zipName
            ..target = '_blank'
            ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Downloading $zipName …')));
      return;
    }

    // Android / desktop
    if (!await Permission.manageExternalStorage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    final dirPath = '/storage/emulated/0/Download';
    final filePath = '$dirPath/$zipName';

    try {
      final res = await _dio.download(url, filePath);
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ZIP saved to $filePath')));
        }
        await OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ZIP download error: $e')));
    }
  }

  /* ─────────────── Download images one‑by‑one ─────────────── */
  Future<void> downloadImagesByDisease() async {
    final scans =
        (selectedDisease == 'All')
            ? allScans
            : allScans
                .where((s) => s['diseaseDetected'] == selectedDisease)
                .toList();

    if (kIsWeb) {
      for (final scan in scans) {
        final url = scan['imageUrl'] ?? '';
        if (url.isEmpty) continue;

        final fileName =
            '${scan['diseaseDetected'].toString().replaceAll(" ", "_")}-'
            '${url.split('/').last.split('?').first}';

        final a =
            html.AnchorElement(href: url)
              ..download = fileName
              ..target = '_blank'
              ..style.display = 'none';
        html.document.body?.append(a);
        a.click();
        a.remove();

        await Future.delayed(const Duration(milliseconds: 150));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Browser is downloading images…')),
      );
      return;
    }

    // Android / desktop
    if (!await Permission.manageExternalStorage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    for (final scan in scans) {
      final imageUrl = scan['imageUrl'];
      final disease = (scan['diseaseDetected'] ?? 'Unknown')
          .toString()
          .replaceAll(' ', '_');

      final dirPath = '/storage/emulated/0/Download/$disease';
      final dir = Directory(dirPath);
      if (!await dir.exists()) await dir.create(recursive: true);

      try {
        final res = await http.get(Uri.parse(imageUrl));
        if (res.statusCode == 200) {
          final fileName = imageUrl.split('/').last.split('?').first;
          final file = File('$dirPath/$fileName');
          await file.writeAsBytes(res.bodyBytes);
        }
      } catch (e) {
        debugPrint('Image download error: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Images saved in Download folder.')),
    );
  }

  /* ─────────────── UI ─────────────── */
  @override
  Widget build(BuildContext context) {
    final diseases = [
      'All',
      ...{
        for (var s in allScans) s['diseaseDetected']?.toString() ?? 'Unknown',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'All Scanned Reports',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF116736),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
      body: Column(
        children: [
          /* ── Controls ── */
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Filter by Disease:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedDisease,
                      items:
                          diseases
                              .map(
                                (d) =>
                                    DropdownMenuItem(value: d, child: Text(d)),
                              )
                              .toList(),
                      onChanged: (d) => filterScans(d!),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        switch (val) {
                          case 'excel':
                            downloadExcel();
                            break;
                          case 'images':
                            downloadImagesByDisease();
                            break;
                          case 'zip':
                            downloadZipByDisease();
                            break;
                        }
                      },
                      itemBuilder:
                          (_) => const [
                            PopupMenuItem(
                              value: 'excel',
                              child: Text('Download Excel'),
                            ),
                            PopupMenuItem(
                              value: 'images',
                              child: Text('Download Images'),
                            ),
                            PopupMenuItem(
                              value: 'zip',
                              child: Text('Download ZIP'),
                            ),
                          ],
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /* ── DataTable ── */
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Image')),
                  DataColumn(label: Text('Disease')),
                ],
                rows:
                    filteredScans
                        .map(
                          (scan) => DataRow(
                            cells: [
                              DataCell(
                                Image.network(
                                  scan['imageUrl'] ?? '',
                                  width: 100,
                                  height: 100,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                ),
                              ),
                              DataCell(
                                Text(scan['diseaseDetected'] ?? 'Unknown'),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
