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

    // 슬로프별 카운트 정렬 (내림차순)
    final sortedSlopes = summary.slopeCountsByName.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 최대 카운트 (막대 그래프 비율 계산용)
    final maxCount = sortedSlopes.isNotEmpty
        ? sortedSlopes.first.value
        : 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캡처 영역
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Container(
              decoration: BoxDecoration(
                color: SDSColor.snowliveWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 날짜 & 요일
                  Text(
                    '${summary.date} ${summary.weekday}',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 14,
                      color: SDSColor.gray500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 프로필 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SDSColor.gray100, width: 2),
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
                      fontSize: 18,
                      color: SDSColor.gray900,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 오늘 총 라이딩 횟수
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '오늘 총 라이딩',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 14,
                            color: SDSColor.gray600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${summary.totalSlopeCount}회',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 32,
                            color: SDSColor.snowliveBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 슬로프별 라이딩 횟수
                  if (sortedSlopes.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '슬로프별 라이딩',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 14,
                          color: SDSColor.gray900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...sortedSlopes.take(5).map((entry) {
                      final ratio = entry.value / maxCount;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                entry.key,
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.gray700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: SDSColor.gray100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: ratio,
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: SDSColor.snowliveBlue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${entry.value}회',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.gray900,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],

                  // 총 이동 거리 & 최고 속도
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: SDSColor.gray50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '총 이동 거리',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: SDSColor.gray500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _formatDistance(summary.totalDistance),
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 18,
                                    color: SDSColor.gray900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: SDSColor.gray50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '최고 속도',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: SDSColor.gray500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${summary.topSpeed.toStringAsFixed(1)} km/h',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 18,
                                    color: SDSColor.gray900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 스노우라이브 로고
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/imgs/logos/snowliveLogo_main_new_blue.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SNOWLIVE',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 12,
                          color: SDSColor.gray400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 버튼 영역 (캡처 영역 밖)
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
                    '닫기',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 16,
                      color: SDSColor.gray600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.snowliveBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              SDSColor.snowliveWhite,
                            ),
                          ),
                        )
                      : Text(
                          '이미지 저장',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 16,
                            color: SDSColor.snowliveWhite,
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
  );
}
