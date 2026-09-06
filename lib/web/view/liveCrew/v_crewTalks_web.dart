import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_sidebar_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_overlay_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_feed_item_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 라이브톡 홈과 같은 폭(피드 480 + 간격 40 + 우측 열 246).
const double kCrewTalksFeedWidth = 480;
const double kCrewTalksContentMaxWidth = 480 + 40 + 280;

/// 크루톡 목록. `#/livecrew-talks?id=334`
///
/// ⚠️ **크루별 크루톡 조회 API가 아직 없다** — `POST /api/livetalk/list/`는 `crew_id`를
/// 무시하고 전체 라이브톡을 돌려주고(실측), 크루 전용 경로는 404다. 그래서 지금은
/// 빈 상태만 보인다. 서버가 필터를 열어주면 [_talks]만 뷰모델 값으로 바꾸면 된다.
class CrewTalksViewWeb extends StatefulWidget {
  const CrewTalksViewWeb({super.key});

  @override
  State<CrewTalksViewWeb> createState() => _CrewTalksViewWebState();
}

class _CrewTalksViewWebState extends State<CrewTalksViewWeb> {
  final CrewDetailViewModelWeb _vm = Get.find<CrewDetailViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  int? _crewId;

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

  List<LiveTalk> get _talks => const [];

  Future<void> _onUpload() async {
    final userId = _userVm.user.user_id;
    final crewId = _crewId;
    if (crewId == null) return;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    await showLiveTalkUploadFlow(context: context, userId: userId, crewId: crewId);
  }

  Future<void> _openDetail(LiveTalk item) async {
    final id = item.livetalkId;
    if (id == null) return;
    if (context.screenType == WebScreenType.mobile) {
      await Get.toNamed('${WebRoutes.liveTalkComments}?id=$id');
      return;
    }
    await showLiveTalkDetailOverlay(
      context: context,
      livetalkId: id,
      userId: _userVm.user.user_id,
    );
  }

  void _onMoreAction(LiveTalk item, WebMoreAction action) {
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    // 라이브톡 홈과 같은 처리 — 코어 VM의 신고/차단은 내부에서 Get.back()을 부른다.
    handleWebMoreAction(
      context,
      action: action,
      onDelete: () async {
        final response = await LiveTalkAPI().delete({
          'livetalk_id': item.livetalkId,
          'user_id': userId,
        });
        return response.success;
      },
      onReport: () => mapWebActionResponse(
        () => LiveTalkAPI().report({
          'livetalk_id': item.livetalkId,
          'user_id': userId,
        }),
      ),
      onHideUser: () => mapWebActionResponse(
        () => UserAPI().blockUser({
          'user_id': userId,
          'block_user_id': item.userId,
        }),
      ),
    );
  }

  bool _isMine(LiveTalk item) =>
      item.userId != null && item.userId == _userVm.user.user_id;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final talks = _talks;

    final feed = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '크루톡',
          style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.lg),
        if (talks.isEmpty)
          const WebEmptyState(message: '아직 크루톡이 없어요')
        else
          for (var i = 0; i < talks.length; i++)
            LiveTalkFeedItemWeb(
              item: talks[i],
              onTapImage: () => _openDetail(talks[i]),
              onTapComment: () => _openDetail(talks[i]),
              onTapLike: () => Get.snackbar('알림', '준비 중이에요.'),
              moreActions: _isMine(talks[i])
                  ? const [WebMoreAction.delete]
                  : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
              onMoreAction: (action) => _onMoreAction(talks[i], action),
              isLast: i == talks.length - 1,
            ),
        // 크루톡은 크루원만 올릴 수 있다.
        if (!isDesktop && _vm.isMyCrew) ...[
          const SizedBox(height: SDSSpacing.xl),
          CrewTalkUploadButton(onTap: _onUpload),
        ],
      ],
    );

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kCrewTalksContentMaxWidth),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: kCrewTalksFeedWidth, child: feed),
                      const Spacer(),
                      if (_vm.isMyCrew)
                        SizedBox(
                          width: 280,
                          child: Padding(
                            // 타이틀 줄만큼 내려서 시작한다(다른 화면과 같은 규격).
                            padding: const EdgeInsets.only(top: 8),
                            child: CrewTalkUploadButton(onTap: _onUpload),
                          ),
                        ),
                    ],
                  )
                : feed,
          ),
        ),
      ),
    );
  }
}
