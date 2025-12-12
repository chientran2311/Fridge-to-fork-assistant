import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FridgeBarcodeScanScreen extends StatefulWidget {
  const FridgeBarcodeScanScreen({super.key});

  @override
  State<FridgeBarcodeScanScreen> createState() =>
      _FridgeBarcodeScanScreenState();
}

class _FridgeBarcodeScanScreenState extends State<FridgeBarcodeScanScreen> {
  bool flashOn = false;
  bool isScanned = false;

  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// CAMERA PREVIEW + BARCODE DETECTION
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (isScanned) return;
                isScanned = true;

                final barcode = capture.barcodes.first.rawValue;

                if (barcode != null) {
                  debugPrint("BARCODE FOUND = $barcode");

                  /// Sau khi scan OK → chuyển sang màn hình khác
                  Navigator.pop(context, barcode);
                }
              },
            ),

            /// TOP LEFT BACK BUTTON
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color(0xFFE7EAE9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: mainColor),
                ),
              ),
            ),

            /// FLASH BUTTON
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    flashOn = !flashOn;
                    cameraController.toggleTorch();
                    setState(() {});
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      color: flashOn ? mainColor : Color(0xFFE7EAE9),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.3),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.flash_on,
                      size: 28,
                      color: flashOn ? Colors.white : mainColor,

                    ),
                  ),
                ),
              ),
            ),

            /// SCAN FRAME UI
            Center(
              child: Container(
                height: 260,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
