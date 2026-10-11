import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét mã QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi Camera: ${error.errorCode}\n${error.errorDetails?.message ?? ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
            placeholderBuilder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    _isScanned = true;
                  });
                  // Trả về mã QR
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          // Khung quét
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(top: true, left: true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCorner(top: true, left: false),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCorner(top: false, left: true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCorner(top: false, left: false),
                  ),
                ],
              ),
            ),
          ),
          // Hướng dẫn
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Text(
              'Đưa mã QR vào khung hình để quét',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.blueAccent, width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Colors.blueAccent, width: 4) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.blueAccent, width: 4) : BorderSide.none,
          right: !left ? const BorderSide(color: Colors.blueAccent, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
