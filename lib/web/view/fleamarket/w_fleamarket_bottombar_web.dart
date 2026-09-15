import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kFleamarketBottomBarHeight = 64;

/// 태블릿/모바일 전용 하단 고정 2버튼 바.
class FleamarketBottomBarWeb extends StatelessWidget {
  const FleamarketBottomBarWeb({super.key});

  @override
  Widget build(BuildContext context) {
    // 블러 없이 투명→흰색 그라데이션 배경 위에 pill 버튼 두 개가 떠 있는 구성.
    // 위쪽 페이드 구간에서 콘텐츠가 자연스럽게 사라지고, 버튼 뒤는 흰색이 깔린다.
    // 페이드 60px + 버튼 뒤 흰색 64px. 농도를 직선이 아니라 ease 곡선으로
    // 올려야(정지점 여러 개로 근사) 목업처럼 콘텐츠가 서서히 녹아 사라진다.
    //
    // ⚠️ 그라데이션 배경은 반드시 IgnorePointer로 클릭을 통과시킨다 — 데코레이션이
    // 있는 Container는 반투명이어도 영역 전체의 히트를 가로채서, 이 바가 덮는
    // 124px 안에 걸친 콘텐츠(페이지네이션 등)가 클릭되지 않았다(실측).
    // 클릭은 아래 버튼 줄만 받는다.
    return SizedBox(
      height: kFleamarketBottomBarHeight + 60,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SDSColor.snowliveWhite.withValues(alpha: 0),
                      SDSColor.snowliveWhite.withValues(alpha: 0.15),
                      SDSColor.snowliveWhite.withValues(alpha: 0.45),
                      SDSColor.snowliveWhite.withValues(alpha: 0.8),
                      SDSColor.snowliveWhite,
                      SDSColor.snowliveWhite,
                    ],
                    // 흰색 100% 지점을 버튼 상단(68px)보다 12px 아래(80px)로 내린다 —
                    // 80~90% 알파도 이미 흰색처럼 보여서, 수학적으로 버튼 상단에 맞추면
                    // 체감상 그보다 위에서 끝나 보였다(실측). 버튼이 불투명해서
                    // 페이드가 버튼 뒤로 이어져도 보이지 않는다.
                    stops: const [
                      0,
                      80 / 124 * 0.33,
                      80 / 124 * 0.61,
                      80 / 124 * 0.82,
                      80 / 124,
                      1,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              // 모바일: 좌우 10/하단 10 (피그마 32:19273). 태블릿: 기존 16/8 유지.
              padding: context.screenType == WebScreenType.mobile
                  ? const EdgeInsets.fromLTRB(10, 0, 10, 10)
                  : const EdgeInsets.fromLTRB(
                      SDSSpacing.md, 0, SDSSpacing.md, SDSSpacing.sm),
              child: _buildButtons(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        // 데스크탑은 사이드바에 이 버튼이 있다. 좁은 폭에서는 사이드바가 없으므로
        // 여기가 유일한 진입점이다.
        // 공통 색 규칙: 보조(키워드 알림)는 연회색 채움, 주(물품 올리기)는
        // PC 사이드바와 같은 브랜드 블루. PC/태블릿/모바일 동일.
        Expanded(
          child: _PillButton(
            label: '키워드 알림 설정',
            background: SDSColor.gray100,
            foreground: SDSColor.gray900,
            onTap: () => Get.toNamed(WebRoutes.fleamarketAlert),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Expanded(
          child: _PillButton(
            label: '중고거래 물품 올리기',
            background: SDSColor.snowliveBlue,
            foreground: SDSColor.snowliveWhite,
            onTap: () => Get.toNamed(WebRoutes.fleamarketUpload),
          ),
        ),
      ],
    );
  }
}

/// 하단바 버튼. 목업(월렛식)처럼 보더·그림자 없이 플랫하고, 라운드는 기존과 같은 5.
class _PillButton extends StatefulWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // hover 시 배경에 검정 10%를 섞어 어둡게(사이드바 버튼과 동일 규칙).
            color: _hovered
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.1), widget.background)
                : widget.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 15,
              color: widget.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
