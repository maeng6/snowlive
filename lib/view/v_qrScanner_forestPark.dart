import 'package:com.snowlive/data/snowliveDesignStyle.dart';
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

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          title: Text('QR코드 스캔',
            style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.snowliveWhite,
                fontSize: 18
            ),
          ),
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              color: SDSColor.snowliveWhite,
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xFF12341E),
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
        overlayBuilder: (context, constraints) {
          return Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Container(
                      width: _size.width,
                      height: _size.height,
                      child: Image.asset(
                        'assets/imgs/imgs/img_forest_qr_scan.png',
                        scale: 3,
                        width: _size.width - 80,
                        height: _size.width - 80,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 72),
                      child: Container(
                        width: _size.width - 80,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: SDSColor.snowliveBlack.withOpacity(0.7)
                        ),
                        child: Center(
                          child: Text('퀴즈 QR 코드를 스캔해 주세요.',
                          style: SDSTextStyle.regular.copyWith(
                            color: SDSColor.snowliveWhite
                          ),),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
