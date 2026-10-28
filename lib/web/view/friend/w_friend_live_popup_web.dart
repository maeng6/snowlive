import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_friend.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_profile_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart'
    show WebPopupCloseButton;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── 팝업 규격 ──
// 카드 폭은 **친구 타일 4열이 정확히 들어가는 값**으로 잡는다(사용자 확정) —
// 숫자로 박아 두면 타일 폭·간격을 고칠 때마다 오른쪽에 못 쓰는 여백이 남는다.
const double _kFriendTileWidth = 76;
const double _kFriendTileGap = 8; // 타일 좌우 간격
const double _kFriendTileRunGap = 20; // 타일 줄 사이(상하) 간격
const int _kFriendTileColumns = 4;
const double _kFriendPopupPadH = 24; // 카드 좌우 패딩(웹 팝업 표준)
const double _kFriendPopupWidth =
    _kFriendTileColumns * _kFriendTileWidth +
    (_kFriendTileColumns - 1) * _kFriendTileGap +
    _kFriendPopupPadH * 2; // 76*4 + 8*3 + 48 = 376

/// 상단 친구 아이콘 → 앱의 '라이브중인 친구'와 같은 내용.
/// 친구 그리드(아바타 + 라이브 뱃지) + 위치정보(마지막 슬로프 · N분 전) + 친구 관리 바로가기.
///
/// **모바일은 앱과 같은 하단 바텀시트**, 그 외 폭은 중앙 팝업이다(사용자 확정).
Future<void> showFriendLivePopupWeb(BuildContext context) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<void>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    // 시트는 화면 아래 끝에 붙어야 하므로 딤 패딩을 없앤다.
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(24),
    builder: (_, close) => _FriendLivePopup(close: close),
  );
}

class _FriendLivePopup extends StatefulWidget {
  final void Function([void result]) close;
  const _FriendLivePopup({required this.close});

  @override
  State<_FriendLivePopup> createState() => _FriendLivePopupState();
}

/// PC·태블릿 팝업의 `새로고침` 텍스트 버튼 — **위 버튼과 같은 16**, 두께만 Regular, gray500.
/// hover는 웹 공통 인바 링크 규칙(밑줄). 리플·배경 변화는 쓰지 않는다.
class _RefreshTextButton extends StatefulWidget {
  final Future<void> Function() onTap;

  const _RefreshTextButton({required this.onTap});

  @override
  State<_RefreshTextButton> createState() => _RefreshTextButtonState();
}

class _RefreshTextButtonState extends State<_RefreshTextButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          // 글자만 두면 클릭 영역이 너무 얇다 — 상하 8씩 준다.
          padding: const EdgeInsets.symmetric(vertical: SDSSpacing.sm),
          child: Text(
            '새로고침',
            style: SDSTextStyle.regular.copyWith(
              fontSize: 16,
              height: 20 / 16,
              color: SDSColor.gray500,
              decoration: _hovered ? TextDecoration.underline : null,
              decorationColor: SDSColor.gray500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 앱 시트의 `새로고침` pill — 흰 면 · gray200 테두리 · 라운드 100 ·
/// 패딩 14/3 · 최소 36×32 · Bold 13 gray900(앱과 동일 값).
class _RefreshPill extends StatelessWidget {
  final Future<void> Function() onTap;

  const _RefreshPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          minimumSize: const Size(36, 32),
          backgroundColor: SDSColor.snowliveWhite,
          side: BorderSide(color: SDSColor.gray200),
          splashFactory: NoSplash.splashFactory,
          elevation: 0,
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          '새로고침',
          style: SDSTextStyle.bold.copyWith(
            fontSize: 13,
            color: SDSColor.gray900,
          ),
        ),
      ),
    );
  }
}

/// 팝업 타이틀 — 공통 규격(Bold 16 · 글줄 24 · gray900 · 가운데).
class _PopupTitle extends StatelessWidget {
  const _PopupTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      '라이브중인 친구',
      textAlign: TextAlign.center,
      style: SDSTextStyle.bold.copyWith(
        fontSize: 16,
        height: 24 / 16,
        color: SDSColor.gray900,
      ),
    );
  }
}

class _FriendLivePopupState extends State<_FriendLivePopup> {
  final FriendAPI _api = FriendAPI();
  bool _loading = true;
  List<FriendListModel> _friends = [];

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user?.user_id;
    return (id is int) ? id : int.tryParse('$id');
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final ApiResponse res = await _api.fetchFriendList(
      userId: uid,
      bestFriend: false,
    );
    if (!mounted) return;
    if (res.success && res.data is List) {
      _friends = FriendListResponse.fromJson(res.data as List).friends ?? [];
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (context.screenType == WebScreenType.mobile) return _buildSheet(context);
    return _buildCard();
  }

  /// 모바일 — 앱(`v_resortHome`의 바텀시트)과 같은 구성·값.
  /// 드래그 핸들 → 타이틀 + 새로고침 → 4열 그리드 → 하단 고정 버튼.
  Widget _buildSheet(BuildContext context) {
    // 앱 시트는 화면의 88%를 차지한다(DraggableScrollableSheet initialChildSize).
    final height = MediaQuery.sizeOf(context).height * 0.88;
    return Material(
      color: SDSColor.snowliveWhite,
      // 앱과 같은 상단 라운드 20.
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Column(
          children: [
            // 드래그 핸들 — 위 12, 36×4 gray200(앱과 동일). 웹은 드래그로 닫지 않지만
            // 시트 모양을 앱과 같게 맞추려고 그대로 둔다.
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: SDSColor.gray200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: Padding(
                // 앱 시트 콘텐츠 패딩 — 좌우 16 · 위 12.
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 타이틀 줄(높이 32) + 우측 새로고침 pill — 앱과 동일.
                    SizedBox(
                      height: 32,
                      child: Row(
                        children: [
                          Text(
                            '라이브중인 친구',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 15,
                              color: SDSColor.gray700,
                            ),
                          ),
                          const Spacer(),
                          _RefreshPill(onTap: _reload),
                        ],
                      ),
                    ),
                    // 타이틀 ↔ 목록 20(앱과 동일).
                    const SizedBox(height: 20),
                    Expanded(child: _body(sheet: true)),
                  ],
                ),
              ),
            ),
            // 하단 고정 버튼 — 앱과 같은 패딩(좌우 16 · 위 12 · 아래 20) + SafeArea.
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 20,
                ),
                child: _manageButton(radius: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _kFriendPopupWidth,
          maxHeight: 560,
        ),
        child: Stack(
          children: [
            Padding(
              // 웹 팝업 표준 패딩 — 좌우 24 · 위 30 · 아래 24.
              padding: const EdgeInsets.fromLTRB(
                _kFriendPopupPadH,
                30,
                _kFriendPopupPadH,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 웹 팝업 표준 타이틀 — Bold 16 · 글줄 24 · **가운데 정렬**.
                  // 우상단 X를 피하면서 가운데를 유지하려면 좌우를 같은 값으로 비운다.
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: _PopupTitle(),
                  ),
                  // 타이틀 ↔ 목록 24.
                  const SizedBox(height: SDSSpacing.lg),
                  Flexible(child: _body()),
                  // 목록 ↔ 버튼 30 — 웹 팝업 표준(본문 ↔ 버튼)과 같은 값.
                  const SizedBox(height: 30),
                  _manageButton(radius: 5),
                  // 앱 시트의 `새로고침`을 PC·태블릿에서는 버튼 아래 텍스트 버튼으로
                  // 둔다(사용자 확정) — 타이틀 줄에 pill을 넣으면 가운데 정렬한
                  // 타이틀이 다시 틀어진다.
                  const SizedBox(height: SDSSpacing.sm),
                  Center(child: _RefreshTextButton(onTap: _reload)),
                ],
              ),
            ),
            // 닫기 X — 웹 팝업 공통(26 · gray900 50% · 우상단 16/16).
            WebPopupCloseButton(onTap: widget.close),
          ],
        ),
      ),
    );
  }

  /// `친구 관리 바로가기`(비로그인은 `로그인`) — 데스크탑 팝업과 모바일 시트가 공유한다.
  /// 라운드만 다르다(팝업 5 / 앱 시트 6).
  ///
  /// ⚠️ 높이는 SizedBox로 겉에서 못 박는다 — 웹 기본 visualDensity가 버튼을 깎아
  /// 48이 40으로 렌더된다. minimumSize + standard density로 같이 못 박는다.
  Widget _manageButton({required double radius}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          widget.close();
          // 비로그인이면 로그인 화면으로, 로그인 상태면 친구 관리로.
          Get.toNamed(_uid == null ? WebRoutes.login : WebRoutes.friend);
        },
        // 액션 버튼 표준 — 높이 48 · Bold 16. 보조 동작이라 면은 gray100,
        // 글자는 gray900(홈 `더보기`와 같은 조합).
        // hover는 웹 공통 — 리플·그림자 없이 연회색 면에 검정 4%만 덧칠.
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          animationDuration: Duration.zero,
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.04),
                    SDSColor.gray100,
                  )
                : SDSColor.gray100,
          ),
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 48)),
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
        ),
        child: Text(
          _uid == null ? '로그인' : '친구 관리 바로가기',
          style: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            height: 20 / 16,
            color: SDSColor.gray900,
          ),
        ),
      ),
    );
  }

  /// 앱 시트의 `새로고침` — 목록만 다시 받는다(시트는 닫지 않는다).
  Future<void> _reload() async {
    setState(() => _loading = true);
    await _load();
  }

  Widget _body({bool sheet = false}) {
    if (_loading) {
      // 앱 시트는 24 · 두께 4 · gray300 60%(배경 gray100), 팝업은 기존 표시 그대로.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: sheet ? 4 : 3,
              backgroundColor: sheet ? SDSColor.gray100 : null,
              color: sheet ? SDSColor.gray300.withValues(alpha: 0.6) : null,
            ),
          ),
        ),
      );
    }
    if (_uid == null) {
      return _centered('로그인하고 친구를 추가해보세요.');
    }
    if (_friends.isEmpty) {
      return _centered('친구를 등록해보세요.\n라이브중인 친구를 바로 확인할 수 있어요.');
    }
    if (sheet) {
      // 앱과 같은 4열 그리드(가로:세로 = 2:3).
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2 / 3,
        ),
        itemCount: _friends.length,
        itemBuilder: (_, i) => _tile(_friends[i], sheet: true),
      );
    }
    return SingleChildScrollView(
      child: Wrap(
        spacing: _kFriendTileGap,
        runSpacing: _kFriendTileRunGap,
        children: [for (final f in _friends) _tile(f)],
      ),
    );
  }

  Widget _centered(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Text(
      msg,
      textAlign: TextAlign.center,
      style: SDSTextStyle.regular.copyWith(
        fontSize: 14,
        color: SDSColor.gray500,
        height: 1.4,
      ),
    ),
  );

  /// 친구 타일. [sheet]면 앱 바텀시트 규격(아바타 68 · 비라이브도 gray100 1px 테두리),
  /// 아니면 팝업 규격(아바타 64 · 폭 76 고정).
  Widget _tile(FriendListModel f, {bool sheet = false}) {
    final info = f.friendInfo;
    final live = info.withinBoundary == true && info.revealWb == true;
    final slope = info.lastPassSlope ?? f.lastPassSlope;
    final passTime = info.lastPassTime ?? f.lastPassTime;
    final ago = (passTime != null && passTime.isNotEmpty)
        ? GetDatetime().getAgoString(passTime)
        : '';
    final sub = [
      if (slope != null && slope.isNotEmpty) slope,
      if (ago.isNotEmpty) ago,
    ].join(' · ');

    return SizedBox(
      // 시트는 그리드가 칸 폭을 정한다(4열) → 폭을 박지 않는다.
      width: sheet ? null : _kFriendTileWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          // 라이브 팝업은 닫지 않고, 프로필 다이얼로그를 그 위에 스택으로 띄운다.
          // (프로필 X를 눌러도 라이브중인 친구 팝업은 그대로 남는다.)
          await showFriendProfileModal(
            context,
            friendUserId: info.userId,
            initialName: info.displayName,
            initialAvatarUrl: info.profileImageUrlUser,
            initialAreWeFriend: true,
          );
        },
        child: Column(
          // 그리드 칸 높이에 맞춰 위에서부터 쌓는다(앱과 동일).
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                WebAvatar(
                  url: info.profileImageUrlUser,
                  // 앱 시트는 68, 팝업은 64.
                  size: sheet ? 68 : 64,
                  // 앱은 라이브면 파란 2px, 아니면 gray100 1px 테두리를 준다.
                  borderColor: live
                      ? SDSColor.snowliveBlue
                      : (sheet ? SDSColor.gray100 : null),
                  borderWidth: live ? 2 : (sheet ? 1 : 0),
                ),
                if (live)
                  Positioned(
                    // 앱은 아바타 아래 변에 맞춰 붙는다(팝업은 2px 내려 달았다).
                    bottom: sheet ? 0 : -2,
                    child: Image.asset(
                      'assets/imgs/icons/icon_badge_live.png',
                      width: 34,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              info.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(
                fontSize: 12,
                color: SDSColor.gray900,
              ),
            ),
            if (sub.isNotEmpty)
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 11,
                  color: SDSColor.gray500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
