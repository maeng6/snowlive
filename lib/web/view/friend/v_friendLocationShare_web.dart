import 'package:com.snowlive/core/api/api_locationShare.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_page_scaffold_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebConfirmDialog;
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 친구 설정 > 실시간 위치 공유 관리.
/// 서로 수락한(위치공유 중) 친구 목록 + 해제, 받은 위치공유 신청 수락/거절.
/// 신청은 친구 목록의 `···` → '위치공유 신청'으로 보낸다.
class FriendLocationShareViewWeb extends StatefulWidget {
  const FriendLocationShareViewWeb({super.key});

  @override
  State<FriendLocationShareViewWeb> createState() =>
      _FriendLocationShareViewWebState();
}

class _FriendLocationShareViewWebState
    extends State<FriendLocationShareViewWeb> {
  final LocationShareAPI _api = LocationShareAPI();

  bool _loading = true;
  bool _isPaid = false;
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _incoming = [];

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user?.user_id;
    return (id is int) ? id : int.tryParse('$id');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  List<Map<String, dynamic>> _asList(dynamic v) =>
      v is List ? v.map((e) => Map<String, dynamic>.from(e)).toList() : [];

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final res = await _api.list(userId: uid);
    if (!mounted) return;
    if (res.success && res.data is Map) {
      setState(() {
        _isPaid = res.data['is_paid'] == true;
        _accepted = _asList(res.data['accepted']);
        _incoming = _asList(res.data['incoming']);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _accept(int fid) async {
    final uid = _uid;
    if (uid == null) return;
    final res = await _api.accept(userId: uid, friendUserId: fid);
    if (!mounted) return;
    _toast(res.success ? '위치공유를 수락했어요.' : _err(res, '수락에 실패했어요.'));
    await _load();
  }

  Future<void> _revoke(int fid, String name, {bool isIncoming = false}) async {
    final uid = _uid;
    if (uid == null) return;
    if (!isIncoming) {
      final ok = await showWebConfirmDialog(
        context: context,
        title: '$name님과 위치공유를\n해제하시겠어요?',
        message: '해제하면 서로의 실시간 위치가 더 이상 보이지 않아요.',
        confirmLabel: '해제하기',
        isDestructive: true,
      );
      if (!ok || !mounted) return;
    }
    final res = await _api.revoke(userId: uid, friendUserId: fid);
    if (!mounted) return;
    _toast(res.success
        ? (isIncoming ? '신청을 거절했어요.' : '위치공유를 해제했어요.')
        : '잠시 후 다시 시도해 주세요.');
    await _load();
  }

  String _err(res, String fallback) =>
      (res.data is Map && res.data['message'] != null)
          ? '${res.data['message']}'
          : fallback;

  void _toast(String m) => showWebToast(context, m);

  @override
  Widget build(BuildContext context) {
    return FriendPageScaffoldWeb(
      title: '실시간 위치 공유',
      child: _loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 3)))
          : (_uid == null)
              ? WebEmptyState(
                  message: '로그인이 필요해요.',
                  actionLabel: '로그인하기',
                  onAction: () => Get.toNamed(WebRoutes.login),
                )
              : !_isPaid
                  ? _lockedBody()
                  : _body(),
    );
  }

  Widget _lockedBody() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('실시간 위치 공유는 시즌권 이용 중일 때, 서로 수락한 친구끼리 사용할 수 있어요.',
              style:
                  SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600)),
          const SizedBox(height: SDSSpacing.lg),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(WebRoutes.seasonPass),
              style: ElevatedButton.styleFrom(
                backgroundColor: SDSColor.snowliveBlue,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('시즌권 보기',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
            ),
          ),
        ],
      );

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_incoming.isNotEmpty) ...[
          _sectionTitle('받은 위치공유 신청'),
          ..._incoming.map((f) {
            final fid = (f['user_id'] as num).toInt();
            final name = '${f['display_name'] ?? ''}';
            return _row(
              name: name,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _accept(fid),
                    child: Text('수락',
                        style: SDSTextStyle.bold
                            .copyWith(fontSize: 13, color: SDSColor.snowliveBlue)),
                  ),
                  TextButton(
                    onPressed: () => _revoke(fid, name, isIncoming: true),
                    child: Text('거절',
                        style: SDSTextStyle.regular
                            .copyWith(fontSize: 13, color: SDSColor.gray500)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: SDSSpacing.lg),
        ],
        _sectionTitle('위치공유 중인 친구'),
        if (_accepted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('아직 위치공유 중인 친구가 없어요.\n친구 목록에서 ··· → 위치공유 신청으로 요청해보세요.',
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 13, color: SDSColor.gray500, height: 1.4)),
          )
        else
          ..._accepted.map((f) {
            final fid = (f['user_id'] as num).toInt();
            final name = '${f['display_name'] ?? ''}';
            return _row(
              name: name,
              trailing: TextButton(
                onPressed: () => _revoke(fid, name),
                child: Text('해제',
                    style:
                        SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.red)),
              ),
            );
          }),
      ],
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
        child: Text(t,
            style:
                SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
      );

  Widget _row({required String name, required Widget trailing}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(name,
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 14, color: SDSColor.gray900)),
            ),
            trailing,
          ],
        ),
      );
}
