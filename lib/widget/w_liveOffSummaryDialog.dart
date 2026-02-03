import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_liveOffSummary.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiveOffSummaryDialog extends StatefulWidget {
  final LiveOffSummaryModel summary;

  const LiveOffSummaryDialog({Key? key, required this.summary}) : super(key: key);

  @override
  State<LiveOffSummaryDialog> createState() => _LiveOffSummaryDialogState();
}

class _LiveOffSummaryDialogState extends State<LiveOffSummaryDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isSharing = false;
  int _cardType = 0; // 0: 기본 카드, 1: 슬로프 리스트 카드

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
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
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

      // GA 이벤트 로깅
      final userViewModel = Get.find<UserViewModel>();
      FirebaseAnalytics.instance.logEvent(name: 'tap_save_DailyRideCard', parameters: {
        'user_id': userViewModel.user.user_id,
        'user_name': userViewModel.user.display_name,
      });

      print('✅ 이미지 저장 완료');
      setState(() {
        _isSaved = true;
      });

      // 1초 후 버튼 상태 원래대로 복원 (카드 변경 후 재저장 가능하도록)
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
        }
      });
    } catch (e) {
      print('❌ 이미지 저장 오류: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // RepaintBoundary에서 이미지 캡처
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_summary_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      // 공유 시트 열기 (await 제거 - 공유창이 열리면 바로 상태 업데이트)
      Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '스노우라이브에서 ${widget.summary.displayName}님이 오늘의 라이딩 기록을 공유합니다!',
      );
    } catch (e) {
      print('이미지 공유 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  // 카드 타입 0: 오늘 총 라이딩 (기존 디자인)
  Widget _buildCardType0Content(LiveOffSummaryModel summary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 & 최다 슬로프 (2열)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 오늘 총 라이딩
            Expanded(
              child: Column(
                children: [
                  Text(
                    summary.totalSlopeCount == 0 ? '-' : '${summary.totalSlopeCount}',
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 30,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '오늘 총 라이딩',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 최다 슬로프
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        summary.mostRiddenSlope.isNotEmpty
                            ? summary.mostRiddenSlope
                            : '-',
                        style: SDSTextStyle.extraBold.copyWith(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      if (summary.mostRiddenCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${summary.mostRiddenCount}회',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '최다 슬로프',
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
        const SizedBox(height: 16),
        // 라이딩 거리 & 평균 경사도 & 최고 속도
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라이딩 거리
            Expanded(
              child: Column(
                children: [
                  summary.totalDistance == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              summary.totalDistance.toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'km',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '라이딩 거리',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 평균 경사도
            Expanded(
              child: Column(
                children: [
                  summary.avgSlope == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              summary.avgSlope.toStringAsFixed(1),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '°',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '평균 경사도',
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
                  summary.topSpeed == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              summary.topSpeed.toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'km/h',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
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
    );
  }

  // 텍스트 너비 계산
  double _getTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  // 2줄에 맞는 슬로프 개수 계산 (+N 포함 고려)
  int _getSlopeCountForTwoLines(List<MapEntry<String, int>> slopes, double maxWidth, TextStyle style, double spacing) {
    double currentLineWidth = 0;
    int lineCount = 1;
    int count = 0;

    for (int i = 0; i < slopes.length; i++) {
      final textWidth = _getTextWidth(slopes[i].key, style);

      if (currentLineWidth + textWidth > maxWidth) {
        lineCount++;
        if (lineCount > 2) {
          // 2줄 초과 시, "+N" 공간 확보를 위해 마지막 아이템 제거 필요할 수 있음
          final plusNWidth = _getTextWidth('+${slopes.length - count}', style);
          // 현재 줄에 +N이 들어갈 수 있는지 확인
          while (count > 0) {
            double lastLineWidth = 0;
            int tempLineCount = 1;
            for (int j = 0; j < count; j++) {
              final w = _getTextWidth(slopes[j].key, style);
              if (lastLineWidth + w > maxWidth) {
                tempLineCount++;
                lastLineWidth = w + spacing;
              } else {
                lastLineWidth += w + spacing;
              }
            }
            // +N이 현재 줄에 들어가는지 확인
            if (tempLineCount <= 2 && lastLineWidth + plusNWidth <= maxWidth) {
              break;
            }
            if (tempLineCount < 2) {
              break;
            }
            count--;
          }
          return count;
        }
        currentLineWidth = textWidth + spacing;
      } else {
        currentLineWidth += textWidth + spacing;
      }
      count++;
    }

    return slopes.length; // 모든 슬로프가 2줄에 들어감
  }

  // 카드 타입 1: 라이딩 슬로프 리스트
  Widget _buildCardType1Content(LiveOffSummaryModel summary) {
    final slopeEntries = summary.slopeCountsByName.entries.toList();
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;
    final restSlopes = slopeEntries.length > 1 ? slopeEntries.sublist(1) : <MapEntry<String, int>>[];

    // 사용 가능한 너비 (카드 너비 320 - 좌우 패딩 24*2)
    const double availableWidth = 320 - 48;
    const double spacing = 8;
    final textStyle = SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white);

    // 2줄에 맞는 슬로프 개수 계산
    final displayCount = _getSlopeCountForTwoLines(restSlopes, availableWidth, textStyle, spacing);
    final displaySlopes = restSlopes.take(displayCount).toList();
    final remainingCount = restSlopes.length - displayCount;

    return Column(
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
        const SizedBox(height: 24),
        // 첫 번째 슬로프 이름 (큰 글씨)
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 24,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        // 나머지 슬로프들 (작은 텍스트, 최대 2줄)
        if (displaySlopes.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing,
            runSpacing: 2,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: textStyle,
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        // 라이딩 슬로프 라벨
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Spacer(),
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
                        _cardType == 0
                            ? 'assets/imgs/imgs/img_summury_bg.png'
                            : 'assets/imgs/imgs/img_summury_bg_2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 상단: 프로필 이미지, 닉네임, 날짜
                    Positioned(
                      top: 40,
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
                          const SizedBox(height: 10),
                          // 닉네임
                          Text(
                            summary.displayName,
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          // 날짜
                          Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text(
                              summary.date,
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // 라이더 타이틀
                          if (summary.riderTitle.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: _cardType == 0
                                    ? const Color(0xFF1B3A5C)
                                    : const Color(0xFFE2EDF8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                summary.riderTitle,
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: _cardType == 0
                                      ? Colors.white
                                      : const Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 중앙: 라이딩 정보
                    Positioned(
                      top: 236,
                      bottom: 80,
                      left: 24,
                      right: 24,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: _cardType == 0
                              ? _buildCardType0Content(summary)
                              : _buildCardType1Content(summary),
                        ),
                      ),
                    ),
                    // 하단: 스노우라이브 로고
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

          // 닫기 버튼 + 카드 변경 버튼
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // X 버튼 (닫기)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
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
                        size: 26,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 카드 변경 버튼
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _cardType = _cardType == 0 ? 1 : 0;
                    });
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/imgs/icons/icon_summury_change.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          const Spacer(),

          
          // 공유 + 이미지 저장 버튼 (하단 고정)
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 공유 버튼
                GestureDetector(
                  onTap: _isSharing ? null : _shareImage,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/imgs/icons/icon_summury_share.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 이미지 저장 버튼
                GestureDetector(
                  onTap: (_isSaving || _isSaved) ? null : _saveImage,
                  child: Container(
                    width: 160,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isSaved ? const Color(0xFF34C759) : SDSColor.snowliveBlue,
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
                          : _isSaved
                              ? Icon(
                                  Icons.check,
                                  size: 28,
                                  color: Colors.white,
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
          ),
        ],
      ),
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
    barrierColor: Colors.black.withOpacity(0.85),
  );
}
