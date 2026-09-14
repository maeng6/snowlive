import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 태블릿/모바일 전용 전체 화면 메뉴 패널(피그마 1:16330 비로그인 / 1:17339 로그인).
///
///  - 드로어가 아니라 **앱바 아래** 영역을 가득 채우는 패널로 뜬다(요청).
///    상단바(로고+메뉴/X 아이콘)는 그대로 보이고, 닫기는 셸의 X 아이콘이 담당한다.
///  - 열릴 때 항목들이 위에서부터 순차적으로 페이드인된다(요청).
///  - 로그인: 상단 프로필 블록(아바타·닉네임·리조트·상태메시지) +
///    계정 그룹(마이페이지/멤버십 업그레이드/로그아웃).
///  - 비로그인: 하단 고정 로그인/회원가입 버튼.
///  - 메뉴 구성은 피그마와 달리 **사이드바와 동일하게 전부** 노출한다(요청).
///  - 알림·멤버십 업그레이드는 화면이 아직 없어 "준비 중" 스낵바만 띄운다(요청).
///  - 앱 다운로드 배너는 보류(요청).
class WebGnbMenuPanel extends StatefulWidget {
  /// 항목 탭 등으로 메뉴를 닫아야 할 때 호출한다(셸이 패널을 내린다).
  final VoidCallback onClose;

  const WebGnbMenuPanel({super.key, required this.onClose});

  @override
  State<WebGnbMenuPanel> createState() => _WebGnbMenuPanelState();
}

class _WebGnbMenuPanelState extends State<WebGnbMenuPanel>
    with SingleTickerProviderStateMixin {
  /// 패널 전용 알림 항목 — routePrefix가 없어 누르면 "준비 중" 스낵바가 뜬다.
  static const GnbNavItemData _kAlarmItem = GnbNavItemData(label: '알림');

  /// **세 그룹**(아이콘 메뉴 / 친구·알림·설정 / 계정)으로 나눠 부드럽게
  /// 페이드인한다(요청). 그룹당 350ms + 살짝(8px) 위로 올라오며 등장,
  /// 그룹 간 120ms 지연으로 자연스럽게 겹친다.
  static const int _kFadeMs = 550;
  static const int _kDelayMs = 180;
  static const int _kTotalMs = _kFadeMs + _kDelayMs * 2; // 910

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _kTotalMs),
  )..forward();

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  /// group 순번대로 120ms씩 늦게 350ms 동안 페이드인 + 8px 상승.
  Widget _groupFade(int group, Widget child) {
    final double start =
        ((group * _kDelayMs) / _kTotalMs).clamp(0.0, 1.0).toDouble();
    final double end =
        ((group * _kDelayMs + _kFadeMs) / _kTotalMs).clamp(0.0, 1.0).toDouble();
    final anim = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, builtChild) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 8),
          child: builtChild,
        ),
      ),
      child: child,
    );
  }

  Future<void> _signOut() async {
    widget.onClose();
    await Get.find<AuthCheckViewModelWeb>().signOut();
    Get.find<UserViewModel>().resetUser();
    Get.offAllNamed(WebRoutes.home);
  }

  /// favorite_resort(index) → 리조트 이름. 없으면 null.
  String? _resortNameOf(int? index) {
    if (index == null) return null;
    for (final resort in resortList) {
      if (resort.index == index) return resort.resortName;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final UserViewModel userVM = Get.find<UserViewModel>();

    return Material(
      color: SDSColor.snowliveWhite,
      child: Obx(() {
        final user = userVM.user;
        final bool isLoggedIn = user != null && user.user_id != null;

        // 그룹 구성: [프로필+아이콘 메뉴] → [친구/알림/설정] → [계정].
        final List<Widget> groups = [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLoggedIn) ...[
                // 모바일: 프로필 블록 위 여백 30 (리스트 상단 패딩 8 포함).
                if (context.screenType == WebScreenType.mobile)
                  const SizedBox(height: 22),
                _buildProfileBlock(user),
                const SizedBox(height: 24),
              ],
              for (final item in kGnbPrimaryItems)
                GnbNavRow(item: item, onNavigate: widget.onClose),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: SDSColor.gray100, height: 1),
              ),
              // 친구 / 알림(준비 중) / 설정.
              GnbNavRow(
                  item: kGnbSecondaryItems.first, onNavigate: widget.onClose),
              const GnbNavRow(item: _kAlarmItem),
              GnbNavRow(
                  item: kGnbSecondaryItems.last, onNavigate: widget.onClose),
            ],
          ),
          if (isLoggedIn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: SDSColor.gray100, height: 1),
                ),
                // 계정 그룹: 마이페이지 / 멤버십 업그레이드(준비 중) / 로그아웃.
                _AccountRow(
                  label: '마이페이지',
                  onTap: () {
                    widget.onClose();
                    Get.toNamed('${WebRoutes.userProfile}?id=${user.user_id}');
                  },
                ),
                _AccountRow(
                  label: '멤버십 업그레이드',
                  onTap: () =>
                      Get.snackbar('준비 중입니다', '멤버십 업그레이드는 아직 준비 중이에요.'),
                ),
                _AccountRow(
                  label: '로그아웃',
                  onTap: _signOut,
                ),
              ],
            ),
        ];

        final List<Widget> items = [
          for (var g = 0; g < groups.length; g++) _groupFade(g, groups[g]),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: items,
              ),
            ),
            // 비로그인: 하단 고정 로그인/회원가입 (피그마) — 애니메이션 없이 바로 노출.
            if (!isLoggedIn) _buildAuthButtons(),
          ],
        );
      }),
    );
  }

  /// 로그인 상태 상단 프로필 블록 — 아바타 64 + 닉네임 + 리조트 + 상태메시지(피그마).
  /// 크루명은 아직 이름을 받아오지 않아 제외한다(요청 — 리조트명만).
  Widget _buildProfileBlock(dynamic user) {
    final String? resortName = _resortNameOf(user.favorite_resort as int?);
    final String? stateMsg = user.state_msg as String?;

    return Column(
      children: [
        WebAvatar(
          url: user.profile_image_url_user as String?,
          size: 64,
          userId: user.user_id as int?,
        ),
        const SizedBox(height: 12),
        Text(
          '${user.display_name ?? ''}',
          textAlign: TextAlign.center,
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
        ),
        if (resortName != null && resortName.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            resortName,
            textAlign: TextAlign.center,
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700),
          ),
        ],
        if (stateMsg != null && stateMsg.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            stateMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
          ),
        ],
      ],
    );
  }

  /// 비로그인 하단 고정 버튼 — 로그인(화이트+보더) / 회원가입(블랙), 풀폭 세로(피그마).
  Widget _buildAuthButtons() {
    void goLogin() {
      widget.onClose();
      Get.toNamed(WebRoutes.login);
    }

    ButtonStyle style({required Color background, Color? borderColor}) =>
        ElevatedButton.styleFrom(
          backgroundColor: background,
          elevation: 0,
          shadowColor: Colors.transparent,
          overlayColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          minimumSize: const Size.fromHeight(48),
          side: borderColor == null ? null : BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: goLogin,
            style: style(
              background: SDSColor.snowliveWhite,
              borderColor: SDSColor.gray200,
            ),
            child: Text(
              '로그인',
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: goLogin,
            style: style(background: SDSColor.snowliveBlack),
            child: Text(
              '회원가입',
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
            ),
          ),
        ],
      ),
    );
  }
}

/// 계정 그룹 한 줄 — GnbNavRow와 같은 톤(높이 44, Bold 14).
class _AccountRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AccountRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: SDSColor.gray50,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
          ),
        ),
      ),
    );
  }
}
