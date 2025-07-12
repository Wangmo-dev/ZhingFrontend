import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_providers.dart';
import '../screens/scan_result.dart';
import '../services/api_service.dart';

class XFileImage extends StatelessWidget {
  final XFile xFile;
  final BoxFit fit;
  const XFileImage(this.xFile, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Image.network(xFile.path, fit: fit)
        : Image.file(File(xFile.path), fit: fit);
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0;
  bool _isInitialized = false;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isEmpty) return;

    _controller = CameraController(
      _cameras![_selectedCameraIdx],
      ResolutionPreset.high,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  void _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() => _isInitialized = false); // Reset UI
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras!.length;

    await _controller?.dispose();
    _controller = CameraController(
      _cameras![_selectedCameraIdx],
      ResolutionPreset.high,
    );
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Camera init error: $e');
    }
  }

  Future<void> _captureImage() async {
    try {
      if (!(_controller?.value.isInitialized ?? false) ||
          _controller!.value.isTakingPicture) {
        return;
      }

      final shot = await _controller!.takePicture();
      await _reviewAndUpload(shot);
    } catch (e) {
      print('Capture failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to capture image: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) await _reviewAndUpload(picked);
  }

  Future<void> _reviewAndUpload(XFile xFile) async {
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ImageReviewScreen(xFile: xFile)),
    );
    if (confirmed != true) return;

    final auth = context.read<AuthProvider>();

    if (auth.token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to upload')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prediction = await _apiService.predictDisease(xFile);
      final disease = prediction['predicted_class'] ?? 'Unknown';

      final scanData = await _apiService.uploadScan(
        image: xFile,
        disease: disease,
        token: auth.token,
      );

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ScanResultPage(imagePath: xFile.path, scanData: scanData),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isInitialized
              ? Stack(
                children: [
                  Positioned.fill(child: CameraPreview(_controller!)),
                  Positioned.fill(
                    child: CustomPaint(painter: ScanBorderPainter()),
                  ),
                  _buildBottomControls(),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomControls() => Positioned(
    bottom: 30,
    left: 0,
    right: 0,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 30,
          child: FloatingActionButton(
            heroTag: 'gallery',
            backgroundColor: Colors.white,
            onPressed: _pickFromGallery,
            child: const Icon(Icons.photo, color: Colors.black),
          ),
        ),
        Positioned(
          right: 30,
          child: FloatingActionButton(
            heroTag: 'flip',
            backgroundColor: Colors.white,
            onPressed: _flipCamera,
            child: const Icon(Icons.cameraswitch, color: Colors.black),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, size: 36, color: Colors.black),
            onPressed: _captureImage,
          ),
        ),
      ],
    ),
  );

  Widget _buildBottomNav(BuildContext context) => BottomNavigationBar(
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

class ImageReviewScreen extends StatelessWidget {
  final XFile xFile;
  const ImageReviewScreen({super.key, required this.xFile});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(child: XFileImage(xFile, fit: BoxFit.contain)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roundBtn(
                  Icons.close,
                  Colors.red,
                  () => Navigator.pop(context, false),
                ),
                const SizedBox(width: 30),
                _roundBtn(
                  Icons.check,
                  const Color(0xFF116736),
                  () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _roundBtn(IconData icon, Color color, VoidCallback onTap) => Container(
    width: 60,
    height: 60,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: IconButton(
      icon: Icon(icon, color: color, size: 32),
      onPressed: onTap,
    ),
  );
}

class ScanBorderPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    const cLen = 30.0;
    final paint =
        Paint()
          ..color = const Color(0xFF116736)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final w = s.width * 0.8, h = s.height * 0.6;
    final l = (s.width - w) / 2, t = (s.height - h) / 2;
    final r = l + w, b = t + h;

    c
      ..drawLine(Offset(l, t), Offset(l + cLen, t), paint)
      ..drawLine(Offset(l, t), Offset(l, t + cLen), paint)
      ..drawLine(Offset(r - cLen, t), Offset(r, t), paint)
      ..drawLine(Offset(r, t), Offset(r, t + cLen), paint)
      ..drawLine(Offset(l, b - cLen), Offset(l, b), paint)
      ..drawLine(Offset(l, b), Offset(l + cLen, b), paint)
      ..drawLine(Offset(r - cLen, b), Offset(r, b), paint)
      ..drawLine(Offset(r, b), Offset(r, b - cLen), paint);

    final dim = Paint()..color = Colors.black.withOpacity(0.5);
    c
      ..drawRect(Rect.fromLTRB(0, 0, s.width, t), dim)
      ..drawRect(Rect.fromLTRB(0, b, s.width, s.height), dim)
      ..drawRect(Rect.fromLTRB(0, t, l, b), dim)
      ..drawRect(Rect.fromLTRB(r, t, s.width, b), dim);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
