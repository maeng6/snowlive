import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/themeStore/vm_themeStore.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ThemestoreHomeView extends StatefulWidget {
  @override
  State<ThemestoreHomeView> createState() => _ThemestoreHomeViewState();
}

class _ThemestoreHomeViewState extends State<ThemestoreHomeView> {
  late ThemeStoreViewModel _themeStoreViewModel;
  late UserViewModel _userViewModel;

  @override
  void initState() {
    super.initState();
    _themeStoreViewModel = Get.find<ThemeStoreViewModel>();
    _userViewModel = Get.find<UserViewModel>();

    // ✅ initState에서 데이터 fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeStoreViewModel.fetchThemeStoreMain();
    });
  }

  String _formatWon(int? value) {
    if (value == null) return '';
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              _themeStoreViewModel.themeStore?.name ?? '기획전',
              style: SDSTextStyle.bold.copyWith(
                color: SDSColor.gray900,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.white,
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                color: SDSColor.gray900,
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                Get.back();
              },
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.themestoreBuyRecord);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Icon(
                      Icons.receipt_long,
                      color: SDSColor.gray900,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: _themeStoreViewModel.isLoading.value
            ? Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: SDSColor.gray100,
                color: const Color(0xFF3D83ED),
              ),
            ),
          ),
        )
            : RefreshIndicator(
          strokeWidth: 2,
          backgroundColor: const Color(0xFF3D83ED),
          color: SDSColor.snowliveWhite,
          onRefresh: () async {
            await _themeStoreViewModel.fetchThemeStoreMain();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // 메인 이미지
              if (_themeStoreViewModel.themeStore?.mainImageUrl != null &&
                  _themeStoreViewModel.themeStore!.mainImageUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  child: ExtendedImage.network(
                    _themeStoreViewModel.themeStore!.mainImageUrl!,
                    fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[50]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          );
                        case LoadState.completed:
                          return null;
                        case LoadState.failed:
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.error, color: Colors.grey),
                            ),
                          );
                      }
                    },
                  ),
                ),

              // 상품 그리드
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: _themeStoreViewModel.themestoreItems.length,
                  itemBuilder: (context, index) {
                    final item = _themeStoreViewModel.themestoreItems[index];
                    final isOutOfStock = (item.remainingCount ?? 0) == 0;

                    return GestureDetector(
                      onTap: () async {
                        if (isOutOfStock) return;

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFF3D83ED),
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
                                    color: Color(0xFF3D83ED),
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
                                      // 상단 닫기 바
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
                                          // 이미지
                                          SizedBox(
                                            width: 200,
                                            height: 200,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: ExtendedImage.network(
                                                item.imageUrl ?? '',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // 상품명
                                          Text(
                                            item.name ?? '상품 이름',
                                            style: SDSTextStyle.bold.copyWith(
                                              fontSize: 18,
                                              color: SDSColor.snowliveWhite,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // 가격
                                          if (item.priceEvent != null && item.priceEvent! > 0)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${_formatWon(item.priceOrigin)}원',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 14,
                                                    color: Colors.white.withOpacity(0.5),
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${_formatWon(item.priceEvent)}원',
                                                  style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 18,
                                                    color: SDSColor.snowliveWhite,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (item.priceEvent == null || item.priceEvent == 0)
                                            Text(
                                              '${_formatWon(item.priceOrigin)}원',
                                              style: SDSTextStyle.bold.copyWith(
                                                fontSize: 18,
                                                color: SDSColor.snowliveWhite,
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          // 설명
                                          if (item.description != null && item.description!.isNotEmpty)
                                            Text(
                                              item.description ?? '',
                                              textAlign: TextAlign.center,
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                          const SizedBox(height: 24),
                                          // 버튼들
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              if (item.landingUrl != null && item.landingUrl!.isNotEmpty)
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      final uri = Uri.parse(item.landingUrl!);
                                                      if (await canLaunchUrl(uri)) {
                                                        await launchUrl(
                                                          uri,
                                                          mode: LaunchMode.externalApplication,
                                                        );
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                      ),
                                                      splashFactory: InkRipple.splashFactory,
                                                      elevation: 0,
                                                      minimumSize: const Size(100, 48),
                                                      backgroundColor: const Color(0xFF1C3F70),
                                                    ),
                                                    child: Text(
                                                      '상세 정보 보기',
                                                      style: SDSTextStyle.bold.copyWith(
                                                        color: SDSColor.snowliveWhite,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (item.landingUrl != null && item.landingUrl!.isNotEmpty)
                                                const SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);

                                                    if (item.payUrl != null && item.payUrl!.isNotEmpty) {
                                                      final uri = Uri.parse(item.payUrl!);
                                                      if (await canLaunchUrl(uri)) {
                                                        await launchUrl(
                                                          uri,
                                                          mode: LaunchMode.externalApplication,
                                                        );
                                                      }
                                                    } else {
                                                      // 구매 정보 입력 페이지로 이동
                                                      Get.toNamed(
                                                        AppRoutes.themestoreInputInfo,
                                                        arguments: item,
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                                    ),
                                                    splashFactory: InkRipple.splashFactory,
                                                    elevation: 0,
                                                    minimumSize: const Size(100, 48),
                                                    backgroundColor: SDSColor.snowliveWhite,
                                                  ),
                                                  child: Text(
                                                    '구매하기',
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

                      // ✅ 그리드 카드 UI (테두리 제거)
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey[100],
                                    child: ExtendedImage.network(
                                      item.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      loadStateChanged: (ExtendedImageState state) {
                                        switch (state.extendedImageLoadState) {
                                          case LoadState.loading:
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[200]!,
                                              highlightColor: Colors.grey[50]!,
                                              child: Container(color: Colors.white),
                                            );
                                          case LoadState.completed:
                                            return null;
                                          case LoadState.failed:
                                            return const Center(
                                              child: Icon(Icons.image, color: Colors.grey),
                                            );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                if (isOutOfStock)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '품절',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 14,
                                            color: SDSColor.snowliveWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (item.size != null && item.size!.isNotEmpty)
                            Text(
                              item.size!,
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 12,
                                color: SDSColor.gray500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 4),

                          Text(
                            item.name ?? '상품 이름',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              if (item.discountPerct != null && item.discountPerct! > 0) ...[
                                Text(
                                  '${item.discountPerct}%',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 14,
                                    color: const Color(0xFFFF3B3B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (item.priceEvent != null && item.priceEvent! > 0) ...[
                                Text(
                                  '${_formatWon(item.priceOrigin)}원',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 12,
                                    color: SDSColor.gray400,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${_formatWon(item.priceEvent)}원',
                                    style: SDSTextStyle.bold.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: Text(
                                    '${_formatWon(item.priceOrigin)}원',
                                    style: SDSTextStyle.bold.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
