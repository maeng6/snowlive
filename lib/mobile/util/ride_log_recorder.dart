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
/// - 어드민 등록 대상이면 **라이브오프 시 자동 업로드**된다([stop]→[_autoUploadIfTarget]).
///   수동으로도 "라이딩 궤적" 페이지의 "로그 전송" 버튼([uploadLatest])으로 올릴 수 있다.
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

  /// 라이브온 시 호출. **전원 상시 기록**(온디바이스 롤링, 캡 3일/20MB).
  /// 전송은 어드민 등록자만 설정의 "로그 전송" 메뉴로(uploadLatest).
  Future<void> maybeStartForUser(dynamic userId) async {
    final uid = (userId is int) ? userId : int.tryParse('$userId');
    if (uid == null) return;
    _sessionUserId = uid;
    try {
      await start();
      log('[RideLog] 기록 시작 (user_id=$uid)');
    } catch (e) {
      debugPrint('[RideLog] start 실패: $e');
    }
  }

  /// 어드민 로그수집 대상 여부(설정의 "로그 전송" 메뉴 노출 판정용).
  Future<bool> isLogTarget(int uid) async {
    try {
      final uri = Uri.parse('${RankingAPI.baseUrl}/debug/is-log-target/?user_id=$uid');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['is_target'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> start() async {
    if (_enabled) return; // 이미 기록 중이면 같은 세션 유지(재시작 대비)
    _enabled = true;
    _sessionStart = DateTime.now();
    try {
      final dir = await getApplicationDocumentsDirectory();
      await _pruneOldLogs(dir); // 온디바이스 롤링 캡(3일/20MB) 유지
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

  /// 라이브오프 시 호출. 파일을 닫는다. 어드민 로그수집 **대상으로 등록된 유저면
  /// 세션 종료 시 자동으로 서버에 업로드**한다(유저가 "로그 전송"을 누르지 않아도 됨).
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
    // 어드민 등록 대상이면 세션 종료 시 자동 업로드(네트워크 호출은 라이브오프를
    // 막지 않게 백그라운드로). 대상이 아니면 is-log-target 조회만 하고 끝난다.
    final uid = _sessionUserId;
    if (uid != null) unawaited(_autoUploadIfTarget(uid));
  }

  /// 어드민 로그수집 대상이면 직전 세션 로그를 자동 업로드한다.
  Future<void> _autoUploadIfTarget(int uid) async {
    try {
      if (!await isLogTarget(uid)) return;
      final ok = await uploadLatest(userId: uid);
      debugPrint('[RideLog] 자동 업로드 ${ok ? '성공' : '실패'} (user_id=$uid)');
    } catch (e) {
      debugPrint('[RideLog] 자동 업로드 오류: $e');
    }
  }

  DateTime? _lastEventUploadAt;

  /// GPS 조작/에러 등 **이상 상황**에서 현재(또는 직전) 세션 로그를 서버로 즉시
  /// 올린다 — **대상 등록 여부와 무관**. 같은 세션에서 에러가 연달아 나도 과도하게
  /// 전송하지 않도록 최소 15초 간격으로 스로틀한다.
  Future<void> uploadOnEvent(String reason) async {
    final uid = _sessionUserId;
    if (uid == null) return;
    final now = DateTime.now();
    if (_lastEventUploadAt != null &&
        now.difference(_lastEventUploadAt!) < const Duration(seconds: 15)) {
      return;
    }
    _lastEventUploadAt = now;
    try {
      final ok = await uploadLatest(userId: uid);
      debugPrint('[RideLog] 이벤트 업로드($reason) ${ok ? '성공' : '실패'} (user_id=$uid)');
    } catch (e) {
      debugPrint('[RideLog] 이벤트 업로드 오류: $e');
    }
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

  /// 온디바이스 롤링 캡: 3일 지난 로그 삭제 + 총합 20MB 초과 시 오래된 것부터 삭제.
  Future<void> _pruneOldLogs(Directory dir) async {
    try {
      const maxAge = Duration(days: 3);
      const maxBytes = 20 * 1024 * 1024;
      final now = DateTime.now();
      var files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('ridelog_') && f.path.endsWith('.txt'))
          .toList();
      // 1) 오래된 것(3일 초과) 삭제
      for (final f in files.toList()) {
        try {
          if (now.difference(f.statSync().modified) > maxAge) {
            f.deleteSync();
            files.remove(f);
          }
        } catch (_) {}
      }
      // 2) 총 용량 20MB 초과 시 오래된 것부터 삭제
      files.sort((a, b) =>
          a.statSync().modified.compareTo(b.statSync().modified));
      int total = 0;
      for (final f in files) {
        try {
          total += f.lengthSync();
        } catch (_) {}
      }
      int i = 0;
      while (total > maxBytes && i < files.length) {
        try {
          final len = files[i].lengthSync();
          files[i].deleteSync();
          total -= len;
        } catch (_) {}
        i++;
      }
    } catch (_) {}
  }

  static String _2(int n) => n.toString().padLeft(2, '0');
  static String _3(int n) => n.toString().padLeft(3, '0');
}
