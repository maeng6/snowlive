import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';

/// 플로팅 바의 흰색 배경 구간 높이(버튼 줄 영역). 스크롤 콘텐츠 하단 패딩은
/// 이 값 + 여백으로 확보한다(페이드 구간은 콘텐츠가 비쳐야 하므로 제외).
const double kWebFloatingBottomBarHeight = 64;

/// 태블릿/모바일 하단 고정 플로팅 바 공통 골격 — 투명→흰색 페이드(60px) 위에
/// 버튼 줄이 떠 있는 구성(중고거래 목록 하단바에서 확정). 쓰는 쪽은
/// Stack + Positioned(left/right/bottom: 0)에 두고, 스크롤 콘텐츠가 바 뒤로
/// 지나가도록 페이지 패딩을 스크롤뷰 안쪽에 둔다.
class WebFloatingBottomBar extends StatelessWidget {
  final Widget child;

  const WebFloatingBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 블러 없이 투명→흰색 그라데이션 배경 위에 버튼이 떠 있는 구성.
    // 페이드 60px + 버튼 뒤 흰색 64px. 농도를 직선이 아니라 ease 곡선으로
    // 올려야(정지점 여러 개로 근사) 콘텐츠가 서서히 녹아 사라진다.
    //
    // ⚠️ 그라데이션 배경은 반드시 IgnorePointer로 클릭을 통과시킨다 — 데코레이션이
    // 있는 Container는 반투명이어도 영역 전체의 히트를 가로채서, 이 바가 덮는
    // 124px 안에 걸친 콘텐츠(페이지네이션 등)가 클릭되지 않았다(실측).
    // 클릭은 아래 버튼 줄만 받는다.
    return SizedBox(
      height: kWebFloatingBottomBarHeight + 60,
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
                      SDSSpacing.md,
                      0,
                      SDSSpacing.md,
                      SDSSpacing.sm,
                    ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// 플로팅 바 버튼 — 보더·그림자 없는 플랫 pill(높이 48, 라운드 6, bold 15).
/// hover 시 배경에 검정 10%를 섞어 어둡게(사이드바 버튼과 동일 규칙).
/// [onTap]이 null이면 비활성(gray200 배경). [leading]은 제출 스피너 등
/// 라벨 앞에 끼워 넣는 위젯 — 라벨을 교체하지 않아 버튼 폭이 튀지 않는다.
class WebBottomBarButton extends StatefulWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final Widget? leading;

  const WebBottomBarButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.leading,
  });

  @override
  State<WebBottomBarButton> createState() => _WebBottomBarButtonState();
}

class _WebBottomBarButtonState extends State<WebBottomBarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    final Color background = !enabled
        ? SDSColor.gray200
        : _hovered
        ? Color.alphaBlend(
            Colors.black.withValues(alpha: 0.1),
            widget.background,
          )
        : widget.background;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: SDSSpacing.sm),
              ],
              Flexible(
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
            ],
          ),
        ),
      ),
    );
  }
}
