import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_friendsTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';

const String kProfileGuestbookHint = '방명록을 남겨주세요';
const String kProfileGuestbookEmptyIcon = 'assets/imgs/icons/icon_friendsTalk_nodata.png';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.lock, size: 16, color: SDSColor.gray400),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                kProfileGuestbookHint,
                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: SDSColor.gray200, shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.arrow_upward, size: 16, color: SDSColor.snowliveWhite),
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
            Image.asset(kProfileGuestbookEmptyIcon, width: 74),
            const SizedBox(height: 8),
            Text(
              '방명록에 안부 인사를 남겨보세요!',
              textAlign: TextAlign.center,
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
            if ((emptyHint ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                emptyHint!,
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
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
    final actions = <WebMoreAction>[
      if (canDelete) WebMoreAction.delete,
      if (canReport) WebMoreAction.report,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.md),
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
                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                TimeStamp().getAgo(talk.uploadTime),
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
              ),
              const Spacer(),
              if (actions.isNotEmpty)
                WebMoreButton(
                  actions: actions,
                  iconSize: 16,
                  onSelected: (action) => handleWebMoreAction(
                    context,
                    action: action,
                    onDelete: onDelete,
                    onReport: onReport,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            // 아바타(20) + 간격(8)만큼 들여써서 이름 아래에 붙는다(목업).
            padding: const EdgeInsets.only(left: 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: SDSColor.blue50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Text(
                  talk.content,
                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
