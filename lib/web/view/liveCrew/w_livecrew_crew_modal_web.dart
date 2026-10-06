import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루 미리보기 팝업. 캐러셀·목록 행·랭킹 크루 행이 모두 같은 팝업을 쓴다.
///
/// 카드는 **유저 프로필 팝업과 같은 공용 위젯**([WebProfileCard])이다 — 목업(106:18120)이
/// 사실상 같은 구성이라(로고 → 이름 → 부제 → 소개 → 하단 버튼) 따로 그릴 이유가 없다.
/// 다른 점은 아바타가 원형이 아니라 **라운드 사각 로고(72 · 라운드 12)** 라는 것뿐.
///
/// 넘겨받는 [CrewCard]에 있는 값만 그린다(추가 조회 없음) — 멤버 수가 없는 호출자
/// (랭킹·슬로프크래프트)에서는 `N명` 줄이 비는 게 정상이다.
Future<void> showLiveCrewModal(
  BuildContext context,
  CrewCard crew, {
  Map<int, String> resortFullnames = const {},
}) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<void>(
    context: context,
    // 모바일은 하단에 붙는 시트라 좌우 여백이 없어야 한다(유저 프로필 팝업과 동일).
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _CrewModalCard(
      crew: crew,
      resortFullnames: resortFullnames,
      isSheet: isMobile,
      onClose: close,
    ),
  );
}

class _CrewModalCard extends StatelessWidget {
  final CrewCard crew;
  final Map<int, String> resortFullnames;
  final bool isSheet;
  final void Function([void result]) onClose;

  const _CrewModalCard({
    required this.crew,
    required this.resortFullnames,
    required this.isSheet,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    // 부제는 **리조트 이름만** 쓴다. 서버에 크루 별명 필드가 없어서 카드처럼
    // `소개 · 리조트`로 쓰면 아래 소개문과 같은 글이 두 번 찍힌다(실측).
    final resortId = crew.baseResortId;
    final subtitle = (resortId != null ? resortFullnames[resortId] : null) ??
        crew.baseResortNickname ??
        '';
    final memberCount = crew.memberCount;
    final description = crew.description?.trim() ?? '';
    final crewId = crew.crewId;

    return WebProfileCard(
      isSheet: isSheet,
      // 시트는 닫기 X 대신 드래그 핸들을 쓴다.
      onClose: isSheet ? null : onClose,
      data: WebProfileCardData(
        avatarUrl: logoUrl,
        // 목업(106:19153) — 크루 로고는 72에 라운드 12인 사각이다.
        avatarSize: 72,
        avatarRadius: 12,
        displayName: crew.crewName,
        // 크루는 줄이 더 많아(이름·리조트·멤버수·소개) 간격을 한 단계 좁힌다.
        compactLines: true,
        resortName: subtitle.isEmpty ? null : subtitle,
        // 멤버 수는 있는 호출자(라이브크루 홈)에서만 나온다 — 랭킹·슬로프크래프트
        // 응답에는 필드가 없어서 이 줄이 통째로 빠진다.
        extraLine: memberCount == null ? null : '$memberCount명',
        stateMsg: description.isEmpty ? null : description,
      ),
      footer: WebProfileFooterButton(
        label: '크루 구경하기',
        onTap: crewId == null
            ? null
            : () {
                // 팝업을 먼저 닫아야 크루홈 위에 딤이 남지 않는다.
                onClose();
                Get.toNamed('${WebRoutes.crewHome}?id=$crewId');
              },
      ),
    );
  }
}
