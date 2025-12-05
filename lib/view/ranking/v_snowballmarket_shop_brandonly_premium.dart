import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_forestPark.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SnowballMarketBrandOnlyPremiumShopView extends StatefulWidget {
  @override
  State<SnowballMarketBrandOnlyPremiumShopView> createState() => _SnowballMarketBrandOnlyPremiumShopViewState();
}

class _SnowballMarketBrandOnlyPremiumShopViewState extends State<SnowballMarketBrandOnlyPremiumShopView> {
  final SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  bool _hasFetchedData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('snowball_market').doc('snowball_market').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final int eventDate = data?['event_date'] ?? 0;

        // ✅ 최초 한 번만 실행
        if (!_hasFetchedData) {
          _snowballShopViewModel.fetchSnowballShop(isTierOnly: true, isForMission: false);
          _hasFetchedData = true;
        }

        return Obx(
          () => Scaffold(
            backgroundColor: const Color(0xFF0C7519),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: AppBar(
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  '프리미엄 눈송이 상점',
                  style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.snowliveWhite,
                    fontSize: 16,
                  ),
                ),
                backgroundColor: const Color(0xFF0C7519),
                leading: GestureDetector(
                  child: Image.asset(
                    'assets/imgs/icons/icon_snowLive_back.png',
                    color: SDSColor.snowliveWhite,
                    scale: 4,
                    width: 26,
                    height: 26,
                  ),
                  onTap: () => Get.back(),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                  height: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_snowballShopViewModel.summary[0].remaining}',
                                  style: SDSTextStyle.regular.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                  height: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_snowballShopViewModel.summary[1].remaining}',
                                  style: SDSTextStyle.regular.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: _snowballShopViewModel.isLoading.value
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFF0C7519),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          backgroundColor: SDSColor.gray100,
                          color: SDSColor.gray300.withOpacity(0.6),
                        ),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          strokeWidth: 2,
                          edgeOffset: -40,
                          displacement: 40,
                          backgroundColor: const Color(0xFF0C7519),
                          color: SDSColor.snowliveWhite,
                          onRefresh: () async {
                            await _snowballShopViewModel.fetchSnowballShop(
                              isTierOnly: true,
                              isForMission: false,
                            );
                          },
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification notification) {
                              if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 50) {
                                final nextUrl = _snowballShopViewModel.nextPageUrlShop;
                                if (nextUrl != null && nextUrl.isNotEmpty && !_snowballShopViewModel.isMoreLoading.value) {
                                  _snowballShopViewModel.fetchSnowballShop(
                                    isTierOnly: true,
                                    isForMission: false,
                                    url: nextUrl,
                                  );
                                }
                              }
                              return false;
                            },
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '획득한 눈송이는 당일에 사용하지 않으면 모두 사라집니다',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                        color: const Color(0xFFFFFFFF).withOpacity(0.6),
                                      ),
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
                                      itemCount: _snowballShopViewModel.shopItems.length,
                                      itemBuilder: (context, index) {
                                        final item = _snowballShopViewModel.shopItems[index];
                                        return Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                if (item.itemCount == 0) return;

                                                final updatedItem = _snowballShopViewModel.shopItems.firstWhere(
                                                  (updated) => updated.snowballItemId == item.snowballItemId,
                                                  orElse: () => SnowballShopItem(itemCount: 0),
                                                );

                                                if (updatedItem.itemCount == 0) return;

                                                _snowballShopViewModel.selectItem(item);

                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: const Color(0xFF0C7519),
                                                  builder: (BuildContext context) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(context).pop(),
                                                      child: SafeArea(
                                                        child: Container(
                                                          decoration: const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(16),
                                                              topRight: Radius.circular(16),
                                                            ),
                                                            color: Color(0xFF0C7519),
                                                          ),
                                                          padding: const EdgeInsets.only(
                                                            bottom: 16,
                                                            right: 16,
                                                            left: 16,
                                                            top: 12,
                                                          ),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(bottom: 20),
                                                                child: Center(
                                                                  child: Container(
                                                                    width: 40,
                                                                    height: 4,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.grey[300],
                                                                      borderRadius: BorderRadius.circular(2),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  const SizedBox(height: 4),
                                                                  SizedBox(
                                                                    width: 113,
                                                                    height: 113,
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(4),
                                                                      child: ExtendedImage.network(
                                                                        item.imageUrl ?? '',
                                                                        width: 120,
                                                                        height: 120,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 16),
                                                                  Text(
                                                                    item.name ?? '상품 이름',
                                                                    style: SDSTextStyle.bold.copyWith(
                                                                      fontSize: 16,
                                                                      color: SDSColor.snowliveWhite,
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                  const SizedBox(height: 6),
                                                                  Text(
                                                                    item.description ?? '',
                                                                    textAlign: TextAlign.center,
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 13,
                                                                      color: Colors.white.withOpacity(0.5),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 24),
                                                                  if (_snowballShopViewModel.isPremiumUser.value == false)
                                                                    Text(
                                                                      '랭킹 등급 골드 이상만 구매 가능합니다.',
                                                                      textAlign: TextAlign.center,
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 13,
                                                                        color: const Color(0xFFFFFFFF),
                                                                      ),
                                                                    ),
                                                                  const SizedBox(height: 12),
                                                                  if (item.isFieldGame == false)
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      children: [
                                                                        if (item.landingUrl != null && item.landingUrl != '')
                                                                          Expanded(
                                                                            child: ElevatedButton(
                                                                              onPressed: () async {
                                                                                await otherShare(
                                                                                  contents: '${item.landingUrl}',
                                                                                );
                                                                              },
                                                                              style: TextButton.styleFrom(
                                                                                shape: const RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                ),
                                                                                splashFactory: InkRipple.splashFactory,
                                                                                elevation: 0,
                                                                                minimumSize: const Size(100, 48),
                                                                                backgroundColor: const Color(0xFF86ED3D),
                                                                              ),
                                                                              child: Text(
                                                                                '상세 정보 보기',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                  color: SDSColor.snowliveBlack,
                                                                                  fontSize: 16,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if (item.landingUrl != null && item.landingUrl != '') const SizedBox(width: 10),
                                                                        if (_snowballShopViewModel.isPremiumUser.value)
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
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    AspectRatio(
                                                      aspectRatio: 1,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(4),
                                                        child: Container(
                                                          color: Colors.white,
                                                          child: Stack(
                                                            children: [
                                                              Center(
                                                                child: Container(
                                                                  color: SDSColor.snowliveWhite,
                                                                  child: ExtendedImage.network(
                                                                    item.imageUrl ?? '',
                                                                    enableMemoryCache: true,
                                                                    fit: BoxFit.cover,
                                                                    loadStateChanged: (ExtendedImageState state) {
                                                                      switch (state.extendedImageLoadState) {
                                                                        case LoadState.loading:
                                                                          return Shimmer.fromColors(
                                                                            baseColor: Colors.grey[200]!,
                                                                            highlightColor: Colors.grey[50]!,
                                                                            child: Container(
                                                                              decoration: const BoxDecoration(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        case LoadState.completed:
                                                                          return state.completedWidget;
                                                                        case LoadState.failed:
                                                                          return Image.asset(
                                                                            'assets/imgs/imgs/img_flea_default.png',
                                                                            fit: BoxFit.cover,
                                                                          );
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              if (item.itemCount == 0)
                                                                Positioned(
                                                                  top: 0,
                                                                  bottom: 0,
                                                                  right: 0,
                                                                  left: 0,
                                                                  child: Container(
                                                                    color: SDSColor.sBlue900.withOpacity(0.8),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      item.name ?? '상품 이름',
                                                      style: SDSTextStyle.bold.copyWith(
                                                        fontSize: 12,
                                                        color: SDSColor.snowliveWhite,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(width: 1),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                                              height: 12,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${item.price![0].snowballCount ?? 0}',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                                              height: 12,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${item.price![1].snowballCount ?? 0}',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    if (item.itemCount != 0)
                                                      Text(
                                                        '잔여 수량 ${item.itemCount}개',
                                                        style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 12,
                                                          color: const Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    if (item.itemCount == 0)
                                                      Text(
                                                        '품절',
                                                        style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 12,
                                                          color: const Color(0xFF000000),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    Obx(
                                      () => _snowballShopViewModel.isMoreLoading.value
                                          ? Container(
                                              height: 100,
                                              padding: const EdgeInsets.only(bottom: 75),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 4,
                                                        backgroundColor: SDSColor.gray100,
                                                        color: SDSColor.gray300.withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    '경품 교환 목록',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
