import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SnowballMarketBrandOnlyPublicShopView extends StatefulWidget {
  @override
  State<SnowballMarketBrandOnlyPublicShopView> createState() => _SnowballMarketBrandOnlyPublicShopViewState();
}

class _SnowballMarketBrandOnlyPublicShopViewState extends State<SnowballMarketBrandOnlyPublicShopView> {
  final SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  bool _hasFetchedData = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('snowball_market').doc('snowball_market').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        if (!_hasFetchedData) {
          _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: false);
          _hasFetchedData = true;
        }

        return Obx(() => Scaffold(
          backgroundColor: const Color(0xFF0C7519),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: AppBar(
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: const Color(0xFF0C7519),
              title: Text('일반 눈송이 상점', style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 16)),
              leading: Padding(
                padding: EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26, colorFilter: ColorFilter.mode(SDSColor.snowliveWhite, BlendMode.srcIn)),
                  highlightColor: Colors.transparent,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          Row(children: [
                            Image.asset('assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png', height: 16),
                            const SizedBox(width: 4),
                            Text('${_snowballShopViewModel.summary[0].remaining}',
                                style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13)),
                          ]),
                          const SizedBox(width: 8),
                          Row(children: [
                            Image.asset('assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png', height: 16),
                            const SizedBox(width: 4),
                            Text('${_snowballShopViewModel.summary[1].remaining}',
                                style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          body: _snowballShopViewModel.isLoading.value
              ? Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: SDSColor.gray100,
                color: SDSColor.gray300.withOpacity(0.6),
              ),
            ),
          )
              : Column(children: [
            Expanded(
              child: RefreshIndicator(
                strokeWidth: 2,
                edgeOffset: -40,
                displacement: 40,
                backgroundColor: const Color(0xFF0C7519),
                color: SDSColor.snowliveWhite,
                onRefresh: () async =>
                    _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: false),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification n) {
                    final nextUrl = _snowballShopViewModel.nextPageUrlShop;
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 50) {
                      if (nextUrl != null &&
                          nextUrl.isNotEmpty &&
                          !_snowballShopViewModel.isMoreLoading.value) {
                        _snowballShopViewModel.fetchSnowballShop(
                          isTierOnly: false,
                          isForMission: false,
                          url: nextUrl,
                        );
                      }
                    }
                    return false;
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Center(
                        child: Text('획득한 눈송이는 당일에 사용하지 않으면 모두 사라집니다',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 10, childAspectRatio: 11 / 19),
                        itemCount: _snowballShopViewModel.shopItems.length,
                        itemBuilder: (context, index) {
                          final item = _snowballShopViewModel.shopItems[index];
                          return Stack(children: [
                            GestureDetector(
                              onTap: () async {
                                if (item.itemCount == 0) return;
                                _snowballShopViewModel.selectItem(item);

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: const Color(0xFF0C7519),
                                  builder: (_) {
                                    return SafeArea(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0C7519),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                                          Center(
                                              child: Container(width: 40, height: 4,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(2)))),
                                          const SizedBox(height: 20),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: ExtendedImage.network(
                                              item.imageUrl ?? '',
                                              width: 120, height: 120, fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(item.name ?? '', style: SDSTextStyle.bold.copyWith(
                                              fontSize: 16, color: SDSColor.snowliveWhite)),
                                          const SizedBox(height: 6),
                                          Text(item.description ?? '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                                          const SizedBox(height: 40),
                                          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                            if (item.landingUrl != null && item.landingUrl!.isNotEmpty)
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () => otherShare(contents: item.landingUrl!),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF86ED3D),
                                                      minimumSize: const Size(100, 48),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(6))),
                                                  child: Text('상세 정보 보기',
                                                      style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 16, color: SDSColor.snowliveBlack)),
                                                ),
                                              ),
                                            if (item.landingUrl != null && item.landingUrl!.isNotEmpty)
                                              const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final userWhite = _snowballShopViewModel.summary[0].remaining ?? 0;
                                                  final userGold = _snowballShopViewModel.summary[1].remaining ?? 0;

                                                  final needWhite = item.price![0].snowballCount ?? 0;
                                                  final needGold = item.price![1].snowballCount ?? 0;

                                                  final whiteShort = userWhite < needWhite ? needWhite - userWhite : 0;
                                                  final goldShort = userGold < needGold ? needGold - userGold : 0;

                                                  final isNotEnough = whiteShort > 0 || goldShort > 0;

                                                  if (isNotEnough) {
                                                    final shortfallTitle = '교환에 필요한 눈송이가 부족해요.';
                                                    String? shortfallWhite;
                                                    String? shortfallGold;

                                                    if (whiteShort > 0) {
                                                      shortfallWhite = '하얀 눈송이 ${whiteShort}개 부족';
                                                    }

                                                    if (goldShort > 0) {
                                                      shortfallGold = '황금 눈송이 ${goldShort}개 부족';
                                                    }

                                                    final shortfallDetails = [
                                                      if (shortfallWhite != null) '$shortfallWhite',
                                                      if (shortfallGold != null) '$shortfallGold',
                                                    ].join('\n');

                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => AlertDialog(
                                                        backgroundColor: SDSColor.snowliveWhite,
                                                        contentPadding: const EdgeInsets.only(
                                                          bottom: 0,
                                                          left: 28,
                                                          right: 28,
                                                          top: 36,
                                                        ),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        content: SizedBox(
                                                          height: 94,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                '눈송이가 부족해요',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                  color: SDSColor.gray900,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Text(
                                                                shortfallTitle,
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  color: SDSColor.gray500,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Text(
                                                                shortfallDetails,
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  color: const Color(0xFF000000),
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 24),
                                                            child: SizedBox(
                                                              width: 240,
                                                              height: 48,
                                                              child: ElevatedButton(
                                                                onPressed: () => Navigator.of(context).pop(),
                                                                style: ElevatedButton.styleFrom(
                                                                  elevation: 0,
                                                                  backgroundColor: const Color(0xFF3D83ED),
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(6),
                                                                  ),
                                                                ),
                                                                child: const Text(
                                                                  '확인',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  Navigator.pop(context);
                                                  CustomFullScreenDialog.showDialog();
                                                  final result = await _snowballShopViewModel.purchaseSnowballItem(
                                                    snowballItemId: _snowballShopViewModel.selectedItem.value.snowballItemId!,
                                                  );
                                                  await _snowballShopViewModel.fetchSnowballShopExchange(
                                                    isTierOnly: true,
                                                    isForMission: false,
                                                  );
                                                  CustomFullScreenDialog.cancelDialog();

                                                  if (result) {
                                                    Get.dialog(
                                                      AlertDialog(
                                                        backgroundColor: SDSColor.snowliveWhite,
                                                        contentPadding: const EdgeInsets.only(
                                                          bottom: 0,
                                                          left: 28,
                                                          right: 28,
                                                          top: 36,
                                                        ),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        buttonPadding: const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 0,
                                                        ),
                                                        content: SizedBox(
                                                          height: 80,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                '교환 완료!',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                  color: SDSColor.gray900,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Text(
                                                                '경품 교환이 성공적으로 완료되었습니다.\n경품 수령처에서 경품을 수령해 주세요.',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  color: SDSColor.gray500,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 24),
                                                            child: SizedBox(
                                                              width: 240,
                                                              height: 48,
                                                              child: ElevatedButton(
                                                                onPressed: () => Get.back(),
                                                                style: ElevatedButton.styleFrom(
                                                                  elevation: 0,
                                                                  backgroundColor: const Color(0xFF3D83ED),
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(6),
                                                                  ),
                                                                ),
                                                                child: const Text(
                                                                  '확인',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    Get.dialog(
                                                      AlertDialog(
                                                        backgroundColor: SDSColor.snowliveWhite,
                                                        contentPadding: const EdgeInsets.only(
                                                          bottom: 0,
                                                          left: 28,
                                                          right: 28,
                                                          top: 36,
                                                        ),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        buttonPadding: const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 0,
                                                        ),
                                                        content: SizedBox(
                                                          height: 80,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                '교환 실패',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                  color: SDSColor.gray900,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Text(
                                                                '이미 품절된 상품입니다.',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  color: SDSColor.gray500,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 24),
                                                            child: SizedBox(
                                                              width: 240,
                                                              height: 48,
                                                              child: ElevatedButton(
                                                                onPressed: () => Get.back(),
                                                                style: ElevatedButton.styleFrom(
                                                                  elevation: 0,
                                                                  backgroundColor: const Color(0xFF3D83ED),
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(6),
                                                                  ),
                                                                ),
                                                                child: const Text(
                                                                  '확인',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                  ),
                                                  splashFactory: InkRipple.splashFactory,
                                                  elevation: 0,
                                                  minimumSize: const Size(100, 48),
                                                  backgroundColor: SDSColor.snowliveWhite,
                                                ),
                                                child: Text(
                                                  '교환하기',
                                                  style: SDSTextStyle.bold.copyWith(
                                                    color: SDSColor.snowliveBlack,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ]),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      color: Colors.white,
                                      child: Stack(children: [
                                        Center(
                                          child: Container(
                                            color: SDSColor.snowliveWhite,
                                            child: ExtendedImage.network(
                                              item.imageUrl ?? '',
                                              fit: BoxFit.cover,
                                              loadStateChanged: (state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return Shimmer.fromColors(
                                                      baseColor: Colors.grey[200]!,
                                                      highlightColor: Colors.grey[50]!,
                                                      child: Container(color: Colors.white),
                                                    );
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                    return Image.asset('assets/imgs/imgs/img_flea_default.png',
                                                        fit: BoxFit.cover);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        if (item.itemCount == 0)
                                          Positioned.fill(
                                              child: Container(color: SDSColor.sBlue900.withOpacity(0.8))),
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(item.name ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: SDSTextStyle.bold.copyWith(fontSize: 12, color: Colors.white)),
                                Row(children: [
                                  Row(children: [
                                    Image.asset(
                                      'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                      height: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${item.price![0].snowballCount}',
                                        style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12, color: Colors.white.withOpacity(0.7)))
                                  ]),
                                  const SizedBox(width: 8),
                                  Row(children: [
                                    Image.asset(
                                      'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                      height: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${item.price![1].snowballCount}',
                                        style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12, color: Colors.white.withOpacity(0.7)))
                                  ]),
                                ]),
                                const SizedBox(height: 2),
                                Text(
                                  item.itemCount == 0 ? '품절' : '잔여 수량 ${item.itemCount}개',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: item.itemCount == 0 ? Colors.black : Colors.white),
                                )
                              ]),
                            )
                          ]);
                        },
                      ),
                      Obx(() => _snowballShopViewModel.isMoreLoading.value
                          ? Container(
                        height: 100,
                        padding: const EdgeInsets.only(bottom: 75),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: SDSColor.gray100,
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        CustomFullScreenDialog.showDialog();
                        await _snowballShopViewModel.fetchPurchaseHistoryOnly();
                        CustomFullScreenDialog.cancelDialog();
                        Get.toNamed(AppRoutes.snowballMarketBuyRecord);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF86ED3D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('경품 교환 목록',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ));
      },
    );
  }
}
