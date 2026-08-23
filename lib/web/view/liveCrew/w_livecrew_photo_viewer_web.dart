import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 사진 아래 정보 바 높이.
const double _kBarHeight = 60;

/// 카드 최대 폭(목업 실측 820).
const double _kMaxCardWidth = 820;

/// 크루 갤러리 사진 라이트박스.
///
/// 공용 [showWebImageViewer]를 쓰지 않는다 — 그쪽은 타이틀 바·줌 컨트롤·썸네일 스트립이
/// 레이아웃의 골격이고 이미 4개 화면이 의존한다. 목업은 "사진 + 흰 정보 바 + 카드 밖
/// 원형 버튼"이라 구조가 달라서, 딤·루트 Overlay만 [showWebOverlayModal]에서 빌려온다.
Future<void> showLiveCrewPhotoViewer(
  BuildContext context, {
  required List<LiveTalk> talks,
  required int initialIndex,
  required Map<int, CrewCard> crewIndex,
  required void Function(LiveTalk talk) onOpenLiveTalk,
  required Future<void> Function(LiveTalk talk, WebMoreAction action) onMoreAction,
}) {
  if (talks.isEmpty) return Future.value();
  return showWebOverlayModal<void>(
    context: context,
    padding: EdgeInsets.symmetric(
      horizontal: context.screenType == WebScreenType.mobile ? 12 : 40,
      vertical: 32,
    ),
    builder: (_, close) => _CrewPhotoViewer(
      talks: talks,
      initialIndex: initialIndex.clamp(0, talks.length - 1),
      crewIndex: crewIndex,
      onOpenLiveTalk: onOpenLiveTalk,
      onMoreAction: onMoreAction,
      onClose: close,
    ),
  );
}

class _CrewPhotoViewer extends StatefulWidget {
  final List<LiveTalk> talks;
  final int initialIndex;
  final Map<int, CrewCard> crewIndex;
  final void Function(LiveTalk talk) onOpenLiveTalk;
  final Future<void> Function(LiveTalk talk, WebMoreAction action) onMoreAction;
  final void Function([void result]) onClose;

  const _CrewPhotoViewer({
    required this.talks,
    required this.initialIndex,
    required this.crewIndex,
    required this.onOpenLiveTalk,
    required this.onMoreAction,
    required this.onClose,
  });

  @override
  State<_CrewPhotoViewer> createState() => _CrewPhotoViewerState();
}

class _CrewPhotoViewerState extends State<_CrewPhotoViewer> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.talks.length) return;
    setState(() => _index = index);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onClose();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _goTo(_index - 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _goTo(_index + 1);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final talk = widget.talks[_index];

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 버튼 열이 카드 밖 우측에 서므로 그만큼 폭을 비워둔다(모바일은 겹쳐 놓는다).
          final reserved = isMobile ? 0.0 : 52.0;
          final cardWidth = math.min(_kMaxCardWidth, constraints.maxWidth - reserved);
          final imageSize = math.max(
            160.0,
            math.min(cardWidth, constraints.maxHeight - _kBarHeight),
          );
          final card = _buildCard(talk, width: cardWidth, imageHeight: imageSize);

          if (isMobile) {
            return Stack(
              children: [
                card,
                Positioned(
                  top: SDSSpacing.sm,
                  right: SDSSpacing.sm,
                  child: Row(children: _buildActions(talk, gap: SDSSpacing.sm)),
                ),
              ],
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              card,
              const SizedBox(width: 12),
              Column(children: _buildActions(talk, gap: SDSSpacing.sm, vertical: true)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(LiveTalk talk, {required double gap, bool vertical = false}) {
    return [
      _CircleIconButton(icon: Icons.close, onTap: widget.onClose),
      SizedBox(width: vertical ? 0 : gap, height: vertical ? gap : 0),
      _CircleMoreButton(onSelected: (action) => widget.onMoreAction(talk, action)),
    ];
  }

  Widget _buildCard(LiveTalk talk, {required double width, required double imageHeight}) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width,
              height: imageHeight,
              color: SDSColor.gray50,
              // 사진 비율이 제각각이라 잘라내지 않고 맞춰 넣는다.
              child: WebNetworkImage(
                url: talk.imageUrl,
                width: width,
                height: imageHeight,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
            _buildInfoBar(talk),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar(LiveTalk talk) {
    final crewId = talk.crewId;
    final crew = crewId == null ? null : widget.crewIndex[crewId];
    final logoUrl = crewLogoUrlOf(logoUrl: crew?.crewLogoUrl, color: crew?.color);
    // 크루홈 응답 어느 리스트에도 없는 크루면(순위권 밖) 작성자 닉네임으로 대체한다.
    final title = crew?.crewName ?? talk.userInfo?.displayName ?? '';
    final time = talk.uploadTime != null ? GetDatetime().getAgoString(talk.uploadTime!) : '';
    final nick = crew?.baseResortNickname?.trim() ?? '';
    final sub = [if (nick.isNotEmpty) nick, if (time.isNotEmpty) time].join(' ');

    return Container(
      height: _kBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: SDSColor.gray100),
            ),
            clipBehavior: Clip.antiAlias,
            child: (logoUrl?.isNotEmpty ?? false)
                ? WebNetworkImage(url: logoUrl, width: 28, height: 28)
                : Container(color: SDSColor.gray100),
          ),
          const SizedBox(width: SDSSpacing.sm),
          // 크루명과 `리조트 N시간 전`을 **한 Text로** 묶는다. Flexible 두 개 + Spacer로
          // 짜면 남은 폭을 서로 나눠 가져서 좁은 화면에서 크루명이 통째로 사라진다(실측).
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                  ),
                  if (sub.isNotEmpty)
                    TextSpan(
                      text: '  $sub',
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: SDSSpacing.sm),
          // 크루 사진은 곧 라이브톡 게시글이라 항상 갈 곳이 있다.
          InkWell(
            onTap: () => widget.onOpenLiveTalk(talk),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: [
                  Text(
                    '라이브톡에서 보기',
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: SDSColor.gray400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: SDSColor.gray700),
        ),
      ),
    );
  }
}

/// ⋯ 원형 버튼. 공용 [WebMoreButton]은 SVG 아이콘만 그려서 흰 원 모양이 안 나오므로
/// 앵커 링크 + [showWebFilterMenu](데스크탑 드롭다운 / 좁은 폭 시트 분기)만 같은 방식으로 쓴다.
class _CircleMoreButton extends StatefulWidget {
  final ValueChanged<WebMoreAction> onSelected;

  const _CircleMoreButton({required this.onSelected});

  @override
  State<_CircleMoreButton> createState() => _CircleMoreButtonState();
}

class _CircleMoreButtonState extends State<_CircleMoreButton> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final selected = await showWebFilterMenu<WebMoreAction>(
      context: context,
      link: _link,
      values: const [WebMoreAction.reportPost, WebMoreAction.hideUser],
      labelOf: (a) => a.label,
      centerSheetOnTablet: true,
    );
    if (selected == null) return;
    widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: _CircleIconButton(icon: Icons.more_horiz, onTap: _open),
    );
  }
}
