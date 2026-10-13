import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';

/// 크루 설정 허브의 섹션(회색 소제목 + 행 묶음).
class CrewSettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const CrewSettingSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 목업(174:85475) — 섹션 제목 줄 27, 제목 끝 ↔ 첫 행 20(행 자체 상하 12 포함).
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: SDSTextStyle.bold
                .copyWith(fontSize: 13, height: 27 / 13, color: SDSColor.gray400),
          ),
        ),
        ...children,
        // 섹션 사이 40 (목업 — 섹션 176, 다음 섹션 216).
        const SizedBox(height: 40),
      ],
    );
  }
}

/// 역할 배지. 색은 앱 `vm_crewMemberList.getRoleColorBox/Text`와 같은 값이다.
class CrewRoleBadge extends StatelessWidget {
  final String role;

  /// 닉네임 줄 안에 붙일 때(멤버 화면). 줄높이를 못 박아 배지 높이를 18로 고정한다 —
  /// 행 높이가 고정이라 배지가 닉네임 줄(20)보다 크면 행이 넘친다.
  final bool compact;

  const CrewRoleBadge({super.key, required this.role, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    switch (role) {
      case kCrewRoleLeader:
        background = SDSColor.snowliveBlue;
        foreground = SDSColor.snowliveWhite;
      case kCrewRoleManager:
        background = SDSColor.gray800;
        foreground = SDSColor.snowliveWhite;
      default:
        background = SDSColor.gray100;
        foreground = SDSColor.snowliveBlack;
    }

    return Container(
      // 닉네임 옆에 붙는 작은 배지 — 패딩을 조인다(사용자 확정).
      padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 6, vertical: compact ? 1 : 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(4)),
      child: Text(
        role.isEmpty ? kCrewRoleMember : role,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 11,
          height: compact ? 14 / 11 : null,
          color: foreground,
        ),
      ),
    );
  }
}

/// `ON`/`OFF` 알약 토글. 앱 `v_managerPermission._buildOnOffButton`과 같은 규격이다.
class CrewOnOffToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CrewOnOffToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onChanged == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Container(
          width: 44,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: value
                ? SDSColor.snowliveBlue.withOpacity(0.1)
                : SDSColor.gray700.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value ? 'ON' : 'OFF',
            style: SDSTextStyle.bold.copyWith(
              fontSize: 12,
              color: value ? SDSColor.snowliveBlue : SDSColor.snowliveBlack,
            ),
          ),
        ),
      ),
    );
  }
}

/// 행 끝에 붙는 작은 알약 버튼 — `수락하기`/`거절`(가입 신청 목록),
/// `신청취소`(가입 신청한 크루)가 공유한다.
///
/// 목업(174:86102) — 높이 28 = 글줄 16 + 상하 6, 좌우 10, 라운드 16, Bold 12.
class CrewPillButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool hasBorder;
  final VoidCallback onTap;

  const CrewPillButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    // 채움 버튼 hover는 웹 공통(배경에 검정 10% 블렌드) — `ElevatedButton`은 hover에서
    // elevation을 올려 그림자를 만들므로 모든 상태의 elevation을 0으로 못 박는다.
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        side: hasBorder ? BorderSide(color: SDSColor.gray200) : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // 웹 기본 compact density가 최소 크기를 건드리지 않게 표준으로 못 박는다
        // (다른 공용 버튼과 같은 처리 — `w_web_section_link_button_web.dart`).
        visualDensity: VisualDensity.standard,
        animationDuration: Duration.zero,
      ).copyWith(
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? Color.alphaBlend(Colors.black.withValues(alpha: 0.1), background)
              : background,
        ),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold
            .copyWith(fontSize: 12, height: 16 / 12, color: foreground),
      ),
    );
  }
}

/// 크루 설정 계열 화면의 로딩 자리표시 모음.
///
/// 이 화면들은 서버 값을 **폼에 미리 채우는** 구조라 자리표시가 없으면 빈 입력칸·
/// 꺼진 토글·엉뚱한 색이 먼저 보이다가 값이 도착하면서 튄다(토글은 그 사이에 눌러
/// 버릴 수도 있다). 자리값은 **실제 레이아웃과 같은 수치**로 둔다.
///
/// ⚠️ [SkeletonShimmer]는 각 스켈레톤 루트에서 **한 번만** 감싼다.

/// `가입 신청 목록` — 머리줄 + (아바타 32 줄 + 메시지 박스) × N.
class CrewApplicationsSkeleton extends StatelessWidget {
  const CrewApplicationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 머리줄(ExtraBold 14) + 아래 16.
          const SkeletonLine(width: 96, height: 17),
          const SizedBox(height: SDSSpacing.md),
          for (var i = 0; i < 3; i++) ...[
            // 신청자 사이 24(실제 목록과 같은 값).
            if (i > 0) const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  // 줄 높이 32 = 아바타 크기.
                  height: 32,
                  child: Row(
                    children: [
                      const SkeletonBox(width: 32, height: 32, radius: 16),
                      const SizedBox(width: 10),
                      SkeletonLine(width: 80 + (i % 3) * 24, height: 18),
                      const Spacer(),
                      // `수락하기`·`거절` 알약(높이 28).
                      const SkeletonBox(width: 66, height: 28, radius: 16),
                      const SizedBox(width: 8),
                      const SkeletonBox(width: 48, height: 28, radius: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // 메시지 박스 — 패딩 10 + 글줄 16 + 10.
                const SkeletonBox(height: 36, radius: 12),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// `크루원 관리` — 머리줄 + (아바타 36 + 닉네임 + 역할 배지) × N.
class CrewMemberAdminSkeleton extends StatelessWidget {
  const CrewMemberAdminSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 머리줄(ExtraBold 14) + 아래 16 — 형제 목록들과 같은 자리값.
          const SkeletonLine(width: 72, height: 17),
          const SizedBox(height: SDSSpacing.md),
          for (var i = 0; i < 6; i++)
            Padding(
              // 실제 행과 같은 상하 8.
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SkeletonBox(width: 36, height: 36, radius: 18),
                  const SizedBox(width: 12),
                  SkeletonLine(width: 84 + (i % 4) * 22, height: 18),
                  const SizedBox(width: 8),
                  // 역할 배지(글줄 11 + 상하 2 = 높이 19, 라운드 4).
                  const SkeletonBox(width: 38, height: 19, radius: 4),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// `운영진 권한 설정` — (제목 15 [+ 설명 13] + ON/OFF 토글) × 3.
/// 첫 줄만 설명이 있다(실제 화면과 같다).
class CrewPermissionsSkeleton extends StatelessWidget {
  const CrewPermissionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              // 실제 행과 같은 규칙 — 간격은 줄 사이에만(마지막 줄은 0).
              padding: EdgeInsets.only(bottom: i == 2 ? 0 : SDSSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLine(width: 150 + (i % 3) * 20, height: 18),
                        // 첫 줄만 설명 두 줄(제목 ↔ 설명 6).
                        if (i == 0) ...[
                          const SizedBox(height: 6),
                          const SkeletonLine(height: 16),
                          const SizedBox(height: 4),
                          const SkeletonLine(width: 220, height: 16),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: SDSSpacing.md),
                  // ON/OFF 토글 44×26.
                  const SkeletonBox(width: 44, height: 26, radius: 15),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// `크루 소개글 작성/변경` — 라벨 14 + 입력칸(높이 160).
class CrewSettingDescSkeleton extends StatelessWidget {
  const CrewSettingDescSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // 폼 라벨(regular 14) + 아래 8 (`WebFormLabel`과 같은 값).
          SkeletonLine(width: 44, height: 17),
          SizedBox(height: SDSSpacing.sm),
          SkeletonBox(height: 160, radius: 6),
        ],
      ),
    );
  }
}

/// `크루 이미지 및 컬러 설정` — 로고 80 + `이미지 직접 등록` 알약 + 색 원 8개.
class CrewSettingImageSkeleton extends StatelessWidget {
  const CrewSettingImageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        // 실제 화면과 같은 위 24.
        padding: const EdgeInsets.only(top: SDSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 로고 미리보기 80 · 라운드 16.
            const Center(child: SkeletonBox(width: 80, height: 80, radius: 16)),
            // 로고 ↔ 알약 30.
            const SizedBox(height: 30),
            // `이미지 직접 등록` — 높이 35 · 라운드 20.
            const Center(child: SkeletonBox(width: 118, height: 35, radius: 20)),
            // 알약 ↔ 색상 라벨 52.
            const SizedBox(height: 52),
            const Center(child: SkeletonLine(width: 130, height: 16)),
            // 라벨 ↔ 색 줄 12.
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 8; i++) ...[
                  // 색 원 사이 10.
                  if (i > 0) const SizedBox(width: 10),
                  const SkeletonBox(width: 24, height: 24, radius: 12),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// `공지사항` 목록 — (본문 15 + 메타 13) × N, 사이에 구분선(height 32).
class CrewNoticeListSkeleton extends StatelessWidget {
  const CrewNoticeListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 4; i++) ...[
            // 실제 목록과 같은 구분선 자리(Divider height 32).
            if (i > 0) const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(width: 180.0 + (i % 3) * 70, height: 18),
                      // 본문 ↔ 메타 4.
                      const SizedBox(height: 4),
                      const SkeletonLine(width: 120, height: 16),
                    ],
                  ),
                ),
                const SizedBox(width: SDSSpacing.sm),
                // ⋯ 더보기 버튼 자리.
                const SkeletonBox(width: 24, height: 24, radius: 4),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
