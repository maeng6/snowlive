import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// [임시/테스트용] 원격 라이딩 로그 수집.
///
/// - 어드민에 **로그 수집 대상**으로 등록된 user만, 라이브온 시 로그를 기기 파일에 기록한다.
/// - main()의 Zone print 후킹으로 모든 print/debugPrint/에러가 [log]로 전달된다.
/// - 라이브오프 후 "라이딩 궤적" 페이지의 "로그 전송" 버튼이 [uploadLatest]로 서버에 올린다.
/// - 상한 없음(세션 전체 로그 그대로 전송).
///
/// ⚠️ 테스트가 끝나면 통째로 제거할 임시 코드.
class RideLogRecorder {
  RideLogRecorder._();
  static final RideLogRecorder instance = RideLogRecorder._();

  bool _enabled = false;
  IOSink? _sink;
  File? _file;
  File? _lastFile; // 라이브오프 후에도 업로드할 수 있게 유지
  DateTime? _sessionStart;
  int? _sessionUserId;
  Timer? _flushTimer;

  final List<String> _pending = <String>[];
  static const int _maxPending = 2000;

  bool get isActive => _enabled;

  /// 업로드할 로그가 있는지(현재/직전 세션 파일 존재).
  bool get hasLog => _lastFile != null;

  int? get sessionUserId => _sessionUserId;

  /// 라이브온 시 호출. 어드민 등록 대상이면 기록 시작.
  Future<void> maybeStartForUser(dynamic userId) async {
    final uid = (userId is int) ? userId : int.tryParse('$userId');
    if (uid == null) return;
    _sessionUserId = uid;
    try {
      final isTarget = await _isLogTarget(uid);
      if (isTarget) {
        await start();
        log('[RideLog] 수집 대상 — 기록 시작 (user_id=$uid)');
      }
    } catch (e) {
      debugPrint('[RideLog] 대상 확인 실패: $e');
    }
  }

  Future<bool> _isLogTarget(int uid) async {
    final uri = Uri.parse('${RankingAPI.baseUrl}/debug/is-log-target/?user_id=$uid');
    final resp = await http.get(uri).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) return false;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['is_target'] == true;
  }

  Future<void> start() async {
    if (_enabled) return; // 이미 기록 중이면 같은 세션 유지(재시작 대비)
    _enabled = true;
    _sessionStart = DateTime.now();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final t = _sessionStart!;
      final name =
          'ridelog_${t.year}${_2(t.month)}${_2(t.day)}_${_2(t.hour)}${_2(t.minute)}${_2(t.second)}.txt';
      _file = File('${dir.path}/$name');
      _lastFile = _file;
      _sink = _file!.openWrite(mode: FileMode.writeOnlyAppend);
      _sink!.writeln('==== RIDE LOG START ${t.toIso8601String()} (user_id=$_sessionUserId) ====');
      for (final l in _pending) {
        _sink!.writeln(l);
      }
      _pending.clear();
      _flushTimer = Timer.periodic(const Duration(seconds: 2), (_) => _flush());
    } catch (e) {
      debugPrint('[RideLog] start 실패: $e');
    }
  }

  /// Zone print 후킹에서 호출. 활성 상태일 때만 기록.
  void log(String line) {
    if (!_enabled) return;
    final t = DateTime.now();
    final stamped =
        '[${_2(t.hour)}:${_2(t.minute)}:${_2(t.second)}.${_3(t.millisecond)}] $line';
    final sink = _sink;
    if (sink != null) {
      try {
        sink.writeln(stamped);
      } catch (_) {}
    } else if (_pending.length < _maxPending) {
      _pending.add(stamped);
    }
  }

  Future<void> _flush() async {
    try {
      await _sink?.flush();
    } catch (_) {}
  }

  /// 라이브오프 시 호출. 파일을 닫는다(공유/업로드는 궤적 페이지 버튼에서).
  Future<void> stop() async {
    if (!_enabled) return;
    _enabled = false;
    _flushTimer?.cancel();
    _flushTimer = null;
    final sink = _sink;
    _sink = null;
    try {
      sink?.writeln('==== RIDE LOG END ${DateTime.now().toIso8601String()} ====');
      await sink?.flush();
      await sink?.close();
    } catch (_) {}
  }

  /// 직전(또는 현재) 세션 로그를 서버로 업로드. 성공 시 true.
  Future<bool> uploadLatest({required int userId, String displayName = ''}) async {
    await _flush();
    final file = _lastFile;
    if (file == null || !await file.exists()) return false;
    try {
      final text = await file.readAsString();
      final resp = await http
          .post(
            Uri.parse('${RankingAPI.baseUrl}/debug/ride-log/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'display_name': displayName,
              'started_at': _sessionStart?.toIso8601String(),
              'app_info': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
              'log': text,
            }),
          )
          .timeout(const Duration(seconds: 60));
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      debugPrint('[RideLog] 업로드 실패: $e');
      return false;
    }
  }

  static String _2(int n) => n.toString().padLeft(2, '0');
  static String _3(int n) => n.toString().padLeft(3, '0');
}
