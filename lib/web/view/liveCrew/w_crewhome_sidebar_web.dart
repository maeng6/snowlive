import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루홈 우측 열 — `크루톡 올리기` + `시즌 기록실` / `일별 현황`.
///
/// [onUploadTalk]이 null이면 업로드 버튼을 그리지 않는다(내 크루가 아닐 때).
class CrewHomeSidebarWeb extends StatelessWidget {
  final VoidCallback? onUploadTalk;
  final int? crewId;

  const CrewHomeSidebarWeb({super.key, required this.onUploadTalk, required this.crewId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kWebSidebarWidth,
      // 헤더가 블록 전체 폭을 쓰고 사이드바는 그 아래(통계 바와 같은 줄)에서
      // 시작하므로 위쪽 오프셋이 필요 없다.
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onUploadTalk != null) ...[
            CrewTalkUploadButton(onTap: onUploadTalk!),
            // 버튼 ↔ 링크 카드 30 (목업 — 버튼 끝 254, 카드 284).
            const SizedBox(height: 30),
          ],
          CrewRecordLinkCards(crewId: crewId),
        ],
      ),
    );
  }
}

/// `시즌 기록실` / `일별 현황` 두 링크의 **좁은 폭 버전** — 우측 열이 접히는
/// 태블릿·모바일에서는 카드가 아니라 크루명 바로 아래 **텍스트 링크 줄**이 된다
/// (목업 161:94380). 간격 19 · 세로 구분선 1×14 · Bold 14.
class CrewRecordLinkRow extends StatelessWidget {
  final int? crewId;

  const CrewRecordLinkRow({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CrewLinkText(
          label: '시즌 기록실',
          onTap: () => Get.toNamed('${WebRoutes.crewRecordRoom}?id=$crewId'),
        ),
        const SizedBox(width: 19),
        Container(width: 1, height: 14, color: SDSColor.gray200),
        const SizedBox(width: 19),
        _CrewLinkText(
          label: '일별 현황',
          onTap: () => Get.toNamed('${WebRoutes.crewDailyRecord}?id=$crewId'),
        ),
      ],
    );
  }
}

/// 텍스트 링크 한 칸. hover 규칙은 통계 바의 `멤버(명)`과 같다 — **밑줄만** 생긴다.
class _CrewLinkText extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _CrewLinkText({required this.label, required this.onTap});

  @override
  State<_CrewLinkText> createState() => _CrewLinkTextState();
}

class _CrewLinkTextState extends State<_CrewLinkText> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        // 줄 높이 39 = 글줄 17 + 상하 11 (목업).
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Text(
            widget.label,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 14,
              height: 17 / 14,
              color: SDSColor.gray900,
              decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

/// `시즌 기록실` / `일별 현황` 두 링크의 **데스크탑 카드 버전**(우측 열).
class CrewRecordLinkCards extends StatelessWidget {
  final int? crewId;

  const CrewRecordLinkCards({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CrewLinkCard(
          label: '시즌 기록실',
          onTap: () => Get.toNamed('${WebRoutes.crewRecordRoom}?id=$crewId'),
        ),
        // 카드 사이 8 (목업 — 카드 52, 다음 카드 60).
        const SizedBox(height: 8),
        _CrewLinkCard(
          label: '일별 현황',
          onTap: () => Get.toNamed('${WebRoutes.crewDailyRecord}?id=$crewId'),
        ),
      ],
    );
  }
}

/// 파란 `크루톡 올리기` 버튼. PC는 우측 열, 좁은 폭에서는 하단 플로팅 바에 들어간다.
class CrewTalkUploadButton extends StatelessWidget {
  final VoidCallback onTap;

  const CrewTalkUploadButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 높이는 공용 webActionButtonHeight(PC 44 / 그 외 48).
    final double height = webActionButtonHeight(context);
    // 글자는 PC 사이드바 공통 Bold 14, 좁은 폭 플로팅 바는 Bold 16
    // (라이브톡 하단 바와 같은 규격 — 목업 161:94356도 16).
    final double fontSize = context.isDesktop ? 14 : 16;

    return SizedBox(
      // ⚠️ 폭도 못 박는다 — 하단 플로팅 바는 느슨한 제약(Align)을 주므로 폭을
      // 비워두면 버튼이 글자 크기로 쪼그라든다. PC 사이드바는 stretch라 무영향.
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        // 채움 버튼 hover — 배경에 검정 10%를 섞어 어두워진다(웹 공통).
        // ⚠️ `elevation: 0`만으로는 부족하다. ElevatedButton은 hover에서 elevation을
        // 올려 **그림자**를 만들므로 모든 상태의 elevation을 0으로 못 박는다.
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          animationDuration: Duration.zero,
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue)
                : SDSColor.snowliveBlue,
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          // 웹 기본 compact density가 minimumSize 높이를 깎으므로 강제한다.
          minimumSize: WidgetStatePropertyAll(Size(0, height)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(
            // 라운드 5 — 웹 액션 버튼 공통(라이브톡 하단 바·사이드바와 동일).
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        child: Text(
          '크루톡 올리기',
          style: SDSTextStyle.bold.copyWith(fontSize: fontSize, color: SDSColor.snowliveWhite),
        ),
      ),
    );
  }
}

class _CrewLinkCard extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _CrewLinkCard({required this.label, required this.onTap});

  @override
  State<_CrewLinkCard> createState() => _CrewLinkCardState();
}

class _CrewLinkCardState extends State<_CrewLinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // 카드형 진입 버튼 hover 규칙(랭킹 사이드바와 동일) — 평상시 그림자 없음 →
    // hover에서 `0 2 2 / 검정 6%`가 150ms로 올라온다. 목업은 상시 그림자지만
    // 웹 전체 규칙을 따른다(사용자 확정값).
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.06 : 0),
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        // 목업(161:86838) — 라운드 12.
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: SDSColor.gray100),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          // 목업(161:86838) — 카드 높이 52 = 패딩 16 + 콘텐츠 20.
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  // 목업(161:86842) — Bold 14, 화살표 20.
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: SDSColor.gray300),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}
