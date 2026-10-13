import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/location/vm_liveMap_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 친구 실시간 위치 지도(유료). 상호 수락 친구들의 좌표를 5초마다 폴링해 표시.
class LiveMapViewWeb extends StatelessWidget {
  const LiveMapViewWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<LiveMapViewModelWeb>();
    return Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // push로 진입했으면(시즌권 홈 바로가기 등) 뒤로가기로 복귀한다.
                if (Navigator.of(context).canPop()) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: WebIconButton(
                      onTap: Get.back,
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      icon: const WebBackIcon(size: 24),
                    ),
                  ),
                  const SizedBox(height: SDSSpacing.sm),
                ],
                Text('친구 실시간 위치',
                    style: SDSTextStyle.extraBold
                        .copyWith(fontSize: 22, color: SDSColor.gray900)),
                const SizedBox(height: SDSSpacing.lg),
                Obx(() {
                  if (!vm.isPaid.value) return _lockedCard();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (vm.incoming.isNotEmpty) _incomingCard(vm),
                      _mapCard(vm),
                      const SizedBox(height: SDSSpacing.md),
                      _acceptedCard(vm),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: SDSSpacing.md),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          border: Border.all(color: SDSColor.gray200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _title(String t) =>
      Text(t, style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900));

  Widget _lockedCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title('프리미엄 전용'),
            const SizedBox(height: SDSSpacing.sm),
            Text('친구 실시간 위치 공유는 시즌권 이용 중일 때, 서로 수락한 친구끼리 사용할 수 있어요.',
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 14, color: SDSColor.gray600)),
            const SizedBox(height: SDSSpacing.lg),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(WebRoutes.seasonPass),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SDSColor.snowliveBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('시즌권 보기',
                    style: SDSTextStyle.bold
                        .copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
              ),
            ),
          ],
        ),
      );

  Widget _incomingCard(LiveMapViewModelWeb vm) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('받은 위치공유 신청'),
            const SizedBox(height: SDSSpacing.sm),
            ...vm.incoming.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${f['display_name'] ?? ''}',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 14, color: SDSColor.gray900)),
                      ),
                      TextButton(
                        onPressed: () =>
                            vm.acceptRequest((f['user_id'] as num).toInt()),
                        child: Text('수락',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 13, color: SDSColor.snowliveBlue)),
                      ),
                      TextButton(
                        onPressed: () =>
                            vm.revoke((f['user_id'] as num).toInt()),
                        child: Text('거절',
                            style: SDSTextStyle.regular
                                .copyWith(fontSize: 13, color: SDSColor.gray500)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      );

  Widget _mapCard(LiveMapViewModelWeb vm) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title('실시간 위치'),
            const SizedBox(height: SDSSpacing.sm),
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Obx(() => CustomPaint(
                      painter: _PositionsPainter(
                          vm.friendsOnMap.toList(growable: false)),
                      child: vm.friendsOnMap.isEmpty
                          ? Center(
                              child: Text('공유 중인 친구 위치가 없어요.',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 13, color: SDSColor.gray400)),
                            )
                          : null,
                    )),
              ),
            ),
          ],
        ),
      );

  Widget _acceptedCard(LiveMapViewModelWeb vm) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('공유 중인 친구'),
            const SizedBox(height: SDSSpacing.sm),
            Obx(() {
              if (vm.accepted.isEmpty) {
                return Text('아직 서로 수락한 친구가 없어요.',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 13, color: SDSColor.gray500));
              }
              // 지도 좌표의 seconds_ago를 user_id로 매핑
              final agoByUid = <int, dynamic>{};
              for (final f in vm.friendsOnMap) {
                agoByUid[(f['user_id'] as num).toInt()] = f['seconds_ago'];
              }
              return Column(
                children: vm.accepted.map((f) {
                  final uid = (f['user_id'] as num).toInt();
                  final ago = agoByUid[uid];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${f['display_name'] ?? ''}',
                              style: SDSTextStyle.bold.copyWith(
                                  fontSize: 14, color: SDSColor.gray900)),
                        ),
                        Text(_agoText(ago),
                            style: SDSTextStyle.regular.copyWith(
                                fontSize: 12, color: SDSColor.gray500)),
                        TextButton(
                          onPressed: () => vm.revoke(uid),
                          child: Text('해제',
                              style: SDSTextStyle.regular
                                  .copyWith(fontSize: 13, color: SDSColor.red)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      );

  String _agoText(dynamic secondsAgo) {
    if (secondsAgo is! num) return '위치 없음';
    final s = secondsAgo.toInt();
    if (s < 60) return '$s초 전';
    final m = (s / 60).floor();
    if (m < 60) return '$m분 전';
    return '${(m / 60).floor()}시간 전';
  }
}

/// 친구들의 경위도를 뷰 bbox에 투영해 마커로 찍는다(간이 지도).
class _PositionsPainter extends CustomPainter {
  final List<Map<String, dynamic>> friends;
  _PositionsPainter(this.friends);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF0B1220));
    final pts = <List<double>>[];
    for (final f in friends) {
      final c = f['coordinates'];
      if (c is List && c.length >= 2 && c[0] is num && c[1] is num) {
        pts.add([(c[0] as num).toDouble(), (c[1] as num).toDouble()]);
      }
    }
    if (pts.isEmpty) return;
    double minX = pts.first[0], maxX = pts.first[0];
    double minY = pts.first[1], maxY = pts.first[1];
    for (final p in pts) {
      if (p[0] < minX) minX = p[0];
      if (p[0] > maxX) maxX = p[0];
      if (p[1] < minY) minY = p[1];
      if (p[1] > maxY) maxY = p[1];
    }
    final spanX = (maxX - minX) == 0 ? 1e-6 : (maxX - minX);
    final spanY = (maxY - minY) == 0 ? 1e-6 : (maxY - minY);
    const pad = 36.0;
    for (final f in friends) {
      final c = f['coordinates'];
      if (c is! List || c.length < 2 || c[0] is! num || c[1] is! num) continue;
      final lng = (c[0] as num).toDouble();
      final lat = (c[1] as num).toDouble();
      final x = pad + (lng - minX) / spanX * (size.width - 2 * pad);
      // 위도는 위가 북쪽 → 화면 위로
      final y = size.height - pad - (lat - minY) / spanY * (size.height - 2 * pad);
      final riding = f['is_riding'] == true;
      canvas.drawCircle(Offset(x, y), 7,
          Paint()..color = riding ? const Color(0xFF3D83ED) : const Color(0xFF94A3B8));
      canvas.drawCircle(Offset(x, y), 7,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      final name = '${f['display_name'] ?? ''}';
      final tp = TextPainter(
        text: TextSpan(
            text: name,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontFamily: 'Pretendard')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y + 10));
    }
  }

  @override
  bool shouldRepaint(covariant _PositionsPainter old) => old.friends != friends;
}
