import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';

/// "스노우라이브 랭킹 등급표" 안내 모달.
///
/// 등급 7종(배지 이미지 + 이름 + 상위 %)은 **모바일 앱과 같은 정적 이미지 한 장**을
/// 쓴다(`v_ranking_Home.dart`도 같은 에셋을 폭 300으로 그린다). 등급 목록은 서버가
/// 주는 값이 아니라 고정이고, 배지는 글로우까지 들어간 그림이라 코드로 다시 그리면
/// 앱과 미묘하게 달라진다.
///
/// PC·태블릿은 중앙 카드(390), **모바일은 하단 시트**다(목업 106:35695 —
/// 다른 웹 팝업과 같은 규칙: 드래그 핸들, 상단만 라운드, 좌우 여백 없음).
Future<void> showRankingTierGuide(BuildContext context) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<void>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _TierGuideCard(isSheet: isMobile, onClose: close),
  );
}

class _TierGuideCard extends StatefulWidget {
  final bool isSheet;
  final VoidCallback onClose;

  const _TierGuideCard({required this.isSheet, required this.onClose});

  @override
  State<_TierGuideCard> createState() => _TierGuideCardState();
}

class _TierGuideCardState extends State<_TierGuideCard> {
  /// 아래로 끌어내린 거리(시트 전용). 0 위로는 안 올라간다.
  double _dragDy = 0;

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() => _dragDy = (_dragDy + d.delta.dy).clamp(0.0, 10000.0));
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    // 충분히 내렸거나(100px) 아래로 튕기면(700px/s) 닫는다. 아니면 제자리로.
    if (_dragDy > 100 || v > 700) {
      widget.onClose();
    } else {
      setState(() => _dragDy = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);
    if (!widget.isSheet) return card; // 데스크탑 중앙 카드 — 드래그 없음.
    // 하단 시트: 끌어내린 만큼 따라 내려간다.
    return Transform.translate(offset: Offset(0, _dragDy), child: card);
  }

  Widget _buildCard(BuildContext context) {
    final isSheet = widget.isSheet;
    return Material(
      // 목업(106:20209) — 카드 390 / 라운드 16, 상하 40, 등급표 폭 300(좌우 45).
      color: SDSColor.snowliveWhite,
      borderRadius: isSheet
          ? const BorderRadius.vertical(top: Radius.circular(20))
          : BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: isSheet ? double.infinity : 390,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Stack의 기본 정렬이 좌상단이라 Column을 그냥 두면 가장 넓은 자식(300)
              // 만큼만 폭을 갖고 왼쪽에 붙는다 → 폭을 꽉 채운다.
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSheet)
                      // 시트는 닫기 X 대신 드래그 핸들 — 이 상단을 아래로 끌면 닫힌다.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                        child: Container(
                          // 핸들만이 아니라 상단 띠 전체를 잡기 쉽게 넉넉히 둔다.
                          width: double.infinity,
                          color: Colors.transparent,
                          padding: const EdgeInsets.only(top: SDSSpacing.md, bottom: SDSSpacing.lg),
                          alignment: Alignment.center,
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: SDSColor.gray200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 40),
                    Text(
                      '스노우라이브 랭킹 등급표',
                      textAlign: TextAlign.center,
                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                    ),
                    // 타이틀 ↔ 등급표 24 (앱과 동일).
                    const SizedBox(height: 24),
                    // 시트는 화면 폭에 맞춰 좌우 16을 두고 늘어난다(목업).
                    if (isSheet)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Image.asset(
                          'assets/imgs/imgs/img_ranking_tierlist.png',
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    else
                      Image.asset('assets/imgs/imgs/img_ranking_tierlist.png', width: 300),
                    SizedBox(height: isSheet ? 30 : 40),
                  ],
                ),
              ),
              // 닫기 X — 프로필 팝업과 같은 규격(26 · 50% · 우상단 16/16). 시트에는 없다.
              if (!isSheet)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Opacity(
                    opacity: 0.5,
                    child: InkWell(
                      onTap: widget.onClose,
                      customBorder: const CircleBorder(),
                      child: Icon(Icons.close, size: 26, color: SDSColor.gray900),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
