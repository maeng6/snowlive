import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kCrewHomeSidebarWidth = 280;

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
      width: kCrewHomeSidebarWidth,
      // 좌측 헤더(로고 64) 높이만큼 내려서 시작한다.
      padding: const EdgeInsets.only(left: SDSSpacing.lg, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onUploadTalk != null) ...[
            CrewTalkUploadButton(onTap: onUploadTalk!),
            const SizedBox(height: SDSSpacing.md),
          ],
          CrewRecordLinkCards(crewId: crewId),
        ],
      ),
    );
  }
}

/// `시즌 기록실` / `일별 현황` 두 링크. 데스크탑은 우측 열, 그보다 좁으면 본문 끝에
/// 놓는다(우측 열이 접히면 이 진입점이 사라져 버린다).
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
        const SizedBox(height: 12),
        _CrewLinkCard(
          label: '일별 현황',
          onTap: () => Get.toNamed('${WebRoutes.crewDailyRecord}?id=$crewId'),
        ),
      ],
    );
  }
}

/// 파란 `크루톡 올리기` 버튼. 좁은 폭에서는 본문 끝에 전체폭으로 놓는다.
class CrewTalkUploadButton extends StatelessWidget {
  final VoidCallback onTap;

  const CrewTalkUploadButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        '크루톡 올리기',
        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
      ),
    );
  }
}

class _CrewLinkCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CrewLinkCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SDSColor.gray100),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: SDSColor.gray300),
            ],
          ),
        ),
      ),
    );
  }
}
