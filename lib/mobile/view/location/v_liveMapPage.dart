import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:com.snowlive/core/api/api_locationShare.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/mobile/test_polygon/slope_geometry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// 모바일 친구 실시간 위치 지도(유료) 전체 페이지.
/// (현재는 친구 바텀시트의 '실시간 위치' 탭이 [LiveMapPanel]을 직접 쓴다.)
class LiveMapPage extends StatelessWidget {
  const LiveMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: SDSColor.gray900),
        title: Text('친구 실시간 위치',
            style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
      ),
      body: const LiveMapPanel(),
    );
  }
}

/// 친구 실시간 위치 본문(Scaffold/AppBar 없음) — 바텀시트 탭·전체 페이지 공용.
/// 상호 수락 친구 좌표를 5초마다 폴링. 친구들이 서로 다른 스키장에 있으면 리조트 칩으로
/// 그룹핑하고, 선택한 리조트의 슬로프 폴리곤 지도 위에 친구 점을 올린다.
class LiveMapPanel extends StatefulWidget {
  const LiveMapPanel({super.key});

  @override
  State<LiveMapPanel> createState() => _LiveMapPanelState();
}

class _LiveMapPanelState extends State<LiveMapPanel> {
  static const String _apiHost = 'https://snowlive-api-c617725e2b78.herokuapp.com';

  final LocationShareAPI _api = LocationShareAPI();
  Timer? _poll;
  bool _isPaid = false;
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _incoming = [];
  List<Map<String, dynamic>> _friends = [];

  int? _selectedResortId;                     // 현재 보고 있는 스키장
  final Map<int, List<SlopePoly>> _slopeCache = {}; // resortId → 슬로프 폴리곤
  bool _loadingSlopes = false;

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user.user_id;
    return (id is int) ? id : int.tryParse('$id');
  }

  @override
  void initState() {
    super.initState();
    _loadShares();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _loadMap());
    _loadMap();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> _asList(dynamic v) =>
      v is List ? v.map((e) => Map<String, dynamic>.from(e)).toList() : [];

  Future<void> _loadShares() async {
    final uid = _uid;
    if (uid == null) return;
    final res = await _api.list(userId: uid);
    if (!mounted) return;
    if (res.success && res.data is Map) {
      setState(() {
        _isPaid = res.data['is_paid'] == true;
        _accepted = _asList(res.data['accepted']);
        _incoming = _asList(res.data['incoming']);
      });
    }
  }

  Future<void> _loadMap() async {
    final uid = _uid;
    if (uid == null) return;
    final res = await _api.map(userId: uid);
    if (!mounted) return;
    if (res.success && res.data is Map && res.data['friends'] is List) {
      setState(() => _friends = _asList(res.data['friends']));
      _ensureResortSelection();
    }
  }

  /// 친구가 올라와 있는 리조트들(인원수 내림차순).
  List<_ResortGroup> get _resortGroups {
    final map = <int, _ResortGroup>{};
    for (final f in _friends) {
      final rid = (f['resort_id'] as num?)?.toInt();
      if (rid == null) continue;
      final g = map.putIfAbsent(
          rid, () => _ResortGroup(rid, (f['resort_name'] ?? '스키장').toString()));
      g.count++;
    }
    final list = map.values.toList()..sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  /// 선택 리조트가 비거나 사라졌으면 가장 친구 많은 리조트로 자동 선택 + 슬로프 로드.
  void _ensureResortSelection() {
    final groups = _resortGroups;
    if (groups.isEmpty) {
      _selectedResortId = null;
      return;
    }
    final stillThere = groups.any((g) => g.resortId == _selectedResortId);
    if (!stillThere) {
      _selectedResortId = groups.first.resortId;
    }
    _loadSlopes(_selectedResortId!);
  }

  Future<void> _loadSlopes(int resortId) async {
    if (_slopeCache.containsKey(resortId) || _loadingSlopes) return;
    _loadingSlopes = true;
    try {
      final r = await http
          .get(Uri.parse('$_apiHost/api/resort/slopes-2627/?resort=$resortId'));
      final data = json.decode(utf8.decode(r.bodyBytes));
      final slopes = (data['slopes'] as List)
          .map((j) => SlopePoly.fromJson(j as Map<String, dynamic>))
          .where((s) => s.hasPolygon)
          .toList();
      _slopeCache[resortId] = slopes;
    } catch (_) {
      _slopeCache[resortId] = [];
    } finally {
      _loadingSlopes = false;
      if (mounted) setState(() {});
    }
  }

  void _selectResort(int rid) {
    setState(() => _selectedResortId = rid);
    _loadSlopes(rid);
  }

  Future<void> _accept(int fid) async {
    final uid = _uid;
    if (uid == null) return;
    await _api.accept(userId: uid, friendUserId: fid);
    await _loadShares();
    await _loadMap();
  }

  Future<void> _revoke(int fid) async {
    final uid = _uid;
    if (uid == null) return;
    await _api.revoke(userId: uid, friendUserId: fid);
    await _loadShares();
    await _loadMap();
  }

  String _ago(dynamic s) {
    if (s is! num) return '위치 없음';
    final v = s.toInt();
    if (v < 60) return '$v초 전';
    if (v < 3600) return '${(v / 60).floor()}분 전';
    return '${(v / 3600).floor()}시간 전';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPaid) {
      return Container(
        color: SDSColor.snowliveWhite,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('실시간 위치 공유는 시즌권 이용 중일 때, 서로 수락한 친구끼리 사용할 수 있어요.',
              style: SDSTextStyle.regular
                  .copyWith(fontSize: 14, color: SDSColor.gray600)),
        ),
      );
    }

    final groups = _resortGroups;
    final selected = _selectedResortId;
    final slopes = (selected != null) ? (_slopeCache[selected] ?? const []) : const [];
    // 선택 리조트에 있는 친구만 지도에 올린다.
    final friendsHere = _friends.where((f) {
      final rid = (f['resort_id'] as num?)?.toInt();
      return selected != null && rid == selected;
    }).toList();
    // 스키장 밖(resort 미상/세션 아님) 친구 수.
    final outside = _friends.where((f) => (f['resort_id'] as num?) == null).length;

    return Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_incoming.isNotEmpty) ...[
              _title('받은 위치공유 신청'),
              ..._incoming.map((f) => _incomingRow(f)),
              const SizedBox(height: 12),
            ],
            _title('실시간 위치'),
            const SizedBox(height: 8),
            // 리조트 칩 — 친구가 2개 이상 스키장에 흩어져 있을 때만 노출.
            if (groups.length > 1) ...[
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _resortChip(groups[i]),
                ),
              ),
              const SizedBox(height: 10),
            ],
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: _ResortLiveMapPainter(
                      slopes.cast<SlopePoly>(), friendsHere),
                  child: friendsHere.isEmpty
                      ? Center(
                          child: Text(
                              groups.isEmpty
                                  ? '라이딩 중인 친구가 없어요.'
                                  : '이 스키장에 표시할 친구가 없어요.',
                              style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13, color: SDSColor.gray400)))
                      : null,
                ),
              ),
            ),
            if (outside > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('스키장 밖 · $outside명',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 12, color: SDSColor.gray500)),
              ),
            const SizedBox(height: 16),
            _title('공유 중인 친구'),
            if (_accepted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('아직 서로 수락한 친구가 없어요.',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 13, color: SDSColor.gray500)),
              ),
            ..._accepted.map((f) => _acceptedRow(f)),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) =>
      Text(t, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900));

  Widget _resortChip(_ResortGroup g) {
    final sel = g.resortId == _selectedResortId;
    return GestureDetector(
      onTap: () => _selectResort(g.resortId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? SDSColor.snowliveBlue : SDSColor.gray100,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text('${g.name} ${g.count}',
            style: SDSTextStyle.bold.copyWith(
                fontSize: 13,
                color: sel ? SDSColor.snowliveWhite : SDSColor.gray700)),
      ),
    );
  }

  Widget _incomingRow(Map<String, dynamic> f) {
    final fid = (f['user_id'] as num).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              child: Text('${f['display_name'] ?? ''}',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 14, color: SDSColor.gray900))),
          TextButton(onPressed: () => _accept(fid), child: const Text('수락')),
          TextButton(
              onPressed: () => _revoke(fid),
              child: Text('거절',
                  style: SDSTextStyle.regular.copyWith(color: SDSColor.gray500))),
        ],
      ),
    );
  }

  Widget _acceptedRow(Map<String, dynamic> f) {
    final fid = (f['user_id'] as num).toInt();
    final mp = _friends.firstWhere(
        (m) => (m['user_id'] as num?)?.toInt() == fid,
        orElse: () => const {});
    final resortName = mp['resort_name'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              child: Text('${f['display_name'] ?? ''}',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 14, color: SDSColor.gray900))),
          if (resortName is String && resortName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(resortName,
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: 12, color: SDSColor.gray400)),
            ),
          Text(_ago(mp['seconds_ago']),
              style:
                  SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
          TextButton(
              onPressed: () => _revoke(fid),
              child: Text('해제',
                  style: SDSTextStyle.regular.copyWith(color: SDSColor.red))),
        ],
      ),
    );
  }
}

class _ResortGroup {
  final int resortId;
  final String name;
  int count = 0;
  _ResortGroup(this.resortId, this.name);
}

/// 선택 리조트의 슬로프 폴리곤을 배경으로 깔고, 그 위에 친구 점을 같은 투영으로 올린다.
/// 투영: 위경도 → 등거리 미터 → 단일 배율(종횡비 유지) 센터핏 (궤적 렌더러와 동일 방식).
class _ResortLiveMapPainter extends CustomPainter {
  final List<SlopePoly> slopes;
  final List<Map<String, dynamic>> friends;
  _ResortLiveMapPainter(this.slopes, this.friends);

  static const _bg = Color(0xFF0B1220);
  static const _poly = Color(0xFF94A3B8);
  static const _axis = Color(0xFF334155);
  static const _riding = Color(0xFF3D83ED);
  static const _idle = Color(0xFF94A3B8);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = _bg);

    // 투영 기준 좌표 수집: 슬로프 링 + 친구 좌표.
    final geo = <GeoPt>[];
    for (final s in slopes) {
      geo.addAll(s.ring);
    }
    final friendPts = <GeoPt>[];
    for (final f in friends) {
      final c = f['coordinates'];
      if (c is List && c.length >= 2 && c[0] is num && c[1] is num) {
        final p = GeoPt((c[1] as num).toDouble(), (c[0] as num).toDouble());
        friendPts.add(p);
        geo.add(p);
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
    const pad = 0.86;
    final scale = math.min(size.width / w, size.height / h) * pad;
    final midX = (minX + maxX) / 2, midY = (minY + maxY) / 2;
    Offset toXY(GeoPt p) => Offset(
          size.width / 2 + (mx(p) - midX) * scale,
          size.height / 2 - (my(p) - midY) * scale, // 북쪽이 위
        );

    // 슬로프 폴리곤(채움+테두리) + 축.
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

    // 친구 점(라이딩=파랑/대기=회색) + 흰 테두리 + 이름.
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
  bool shouldRepaint(covariant _ResortLiveMapPainter old) =>
      old.friends != friends || old.slopes != slopes;
}
