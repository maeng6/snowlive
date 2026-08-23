import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루 미리보기 팝업. 캐러셀 카드와 목록 행이 같은 팝업을 쓴다.
///
/// 크루홈 응답의 [CrewCard]에 이름·로고·소개·멤버 수가 모두 들어 있어
/// **추가 조회 없이** 그린다.
///
/// ⚠️ Overlay 직삽이라 Dialog가 주던 `Material` 조상이 없다 → 카드가 직접 Material이다.
Future<void> showLiveCrewModal(
  BuildContext context,
  CrewCard crew, {
  Map<int, String> resortFullnames = const {},
}) {
  return showWebOverlayModal<void>(
    context: context,
    builder: (_, close) => _CrewModalCard(
      crew: crew,
      resortFullnames: resortFullnames,
      onClose: close,
    ),
  );
}

class _CrewModalCard extends StatelessWidget {
  final CrewCard crew;
  final Map<int, String> resortFullnames;
  final void Function([void result]) onClose;

  const _CrewModalCard({
    required this.crew,
    required this.resortFullnames,
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

    final card = Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 384,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(SDSSpacing.lg, SDSSpacing.md, SDSSpacing.lg, SDSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 20, color: SDSColor.gray400),
                  ),
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SDSColor.gray100),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: logoUrl, width: 76, height: 76)
                    : Container(color: SDSColor.gray100),
              ),
              const SizedBox(height: SDSSpacing.md),
              Text(
                crew.crewName ?? '',
                textAlign: TextAlign.center,
                style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                ),
              ],
              if (memberCount != null) ...[
                const SizedBox(height: SDSSpacing.sm),
                Text(
                  '$memberCount명',
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
                ),
              ],
              const SizedBox(height: SDSSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: crew.crewId == null
                      ? null
                      : () {
                          onClose();
                          Get.toNamed('${WebRoutes.crewHome}?id=${crew.crewId}');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.gray50,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    '크루 구경하기',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 짧은 뷰포트에서 넘치면 스크롤되게 한다.
    return SingleChildScrollView(child: card);
  }
}
