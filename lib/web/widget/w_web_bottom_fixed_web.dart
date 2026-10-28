import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
///
/// ⚠️ 셸(`WebAppShell`)이 라우트 Navigator를 **감싸는** 구조라, 이 바가 있는 화면
/// 위로 다른 화면을 push하면 아래 화면이 **계속 mounted로 남아** 있다. 그래서
/// mount 여부만 보면 바가 없는 화면에서도 오픈채팅이 올라간 채로 떠 있었다 →
/// **내 라우트가 맨 위일 때만** 높이를 보고한다.
class WebBottomFixedBar extends StatefulWidget {
  final Widget child;
  final double? opaqueHeight;

  const WebBottomFixedBar({super.key, required this.child, this.opaqueHeight});

  @override
  State<WebBottomFixedBar> createState() => _WebBottomFixedBarState();
}

class _WebBottomFixedBarState extends State<WebBottomFixedBar> {
  final Object _id = Object();

  /// 내 바가 가리는 높이(라우트가 맨 위든 아니든 그대로 들고 있는 값).
  double _height = 0;

  Worker? _routeWorker;

  @override
  void initState() {
    super.initState();
    // 라우트가 바뀌어도 아래 화면은 다시 빌드되지 않는다 → 라우트 신호를 구독해
    // "내가 아직 맨 위인지"를 다시 판단한다.
    _routeWorker = ever<String>(currentRouteWeb, (_) => _syncNextFrame());
  }

  @override
  void dispose() {
    _routeWorker?.dispose();
    _registered.remove(_id);
    // 화면을 떠나는 중이라 바로 알리면 빌드 중 알림이 될 수 있다 → 다음 프레임에.
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
    super.dispose();
  }

  void _syncNextFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  /// 맵에 지금 값을 반영한다. 내 라우트가 맨 위가 아니면 **0으로 둔다** —
  /// 위에 다른 화면이 떠 있는 동안 내 바는 보이지 않으므로 가리지도 않는다.
  void _sync() {
    if (!mounted) return;
    // 라우트 밖(테스트·단독 사용)에서는 맨 위로 본다.
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final next = isCurrent ? _height : 0.0;
    if (_registered[_id] == next) return;
    _registered[_id] = next;
    _publish();
  }

  void _report(double height) {
    if (_height == height && _registered.containsKey(_id)) return;
    _height = height;
    _sync();
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
