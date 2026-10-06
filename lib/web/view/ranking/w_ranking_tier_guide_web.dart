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

class _TierGuideCard extends StatelessWidget {
  final bool isSheet;
  final VoidCallback onClose;

  const _TierGuideCard({required this.isSheet, required this.onClose});

  @override
  Widget build(BuildContext context) {
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
                      // 시트는 닫기 X 대신 드래그 핸들(다른 웹 시트와 동일).
                      Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(top: SDSSpacing.md, bottom: SDSSpacing.lg),
                        decoration: BoxDecoration(
                          color: SDSColor.gray200,
                          borderRadius: BorderRadius.circular(2),
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
                      onTap: onClose,
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
