import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_snowball.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/ranking/w_snowball_web_common.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_snowball_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 눈송이 상점(일반/프리미엄 공용) — `#/snowball-market/public` · `/premium`.
/// 앱의 일반/프리미엄 상점과 동일: 3열 그리드 + 상세/교환 다이얼로그 + 무한스크롤.
class SnowballMarketShopViewWeb extends StatefulWidget {
  /// 프리미엄 상점이면 true(등급 게이트 + isTierOnly).
  final bool isPremium;
  const SnowballMarketShopViewWeb({super.key, required this.isPremium});

  @override
  State<SnowballMarketShopViewWeb> createState() => _SnowballMarketShopViewWebState();
}

class _SnowballMarketShopViewWebState extends State<SnowballMarketShopViewWeb> {
  final SnowballShopViewModelWeb vm = Get.find<SnowballShopViewModelWeb>();
  final ScrollController _scroll = ScrollController();

  Color get _bg => widget.isPremium ? const Color(0xFF1D242E) : const Color(0xFF0C7519);
  Color get _accent => widget.isPremium ? const Color(0xFF3D83ED) : const Color(0xFF86ED3D);
  String get _title => widget.isPremium ? '프리미엄 눈송이 상점' : '일반 눈송이 상점';

  @override
  void initState() {
    super.initState();
    vm.fetchShop(isTierOnly: widget.isPremium, isForMission: false);
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 50) {
        vm.fetchNextPageShop();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SnowballPhoneScaffold(
      title: _title,
      appBarColor: _bg,
      backgroundColor: _bg,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Obx(() =>
                SnowballBalancePills(white: vm.whiteRemaining, gold: vm.goldRemaining, compact: true)),
          ),
        ),
      ],
      bottomBar: _bottomBar(),
      child: Obx(() {
        if (vm.isLoading.value && vm.shopItems.isEmpty) {
          return const Center(
            child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white54)),
          );
        }
        return RefreshIndicator(
          color: Colors.white,
          backgroundColor: _bg,
          onRefresh: () => vm.fetchShop(isTierOnly: widget.isPremium, isForMission: false),
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Text('획득한 눈송이는 당일에 사용하지 않으면 모두 사라집니다',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 10,
                  childAspectRatio: 11 / 19,
                ),
                itemCount: vm.shopItems.length,
                itemBuilder: (_, i) => _itemCard(vm.shopItems[i]),
              ),
              Obx(() => vm.isMoreLoading.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                          child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white54))),
                    )
                  : const SizedBox(height: 16)),
            ],
          ),
        );
      }),
    );
  }

  Widget _itemCard(SnowballShopItem item) {
    final soldOut = item.itemCount == 0;
    return GestureDetector(
      onTap: soldOut ? null : () => _openItemSheet(item),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(fit: StackFit.expand, children: [
              WebNetworkImage(
                url: item.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                fallback: Image.asset('assets/imgs/imgs/img_flea_default.png', fit: BoxFit.cover),
              ),
              if (soldOut) Container(color: SDSColor.sBlue900.withOpacity(0.8)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text(item.name ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.bold.copyWith(fontSize: 12, color: Colors.white)),
        Row(children: [
          Image.asset(snowAsset(kWhiteBall), height: 12),
          const SizedBox(width: 4),
          Text('${item.price?[0].snowballCount ?? 0}',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.7))),
          const SizedBox(width: 8),
          Image.asset(snowAsset(kGoldBall), height: 12),
          const SizedBox(width: 4),
          Text('${item.price?[1].snowballCount ?? 0}',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.7))),
        ]),
        const SizedBox(height: 2),
        Text(soldOut ? '품절' : '잔여 수량 ${item.itemCount}개',
            style: SDSTextStyle.regular
                .copyWith(fontSize: 12, color: soldOut ? Colors.black : Colors.white)),
      ]),
    );
  }

  void _openItemSheet(SnowballShopItem item) {
    final premiumLocked =
        widget.isPremium && vm.isPremiumUser.value == false && item.isFieldGame == false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bg,
      constraints: const BoxConstraints(maxWidth: kSnowballPhoneWidth),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40,
                height: 4,
                decoration:
                    BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              WebNetworkImage(
                  url: item.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  borderRadius: 4),
              const SizedBox(height: 16),
              Text(item.name ?? '',
                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: Colors.white)),
              const SizedBox(height: 6),
              Text(item.description ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 32),
              if (premiumLocked)
                Text('랭킹 등급 골드 이상만 구매 가능합니다.',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white)),
              if (premiumLocked) const SizedBox(height: 16),
              Row(children: [
                if ((item.landingUrl ?? '').isNotEmpty) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => otherShare(contents: item.landingUrl!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isPremium ? const Color(0xFF1C3F70) : _accent,
                        elevation: 0,
                        minimumSize: const Size(100, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('상세 정보 보기',
                          style: SDSTextStyle.bold.copyWith(
                              fontSize: 16,
                              color: widget.isPremium ? Colors.white : SDSColor.snowliveBlack)),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (!premiumLocked)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _tryPurchase(sheetCtx, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(100, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Text('교환하기',
                          style: SDSTextStyle.bold
                              .copyWith(color: SDSColor.snowliveBlack, fontSize: 16)),
                    ),
                  ),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _tryPurchase(BuildContext sheetCtx, SnowballShopItem item) async {
    final needWhite = item.price?[0].snowballCount ?? 0;
    final needGold = item.price?[1].snowballCount ?? 0;
    final whiteShort = vm.whiteRemaining < needWhite ? needWhite - vm.whiteRemaining : 0;
    final goldShort = vm.goldRemaining < needGold ? needGold - vm.goldRemaining : 0;

    if (whiteShort > 0 || goldShort > 0) {
      final details = [
        if (whiteShort > 0) '하얀 눈송이 $whiteShort개 부족',
        if (goldShort > 0) '황금 눈송이 $goldShort개 부족',
      ].join('\n');
      await showSnowballInfoDialog(context,
          title: '눈송이가 부족해요', message: '교환에 필요한 눈송이가 부족해요.\n$details');
      return;
    }

    Navigator.of(sheetCtx).pop();
    final ok = await vm.purchaseItem(item.snowballItemId!);
    if (!mounted) return;
    if (ok) {
      await showSnowballInfoDialog(context,
          title: '교환 완료!',
          message: '경품 교환이 성공적으로 완료되었습니다.\n경품 수령처에서 경품을 수령해 주세요.');
    } else {
      await showSnowballInfoDialog(context, title: '교환 실패', message: '이미 품절된 상품입니다.');
    }
  }

  Widget _bottomBar() {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              vm.fetchPurchaseHistory();
              Get.toNamed(WebRoutes.snowballMarketBuyRecord);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text('경품 교환 목록',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isPremium ? Colors.white : Colors.black)),
          ),
        ),
      ),
    );
  }
}
