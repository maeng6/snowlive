import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_grid_web.dart' show kFleamarketCardTextBlockHeight;
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "추천 중고거래 물품": 전용 추천 API가 없어 같은 카테고리 목록 조회를 재활용하고,
/// 현재 보고 있는 글은 클라이언트에서 제외한다.
class FleamarketDetailRecommendWeb extends StatefulWidget {
  final String? categoryMain;
  final int? excludeFleaId;

  const FleamarketDetailRecommendWeb({super.key, required this.categoryMain, required this.excludeFleaId});

  @override
  State<FleamarketDetailRecommendWeb> createState() => _FleamarketDetailRecommendWebState();
}

class _FleamarketDetailRecommendWebState extends State<FleamarketDetailRecommendWeb> {
  late final Future<List<Fleamarket>> _future = _load();

  Future<List<Fleamarket>> _load() async {
    final userId = Get.find<UserViewModel>().user.user_id;
    final response = await FleamarketAPI().fetchFleamarketList(
      userId: userId,
      categoryMain: widget.categoryMain,
    );
    if (!response.success) return [];
    final parsed = FleamarketResponse.fromJson(response.data!);
    final results = parsed.results ?? [];
    return results.where((item) => item.fleaId != widget.excludeFleaId).take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Fleamarket>>(
      future: _future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        // 로딩과 "결과 없음"을 한 조건으로 묶어 둘 다 숨기면, 데이터가 도착하는 순간
        // 섹션이 통째로 나타나면서 스크롤 위치가 튄다. 로딩 중에는 제목+그리드 높이를
        // 미리 확보해두고, 결과가 비었다고 확정됐을 때만 접는다.
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('추천 중고거래 물품', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
              const SizedBox(height: SDSSpacing.md),
              const FleamarketGridSkeleton(itemCount: 5),
            ],
          );
        }
        if (items.isEmpty) return const SizedBox.shrink();

        final detailVm = Get.find<FleamarketDetailViewModel>();
        final userVm = Get.find<UserViewModel>();
        final crossAxisCount = context.isDesktop ? 5 : 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('추천 중고거래 물품', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
            const SizedBox(height: SDSSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = SDSSpacing.md;
                final cellWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: SDSSpacing.lg,
                    mainAxisExtent: cellWidth + kFleamarketCardTextBlockHeight,
                  ),
                  itemBuilder: (context, index) {
                    final data = items[index];
                    return FleamarketCardWeb(
                      data: data,
                      onTap: () {
                        detailVm.fetchFleamarketDetailFromList(fleamarketResponse: data);
                        Get.offNamed(WebRoutes.fleamarketDetail);
                        final userId = userVm.user.user_id;
                        if (userId != null && data.fleaId != null) {
                          detailVm.addViewerFleamarket(fleamarketId: data.fleaId!, userId: userId);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
