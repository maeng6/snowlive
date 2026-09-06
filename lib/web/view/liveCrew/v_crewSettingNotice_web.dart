import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewNotice.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat('yyyy.MM.dd');

/// 공지 행의 `···` 메뉴.
enum _NoticeAction {
  edit('공지사항 수정하기'),
  delete('공지사항 삭제하기');

  const _NoticeAction(this.label);
  final String label;
}

/// 공지사항 작성 + 올라온 공지 목록(수정·삭제). `#/livecrew-notice?id=334`
///
/// 목업에는 작성 화면만 있지만, 목록이 없으면 한번 올린 공지를 웹에서 고칠 수도 지울 수도
/// 없어서 함께 둔다(사용자 확정).
class CrewSettingNoticeViewWeb extends StatefulWidget {
  const CrewSettingNoticeViewWeb({super.key});

  @override
  State<CrewSettingNoticeViewWeb> createState() => _CrewSettingNoticeViewWebState();
}

class _CrewSettingNoticeViewWebState extends State<CrewSettingNoticeViewWeb> {
  final CrewSettingViewModelWeb _vm = Get.find<CrewSettingViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final TextEditingController _controller = TextEditingController();

  int? _crewId;

  /// 수정 중인 공지. null이면 새로 쓰는 중이다.
  CrewNotice? _editing;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _vm.crewId != id) _vm.load(id);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String message) {
    showWebToast(
      context,
      message,
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  Future<void> _onSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _toast('공지사항을 입력해 주세요.');
      return;
    }

    final editing = _editing;
    final result = editing == null
        ? await _vm.createNotice(text)
        : await _vm.updateNotice(noticeId: editing.noticeCrewId!, text: text);
    if (!mounted) return;
    if (!result.ok) {
      _toast(result.message ?? '저장에 실패했어요. 잠시 후 다시 시도해주세요.');
      return;
    }
    setState(() {
      _editing = null;
      _controller.clear();
    });
    _toast(editing == null ? '공지사항을 올렸습니다.' : '공지사항을 수정했습니다.');
  }

  void _startEdit(CrewNotice notice) {
    setState(() {
      _editing = notice;
      _controller.text = notice.notice ?? '';
    });
  }

  Future<void> _onDelete(CrewNotice notice) async {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '이 공지사항을 삭제하시겠어요?',
      confirmLabel: '삭제하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final result = await _vm.deleteNotice(
      noticeId: notice.noticeCrewId!,
      // 앱과 같이 **작성자 id**를 보낸다(서버 권한 검사가 이 값을 본다).
      authorUserId: notice.authorUserId ?? _userVm.user.user_id ?? 0,
    );
    if (!mounted) return;
    _toast(result.ok ? '공지사항을 삭제했습니다.' : (result.message ?? '잠시 후 다시 시도해 주세요.'));
  }

  @override
  Widget build(BuildContext context) {
    return CrewSettingScaffoldWeb(
      title: '공지사항 작성',
      showBack: true,
      fallbackRoute: '${WebRoutes.crewSetting}?id=$_crewId',
      actionLabel: _editing == null ? '완료' : '수정 완료',
      onAction: _onSubmit,
      child: CrewSettingGuard(
        isLoggedIn: _userVm.user.user_id != null,
        canOpen: _vm.canEditNotice,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebFormTextField(
              label: '공지사항',
              controller: _controller,
              hint: '공지사항을 입력해 주세요. (최대 $kCrewNoticeMaxLength자 이내)\n공지사항은 크루원만 볼 수 있습니다.',
              maxLength: kCrewNoticeMaxLength,
              maxLines: 5,
              height: 160,
              inputFormatters: [LengthLimitingTextInputFormatter(kCrewNoticeMaxLength)],
            ),
            if (_editing != null) ...[
              const SizedBox(height: SDSSpacing.sm),
              Row(
                children: [
                  Text(
                    '공지 수정 중',
                    style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.snowliveBlue),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _editing = null;
                      _controller.clear();
                    }),
                    child: Text(
                      '수정 취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray500),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: SDSSpacing.xl),
            Text(
              '올라온 공지사항',
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const SizedBox(height: SDSSpacing.md),
            Obx(_buildList),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final notices = _vm.notices;
    final count = notices.length;
    if (count == 0) {
      return const WebEmptyState(message: '공지사항이 없습니다.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) Divider(color: SDSColor.gray100, height: 32, thickness: 1),
          _buildRow(notices[i], isLatest: i == 0),
        ],
      ],
    );
  }

  Widget _buildRow(CrewNotice notice, {required bool isLatest}) {
    final uploaded = notice.uploadTime;
    final meta = [
      if (isLatest) '최신 공지',
      if (uploaded != null) _dateFormat.format(uploaded),
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.notice ?? '',
                style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        _NoticeMoreButton(
          onSelected: (action) => action == _NoticeAction.edit
              ? _startEdit(notice)
              : _onDelete(notice),
        ),
      ],
    );
  }
}

/// 공지 행의 `···`. 데스크탑은 앵커 드롭다운, 좁은 폭은 시트로 공용 위젯이 알아서 나눈다.
class _NoticeMoreButton extends StatefulWidget {
  final ValueChanged<_NoticeAction> onSelected;

  const _NoticeMoreButton({required this.onSelected});

  @override
  State<_NoticeMoreButton> createState() => _NoticeMoreButtonState();
}

class _NoticeMoreButtonState extends State<_NoticeMoreButton> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final selected = await showWebFilterMenu<_NoticeAction>(
      context: context,
      link: _link,
      values: _NoticeAction.values,
      labelOf: (a) => a.label,
      centerSheetOnTablet: true,
    );
    if (selected != null) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        onTap: _open,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.more_horiz, size: 20, color: SDSColor.gray400),
        ),
      ),
    );
  }
}
