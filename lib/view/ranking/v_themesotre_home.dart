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

  // 스크롤 컨트롤러 및 FAB 표시 상태
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double _lastScrollPosition = 0;
  double _scrollThreshold = 50; // 스크롤 감도 조절 (픽셀 단위)

  @override
  void initState() {
    super.initState();
    _themeStoreViewModel = Get.find<ThemeStoreViewModel>();
    _userViewModel = Get.find<UserViewModel>();

    // 스크롤 리스너 설정
    _scrollController.addListener(_onScroll);

    // ✅ initState에서 데이터 fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeStoreViewModel.fetchThemeStoreMain();
    });
  }

  void _onScroll() {
    final currentPosition = _scrollController.position.pixels;
    final difference = currentPosition - _lastScrollPosition;

    // 스크롤 방향과 threshold 체크
    if (difference > _scrollThreshold) {
      // 아래로 스크롤 - FAB 숨김
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
      _lastScrollPosition = currentPosition;
    } else if (difference < -_scrollThreshold) {
      // 위로 스크롤 - FAB 표시
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
      _lastScrollPosition = currentPosition;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
                    child: Text('구매 내역',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabVisible ? 1.0 : 0.0,
            child: Container(
              height: 40,
              child: FloatingActionButton.extended(
                onPressed: null,
                backgroundColor: _themeStoreViewModel.isPermitted
                    ? SDSColor.snowliveWhite
                    : SDSColor.snowliveBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: _themeStoreViewModel.isPermitted
                      ? const BorderSide(color: Color(0xFF3D83ED), width: 2)
                      : BorderSide.none,
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _themeStoreViewModel.isPermitted
                          ? 'assets/imgs/icons/icon_theme_unlock.png'
                          : 'assets/imgs/icons/icon_theme_lock.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    _themeStoreViewModel.isPermitted
                        ? Text(
                            '라이딩 완료! 원하시는 상품 구매가 가능합니다',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 12,
                              color: SDSColor.snowliveBlack,
                            ),
                          )
                        : Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '구매제한 상태에요.',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 12,
                                    color: SDSColor.snowliveWhite.withOpacity(0.6),
                                  ),
                                ),
                                TextSpan(
                                  text: '1회 라이딩 완료',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 12,
                                    color: SDSColor.snowliveWhite,
                                  ),
                                ),
                                TextSpan(
                                  text: '하면 구매하실 수 있어요',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 12,
                                    color: SDSColor.snowliveWhite.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            controller: _scrollController,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // 메인 이미지
              if (_themeStoreViewModel.themeStore?.mainImageUrl != null &&
                  _themeStoreViewModel.themeStore!.mainImageUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  child: ExtendedImage.network(
                    _themeStoreViewModel.themeStore!.mainImageUrl!,
                    fit: BoxFit.cover,
                    cache: true,
                    enableMemoryCache: true,
                    clearMemoryCacheWhenDispose: false,
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
                padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: _themeStoreViewModel.themestoreItems.length,
                  itemBuilder: (context, index) {
                    final item = _themeStoreViewModel.themestoreItems[index];
                    final isOutOfStock = (item.remainingCount ?? 0) == 0;

                    return GestureDetector(
                      onTap: () async {

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: SDSColor.snowliveWhite,
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
                                    color: SDSColor.snowliveWhite,
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
                                            width: 120,
                                            height: 120,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: ExtendedImage.network(
                                                item.imageUrl ?? '',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            item.brandName ?? '브랜드 이름',
                                            style: SDSTextStyle.regular.copyWith(
                                              fontSize: 13,
                                              color: SDSColor.snowliveBlack,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          // 상품명
                                          Text(
                                            item.name ?? '상품 이름',
                                            style: SDSTextStyle.bold.copyWith(
                                              fontSize: 16,
                                              color: SDSColor.snowliveBlack,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // 설명
                                          if (item.description != null && item.description!.isNotEmpty)
                                            Text(
                                              item.description ?? '',
                                              textAlign: TextAlign.center,
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: Colors.black.withOpacity(0.6),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Size',
                                                style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 14,
                                                  color: SDSColor.snowliveBlack,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                item.size ?? '',
                                                style: SDSTextStyle.bold.copyWith(
                                                  fontSize: 14,
                                                  color: SDSColor.snowliveBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          // 가격
                                          if (item.priceEvent != null && item.priceEvent! > 0)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${_formatWon(item.priceOrigin)}원',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 16,
                                                    color: Colors.black.withOpacity(0.2),
                                                    decoration: TextDecoration.lineThrough,
                                                    decorationColor: Colors.black.withOpacity(0.2),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  '${item.discountPerct}%',
                                                  style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 16,
                                                    color: const Color(0xFFFF3B3B),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${_formatWon(item.priceEvent)}원',
                                                  style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 16,
                                                    color: SDSColor.snowliveBlack,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (item.priceEvent == null || item.priceEvent == 0)
                                            Text(
                                              '${_formatWon(item.priceOrigin)}원',
                                              style: SDSTextStyle.bold.copyWith(
                                                fontSize: 16,
                                                color: SDSColor.snowliveBlack,
                                              ),
                                            ),
                                          // 상품명
                                          const SizedBox(height: 40),
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
                                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                                      ),
                                                      splashFactory: NoSplash.splashFactory,
                                                      elevation: 0,
                                                      minimumSize: const Size(100, 48),
                                                      backgroundColor: const Color(0xFF7C899D),
                                                    ),
                                                    child: Text(
                                                      '제품 정보 보기',
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

                                                    if(isOutOfStock || _themeStoreViewModel.isPermitted == false) return;

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
                                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    ),
                                                    splashFactory: NoSplash.splashFactory,
                                                    elevation: 0,
                                                    minimumSize: const Size(100, 48),
                                                    backgroundColor:
                                                    isOutOfStock
                                                        ? SDSColor.snowliveBlack
                                                        : (!_themeStoreViewModel.isPermitted
                                                        ? Color(0xFFDEDEDE)
                                                        : Color(0xFF3D83ED)),
                                                  ),
                                                  child: Text(
                                                    isOutOfStock
                                                        ? '품절'
                                                        : (!_themeStoreViewModel.isPermitted
                                                        ? '구매제한'
                                                        : '구매 예약 하기'),
                                                    style: SDSTextStyle.bold.copyWith(
                                                      color: SDSColor.snowliveWhite,
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
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            child: Text(
                                              '품절',
                                              style: SDSTextStyle.bold.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.snowliveBlack,
                                              ),
                                            ),
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
                              item.brandName ?? '브랜드 이름',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 12,
                                color: SDSColor.snowliveBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 4),

                          Text(
                            item.name ?? '상품 이름',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 14,
                              color: SDSColor.snowliveBlack,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (item.discountPerct != null && item.discountPerct! > 0)
                              Text(
                                  '${item.discountPerct}%',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 16,
                                    color: const Color(0xFFFF3B3B),
                                  ),
                                ),
                              const SizedBox(width: 2),
                              Text(
                                '${_formatWon(item.priceEvent)}원',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 16,
                                  color: SDSColor.snowliveBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 안내사항
              Container(
                margin: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안내사항',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 14,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildNoticeItem('라이딩 시 꼭 라이브온 상태에서 라이딩을 완료해주셔야 구매 예약 버튼이 활성화됩니다.'),
                    const SizedBox(height: 6),
                    _buildNoticeItem('구매 예약 완료된 상품은 입력해주신 정보로 연락을 드릴 예정입니다.'),
                    const SizedBox(height: 6),
                    _buildNoticeItem('24시간 이내에 최종 결제까지 완료해주셔야 되며, 완료되지 않은 상품은 자동 구매 취소 처리가 됩니다.'),
                    const SizedBox(height: 6),
                    _buildNoticeItem('상품은 브랜드 재고 상황에 따라 조기 품절될 수 있는 점 양해 부탁 드립니다.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              color: SDSColor.gray500,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: SDSTextStyle.regular.copyWith(
              fontSize: 13,
              color: SDSColor.gray600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
