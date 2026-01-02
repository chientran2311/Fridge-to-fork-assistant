import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // DISABLED - not needed for now

class FridgeBarcodeScanScreen extends StatefulWidget {
  const FridgeBarcodeScanScreen({super.key});

  @override
  State<FridgeBarcodeScanScreen> createState() =>
      _FridgeBarcodeScanScreenState();
}

class _FridgeBarcodeScanScreenState extends State<FridgeBarcodeScanScreen> {
  // bool flashOn = false;
  // bool isScanned = false;

  // final MobileScannerController cameraController = MobileScannerController(
  //   facing: CameraFacing.back,
  //   torchEnabled: false,
  // );

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// TEMPORARY DISABLED - Camera Preview + Barcode Detection
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 80, color: Colors.white54),
                  SizedBox(height: 20),
                  Text(
                    'Barcode Scanner\nTemporarily Disabled',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
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
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),     
                  ),
                  child: const Icon(Icons.arrow_back, color: mainColor),
                ),
              ),
            ),

            /* DISABLED - Flash button
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
                      color: flashOn ? mainColor : Color(0xFFFFFFFF),
                      border: Border.all(
                        color: flashOn ? Colors.white : Colors.white,
                        width: 4,
                      ),
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
            */

            /* DISABLED - Scan frame UI
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
            */
          ],
        ),
      ),
    );
  }
}