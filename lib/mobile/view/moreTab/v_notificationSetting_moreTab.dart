import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 더보기 > 설정 > 알림.
/// - 나의 라이브온 알리기: 끄면 내가 라이브온해도 친구에게 푸시가 전송되지 않는다.
/// - 친구의 라이브온 알림 받기: 끄면 친구 라이브온 푸시를 받지 않는다.
/// 두 값은 User(notify_my_liveon / receive_friend_liveon)에 저장되며, 토글 즉시 서버에 반영된다.
class NotificationSettingView extends StatefulWidget {
  const NotificationSettingView({super.key});

  @override
  State<NotificationSettingView> createState() => _NotificationSettingViewState();
}

class _NotificationSettingViewState extends State<NotificationSettingView> {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  late bool _notifyMyLiveon;
  late bool _receiveFriendLiveon;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // 기본 ON — 서버 기본값과 동일.
    _notifyMyLiveon = _userViewModel.user.notify_my_liveon ?? true;
    _receiveFriendLiveon = _userViewModel.user.receive_friend_liveon ?? true;
  }

  /// 해당 필드 하나만 서버에 저장한다. 저장 동안 로딩 다이얼로그를 띄우고,
  /// 성공하면 서버값으로 재동기화, 실패하면 이전 값으로 되돌린다.
  Future<void> _update({required String field, required bool value}) async {
    if (_saving) return;
    final int? userId = _userViewModel.user.user_id;
    if (userId == null) return;

    _saving = true;
    // 누른 토글 하나만 낙관적으로 반영한다(나머지는 건드리지 않는다).
    setState(() {
      if (field == 'notify_my_liveon') {
        _notifyMyLiveon = value;
      } else {
        _receiveFriendLiveon = value;
      }
    });

    CustomFullScreenDialog.showDialog();
    final ApiResponse response =
        await UserAPI().updateUserInfo({'user_id': userId, field: value});

    if (response.success) {
      // 서버를 단일 진실원으로 삼아 두 값 모두 재동기화.
      await _userViewModel.updateUserModel_api(userId);
      if (mounted) {
        setState(() {
          _notifyMyLiveon = _userViewModel.user.notify_my_liveon ?? true;
          _receiveFriendLiveon = _userViewModel.user.receive_friend_liveon ?? true;
        });
      }
    } else {
      // 실패 시 누른 토글만 롤백.
      if (mounted) {
        setState(() {
          if (field == 'notify_my_liveon') {
            _notifyMyLiveon = !value;
          } else {
            _receiveFriendLiveon = !value;
          }
        });
      }
      Get.snackbar('알림', '설정 저장에 실패했어요. 잠시 후 다시 시도해주세요.');
    }

    CustomFullScreenDialog.cancelDialog();
    _saving = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg',
                width: 26, height: 26),
            highlightColor: Colors.transparent,
          ),
        ),
        title: Text(
          '알림',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _toggleRow(
              title: '나의 라이브온 알리기',
              value: _notifyMyLiveon,
              onChanged: (v) => _update(field: 'notify_my_liveon', value: v),
            ),
            _toggleRow(
              title: '친구의 라이브온 알림 받기',
              value: _receiveFriendLiveon,
              onChanged: (v) => _update(field: 'receive_friend_liveon', value: v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: SDSTextStyle.bold
                  .copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: 12),
          // 켜짐: 파란 트랙 + 흰 노브 / 꺼짐: 회색 트랙 + 흰 노브 (일관된 깔끔한 스타일).
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: MaterialStateProperty.all(SDSColor.snowliveWhite),
            trackColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => states.contains(MaterialState.selected)
                  ? SDSColor.snowliveBlue
                  : SDSColor.gray300,
            ),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            trackOutlineWidth: MaterialStateProperty.all(0),
          ),
        ],
      ),
    );
  }
}
