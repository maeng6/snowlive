import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 크루홈 헤더 — 로고 + 크루명 + `소개 · 리조트` + 방문자 수 + 알림/설정.
class CrewHomeHeaderWeb extends StatelessWidget {
  final CrewDetailInfo info;

  /// 설정 톱니를 그릴지. 앱과 같이 **내 크루일 때만** 보여준다.
  final bool showSettings;

  const CrewHomeHeaderWeb({super.key, required this.info, this.showSettings = false});

  @override
  Widget build(BuildContext context) {
    final accent = crewColorOf(info.color) ?? SDSColor.snowliveBlue;
    final logoUrl = crewLogoUrlOf(logoUrl: info.crewLogoUrl, color: info.color);
    final desc = info.description?.trim().replaceAll('\n', ' ') ?? '';
    final resort = info.baseResortFullname?.trim().isNotEmpty ?? false
        ? info.baseResortFullname!
        : (info.baseResortNickname ?? '');
    final subtitle = [if (desc.isNotEmpty) desc, if (resort.isNotEmpty) resort].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // 목업의 로고 테두리는 크루 색이다.
            border: Border.all(color: accent, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: (logoUrl?.isNotEmpty ?? false)
              ? WebNetworkImage(url: logoUrl, width: 64, height: 64)
              : Container(color: SDSColor.gray100),
        ),
        const SizedBox(width: SDSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info.crewName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                ),
              ],
            ],
          ),
        ),
        // 방문자 집계 API가 아직 없어서 자리만 두고 값은 `-`로 둔다(사용자 확정).
        if (context.isDesktop) ...[
          const SizedBox(width: SDSSpacing.md),
          Text(
            '방문자 Today -  |  Total -',
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
          ),
        ],
        const SizedBox(width: SDSSpacing.md),
        _HeaderIconButton(
          icon: Icons.notifications_none,
          // 크루 알림 화면은 목업이 없어 다음 작업이다.
          onTap: () => Get.snackbar('알림', '크루 알림은 준비 중이에요.'),
        ),
        if (showSettings) ...[
          const SizedBox(width: 4),
          _HeaderIconButton(
            icon: Icons.settings_outlined,
            onTap: () => Get.toNamed('${WebRoutes.crewSetting}?id=${info.crewId}'),
          ),
        ],
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: SDSColor.gray900),
      ),
    );
  }
}

/// 헤더 아래 요약 바 — `멤버(명) / 통합 랭킹 / 총 점수` (+ 내 크루가 아니면 가입 신청).
class CrewHomeSummaryBarWeb extends StatelessWidget {
  final int? memberCount;
  final int? overallRank;
  final double? totalScore;

  /// null이면 가입 신청 항목을 그리지 않는다(내 크루이거나 신청 불가).
  final VoidCallback? onApply;

  const CrewHomeSummaryBarWeb({
    super.key,
    required this.memberCount,
    required this.overallRank,
    required this.totalScore,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final stats = [
      _StatCell(label: '멤버(명)', value: _numberFormat.format(memberCount ?? 0)),
      _StatCell(label: '통합 랭킹', value: _numberFormat.format(overallRank ?? 0)),
      _StatCell(label: '총 점수', value: _numberFormat.format((totalScore ?? 0).round())),
    ];

    return Container(
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? SDSSpacing.md : SDSSpacing.lg, vertical: 18),
      // 모바일은 세 지표 + 신청 링크를 한 줄에 넣으면 넘친다 → 세로로 쌓는다.
      child: isMobile ? _buildStacked(stats) : _buildInline(stats),
    );
  }

  Widget _buildStacked(List<Widget> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          stats[i],
        ],
        if (onApply != null) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '가입 신청하기',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 20, color: SDSColor.gray900),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInline(List<Widget> stats) {
    return Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) _divider(),
            Flexible(child: stats[i]),
          ],
          if (onApply != null) ...[
            const Spacer(),
            InkWell(
              onTap: onApply,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '가입 신청하기',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 20, color: SDSColor.gray900),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
  }

  Widget _divider() => Container(
        width: 1,
        height: 16,
        margin: const EdgeInsets.symmetric(horizontal: SDSSpacing.md),
        color: SDSColor.gray200,
      );
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
        const SizedBox(width: SDSSpacing.sm),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
          ),
        ),
      ],
    );
  }
}
