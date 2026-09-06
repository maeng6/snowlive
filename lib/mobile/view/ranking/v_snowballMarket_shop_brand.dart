import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_forestPark.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/mobile/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SnowballMarketBrandShopView extends StatefulWidget {
  @override
  State<SnowballMarketBrandShopView> createState() => _SnowballMarketBrandShopViewState();
}

class _SnowballMarketBrandShopViewState extends State<SnowballMarketBrandShopView> {
  final SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  bool _hasFetchedData = false;


  // 단일 선택 상태
  int? _selectedBrandId;
  void _toggleBrand(int id) {
    setState(() {
      _selectedBrandId = (_selectedBrandId == id) ? null : id;
    });
  }

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

        // 최초 1회만 상점/미션 데이터 로드
        if (!_hasFetchedData) {
          _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: true);
          _hasFetchedData = true;
        }

        // ---- Reactive UI ----
        return Obx(() {
          final ms = _snowballShopViewModel.missionStatus;
          final badgeUrl = _snowballShopViewModel.missionStatus.badgeUrl;

          // 1) 콘솔 로그: Obx 빌드 시마다 최신 값 출력
          debugPrint('[MS] isApplied=${ms.isApplied} '
              'appliedBrandId=${ms.snowballSponsorId} '
              'badgeUrl=${ms.badgeUrl} '
              'applyNo=${ms.missionApplyId} '
              'sponsorEngName=${ms.sponsorEngName} '
              'totalComplete=${ms.completeTotal} '
              'selectedBrandId=$_selectedBrandId '
              'brandItemPremium.len=${ms.brandItemPremium?.length ?? 0}');

          // 필드명은 프로젝트에 맞게 확인 필요
          final bool totalComplete = ms.completeTotal == true;     // 모든 미션 완료
          final bool isApplied     = ms.isApplied == true;         // 이미 응모 완료
          final int? appliedBrandId = _snowballShopViewModel.missionStatus.snowballItemBrandId;      // 서버가 저장한 응모 브랜드 id

          // 응모 완료 상태면 UI의 선택값을 서버 값으로 고정
          if (isApplied && appliedBrandId != null && _selectedBrandId != appliedBrandId) {
            _selectedBrandId = appliedBrandId;
          }

          // 버튼 활성화 조건: 전부 완료 && 아직 미응모 && 선택됨
          final bool canApply = totalComplete && !isApplied && _selectedBrandId != null;
          Size _size = MediaQuery.of(context).size;


          return Scaffold(
            backgroundColor: const Color(0xFF081322),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: AppBar(
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  '브랜드 미션',
                  style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 16),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFF081322),
                leading: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26, colorFilter: ColorFilter.mode(SDSColor.snowliveWhite, BlendMode.srcIn)),
                    highlightColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RefreshIndicator(
                      strokeWidth: 2,
                      edgeOffset: -40,
                      displacement: 40,
                      backgroundColor: const Color(0xFF3D83ED),
                      color: SDSColor.snowliveWhite,
                      onRefresh: () async {
                        await _snowballShopViewModel.fetchSnowballHomeData();
                        await _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: true);
                        await _snowballShopViewModel.fetchMissionStatus();
                      },
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              // ===== 눈송이 사용 기한 안내 문구=====
                              // const _TopNotice(),
                              SizedBox(
                                height: 10,
                              ),
                              // ===== 브랜드 미션 뱃지=====
                                Stack(
                                  children: [
                                    Image.asset(
                                      'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_bg.png',
                                      width: _size.width,
                                    ),
                                    if (badgeUrl == null || badgeUrl.isEmpty)
                                    Center(
                                      child: Image.asset(
                                        'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_badge.png',
                                        width: _size.width - 40,
                                        height: _size.width - 40,
                                      ),
                                    )
                                    else
                                      Center(
                                        child: Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // 1️⃣ 배지 이미지 (네트워크 or 로컬)
                                                if (badgeUrl.isEmpty)
                                                  Image.asset(
                                                    'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_badge.png',
                                                    width: _size.width - 40,
                                                    height: _size.width - 40,
                                                    fit: BoxFit.contain,
                                                  )
                                                else
                                                  ExtendedImage.network(
                                                    badgeUrl,
                                                    width: 340,
                                                    fit: BoxFit.contain,
                                                    loadStateChanged: (state) {
                                                      switch (state.extendedImageLoadState) {
                                                        case LoadState.loading:
                                                          return SizedBox(
                                                            width: _size.width - 40,
                                                            height: _size.width - 40,
                                                            child: Center(
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          );
                                                        case LoadState.failed:
                                                          return Image.asset(
                                                            'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_badge.png',
                                                            width: _size.width - 40,
                                                            height: _size.width - 40,
                                                            fit: BoxFit.contain,
                                                          );
                                                        case LoadState.completed:
                                                          return state.completedWidget;
                                                      }
                                                    },
                                                  ),
                                                // 2️⃣ 응모번호 (리본 위쪽에 겹쳐 표시)
                                                Positioned(
                                                  bottom: 30,
                                                  child: Text('${_snowballShopViewModel.missionStatus.missionApplyId}',
                                                    style: TextStyle(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white,

                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // 3️⃣ 유저 이름
                                            Text(
                                              '${_userViewModel.user.display_name}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '${_snowballShopViewModel.missionStatus.sponsorEngName}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white.withOpacity(0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 30),
                              // ===== 브랜드 미션 설명 문구=====
                              const _HeroText(),
                              const SizedBox(height: 24),
                              // ===== 미션 달성 현황 영역=====
                              _MissionProgressRow(),
                              const SizedBox(height: 100),
                              // ===== 브랜드 응모 영역 상단 문구=====
                              const _ChooseTitle(),
                              const SizedBox(height: 50),
                              // // ===== 경품 구경하기=====
                              // Align(
                              //   child: SizedBox(
                              //     width: 124, // ⬅️ 좌우 여백 주고 가운데 정렬 (필요시 200~260 사이로 조절)
                              //     height: 40,
                              //     child: ElevatedButton(
                              //       onPressed: () {
                              //         // 캐러셀에 쓸 데이터: 브랜드 아이템 프리미엄
                              //         final brands = _snowballShopViewModel.missionStatus.brandItemPremium ?? [];
                              //
                              //         if (brands.isEmpty) {
                              //           ScaffoldMessenger.of(context).showSnackBar(
                              //             SnackBar(
                              //               content: SizedBox(
                              //                 width: _size.width - 32,
                              //                 height: 40,
                              //                 child: Center(
                              //                   child: Text(
                              //                     '브랜드 경품이 아직 준비되지 않았어요.',
                              //                     textAlign: TextAlign.center,
                              //                     style: const TextStyle(
                              //                       color: Colors.white,
                              //                       fontSize: 14,
                              //                       fontWeight: FontWeight.w400,
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //               backgroundColor: Colors.black.withOpacity(0.8),
                              //               behavior: SnackBarBehavior.floating,
                              //               margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              //               padding: const EdgeInsets.symmetric(
                              //                 horizontal: 16,
                              //                 vertical: 8,
                              //               ),
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius: BorderRadius.circular(8),
                              //               ),
                              //               elevation: 0,
                              //               duration: const Duration(seconds: 2),
                              //             ),
                              //           );
                              //           return;
                              //         }
                              //
                              //         // 시작 페이지: 현재 선택한 브랜드가 있으면 거기서 시작
                              //         final initialPage = (_selectedBrandId != null)
                              //             ? brands.indexWhere((b) => b.snowballItemBrandId == _selectedBrandId)
                              //             : 0;
                              //
                              //         final startPage = (initialPage >= 0) ? initialPage : 0;
                              //
                              //         showModalBottomSheet(
                              //           context: context,
                              //           isScrollControlled: true,
                              //           backgroundColor: const Color(0xFF3D83ED),
                              //           builder: (BuildContext context) {
                              //             final pageController = PageController(initialPage: startPage);
                              //             int currentPage = startPage;
                              //
                              //             return GestureDetector(
                              //               onTap: () => Navigator.of(context).pop(), // 바깥 탭 시 닫기
                              //               child: SafeArea(
                              //                 child: Container(
                              //                   decoration: const BoxDecoration(
                              //                     color: Color(0xFF3D83ED),
                              //                     borderRadius: BorderRadius.only(
                              //                       topLeft: Radius.circular(16),
                              //                       topRight: Radius.circular(16),
                              //                     ),
                              //                   ),
                              //                   padding: const EdgeInsets.only(bottom: 16, top: 12),
                              //                   child: StatefulBuilder(
                              //                     builder: (context, setState) {
                              //                       return Column(
                              //                         mainAxisSize: MainAxisSize.min,
                              //                         children: [
                              //                           // 상단 핸들
                              //                           const Padding(
                              //                             padding: EdgeInsets.only(bottom: 20),
                              //                             child: Center(
                              //                               child: _BottomSheetHandle(),
                              //                             ),
                              //                           ),
                              //
                              //                           // ===== 캐러셀(브랜드 아이템) =====
                              //                           SizedBox(
                              //                             height: 260, // 이미지+텍스트 영역 높이
                              //                             child: PageView.builder(
                              //                               controller: pageController,
                              //                               itemCount: brands.length,
                              //                               onPageChanged: (i) => setState(() => currentPage = i),
                              //                               itemBuilder: (context, i) {
                              //                                 final b = brands[i];
                              //                                 final logo = b.sponsor?.logoUrl;
                              //                                 final bgUrl = (b.image_url_bg ?? '').trim();
                              //
                              //                                 return Stack(
                              //                                   children: [
                              //                                     // ===== 배경 이미지 =====
                              //                                     if (bgUrl.isNotEmpty)
                              //                                       Positioned.fill(
                              //                                         child: ExtendedImage.network(
                              //                                           bgUrl,
                              //                                           fit: BoxFit.cover,
                              //                                           cache: true,
                              //                                         ),
                              //                                       ),
                              //
                              //
                              //                                     // ===== 본문 콘텐츠 =====
                              //                                     Padding(
                              //                                       padding: EdgeInsets.symmetric(horizontal: 30),
                              //                                       child: Column(
                              //                                         mainAxisSize: MainAxisSize.min,
                              //                                         children: [
                              //                                           // 이미지
                              //                                           ExtendedImage.network(
                              //                                             b.imageUrl ?? '',
                              //                                             width: 80,
                              //                                             fit: BoxFit.cover,
                              //                                           ),
                              //                                           const SizedBox(height: 14),
                              //                                           // 타이틀
                              //                                           Text(
                              //                                             b.name ?? '상품 이름',
                              //                                             textAlign: TextAlign.center,
                              //                                             style: SDSTextStyle.bold.copyWith(
                              //                                               fontSize: 16,
                              //                                               color: SDSColor.snowliveWhite,
                              //                                             ),
                              //                                             maxLines: 1,
                              //                                             overflow: TextOverflow.ellipsis,
                              //                                           ),
                              //                                           const SizedBox(height: 6),
                              //                                           // 설명
                              //                                           Text(
                              //                                             b.description ?? '',
                              //                                             textAlign: TextAlign.center,
                              //                                             style: SDSTextStyle.regular.copyWith(
                              //                                               fontSize: 12,
                              //                                               color: Colors.white.withOpacity(0.7),
                              //                                             ),
                              //                                             maxLines: 2,
                              //                                             overflow: TextOverflow.ellipsis,
                              //                                           ),
                              //                                         ],
                              //                                       ),
                              //                                     ),
                              //
                              //                                     // ===== 우상단 스폰서 로고 =====
                              //                                     if (logo != null && logo.isNotEmpty)
                              //                                       Positioned(
                              //                                         right: 20,
                              //                                         child: _SponsorSticker(logoUrl: logo),
                              //                                       ),
                              //                                   ],
                              //                                 );
                              //                               },
                              //                             ),
                              //
                              //                           ),
                              //
                              //                           // 인디케이터(점)
                              //                           const SizedBox(height: 6),
                              //                           Row(
                              //                             mainAxisAlignment: MainAxisAlignment.center,
                              //                             children: List.generate(brands.length, (i) {
                              //                               final active = i == currentPage;
                              //                               return AnimatedContainer(
                              //                                 duration: const Duration(milliseconds: 200),
                              //                                 margin: const EdgeInsets.symmetric(horizontal: 3),
                              //                                 width: active ? 12 : 6,
                              //                                 height: 6,
                              //                                 decoration: BoxDecoration(
                              //                                   color: active ? Colors.white : Color(0xFF2467CC),
                              //                                   borderRadius: BorderRadius.circular(4),
                              //                                 ),
                              //                               );
                              //                             }),
                              //                           ),
                              //                           const SizedBox(height: 10),
                              //                         ],
                              //                       );
                              //                     },
                              //                   ),
                              //                 ),
                              //               ),
                              //             );
                              //           },
                              //         );
                              //       },
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: Colors.white,
                              //         elevation: 0,
                              //         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(20),
                              //         ),
                              //       ),
                              //       child: Row(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         children: [
                              //           Text(
                              //             '경품 구경하기',
                              //             style: SDSTextStyle.bold.copyWith(
                              //               color: Colors.black,
                              //               fontSize: 13,
                              //             ),
                              //           ),
                              //           const SizedBox(width: 8),
                              //           Image.asset(
                              //             'assets/imgs/imgs/snowballShop/icon_snowballshop_arrow_b.png',
                              //             width: 16,
                              //             height: 16,
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 32),
                              // ===== 브랜드 미션 선택 그리드 =====
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 0.82,
                                  ),
                                  itemCount: _snowballShopViewModel.missionStatus.brandItemPremium?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final item = _snowballShopViewModel.missionStatus.brandItemPremium![index];
                                    final id = item.snowballItemBrandId ?? index;

                                    // isApplied면 서버 appliedBrandId 기준으로 강조/디밍
                                    final bool selected = isApplied && appliedBrandId != null
                                        ? (id == appliedBrandId)
                                        : (_selectedBrandId == id);

                                    return _BrandChoiceCard(
                                      title: (item.sponsor?.nameEng ?? '').toUpperCase(),
                                      subtitle: item.sponsor?.name ?? '',
                                      imageUrl: item.imageUrl ?? '',
                                      description: item.description ?? '',
                                      selected: selected,
                                      onTap: () {
                                        if (isApplied) return; // 응모 완료 후 탭 불가
                                        _toggleBrand(id);
                                      },

                                      // 응모 완료 후 UI 규칙
                                      showCheckbox: !isApplied,           // 응모 완료면 체크 숨김
                                      disabled: isApplied,                // 응모 완료면 탭 비활성
                                      dim: isApplied && !selected,        // 응모 완료면 비선택 카드 디밍
                                      emphasized: isApplied && selected,  // 응모 완료면 선택 카드 강조
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 80),
                              // ===== 경품 추첨 방법 설명 문구=====
                              const _DrawHowTo(),
                              const SizedBox(height: 80),
                              // ===== 추가 경품 리스트 (기존 로직 유지) =====
                              const _ExtraPrizeTitle(),
                              const SizedBox(height: 24),
                              GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 11 / 16,
                                ),
                                itemCount: _snowballShopViewModel.shopItems.length,
                                itemBuilder: (context, index) {
                                  final item = _snowballShopViewModel.shopItems[index];
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if (item.itemCount == 0) return;

                                          CustomFullScreenDialog.showDialog();
                                          await _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: true);
                                          CustomFullScreenDialog.cancelDialog();

                                          final updatedItem = _snowballShopViewModel.shopItems.firstWhere(
                                                (updated) => updated.snowballItemId == item.snowballItemId,
                                            orElse: () => SnowballShopItem(itemCount: 0),
                                          );
                                          if (updatedItem.itemCount == 0) return;

                                          _snowballShopViewModel.selectItem(item);

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
                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                      color: Color(0xFF3D83ED),
                                                    ),
                                                    padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 12),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        // 상단 닫기 핸들
                                                        const Padding(
                                                          padding: EdgeInsets.only(bottom: 20),
                                                          child: Center(
                                                            child: _BottomSheetHandle(),
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(height: 4),
                                                            Container(
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
                                                              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              item.description ?? '',
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                                                            ),
                                                            const SizedBox(height: 40),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                (item.landingUrl != null && item.landingUrl!.isNotEmpty)
                                                                    ? Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await otherShare(contents: item.landingUrl!);
                                                                    },
                                                                    style: TextButton.styleFrom(
                                                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                      splashFactory: InkRipple.splashFactory,
                                                                      elevation: 0,
                                                                      minimumSize: const Size(100, 48),
                                                                      backgroundColor: const Color(0xFF1C3F70),
                                                                    ),
                                                                    child: Text(
                                                                      '상세 정보 보기',
                                                                      style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 16),
                                                                    ),
                                                                  ),
                                                                )
                                                                    : Container(),
                                                                (item.landingUrl != null && item.landingUrl!.isNotEmpty) ? const SizedBox(width: 10) : Container(),
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
                                                                      child: Container(color: Colors.white),
                                                                    );
                                                                  case LoadState.completed:
                                                                    return state.completedWidget;
                                                                  case LoadState.failed:
                                                                    return Image.asset('assets/imgs/imgs/img_flea_default.png', fit: BoxFit.cover);
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        if (item.itemCount == 0)
                                                          Positioned.fill(
                                                            child: Container(color: SDSColor.sBlue900.withOpacity(0.8)),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                item.name ?? '상품 이름',
                                                style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.snowliveWhite),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ===== 하단 응모 버튼 =====
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: _size.width,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,      // 위쪽(0%)
                              end: Alignment.bottomCenter,     // 아래쪽(100%)
                              colors: [
                                Color(0x00081322),             // #030C19, opacity 0
                                Color(0xFF081322),             // #030C19, opacity 100
                              ],
                              stops: [0.0, 1.0],
                            ),
                          ),
                        ),
                        Container(
                          color: Color(0xFF081322),
                          padding: EdgeInsets.only(left: 16,right: 16,top: 10, bottom: 16),
                          child: SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              // ✅ 활성 조건: 모든 미션 완료 && 아직 응모 전 && 브랜드 선택됨
                              onPressed: (totalComplete && !isApplied && _selectedBrandId != null)
                                  ? () async {
                                final brands = _snowballShopViewModel.missionStatus.brandItemPremium ?? [];

                                // 1️⃣ 브랜드 데이터가 아직 준비되지 않은 경우 (빈 리스트)
                                if (brands.isEmpty) {
                                  await showApplySuccessPopup(
                                    context,
                                    title: '응모할 경품을 선택해주세요!',
                                    message: '응모할 경품을 선택 후.\n'
                                        '다시 응모 하기 버튼을 눌러주세요.',
                                  );
                                  return;
                                }

                                // 2️⃣ 정상 응모 절차
                                CustomFullScreenDialog.showDialog();
                                try {
                                  await _snowballShopViewModel.applyMission(_selectedBrandId!);
                                  await _snowballShopViewModel.fetchMissionStatus();
                                } finally {
                                  CustomFullScreenDialog.cancelDialog();
                                }

                                // 3️⃣ 응모 완료 안내 팝업
                                await showApplySuccessPopup(
                                  context,
                                  title: '브랜드 미션 응모 완료!',
                                  message: '상단에 표시된 추첨 번호를 확인해주세요.\n'
                                      '19시까지 경품 수령처로 모여주세요!',
                                );
                              }
                                  : null,


                              // ── 3가지 상태별 색상/라벨 계산
                              style: () {
                                final bool hasSelection = _selectedBrandId != null;
                                final bool canApply = totalComplete && !isApplied && hasSelection;

                                // 배경/글자색
                                final Color bgColor = isApplied
                                    ? const Color(0xFF112139)        // 응모완료: 남색 배경
                                    : (canApply
                                    ? const Color(0xFF3D83ED)     // 활성: 파랑
                                    : const Color(0xFFC8C8C8));   // 비활성: 회색

                                final Color fgColor = isApplied
                                    ? const Color(0xFF3D83ED)         // 응모완료: 파란 텍스트
                                    : (canApply
                                    ? Colors.white                 // 활성: 흰색
                                    : const Color(0xFFFFFFFF));    // 비활성: 연회색

                                return ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  padding: EdgeInsets.zero,
                                  backgroundColor: bgColor,
                                  foregroundColor: fgColor,
                                  // onPressed가 null일 때도 우리가 지정한 색을 그대로 쓰도록 지정
                                  disabledBackgroundColor: bgColor,
                                  disabledForegroundColor: fgColor,
                                );
                              }(),

                              child: Text(
                                isApplied ? '응모 완료' : '브랜드 미션 응모하기',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  // 색상은 styleFrom의 foregroundColor가 적용됨
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          );
        });
      },
    );
  }
}

//TODO: 눈송이 사용 기한 안내 문구**************************************************
class _TopNotice extends StatelessWidget {
  const _TopNotice();

  @override
  Widget build(BuildContext context) {
    return Text(
      '획득한 눈송이는 당일에 사용하지 않으면 모두 사라집니다',
      style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveBlue),
    );
  }
}
//TODO: 눈송이 사용 기한 안내 문구**************************************************



//TODO: 브랜드 미션 현황 상단 문구 & 미션 현황**************************************************
class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '브랜드 미션을 완수하라',
          style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text('아래 미션을 완료한 뒤 원하는 브랜드 경품에 응모하면',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.6))),
        Text('추첨을 통해 25/26 신상 의류를 드립니다',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.6))),
      ],
    );
  }
}
class _MissionProgressRow extends StatelessWidget {
  const _MissionProgressRow();

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<SnowballShopViewModel>();
    final SnowballCount count =
        vm.missionStatus.snowballCount ??
            SnowballCount(white: 0, gold: 0, white_on_slope: 0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _missionBlock(
            imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission1.png',
            imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission1_end.png',
            title: vm.missionTitle('mission_1'),
            done: vm.missionComplete('mission_1'),

          ),
          SizedBox(
            width: 14,
          ),
          _missionBlock(
            imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission2.png',
            imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission2_end.png',
            title: vm.missionTitle('mission_2'),
            done: vm.missionComplete('mission_2'),
          ),
          SizedBox(
            width: 14,
          ),
          _missionBlock(
            imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission3.png',
            imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission3_end.png',
            title: vm.missionTitle('mission_3'),
            done: vm.missionComplete('mission_3'),
          ),
          SizedBox(
            width: 14,
          ),
          _missionBlock(
            imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission4.png',
            imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission4_end.png',
            title: vm.missionTitle('mission_4'),
            done: vm.missionComplete('mission_4'),
          ),
        ],
      ),
    );
  }

  // // ── 숫자 기반 미션 (1~3)
  // Widget _missionBlock({
  //   required String imgNormal,
  //   required String imgDone,
  //   required String title,
  //   required int achieved,
  //   required int required,
  // }) {
  //   final bool isDone = achieved >= required;
  //   final int safeAchieved = achieved.clamp(0, required);
  //
  //   return Expanded(
  //     child: Column(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(16),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.12),
  //                 blurRadius: 10,
  //                 offset: const Offset(0, 6),
  //               ),
  //             ],
  //           ),
  //           child: ClipRRect(
  //               borderRadius: BorderRadius.circular(16),
  //               child: Image.asset(isDone ? imgDone : imgNormal)),
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           'MISSION',
  //           style: TextStyle(
  //             fontSize: 11,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white.withOpacity(0.5),
  //           ),
  //         ),
  //         const SizedBox(height: 2),
  //         Text(
  //           title,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(
  //             fontSize: 13,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //             height: 1.2,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         RichText(
  //           text: TextSpan(
  //             children: [
  //               TextSpan(
  //                 text: '$safeAchieved',
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               const TextSpan(
  //                 text: ' / ',
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white54,
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: '$required',
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white54,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── 미션4 (달성/미달성)
  Widget _missionBlock({
    required String imgNormal,
    required String imgDone,
    required String title,
    required bool done,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
                child: Image.asset(done ? imgDone : imgNormal)),
          ),
          const SizedBox(height: 10),
          Text(
            'MISSION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            done ? '달성' : '미달성',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: done ? Colors.white : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
//TODO: 브랜드 미션 현황 상단 문구 & 미션 현황**************************************************


//TODO: 브랜드 선택 박스 상단 문구 & 선택 박스**************************************************
class _ChooseTitle extends StatelessWidget {
  const _ChooseTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('원하는 브랜드의 경품을 선택하고',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('브랜드 미션 응모하기 버튼을 눌러주세요',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('브랜드마다 다양한 경품 구성!',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.6))),
        Text('나에게 필요한 브랜드를 선택하세요',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.6))),
        const SizedBox(height: 4),
        Text('12월 25일 : BSRABBIT, MAF',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite)),
        Text('12월 27일 : SPECIALGUEST, QMILE',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite)),
        const SizedBox(height: 8),
        Text('구성에 맞춰 상품을 직접 선택할 수 있어요',
            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveBlue)),
      ],
    );
  }
}
class _BrandChoiceCard extends StatelessWidget {
  const _BrandChoiceCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.description,
    required this.selected,
    required this.onTap,
    this.showCheckbox = true,
    this.disabled = false,
    this.dim = false,
    this.emphasized = false,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  final bool showCheckbox; // 체크 아이콘 표시
  final bool disabled;     // 탭 비활성
  final bool dim;          // 디밍 처리
  final bool emphasized;   // 강조 처리

  @override
  Widget build(BuildContext context) {
    final borderColor = emphasized
        ? Color(0xFFA4C7FC)
        : (selected ? const Color(0xFFA4C7FC) : const Color(0xFF324C73));

    final Gradient? bgGradient = emphasized
        ? LinearGradient(
      colors: [Color(0xFF14305E), Color(0xFF0F2444)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : null;

    final overlay = selected ? Colors.white.withOpacity(0.06) : Colors.transparent;

    // ⬇️ _BrandChoiceCard.build() 내부에서 card 만드는 부분만 교체
    Widget card = Container(
      decoration: BoxDecoration(
        color: emphasized ? Color(0xFF3D83ED) : Color(0xFF1F3553),
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: emphasized ? 2 : 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1) 우측으로 살짝 튀어나오는 큰 제품 이미지 (텍스트 뒤)
          Positioned(
            // 원하는 만큼 조절하세요
            right: -35,     // ➡️ 카드 오른쪽 밖으로 튀어나오게
            top: -18,
            bottom: 0,    // ⬇️ 세로도 카드보다 살짝 길어 보이게
            child: IgnorePointer(
              ignoring: true,
              child: Image.network(
                imageUrl,
                width: 190,            // 카드 크기에 맞춰 조절(160~210)
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2) 내용(체크배지 + 텍스트)은 왼쪽 아래
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCheckbox) const SizedBox(height: 2) else const SizedBox(height: 26),
                if (showCheckbox) _CheckBadge(selected: selected),
                const SizedBox(height: 16),  // 🔥 여기: Spacer 대신 10~20 정도 여백만

                // 제목/부제목은 이미지 위에 겹쳐짐 (가독성 보정용 그림자)
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1))],
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    shadows: const [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1))],
                  ),
                ),
                const Spacer(),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    shadows: const [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1))],
                  ),
                ),
              ],
            ),
          ),

          // 3) 선택 하이라이트 오버레이 (기존 유지)
          // Positioned.fill(
          //   child: IgnorePointer(
          //     child: AnimatedContainer(
          //       duration: const Duration(milliseconds: 160),
          //       decoration: BoxDecoration(
          //         color: selected ? Color(0xFFA4C7FC).withOpacity(0.04) : Colors.transparent,
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );


    if (dim) {
      card = Opacity(opacity: 0.3, child: card);
    }

    return IgnorePointer(
      ignoring: disabled,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,

      ),
      child: selected
          ? Image.asset(
        'assets/imgs/imgs/snowballShop/icon_brand_checkbox_selected.png',
        width: 24,
        height: 24,
      )
          : Image.asset(
        'assets/imgs/imgs/snowballShop/icon_brand_checkbox_unselected.png',
        width: 24,
        height: 24,
      ),
    );
  }
}
//TODO: 브랜드 선택 박스 상단 문구 & 선택 박스**************************************************



//TODO: 추첨 방법 문구**************************************************
class _DrawHowTo extends StatelessWidget {
  const _DrawHowTo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF3D83ED), borderRadius: BorderRadius.circular(20)),
            child: const Text('추첨 방법', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          const Text('19시까지 경품 수령처로 모여주세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF))),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF141F30), borderRadius: BorderRadius.circular(20)),
            child: Stack(
              children: [
                Positioned.fill(
                  top: 12,
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF324C73), width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '브랜드 미션 응모를 완료하셨다면,\n19시까지 경품 수령처로 모여주세요!\n현장에서 직접 당첨자 추첨을 진행합니다!',
                          textAlign: TextAlign.center,
                          style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveWhite, fontSize: 14),
                        ),
                        SizedBox(height: 12),
                        Text('상단에 표시된 추첨 번호를 확인해주세요.',
                          style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//TODO: 추첨 방법 문구**************************************************



//TODO: 추가 경품 리스트 상단 문구**************************************************
class _ExtraPrizeTitle extends StatelessWidget {
  const _ExtraPrizeTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('브랜드 미션에 응모하시면,',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF))),
        const Text('추첨을 통해 아래 경품을 추가로 드립니다!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF))),
        const SizedBox(height: 4),
        Text('브랜드 미션 응모 시, 자동으로 응모됩니다.',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.6))),
      ],
    );
  }
}
//TODO: 추가 경품 리스트 상단 문구**************************************************


//TODO: 경품 구경하기 바텀싯 우상단 로고**************************************************
class _SponsorSticker extends StatelessWidget {
  const _SponsorSticker({required this.logoUrl});
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      logoUrl,
      width: 110,   // 필요시 80~110 사이로 조절
      fit: BoxFit.cover,
    );
  }
}
//TODO: 경품 구경하기 바텀싯 우상단 로고**************************************************


//TODO: 응모완료 팝업**************************************************
Future<void> showApplySuccessPopup(
    BuildContext context, {
      required String title,
      required String message,
      String buttonText = '확인',
    }) {
  return showDialog(
    context: context,
    barrierDismissible: false, // 바깥 탭으로 닫히지 않게
    builder: (_) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82, // 이미지 느낌의 폭
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16), // 둥근 모서리
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      // 타이틀
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 본문
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                // 확인 버튼 (풀 폭)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D83ED), // 파란 버튼
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
//TODO: 응모완료 팝업**************************************************



class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
    );
  }
}




