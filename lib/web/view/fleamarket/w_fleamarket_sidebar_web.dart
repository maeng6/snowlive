import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const double kFleamarketSidebarWidth = 280;
final _sidebarPriceFormat = NumberFormat('###,###,###,###');

/// 데스크탑 전용 우측 열: 키워드 알림 설정 + 최근 본 상품 + 찜 목록.
class FleamarketSidebarWeb extends StatelessWidget {
  const FleamarketSidebarWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final myActivityVm = Get.find<FleamarketMyActivityViewModel>();

    return Container(
      width: kFleamarketSidebarWidth,
      padding: const EdgeInsets.only(left: SDSSpacing.lg, top: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => Get.toNamed(WebRoutes.fleamarketUpload),
            style: ElevatedButton.styleFrom(
              backgroundColor: SDSColor.snowliveBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: Text('중고거래 물품 올리기', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite)),
          ),
          const SizedBox(height: SDSSpacing.sm),
          OutlinedButton(
            onPressed: () => Get.toNamed(WebRoutes.fleamarketAlert),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: SDSColor.gray200),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: Text('키워드 알림 설정', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
          ),
          const SizedBox(height: SDSSpacing.xl),
          Obx(() {
            final recent = myActivityVm.recentViewed;
            return _ActivitySection(
              title: '최근 본 상품',
              items: recent,
              // 로딩 중에 "없어요"를 먼저 보여줬다가 데이터로 바뀌면 빈 상태가 깜빡인다.
              // 조회가 끝난 뒤에만 빈 상태로 판단한다.
              isLoading: myActivityVm.isLoading.value,
              isEmpty: recent.isEmpty,
              emptyText: '최근 본 상품이 없어요',
            );
          }),
          const SizedBox(height: SDSSpacing.xl),
          Obx(() {
            final favorites = myActivityVm.favoriteList;
            return _ActivitySection(
              title: favorites.isEmpty ? '찜 목록' : '찜 목록 ${favorites.length}',
              items: favorites,
              isLoading: myActivityVm.isLoading.value,
              isEmpty: favorites.isEmpty,
              emptyText: '찜 목록이 없어요',
            );
          }),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final List<FleamarketMyActivityItem> items;
  final bool isLoading;
  final bool isEmpty;
  final String emptyText;

  const _ActivitySection({
    required this.title,
    required this.items,
    required this.isLoading,
    required this.isEmpty,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
        const SizedBox(height: SDSSpacing.sm),
        if (isLoading && items.isEmpty)
          const ActivityListSkeleton()
        else if (isEmpty)
          Text(emptyText, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400)),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(kFleamarketDefaultImage, width: 40, height: 40, fit: BoxFit.cover),
                ),
                const SizedBox(width: SDSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900),
                      ),
                      Text(
                        '${_sidebarPriceFormat.format(item.price)}원',
                        style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
