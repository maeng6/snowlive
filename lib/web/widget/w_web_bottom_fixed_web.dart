import 'package:flutter/material.dart';

/// 화면 하단에 고정된 UI(플로팅 바 · 입력창)가 **지금 얼마나 가리고 있는지**.
///
/// 셸의 오픈채팅은 모든 페이지 위에 떠 있어서, 하단 고정 UI가 있는 화면에서는
/// 보내기 버튼 같은 것을 덮어 버린다 → 그런 화면에서는 이 값만큼 위로 비켜선다.
/// 화면 쪽은 하단 고정 UI를 [WebBottomFixedBar]로 감싸기만 하면 된다.
final ValueNotifier<double> webBottomFixedInset = ValueNotifier<double>(0);

/// 등록된 하단 UI들의 높이. 여러 개가 겹쳐 있으면 가장 높은 것을 쓴다
/// (한 화면에 둘이 동시에 뜨는 경우는 없지만, 화면 전환 중 잠깐 겹칠 수 있다).
final Map<Object, double> _registered = {};

void _publish() {
  final next = _registered.values.fold<double>(0, (a, b) => a > b ? a : b);
  if (next != webBottomFixedInset.value) webBottomFixedInset.value = next;
}

/// 하단 고정 UI를 감싸 **가리는 높이를 셸에 알린다**.
///
/// [opaqueHeight]를 주면 그 값을, 비우면 감싼 위젯의 실제 높이를 쓴다.
/// 위쪽이 투명한 페이드 구간을 가진 바(`WebFloatingBottomBar`)는 콘텐츠가
/// 비쳐 보이므로 **불투명한 구간만** 값으로 넘긴다.
class WebBottomFixedBar extends StatefulWidget {
  final Widget child;
  final double? opaqueHeight;

  const WebBottomFixedBar({super.key, required this.child, this.opaqueHeight});

  @override
  State<WebBottomFixedBar> createState() => _WebBottomFixedBarState();
}

class _WebBottomFixedBarState extends State<WebBottomFixedBar> {
  final Object _id = Object();

  @override
  void dispose() {
    _registered.remove(_id);
    // 화면을 떠나는 중이라 바로 알리면 빌드 중 알림이 될 수 있다 → 다음 프레임에.
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
    super.dispose();
  }

  void _report(double height) {
    if (_registered[_id] == height) return;
    _registered[_id] = height;
    _publish();
  }

  @override
  Widget build(BuildContext context) {
    final fixed = widget.opaqueHeight;
    if (fixed != null) {
      // 값이 정해져 있으면 재지 않는다(페이드가 섞인 바).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _report(fixed);
      });
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final box = context.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) _report(box.size.height);
        });
        return widget.child;
      },
    );
  }
}
