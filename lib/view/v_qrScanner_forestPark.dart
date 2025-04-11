import 'package:com.snowlive/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerForestPark extends StatefulWidget {
  @override
  State<QrScannerForestPark> createState() => _QrScannerForestParkState();
}

class _QrScannerForestParkState extends State<QrScannerForestPark> {
  bool hasScanned = false;

  void handleQrScan(String text) {
    if (hasScanned) return;

    hasScanned = true;
    print('스캔된 값: $text');

    // QR 값 무조건 arguments로 넘기면서 quizPage로 이동
    Get.offNamed(AppRoutes.quizPageForestPark, arguments: text);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          title: Text('QR코드 스캔'),
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          titleSpacing: 0,
        ),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isNotEmpty && !hasScanned) {
            final String? value = barcodes.first.rawValue;
            if (value != null) {
              handleQrScan(value);
            }
          }
        },
      ),
    );
  }
}
