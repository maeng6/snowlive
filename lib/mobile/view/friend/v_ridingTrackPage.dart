import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/mobile/util/ride_log_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// [임시/테스트용] 라이딩 궤적 페이지.
/// - "브라우저에서 궤적 보기": 폴리곤 궤적 SVG 링크 리스트(서버 HTML)를 Safari로 연다.
/// - "로그 전송": 이 기기에서 라이브온 중 기록된 로그를 서버(개발자)로 업로드한다.
class RidingTrackPage extends StatefulWidget {
  final int userId; // 궤적 조회 대상(프로필 주인)

  const RidingTrackPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<RidingTrackPage> createState() => _RidingTrackPageState();
}

class _RidingTrackPageState extends State<RidingTrackPage> {
  bool _uploading = false;

  Future<void> _openWeb() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(
        'https://snowlive-api-c617725e2b78.herokuapp.com/api/ranking/riding-track/?user_id=${widget.userId}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _uploadLog() async {
    final rec = RideLogRecorder.instance;
    if (!rec.hasLog) {
      Get.snackbar('로그 없음', '이 기기에서 기록된 라이딩 로그가 없어요.\n(로그 수집 대상으로 등록된 계정이 라이브온해야 기록됩니다.)',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _uploading = true);
    final user = Get.find<UserViewModel>().user;
    final dynamic rawUid = rec.sessionUserId ?? user.user_id;
    final int uid = (rawUid is int) ? rawUid : (int.tryParse('$rawUid') ?? 0);
    final ok = await rec.uploadLatest(
      userId: uid,
      displayName: (user.display_name ?? '') as String,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    Get.snackbar(
      ok ? '전송 완료' : '전송 실패',
      ok ? '개발자에게 로그가 전송됐어요.' : '잠시 후 다시 시도해주세요.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: SDSColor.gray900),
        title: Text('라이딩 궤적',
            style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ActionButton(
              label: '브라우저에서 궤적 보기',
              background: SDSColor.snowliveWhite,
              foreground: SDSColor.gray900,
              border: true,
              onTap: _openWeb,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: _uploading ? '전송 중…' : '로그 전송',
              background: SDSColor.snowliveBlue,
              foreground: SDSColor.snowliveWhite,
              onTap: _uploading ? null : _uploadLog,
            ),
            const SizedBox(height: 12),
            Text(
              '• "로그 전송"은 이 기기에서 라이브온 중 기록된 디버그 로그를 개발자에게 보냅니다.\n'
              '• 로그는 어드민에 "로그 수집 대상"으로 등록된 계정이 라이브온했을 때만 기록됩니다.',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool border;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    this.border = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: border ? Border.all(color: SDSColor.gray200) : null,
          ),
          child: Text(label,
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: foreground)),
        ),
      ),
    );
  }
}
