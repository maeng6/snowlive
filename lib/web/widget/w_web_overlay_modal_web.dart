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
    builder: (entryContext) => Positioned.fill(
      child: GestureDetector(
        onTap: barrierDismissible ? close : null,
        child: Container(
          color: barrierColor ?? Colors.black.withOpacity(0.5),
          alignment: alignment,
          padding: padding,
          child: GestureDetector(
            // 팝업 본체 탭이 배경으로 전파돼 닫히는 걸 막는다.
            onTap: () {},
            child: builder(entryContext, close),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  return completer.future;
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
              child: builder(entryContext, close, anchorBox.size.width),
            ),
          ),
        ),
      ],
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

/// 이 폭이 안 나오면 앵커 오른쪽에 패널을 펼칠 자리가 없다고 보고 오른쪽 정렬로 뒤집는다.
const double _kAnchoredDropdownMinSpace = 220;

/// 아래로 이만큼도 못 펼치면 위로 뒤집는다.
const double _kAnchoredDropdownMinHeight = 220;

/// 뷰포트 끝에 딱 붙지 않도록 남겨두는 여백.
const double _kAnchoredDropdownEdgeMargin = 12;
