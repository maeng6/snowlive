import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_liveOffSummary.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;

class LiveOffSummaryDialog extends StatefulWidget {
  final LiveOffSummaryModel summary;

  const LiveOffSummaryDialog({Key? key, required this.summary}) : super(key: key);

  @override
  State<LiveOffSummaryDialog> createState() => _LiveOffSummaryDialogState();
}

class _LiveOffSummaryDialogState extends State<LiveOffSummaryDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Gal 패키지 자체 권한 체크 및 요청
      bool hasAccess = await Gal.hasAccess(toAlbum: true);

      if (!hasAccess) {
        // 권한 요청
        hasAccess = await Gal.requestAccess(toAlbum: true);

        if (!hasAccess) {
          // 권한 거부됨 → 설정 안내 다이얼로그 표시
          print('📸 사진 권한 거부됨 → 설정 안내');
          _showPermissionSettingsDialog();
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      // RepaintBoundary에서 이미지 캡처
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        setState(() {
          _isSaving = false;
        });
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 임시 파일로 저장 후 갤러리에 추가
      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_summary_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      // gal 패키지로 갤러리에 저장
      await Gal.putImage(tempFile.path, album: 'Snowlive');

      // 임시 파일 삭제
      await tempFile.delete();

      Get.snackbar(
        '저장 완료',
        '이미지가 갤러리에 저장되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: SDSColor.gray900,
      );
    } catch (e) {
      print('이미지 저장 오류: $e');
      Get.snackbar('오류', '이미지 저장 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캡처 영역
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: SizedBox(
              width: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 960 / 1524, // 배경 이미지 비율
                child: Stack(
                  children: [
                    // 배경 이미지
                    Positioned.fill(
                      child: Image.asset(
                        'assets/imgs/imgs/img_summury_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 상단: 프로필 이미지, 닉네임, 날짜 (상단 기준 70px)
                    Positioned(
                      top: 60,
                      left: 32,
                      right: 32,
                      child: Column(
                        children: [
                          // 프로필 이미지
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: summary.profileImageUrlUser.isNotEmpty
                                  ? ExtendedImage.network(
                                      summary.profileImageUrlUser,
                                      fit: BoxFit.cover,
                                      cache: true,
                                      loadStateChanged: (state) {
                                        if (state.extendedImageLoadState == LoadState.failed) {
                                          return Image.asset(
                                            'assets/imgs/profile/img_profile_default_circle.png',
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return null;
                                      },
                                    )
                                  : Image.asset(
                                      'assets/imgs/profile/img_profile_default_circle.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 닉네임
                          Text(
                            summary.displayName,
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),

                          // 날짜
                          Text(
                            summary.date,
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 중앙: 라이딩 정보 (상단/하단 영역 사이 중앙 배치)
                    Positioned(
                      top: 220, // 상단 영역 아래
                      bottom: 80, // 하단 영역 위
                      left: 32,
                      right: 32,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 오늘 총 라이딩 숫자
                              Text(
                                '${summary.totalSlopeCount}',
                                style: SDSTextStyle.extraBold.copyWith(
                                  fontSize: 40,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 오늘 총 라이딩 라벨
                              Text(
                                '오늘 총 라이딩',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 총 이동거리 & 최고 속도
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 총 이동거리
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              _formatDistanceValue(summary.totalDistance),
                                              style: SDSTextStyle.extraBold.copyWith(
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              _formatDistanceUnit(summary.totalDistance),
                                              style: SDSTextStyle.extraBold.copyWith(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '총 이동거리',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 최고 속도
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              summary.topSpeed.toStringAsFixed(1),
                                              style: SDSTextStyle.extraBold.copyWith(
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              'km/h',
                                              style: SDSTextStyle.extraBold.copyWith(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '최고 속도',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 하단: 스노우라이브 로고 (하단 기준 40px)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/imgs/logos/snowliveLogo_main_white.png',
                          height: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 버튼 영역 (캡처 영역 밖)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // X 버튼 (닫기)
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: SDSColor.gray900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 이미지 저장 버튼
              GestureDetector(
                onTap: _isSaving ? null : _saveImage,
                child: Container(
                  width: 180,
                  height: 56,
                  decoration: BoxDecoration(
                    color: SDSColor.snowliveBlue,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            '이미지 저장',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      return '${meters.toInt()} m';
    }
  }

  String _formatDistanceValue(double meters) {
    return _formatNumberWithComma(meters.toInt());
  }

  String _formatDistanceUnit(double meters) {
    return 'm';
  }

  String _formatNumberWithComma(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 권한 설정 안내 다이얼로그
  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: const EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '사진 접근 권한 필요',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '이미지를 저장하려면 사진 접근 권한이\n필요합니다. 설정에서 권한을 허용해주세요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.gray200,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings();  // 앱 설정으로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '설정으로 이동',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}

/// 라이브오프 요약 다이얼로그 표시
Future<void> showLiveOffSummaryDialog(LiveOffSummaryModel summary) async {
  await Get.dialog(
    LiveOffSummaryDialog(summary: summary),
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.8),
  );
}
