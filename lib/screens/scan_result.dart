import 'dart:io' show File; // used only on mobile / desktop
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_providers.dart';
import '../services/api_service.dart';
import '../screens/recommendation.dart';

class ScanResultPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> scanData;

  const ScanResultPage({
    super.key,
    required this.imagePath,
    required this.scanData,
  });

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  late final String _imagePath; // path works on every platform
  String? _predictedClass;
  String? _scanId;
  String? _error;
  bool _isForwarding = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
    _loadScanData();
  }

  void _loadScanData() {
    try {
      final scan = widget.scanData['scan'];
      setState(() {
        _predictedClass = scan['diseaseDetected'] as String? ?? 'Unknown';
        _scanId = scan['_id'] as String?;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load scan data: $e');
    }
  }

  Future<void> _forwardToAdmin() async {
    if (_scanId == null) return;

    final auth = context.read<AuthProvider>();
    setState(() => _isForwarding = true);

    try {
      final response = await ApiService().forwardScanToAdmin(
        scanId: _scanId!,
        token: auth.token,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Scan forwarded successfully'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Forward failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isForwarding = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF116736),
      title: const Text('Scan Result', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildImageCard(),
            const SizedBox(height: 20),
            _buildPredictionSection(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildForwardButton(),
          ],
        ),
      ),
    ),
    bottomNavigationBar: _buildBottomNav(),
  );

  /* ───────────── Image card ───────────── */
  Widget _buildImageCard() => Container(
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Stack(
      children: [
        SizedBox(
          width: 250,
          height: 300,
          child:
              kIsWeb
                  ? Image.network(_imagePath, fit: BoxFit.cover)
                  : Image.file(File(_imagePath), fit: BoxFit.cover),
        ),
        _greenBorder(),
      ],
    ),
  );

  Widget _greenBorder() {
    const c = Color(0xFF116736);
    const w = 4.0;
    Widget corner(bool l, bool t, bool r, bool b) => Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          left: l ? const BorderSide(color: c, width: w) : BorderSide.none,
          top: t ? const BorderSide(color: c, width: w) : BorderSide.none,
          right: r ? const BorderSide(color: c, width: w) : BorderSide.none,
          bottom: b ? const BorderSide(color: c, width: w) : BorderSide.none,
        ),
      ),
    );
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: corner(true, true, false, false)),
          Positioned(top: 0, right: 0, child: corner(false, true, true, false)),
          Positioned(
            bottom: 0,
            left: 0,
            child: corner(true, false, false, true),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: corner(false, false, true, true),
          ),
        ],
      ),
    );
  }

  /* ───────────── Prediction ───────────── */
  Widget _buildPredictionSection() {
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: Colors.red));
    }
    if (_predictedClass == null) {
      return const CircularProgressIndicator();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identification: $_predictedClass',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /* ───────────── Buttons ───────────── */
  Widget _buildActionButtons() => Center(
    child: ElevatedButton(
      onPressed:
          _predictedClass == null
              ? null
              : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecommendationPage(imagePath: _imagePath),
                ),
              ),
      style: _btnStyle(),
      child: const Text('View More'),
    ),
  );

  Widget _buildForwardButton() => Center(
    child: ElevatedButton.icon(
      onPressed: _isForwarding ? null : _forwardToAdmin,
      icon:
          _isForwarding
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.forward),
      label: Text(_isForwarding ? 'Forwarding...' : 'Share'),
      style: _btnStyle(),
    ),
  );

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF116736),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    textStyle: const TextStyle(fontSize: 16),
  );

  /* ───────────── Bottom nav ───────────── */
  Widget _buildBottomNav() => BottomNavigationBar(
    currentIndex: 2,
    selectedItemColor: const Color(0xFF116736),
    unselectedItemColor: Colors.grey,
    onTap: (i) {
      switch (i) {
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
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
      BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
      BottomNavigationBarItem(
        icon: Icon(Icons.support_agent),
        label: 'Support',
      ),
    ],
  );
}
