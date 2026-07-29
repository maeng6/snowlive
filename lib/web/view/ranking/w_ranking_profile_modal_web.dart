import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 랭킹 목록의 유저 행을 클릭했을 때 뜨는 간단한 프로필 미리보기.
/// 모바일은 이 모달 없이 바로 전체 친구 상세 페이지(FriendDetailView)로 이동하는데,
/// 그 API/화면은 core가 아니라 mobile 전용이라 웹에서 바로 재사용할 수 없다.
/// 그래서 지금은 랭킹 목록 응답에 이미 들어있는 정보(아바타/이름/소속/티어/점수/등수)만으로
/// 미리보기를 구성하고, "친구 추가"/"프로필 보러가기"는 추후 웹 친구 기능이 붙기 전까지
/// 준비 중 안내만 띄운다.
///
/// 딤이 GNB/상단바까지 덮도록 다른 팝업들과 같이 showWebOverlayModal 위에 올린다.
Future<void> showRankingProfileModal(BuildContext context, RankingUser user) {
  return showWebOverlayModal<void>(
    context: context,
    builder: (_, close) => _RankingProfileCard(user: user, onClose: close),
  );
}

class _RankingProfileCard extends StatelessWidget {
  final RankingUser user;
  final VoidCallback onClose;

  const _RankingProfileCard({required this.user, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 카드 표면을 Material로 만든다. Overlay에 직접 꽂는 구조라 Dialog가 주던
      // Material 조상이 없고, 그러면 안쪽 InkWell이 "No Material widget found"로
      // 죽는다. 흰 배경을 Container에 두고 MaterialType.transparency로 감싸는
      // 방식은 잉크가 배경 뒤에 깔려 스플래시가 안 보이므로, Material이 표면을
      // 직접 칠하게 한다.
      child: Material(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(SDSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 닫기 버튼은 카드 상단 우측에 정상적으로 자리를 차지하게 둔다.
              // (크기 없는 Stack에 Positioned로 음수 오프셋을 주면 Stack의 기본
              //  clipBehavior가 hardEdge라 아이콘이 잘려서 아예 안 보인다.)
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 20, color: SDSColor.gray400),
                  ),
                ),
              ),
              ClipOval(
                child: (user.profileImageUrlUser?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: user.profileImageUrlUser, width: 88, height: 88)
                    : Container(
                        width: 88,
                        height: 88,
                        color: SDSColor.gray100,
                        child: Icon(Icons.person, size: 44, color: SDSColor.gray400),
                      ),
              ),
              const SizedBox(height: SDSSpacing.md),
              Text(user.displayName ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900)),
              const SizedBox(height: 4),
              Text(
                [
                  if (user.resortNickname?.isNotEmpty ?? false) user.resortNickname,
                  if (user.crewName?.isNotEmpty ?? false) user.crewName,
                ].join(' · '),
                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
              ),
              const SizedBox(height: SDSSpacing.md),
              OutlinedButton(
                onPressed: () => Get.snackbar('알림', '친구 추가 기능은 준비 중이에요.'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: SDSColor.gray200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: Text('친구 추가', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
              ),
              const SizedBox(height: SDSSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(label: '총 점수', value: '${user.overallTotalScore ?? 0}점'),
                  _StatColumn(label: '통합 랭킹', value: '${user.overallRank ?? 0}등'),
                  _StatColumn(
                    label: user.tierNameKor ?? '',
                    valueWidget: (user.overallTierIconUrl?.isNotEmpty ?? false)
                        ? WebNetworkImage(url: user.overallTierIconUrl, width: 28, height: 28, fit: BoxFit.contain)
                        : Icon(Icons.ac_unit, color: SDSColor.snowliveBlue, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: SDSSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.snackbar('알림', '프로필 화면은 준비 중이에요.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.gray50,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('프로필 보러가기', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _StatColumn({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        valueWidget ?? Text(value ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
        const SizedBox(height: 4),
        Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
      ],
    );
  }
}
