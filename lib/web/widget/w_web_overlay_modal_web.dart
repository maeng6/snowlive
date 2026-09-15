import 'dart:async';

import 'package:flutter/material.dart';

/// 웹 팝업(모달/시트/알럿) 공통 호스트.
///
/// showDialog/showModalBottomSheet/Get.dialog는 가장 가까운 Navigator에 붙는데,
/// 이 앱은 GNB(WebAppShell)가 라우트 Navigator를 **감싸는** 구조라 그 Navigator가
/// 이미 사이드바/상단바 안쪽이다. 그래서 그 계열을 쓰면 딤이 콘텐츠 영역에서 잘리고
/// GNB만 밝게 남는다(useRootNavigator도 소용없다 — 앱의 유일한 Navigator가 셸 안이다).
///
/// main_web.dart가 셸보다 위에 깔아둔 최상위 Overlay에 엔트리를 직접 꽂아서
/// 뷰포트 전체를 덮는다. 웹의 모든 팝업은 이 함수를 거친다.
///
/// [builder]가 받는 close를 호출하면 닫히고, 그 인자가 [Future]의 결과가 된다.
/// 배경(딤) 탭으로도 닫히며, 이때 결과는 null이다.
///
/// 주의: Overlay에 직접 꽂으므로 Dialog가 주던 Material 조상이 없다. 내부에서
/// InkWell/ListTile 등 Material 위젯을 쓰려면 팝업 카드 자체를 Material로 만들 것
/// (배경색을 Container에 두고 MaterialType.transparency로 감싸면 잉크가 배경 뒤에
/// 깔려 스플래시가 안 보인다).
Future<T?> showWebOverlayModal<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, void Function([T? result]) close) builder,
  AlignmentGeometry alignment = Alignment.center,
  EdgeInsets padding = const EdgeInsets.all(24),
  Color? barrierColor,
  bool barrierDismissible = true,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final completer = Completer<T?>();
  late final OverlayEntry entry;
  var isClosed = false;

  void close([T? result]) {
    // 배경 탭과 내부 버튼 탭이 한 프레임에 겹쳐도 remove가 두 번 불리지 않게 막는다.
    if (isClosed) return;
    isClosed = true;
    entry.remove();
    completer.complete(result);
  }

  entry = OverlayEntry(
    builder: (entryContext) => _ModalOpenTransition(
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      alignment: alignment,
      padding: padding,
      onBarrierTap: barrierDismissible ? close : null,
      child: GestureDetector(
        // 팝업 본체 탭이 배경으로 전파돼 닫히는 걸 막는다.
        onTap: () {},
        child: builder(entryContext, close),
      ),
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

/// 딤 모달/시트 열림 애니메이션. OverlayEntry는 라우트 전환이 없어서 팝업이 툭
/// 나타났다 — 딤은 페이드인, 패널은 하단 정렬(모바일 시트)이면 아래에서
/// 슬라이드업+페이드, 그 외(중앙 모달)는 페이드+미세 스케일. 닫힘은 기존처럼
/// 즉시(remove) — 선택/닫기 반응이 굼떠 보이지 않게(드롭다운과 동일 결정).
class _ModalOpenTransition extends StatefulWidget {
  final Color barrierColor;
  final AlignmentGeometry alignment;
  final EdgeInsets padding;
  final VoidCallback? onBarrierTap;
  final Widget child;

  const _ModalOpenTransition({
    required this.barrierColor,
    required this.alignment,
    required this.padding,
    required this.onBarrierTap,
    required this.child,
  });

  @override
  State<_ModalOpenTransition> createState() => _ModalOpenTransitionState();
}

class _ModalOpenTransitionState extends State<_ModalOpenTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    // 드롭다운(220ms)보다 느리게 — 면적이 큰 팝업은 더 길어야 자연스럽다
    // (220은 너무 빠르다는 피드백, 2026-09-16).
    duration: const Duration(milliseconds: 320),
  )..forward();
  late final Animation<double> _t =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool fromBottom = widget.alignment == Alignment.bottomCenter;

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onBarrierTap,
        child: AnimatedBuilder(
          animation: _t,
          builder: (context, child) {
            final double t = _t.value;
            return Container(
              // 딤은 투명 → 지정 농도로 페이드인.
              color: Color.lerp(
                  widget.barrierColor.withAlpha(0), widget.barrierColor, t),
              alignment: widget.alignment,
              padding: widget.padding,
              child: Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: fromBottom
                    // 하단 시트: 32px 아래에서 슬라이드업.
                    ? Transform.translate(
                        offset: Offset(0, (1 - t) * 32), child: child)
                    // 중앙 모달: 97% → 100% 미세 스케일.
                    : Transform.scale(scale: 0.97 + 0.03 * t, child: child),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// 호출한 위젯 바로 아래에 붙는 드롭다운(데스크탑 필터 등).
///
/// 모달과 달리 **딤을 깔지 않는다** — 화면 일부를 잠깐 덮는 앵커형 UI라서 뒤를
/// 가릴 이유가 없다. 바깥 아무 곳이나 탭하면 닫힌다.
///
/// [link]는 앵커 위젯을 감싼 CompositedTransformTarget의 것. LayerLink로 따라가게
/// 해야 드롭다운이 열린 채로 페이지가 스크롤돼도 앵커에 계속 붙어 있는다.
/// [context]는 앵커 위젯의 컨텍스트여야 한다(위치/폭 계산에 RenderBox를 쓴다).
Future<T?> showWebAnchoredDropdown<T>({
  required BuildContext context,
  required LayerLink link,
  required Widget Function(BuildContext context, void Function([T? result]) close, double anchorWidth) builder,
  double gap = 8,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final overlayBox = overlay.context.findRenderObject() as RenderBox;
  final anchorBox = context.findRenderObject() as RenderBox;
  final anchorOffset = anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox);
  final anchorLeft = anchorOffset.dx;

  // 오른쪽 끝에 가까운 앵커는 왼쪽 정렬하면 패널이 화면 밖으로 나간다 → 오른쪽 정렬.
  final alignRight = overlayBox.size.width - anchorLeft < _kAnchoredDropdownMinSpace;

  // 아래로 펼칠 자리가 부족하면 **위로 뒤집는다**. 항목이 많은 드롭다운(예: 스키장 13개)이
  // 아래로만 펼쳐지면 뷰포트 밖으로 나가 잘려 보였다(실측).
  final spaceBelow =
      overlayBox.size.height - (anchorOffset.dy + anchorBox.size.height) - gap - _kAnchoredDropdownEdgeMargin;
  final spaceAbove = anchorOffset.dy - gap - _kAnchoredDropdownEdgeMargin;
  final flipUp = spaceBelow < _kAnchoredDropdownMinHeight && spaceAbove > spaceBelow;
  // 남은 높이를 그대로 최대 높이로 물려준다 → 패널 내부 스크롤이 살아난다.
  final maxHeight = (flipUp ? spaceAbove : spaceBelow).clamp(120.0, double.infinity);

  final completer = Completer<T?>();
  late final OverlayEntry entry;
  var isClosed = false;

  void close([T? result]) {
    if (isClosed) return;
    isClosed = true;
    entry.remove();
    completer.complete(result);
  }

  entry = OverlayEntry(
    builder: (entryContext) => Stack(
      children: [
        // 딤은 없지만 바깥 탭은 받아야 하므로 투명 히트 영역을 전면에 깐다.
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: close),
        ),
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: flipUp
              ? (alignRight ? Alignment.topRight : Alignment.topLeft)
              : (alignRight ? Alignment.bottomRight : Alignment.bottomLeft),
          followerAnchor: flipUp
              ? (alignRight ? Alignment.bottomRight : Alignment.bottomLeft)
              : (alignRight ? Alignment.topRight : Alignment.topLeft),
          offset: Offset(0, flipUp ? -gap : gap),
          child: Align(
            alignment: alignRight ? Alignment.topRight : Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: _DropdownOpenReveal(
                // 위로 뒤집혀 뜰 때는 앵커 쪽(아래 모서리)에서 위로 펼쳐진다.
                fromBottom: flipUp,
                child: builder(entryContext, close, anchorBox.size.width),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

/// 앵커 드롭다운이 열릴 때 흰 박스의 **높이가 실제로 자라나며** 펼쳐지는 애니메이션.
/// OverlayEntry는 라우트 전환 애니메이션이 없어서 패널이 툭 나타났다 —
/// 여기서 한 번 감싸면 showWebAnchoredDropdown을 쓰는 모든 곳에 공통 적용된다.
/// 닫힘은 기존처럼 즉시(remove) — 바깥 탭/선택 반응이 굼떠 보이지 않게.
///
/// 구현: 첫 프레임에 패널을 투명하게 레이아웃해 최종 높이를 실측한 뒤,
/// maxHeight 제약을 0→실측값으로 키운다. 패널이 매 프레임 그 높이로 다시
/// 레이아웃되므로 보더·라운드·그림자가 항상 현재 크기에 맞게 그려진다.
/// (ClipRect 리빌은 그림자가 잘리고, 스케일은 내용이 눌렸다 펴진다 — 둘 다 기각)
class _DropdownOpenReveal extends StatefulWidget {
  /// true면 아래 모서리 고정(위로 뒤집힌 패널) — 아래→위로 펼쳐진다.
  /// 앵커 고정은 CompositedTransformFollower의 followerAnchor가 담당하므로
  /// 여기서는 높이만 키우면 방향은 자동으로 맞는다.
  final bool fromBottom;
  final Widget child;

  const _DropdownOpenReveal({required this.fromBottom, required this.child});

  @override
  State<_DropdownOpenReveal> createState() => _DropdownOpenRevealState();
}

class _DropdownOpenRevealState extends State<_DropdownOpenReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

  final GlobalKey _contentKey = GlobalKey();

  /// 측정 전 null. 측정 후 애니메이션의 목표 높이.
  double? _fullHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      setState(() => _fullHeight = box.size.height);
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // KeyedSubtree로 패널 서브트리를 유지한다 — 측정 프레임 → 애니메이션 프레임
    // 전환에서 패널이 다시 마운트되면 내부 항목들의 순차 페이드가 초기화된다.
    final content = KeyedSubtree(key: _contentKey, child: widget.child);

    // 측정 프레임: 최종 크기로 레이아웃만 시키고 그리지는 않는다.
    if (_fullHeight == null) {
      return Visibility(
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: content,
      );
    }

    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: _fullHeight! * _t.value),
        child: child,
      ),
      child: content,
    );
  }
}

/// 이 폭이 안 나오면 앵커 오른쪽에 패널을 펼칠 자리가 없다고 보고 오른쪽 정렬로 뒤집는다.
const double _kAnchoredDropdownMinSpace = 220;

/// 아래로 이만큼도 못 펼치면 위로 뒤집는다.
const double _kAnchoredDropdownMinHeight = 220;

/// 뷰포트 끝에 딱 붙지 않도록 남겨두는 여백.
const double _kAnchoredDropdownEdgeMargin = 12;
