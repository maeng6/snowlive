import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/settings/vm_settings_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// 웹 설정 화면.
///
/// 목업: 좌측 정렬된 한 열에 `친구 / 중고거래 / 약관 / 계정` 네 그룹이 놓이고,
/// 각 줄은 라벨 + 우측 `>`다. 태블릿·모바일은 제목 앞에 뒤로가기가 붙는다.
///
/// 항목 자체는 앱 설정과 같다 — 약관 3개는 외부 링크, 오픈소스 라이선스는 플러터가
/// 만들어 주는 라이선스 화면, 계정 그룹은 멤버십/로그아웃/회원탈퇴다.
class SettingsViewWeb extends StatefulWidget {
  const SettingsViewWeb({super.key});

  @override
  State<SettingsViewWeb> createState() => _SettingsViewWebState();
}

class _SettingsViewWebState extends State<SettingsViewWeb> {
  /// 목업의 설정 목록 폭(좌측 정렬, 우측은 비어 있다).
  static const double _listMaxWidth = 600;

  static const _terms = 'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88';
  static const _privacy =
      'https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88';
  static const _location =
      'https://sites.google.com/view/134creativelablocationinfo/%ED%99%88';

  final SettingsViewModelWeb _vm = Get.find<SettingsViewModelWeb>();

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final isDesktop = screenType == WebScreenType.desktop;
    final isMobile = screenType == WebScreenType.mobile;

    // 설정 화면 배경은 흰색이다(셸 Scaffold 기본색은 살짝 회색이 섞여 있다).
    return ColoredBox(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? SDSSpacing.md : SDSSpacing.lg,
          vertical: isMobile ? SDSSpacing.md : SDSSpacing.lg,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _listMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitle(isDesktop),
                SizedBox(height: isMobile ? SDSSpacing.lg : SDSSpacing.xl),
                ..._buildGroups(),
                const SizedBox(height: SDSSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDesktop) {
    return Row(
      children: [
        // 목업: 데스크탑은 사이드바가 있어 뒤로가기가 없고, 태블릿·모바일에만 붙는다.
        if (!isDesktop) ...[
          IconButton(
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.arrow_back, color: SDSColor.gray900, size: 24),
          ),
          const SizedBox(width: SDSSpacing.sm),
        ],
        Text(
          '설정',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: isDesktop ? 28 : 18,
            color: SDSColor.gray900,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroups() {
    return [
      _SettingsGroup(
        title: '친구',
        items: [
          _SettingsItem(label: '친구 추가 요청', onTap: () => _goRoute(WebRoutes.friendRequests)),
          _SettingsItem(label: '차단한 친구 목록', onTap: () => _goRoute(WebRoutes.friendBlockList)),
        ],
      ),
      _SettingsGroup(
        title: '중고거래',
        items: [
          _SettingsItem(
            label: '키워드/카테고리 알림 설정',
            onTap: () => _goRoute(WebRoutes.fleamarketAlert),
          ),
        ],
      ),
      _SettingsGroup(
        title: '약관',
        items: [
          _SettingsItem(label: '이용약관', onTap: () => _openUrl(_terms)),
          _SettingsItem(label: '개인정보 처리방침', onTap: () => _openUrl(_privacy)),
          _SettingsItem(label: '위치 정보 이용약관', onTap: () => _openUrl(_location)),
          _SettingsItem(label: '오픈소스 라이선스', onTap: _openLicenses),
        ],
      ),
      _SettingsGroup(
        title: '계정',
        items: [
          _SettingsItem(label: '멤버십 관리', onTap: _onMembership),
          _SettingsItem(label: '로그아웃', onTap: _onSignOut),
          _SettingsItem(label: '회원탈퇴', onTap: _onWithdraw),
        ],
      ),
    ];
  }

  /// 로그인이 필요한 화면은 게스트에게 안내 후 로그인으로 보낸다(웹 관례).
  void _goRoute(String route) {
    if (!_vm.isLoggedIn) {
      _toast('로그인이 필요해요.');
      Get.toNamed(WebRoutes.login);
      return;
    }
    Get.toNamed(route);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openLicenses() {
    // 앱은 자체 라이선스 목록 화면을 쓰지만, 웹은 플러터가 실제 의존성에서
    // 만들어 주는 화면을 그대로 쓴다(직접 목록을 관리하면 금방 낡는다).
    showLicensePage(
      context: context,
      applicationName: '스노우라이브',
    );
  }

  void _onMembership() {
    if (!_vm.isLoggedIn) {
      _toast('로그인이 필요해요.');
      Get.toNamed(WebRoutes.login);
      return;
    }
    // 멤버십 화면은 아직 없다(목업의 `멤버십 업그레이드`도 동일).
    _toast('멤버십 관리는 준비 중이에요.');
  }

  Future<void> _onSignOut() async {
    if (!_vm.isLoggedIn) {
      Get.toNamed(WebRoutes.login);
      return;
    }
    final ok = await showWebConfirmDialog(
      context: context,
      title: '로그아웃하시겠어요?',
      confirmLabel: '로그아웃',
    );
    if (!ok) return;
    await _vm.signOut();
    if (!mounted) return;
    _toast('로그아웃했어요.');
    Get.offAllNamed(WebRoutes.home);
  }

  Future<void> _onWithdraw() async {
    if (!_vm.isLoggedIn) {
      Get.toNamed(WebRoutes.login);
      return;
    }
    final ok = await showWebConfirmDialog(
      context: context,
      title: '정말 탈퇴하시겠어요?',
      message: '탈퇴하면 라이딩 기록과 크루 활동을 되돌릴 수 없어요.',
      confirmLabel: '회원탈퇴',
      isDestructive: true,
    );
    if (!ok) return;

    final result = await _vm.withdraw();
    if (!mounted) return;
    switch (result) {
      case SettingsWithdrawResult.success:
        _toast('탈퇴가 완료됐어요.');
        Get.offAllNamed(WebRoutes.home);
      case SettingsWithdrawResult.crewLeader:
        _toast('크루장은 크루를 위임하거나 삭제한 뒤 탈퇴할 수 있어요.');
      case SettingsWithdrawResult.failed:
        _toast('탈퇴에 실패했어요. 잠시 후 다시 시도해주세요.');
      case SettingsWithdrawResult.notLoggedIn:
        Get.toNamed(WebRoutes.login);
    }
  }

  void _toast(String message) {
    showWebToast(
      context,
      message,
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }
}

/// 그룹 하나 — 회색 소제목 + 줄들.
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
        ),
        const SizedBox(height: SDSSpacing.sm),
        ...items,
        const SizedBox(height: SDSSpacing.xl),
      ],
    );
  }
}

/// 설정 줄 — 라벨 + 우측 `>`.
class _SettingsItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
              Icon(Icons.chevron_right, size: 20, color: SDSColor.gray400),
            ],
          ),
        ),
      ),
    );
  }
}
