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

class SnowballMarketBrandOnlyPublicShopView extends StatefulWidget {
  @override State<SnowballMarketBrandOnlyPublicShopView> createState() => _SnowballMarketBrandOnlyPublicShopViewState();
}

class _SnowballMarketBrandOnlyPublicShopViewState extends State<SnowballMarketBrandOnlyPublicShopView> {
  final SnowballShopViewModel _vm = Get.find<SnowballShopViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  bool _hasFetched = false;

  @override Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('snowball_market').doc('snowball_market').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        if (!_hasFetched) { _vm.fetchSnowballShop(isTierOnly: false, isForMission: false); _hasFetched = true; }

        return Obx(() => Scaffold(
          backgroundColor: const Color(0xFF0C7519),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: AppBar(
              elevation: 0, surfaceTintColor: Colors.transparent, backgroundColor: const Color(0xFF0C7519),
              title: Text('일반 눈송이 상점', style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 16)),
              leading: GestureDetector(
                child: Image.asset('assets/imgs/icons/icon_snowLive_back.png', color: SDSColor.snowliveWhite, scale: 4, width: 26, height: 26),
                onTap: () => Get.back(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          Row(children: [
                            Image.asset('assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png', height: 16),
                            const SizedBox(width: 4),
                            Text('${_vm.summary[0].remaining}', style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13)),
                          ]),
                          const SizedBox(width: 8),
                          Row(children: [
                            Image.asset('assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png', height: 16),
                            const SizedBox(width: 4),
                            Text('${_vm.summary[1].remaining}', style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13)),
                          ])
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          body: _vm.isLoading.value
              ? Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 4, backgroundColor: SDSColor.gray100, color: SDSColor.gray300.withOpacity(0.6))))
              : Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  strokeWidth: 2, edgeOffset: -40, displacement: 40, backgroundColor: const Color(0xFF0C7519), color: Colors.white,
                  onRefresh: () => _vm.fetchSnowballShop(isTierOnly: false, isForMission: false),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >= n.metrics.maxScrollExtent - 50) {
                        final nextUrl = _vm.nextPageUrlShop;
                        if (nextUrl != null && nextUrl.isNotEmpty && !_vm.isMoreLoading.value) {
                          _vm.fetchSnowballShop(isTierOnly: false, isForMission: false, url: nextUrl);
                        }
                      }
                      return false;
                    },
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 12),
                        Text('획득한 눈송이는 당일에 사용하지 않으면 모두 사라집니다', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 10, childAspectRatio: 11 / 19),
                          itemCount: _vm.shopItems.length,
                          itemBuilder: (_, i) {
                            final item = _vm.shopItems[i];
                            return GestureDetector(
                              onTap: () async {
                                if (item.itemCount == 0) return;
                                CustomFullScreenDialog.showDialog();
                                await _vm.fetchSnowballShopTapTheList(isTierOnly: false, isForMission: false);
                                CustomFullScreenDialog.cancelDialog();

                                final updated = _vm.shopItems.firstWhere(
                                      (u) => u.snowballItemId == item.snowballItemId,
                                  orElse: () => SnowballShopItem(itemCount: 0),
                                );
                                if (updated.itemCount == 0) return;

                                _vm.selectItem(item);
                                showModalBottomSheet(
                                  context: context, isScrollControlled: true, backgroundColor: const Color(0xFF0C7519),
                                  builder: (_) => _buildBottomSheet(item),
                                );
                              },
                              child: _buildItemCard(item),
                            );
                          },
                        ),
                        Obx(() => _vm.isMoreLoading.value ? _buildMoreSpinner() : const SizedBox())
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      CustomFullScreenDialog.showDialog();
                      await _vm.fetchPurchaseHistoryOnly();
                      CustomFullScreenDialog.cancelDialog();
                      Get.toNamed(AppRoutes.snowballMarketBuyRecord);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: const Color(0xFF86ED3D), padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('경품 교환 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  Widget _buildItemCard(SnowballShopItem item) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              ExtendedImage.network(
                item.imageUrl ?? '',
                enableMemoryCache: true,
                fit: BoxFit.cover,
                loadStateChanged: (s) {
                  switch (s.extendedImageLoadState) {
                    case LoadState.loading:
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!,
                        child: Container(color: Colors.white),
                      );
                    case LoadState.completed: return s.completedWidget;
                    case LoadState.failed: return Image.asset('assets/imgs/imgs/img_flea_default.png');
                  }
                },
              ),
              if (item.itemCount == 0) Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5)))
            ]),
          ),
          const SizedBox(height: 8),
          Text(item.name ?? '상품 이름', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.bold.copyWith(fontSize: 12, color: Colors.white)),
          const SizedBox(height: 2),
          Row(children: [
            Row(children: [
              Image.asset('assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png', height: 12),
              const SizedBox(width: 4),
              Text('${item.price![0].snowballCount}', style: TextStyle(fontSize: 12, color: Colors.white70))
            ]),
            const SizedBox(width: 8),
            Row(children: [
              Image.asset('assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png', height: 12),
              const SizedBox(width: 4),
              Text('${item.price![1].snowballCount}', style: TextStyle(fontSize: 12, color: Colors.white70))
            ]),
          ]),
          const SizedBox(height: 2),
          Text(item.itemCount == 0 ? '품절' : '잔여 수량 ${item.itemCount}개',
              style: TextStyle(fontSize: 12, color: item.itemCount == 0 ? Colors.black : Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMoreSpinner() {
    return Container(
      height: 100, padding: const EdgeInsets.only(bottom: 75),
      child: const Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 4, backgroundColor: Color(0xFFE0E0E0), color: Color(0xFFCCCCCC)),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(SnowballShopItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0C7519),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ExtendedImage.network(item.imageUrl ?? '', width: 113, height: 113, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(item.name ?? '상품 이름', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 6),
          Text(item.description ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 40),
          Row(
            children: [
              if (item.landingUrl != null && item.landingUrl!.isNotEmpty)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async => await otherShare(contents: item.landingUrl!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF86ED3D), elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text('상세 정보 보기', style: SDSTextStyle.bold.copyWith(color: Colors.black, fontSize: 16)),
                  ),
                ),
              if (item.landingUrl != null && item.landingUrl!.isNotEmpty) const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    CustomFullScreenDialog.showDialog();
                    final ok = await _vm.purchaseSnowballItem(snowballItemId: item.snowballItemId!);
                    await _vm.fetchSnowballShopExchange(
                      isTierOnly: false,
                      isForMission: false,
                    );
                    CustomFullScreenDialog.cancelDialog();
                    if (ok) {
                      Get.dialog(_successDialog());
                    } else {
                      Get.dialog(_failDialog());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('교환하기', style: SDSTextStyle.bold.copyWith(color: Colors.black, fontSize: 16)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _successDialog() {
    return AlertDialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
      content: SizedBox(height: 80, child: Column(children: [
        Text('교환 완료!', style: SDSTextStyle.bold.copyWith(color: Colors.black87, fontSize: 16)),
        const SizedBox(height: 6),
        Text('경품 교환이 성공적으로 완료되었습니다.\n경품 수령처에서 경품을 수령해 주세요.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ])),
      actions: [
        Container(
          width: 240, height: 48, margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D83ED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('확인', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _failDialog() {
    return AlertDialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
      content: SizedBox(height: 80, child: Column(children: [
        Text('교환 실패', style: SDSTextStyle.bold.copyWith(color: Colors.black87, fontSize: 16)),
        const SizedBox(height: 6),
        Text('일시적인 오류로 교환에 실패했어요.\n다시 시도해 주세요.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ])),
      actions: [
        Container(
          width: 240, height: 48, margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D83ED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('확인', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }
}
