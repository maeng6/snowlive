import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
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
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            title,
            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray400),
          ),
        ),
        ...children,
        const SizedBox(height: SDSSpacing.lg),
      ],
    );
  }
}

/// 역할 배지. 색은 앱 `vm_crewMemberList.getRoleColorBox/Text`와 같은 값이다.
class CrewRoleBadge extends StatelessWidget {
  final String role;

  const CrewRoleBadge({super.key, required this.role});

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(4)),
      child: Text(
        role.isEmpty ? kCrewRoleMember : role,
        style: SDSTextStyle.bold.copyWith(fontSize: 11, color: foreground),
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
