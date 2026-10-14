import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/mobile/test_polygon/slope_geometry.dart';
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
            // 리조트 칩 — 친구가 2개 이상 스키장에 흩어져 있을 때만.
            Obx(() {
              final groups = vm.resortGroups;
              if (groups.length < 2) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final g = groups[i];
                      final rid = g['resort_id'] as int;
                      final sel = rid == vm.selectedResortId.value;
                      return GestureDetector(
                        onTap: () => vm.selectResort(rid),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sel ? SDSColor.snowliveBlue : SDSColor.gray100,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('${g['resort_name']} ${g['count']}',
                              style: SDSTextStyle.bold.copyWith(
                                  fontSize: 13,
                                  color: sel
                                      ? SDSColor.snowliveWhite
                                      : SDSColor.gray700)),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Obx(() {
                  final here = vm.friendsInSelectedResort;
                  final hasGroups = vm.resortGroups.isNotEmpty;
                  return CustomPaint(
                    painter: _ResortMapPainter(
                        vm.slopesForSelected.toList(growable: false), here),
                    child: here.isEmpty
                        ? Center(
                            child: Text(
                                hasGroups
                                    ? '이 스키장에 표시할 친구가 없어요.'
                                    : '라이딩 중인 친구가 없어요.',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 13, color: SDSColor.gray400)),
                          )
                        : null,
                  );
                }),
              ),
            ),
            Obx(() {
              final n = vm.outsideCount;
              if (n == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: SDSSpacing.sm),
                child: Text('스키장 밖 · $n명',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 12, color: SDSColor.gray500)),
              );
            }),
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

/// 선택 리조트의 슬로프 폴리곤을 배경으로 깔고, 그 위에 친구 점을 같은 투영으로 올린다.
/// 투영: 위경도 → 등거리 미터 → 단일 배율(종횡비 유지) 센터핏 (앱/궤적 렌더러와 동일).
class _ResortMapPainter extends CustomPainter {
  final List<SlopePoly> slopes;
  final List<Map<String, dynamic>> friends;
  _ResortMapPainter(this.slopes, this.friends);

  static const _bg = Color(0xFF0B1220);
  static const _poly = Color(0xFF94A3B8);
  static const _axis = Color(0xFF334155);
  static const _riding = Color(0xFF3D83ED);
  static const _idle = Color(0xFF94A3B8);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = _bg);

    final geo = <GeoPt>[];
    for (final s in slopes) {
      geo.addAll(s.ring);
    }
    for (final f in friends) {
      final c = f['coordinates'];
      if (c is List && c.length >= 2 && c[0] is num && c[1] is num) {
        geo.add(GeoPt((c[1] as num).toDouble(), (c[0] as num).toDouble()));
      }
    }
    if (geo.isEmpty) return;

    final refLat = geo.map((p) => p.lat).reduce((a, b) => a + b) / geo.length;
    const mPerLat = 111320.0;
    final mPerLng = 111320.0 * math.cos(refLat * math.pi / 180);
    double mx(GeoPt p) => p.lng * mPerLng;
    double my(GeoPt p) => p.lat * mPerLat;

    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (final p in geo) {
      final x = mx(p), y = my(p);
      minX = math.min(minX, x);
      maxX = math.max(maxX, x);
      minY = math.min(minY, y);
      maxY = math.max(maxY, y);
    }
    final w = (maxX - minX).abs() < 1e-6 ? 1.0 : (maxX - minX);
    final h = (maxY - minY).abs() < 1e-6 ? 1.0 : (maxY - minY);
    final scale = math.min(size.width / w, size.height / h) * 0.86;
    final midX = (minX + maxX) / 2, midY = (minY + maxY) / 2;
    Offset toXY(GeoPt p) => Offset(
          size.width / 2 + (mx(p) - midX) * scale,
          size.height / 2 - (my(p) - midY) * scale,
        );

    final fill = Paint()
      ..color = _poly.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = _poly.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final axisPaint = Paint()
      ..color = _axis
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final s in slopes) {
      if (s.ring.length < 3) continue;
      final path = Path()..moveTo(toXY(s.ring.first).dx, toXY(s.ring.first).dy);
      for (int i = 1; i < s.ring.length; i++) {
        final o = toXY(s.ring[i]);
        path.lineTo(o.dx, o.dy);
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      if (s.axis.length >= 2) {
        final ap = Path()..moveTo(toXY(s.axis.first).dx, toXY(s.axis.first).dy);
        for (int i = 1; i < s.axis.length; i++) {
          final o = toXY(s.axis[i]);
          ap.lineTo(o.dx, o.dy);
        }
        canvas.drawPath(ap, axisPaint);
      }
    }

    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final f in friends) {
      final c = f['coordinates'];
      if (c is! List || c.length < 2 || c[0] is! num || c[1] is! num) continue;
      final o = toXY(GeoPt((c[1] as num).toDouble(), (c[0] as num).toDouble()));
      final riding = f['is_riding'] == true;
      canvas.drawCircle(o, 7, Paint()..color = riding ? _riding : _idle);
      canvas.drawCircle(o, 7, white);
      final tp = TextPainter(
        text: TextSpan(
            text: '${f['display_name'] ?? ''}',
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontFamily: 'Pretendard')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy + 10));
    }
  }

  @override
  bool shouldRepaint(covariant _ResortMapPainter old) =>
      old.friends != friends || old.slopes != slopes;
}
