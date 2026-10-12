import 'dart:async';

import 'package:com.snowlive/core/api/api_locationShare.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
/// 상호 수락 친구 좌표를 5초마다 폴링.
class LiveMapPanel extends StatefulWidget {
  const LiveMapPanel({super.key});

  @override
  State<LiveMapPanel> createState() => _LiveMapPanelState();
}

class _LiveMapPanelState extends State<LiveMapPanel> {
  final LocationShareAPI _api = LocationShareAPI();
  Timer? _poll;
  bool _isPaid = false;
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _incoming = [];
  List<Map<String, dynamic>> _friends = [];

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
    }
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
    return Container(
      color: SDSColor.snowliveWhite,
      child: !_isPaid
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Text('실시간 위치 공유는 시즌권 이용 중일 때, 서로 수락한 친구끼리 사용할 수 있어요.',
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: 14, color: SDSColor.gray600)),
            )
          : SingleChildScrollView(
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
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomPaint(
                        painter: _MapPainter(_friends),
                        child: _friends.isEmpty
                            ? Center(
                                child: Text('공유 중인 친구 위치가 없어요.',
                                    style: SDSTextStyle.regular.copyWith(
                                        fontSize: 13, color: SDSColor.gray400)))
                            : null,
                      ),
                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              child: Text('${f['display_name'] ?? ''}',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 14, color: SDSColor.gray900))),
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

class _MapPainter extends CustomPainter {
  final List<Map<String, dynamic>> friends;
  _MapPainter(this.friends);

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
      final y = size.height - pad - (lat - minY) / spanY * (size.height - 2 * pad);
      final riding = f['is_riding'] == true;
      canvas.drawCircle(Offset(x, y), 7,
          Paint()..color = riding ? const Color(0xFF3D83ED) : const Color(0xFF94A3B8));
      canvas.drawCircle(
          Offset(x, y),
          7,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      final tp = TextPainter(
        text: TextSpan(
            text: '${f['display_name'] ?? ''}',
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontFamily: 'Pretendard')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y + 10));
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.friends != friends;
}
