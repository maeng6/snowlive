import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_friendsTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';

const String kProfileGuestbookHint = '방명록을 남겨주세요';

/// 친구가 아니어서 못 쓸 때의 안내(목업 1:9264). 빈 상태 둘째 줄과 잠긴 줄을
/// 눌렀을 때의 안내가 **같은 문구**다.
const String kProfileGuestbookFriendOnlyHint =
    '안부 인사를 남기기 위해서는 먼저 친구가 되어야해요.';
const String kProfileGuestbookEmptyIcon =
    'assets/imgs/icons/icon_friendsTalk_nodata.png';

/// 방명록 입력줄.
///
/// 목업: 쓸 수 없을 때는 자물쇠가 붙은 회색 줄만 보여주고, 누르면 왜 못 쓰는지 알려준다
/// (`안부 인사를 남기기 위해서는 먼저 친구가 되어야해요.`).
class ProfileGuestbookInputWeb extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;

  /// null이면 잠긴 상태(비로그인·친구 아님·내 프로필).
  final Future<void> Function(String text)? onSubmit;

  /// 잠긴 줄을 눌렀을 때 안내.
  final VoidCallback? onLockedTap;

  const ProfileGuestbookInputWeb({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onLockedTap,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (onSubmit == null) return _LockedInput(onTap: onLockedTap);
    return WebCommentInput(
      controller: controller,
      hintText: kProfileGuestbookHint,
      isSubmitting: isSubmitting,
      onSubmit: onSubmit,
    );
  }
}

class _LockedInput extends StatelessWidget {
  final VoidCallback? onTap;

  const _LockedInput({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      // 눌러서 안내가 뜨는 줄 — hover는 웹 공통대로 면이 어두워진다(gray50 + 검정 4%).
      hoverColor: Colors.black.withValues(alpha: 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: SDSColor.gray50,
          borderRadius: BorderRadius.circular(6),
        ),
        // 목업 — 좌 12 / 우 10, 세로는 PC·태블릿 12(1:9106, 줄 높이 48) /
        // 모바일 7(1:6625, 줄 높이 38). 좌우는 쓸 수 있을 때 나오는
        // [WebCommentInput]과 **같은 값**이라 두 상태가 오가도 줄이 안 흔들린다.
        padding: EdgeInsets.fromLTRB(12, isMobile ? 7 : 12, 10, isMobile ? 7 : 12),
        child: Row(
          children: [
            Icon(Icons.lock, size: 24, color: SDSColor.gray500),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                kProfileGuestbookHint,
                // 목업 — PC·태블릿 Regular 15 gray500(1:9108, 입력 가능 상태의
                // 힌트와 같은 값) / 모바일 13 gray400(1:6627).
                style: SDSTextStyle.regular.copyWith(
                  fontSize: isMobile ? 13 : 15,
                  color: isMobile ? SDSColor.gray400 : SDSColor.gray500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 목업(1:9109) — 원 22. 공용 입력줄의 비활성 전송 버튼과 같은 규격.
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: SDSColor.gray200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                size: 15,
                color: SDSColor.snowliveWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 방명록 목록. 비었으면 목업 문구를 보여준다.
class ProfileGuestbookListWeb extends StatelessWidget {
  final List<FriendsTalk> talks;

  /// 내가 쓴 글이거나 내 프로필이면 삭제할 수 있다.
  final bool Function(FriendsTalk talk) canDelete;
  final bool Function(FriendsTalk talk) canReport;
  final Future<bool> Function(FriendsTalk talk) onDelete;
  final Future<WebActionResult> Function(FriendsTalk talk) onReport;

  /// 빈 상태 아래 줄(친구가 아니면 이유를 덧붙인다).
  final String? emptyHint;

  const ProfileGuestbookListWeb({
    super.key,
    required this.talks,
    required this.canDelete,
    required this.canReport,
    required this.onDelete,
    required this.onReport,
    this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    if (talks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            // 목업(1:9265) — 아이콘 74, 아이콘 ↔ 제목 4, 제목 ↔ 부제 6.
            Image.asset(kProfileGuestbookEmptyIcon, width: 74),
            const SizedBox(height: 4),
            Text(
              '방명록에 안부 인사를 남겨보세요!',
              textAlign: TextAlign.center,
              // 목업(1:9263) — Bold 14, 글줄 20.
              style: SDSTextStyle.bold.copyWith(
                fontSize: 14,
                height: 20 / 14,
                color: SDSColor.gray900,
              ),
            ),
            if ((emptyHint ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                emptyHint!,
                textAlign: TextAlign.center,
                // 목업(1:9264) — Regular 14, #666(gray600), 글줄 20.
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  color: SDSColor.gray600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final talk in talks)
          _GuestbookRow(
            talk: talk,
            canDelete: canDelete(talk),
            canReport: canReport(talk),
            onDelete: () => onDelete(talk),
            onReport: () => onReport(talk),
          ),
      ],
    );
  }
}

class _GuestbookRow extends StatelessWidget {
  final FriendsTalk talk;
  final bool canDelete;
  final bool canReport;
  final Future<bool> Function() onDelete;
  final Future<WebActionResult> Function() onReport;

  const _GuestbookRow({
    required this.talk,
    required this.canDelete,
    required this.canReport,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final actions = <WebMoreAction>[
      if (canDelete) WebMoreAction.delete,
      if (canReport) WebMoreAction.report,
    ];

    return Padding(
      // 목업(1:9019) — 글 사이 20.
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WebAvatar(
                url: talk.authorInfo.profileImageUrlUser,
                size: 20,
                userId: talk.authorInfo.userId,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  talk.authorInfo.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // 목업(1:9037) — Bold 12.
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 12,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
              // 목업(1:9036) — 이름 ↔ 시간 4.
              const SizedBox(width: 4),
              Text(
                TimeStamp().getAgo(talk.uploadTime),
                // 목업(1:9038)은 gray500이지만 **gray400으로 쓴다**(사용자 확정) —
                // 같은 줄의 ⋯과 함께 이름보다 한 단계 더 연하게 둔다.
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 12,
                  color: SDSColor.gray400,
                ),
              ),
              // '...' 메뉴는 맨 오른쪽이 아니라 시간 바로 오른쪽에 붙인다.
              const SizedBox(width: 2),
              if (actions.isNotEmpty)
                WebMoreButton(
                  actions: actions,
                  iconSize: 16,
                  // 옆의 `1일 전`과 같은 gray400으로 맞춘다(사용자 확정) —
                  // 에셋 원색(검정)이면 같은 줄에서 ⋯만 진해 보인다.
                  iconColor: SDSColor.gray400,
                  onSelected: (action) => handleWebMoreAction(
                    context,
                    action: action,
                    onDelete: onDelete,
                    onReport: onReport,
                  ),
                ),
            ],
          ),
          // 목업(1:9020) — 이름줄 ↔ 말풍선 9.
          const SizedBox(height: 9),
          // ⚠️ 말풍선은 **들여쓰지 않는다** — 목업에서 아바타와 같은 좌측선에서
          // 시작한다(1:9039의 x가 아바타와 같은 0). 전에는 아바타+간격(28)만큼
          // 밀어 두었는데 목업과 달랐다.
          //
          // 폭: PC·태블릿은 글 길이만큼(목업 1:9020 — 짧은 글은 393, 긴 글은 874),
          // **모바일은 글 길이와 무관하게 콘텐츠 폭을 꽉 채운다**(목업 1:6556 —
          // 글이 짧아도 343 고정).
          Align(
            alignment: Alignment.centerLeft,
            widthFactor: isMobile ? 1 : null,
            child: Container(
              width: isMobile ? double.infinity : null,
              decoration: BoxDecoration(
                // 목업은 #F0F6FF — 토큰 blue50(#ECF3FD)과 육안 차이가 없어
                // 토큰을 쓴다(연회색 라인 gray100 통일과 같은 판단).
                color: SDSColor.blue50,
                // 목업(1:9039) — 라운드 16, 패딩 16/12.
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Text(
                talk.content,
                // 목업(1:9040) — Regular 13, 줄간 1.4.
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 13,
                  height: 1.4,
                  color: SDSColor.gray900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
