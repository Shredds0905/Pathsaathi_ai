import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/premium_button.dart';
import '../../ai_chat/providers/ai_provider.dart' as ai_provider;
import '../widgets/scanning_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        _simulateScanning();
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _simulateScanning() async {
    // Simulate finding a document and increasing confidence
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _confidence = 0.4);
    
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _confidence = 0.85);
  }

  void _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);
    
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isProcessing = false);
        // Pre-fill the AI chat with the "scanned" text
        context.read<ai_provider.AIProvider>().sendMessage(
          'I just scanned this text: "The powerhouse of the cell is the Mitochondria." Can you explain this concept in detail?'
        );
        // Navigate to AI Chat
        context.go('/ai_chat');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_isInitialized && _controller != null)
            CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // Scanning Overlay
          if (!_isProcessing)
            ScanningOverlay(
              isScanning: _isInitialized,
              confidence: _confidence,
            ),

          // Processing Overlay
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Analyzing Document...',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Extracting text and generating interactive content',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.flash_off, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls
          if (!_isProcessing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: PremiumButton(
                    text: 'Scan & Learn',
                    icon: Icons.camera_alt,
                    onPressed: _captureAndProcess,
                  ).animate().slideY(begin: 1, end: 0, duration: 400.ms),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
