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

          // 필드명은 프로젝트에 맞게 확인 필요
          final bool totalComplete = ms.completeTotal == true;     // 모든 미션 완료
          final bool isApplied     = ms.isApplied == true;         // 이미 응모 완료
          final int? appliedBrandId = _snowballShopViewModel.missionStatus.snowballSponsorId;      // 서버가 저장한 응모 브랜드 id

          // 응모 완료 상태면 UI의 선택값을 서버 값으로 고정
          if (isApplied && appliedBrandId != null && _selectedBrandId != appliedBrandId) {
            _selectedBrandId = appliedBrandId;
          }

          // 버튼 활성화 조건: 전부 완료 && 아직 미응모 && 선택됨
          final bool canApply = totalComplete && !isApplied && _selectedBrandId != null;

          return Scaffold(
            backgroundColor: const Color(0xFF1D242E),
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
                backgroundColor: const Color(0xFF1D242E),
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
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                            const SizedBox(height: 10),
                            const _TopNotice(),
                            if (badgeUrl == null || badgeUrl.isEmpty)
                              Image.asset(
                                'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_badge.png',
                                width: 80,
                                height: 80,
                              )
                            else
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // 1️⃣ 배지 이미지 (네트워크 or 로컬)
                                      if (badgeUrl.isEmpty)
                                        Image.asset(
                                          'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_badge.png',
                                          width: 280,
                                          height: 280,
                                          fit: BoxFit.contain,
                                        )
                                      else
                                        ExtendedImage.network(
                                          badgeUrl,
                                          width: 280,
                                          height: 280,
                                          fit: BoxFit.contain,
                                          loadStateChanged: (state) {
                                            switch (state.extendedImageLoadState) {
                                              case LoadState.loading:
                                                return const SizedBox(
                                                  width: 280,
                                                  height: 280,
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
                                                  width: 280,
                                                  height: 280,
                                                  fit: BoxFit.contain,
                                                );
                                              case LoadState.completed:
                                                return state.completedWidget;
                                            }
                                          },
                                        ),

                                      // 2️⃣ 응모번호 (리본 위쪽에 겹쳐 표시)
                                      Positioned(
                                        bottom: 25,
                                        child: Text('1',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black45),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // 3️⃣ 유저 이름
                                  Text(
                                    '${_userViewModel.user.display_name}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 50),
                            const _HeroText(),
                            _MissionProgressRow(),
                            const SizedBox(height: 100),
                            const _ChooseTitle(),
                            const SizedBox(height: 20),
                            Align(
                              child: SizedBox(
                                width: 130, // ⬅️ 좌우 여백 주고 가운데 정렬 (필요시 200~260 사이로 조절)
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // 캐러셀에 쓸 데이터: 브랜드 아이템 프리미엄
                                    final brands = _snowballShopViewModel.missionStatus.brandItemPremium ?? [];

                                    if (brands.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('브랜드 경품이 아직 준비되지 않았어요.')),
                                      );
                                      return;
                                    }

                                    // 시작 페이지: 현재 선택한 브랜드가 있으면 거기서 시작
                                    final initialPage = (_selectedBrandId != null)
                                        ? brands.indexWhere((b) => b.snowballItemBrandId == _selectedBrandId)
                                        : 0;

                                    final startPage = (initialPage >= 0) ? initialPage : 0;

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: const Color(0xFF3D83ED),
                                      builder: (BuildContext context) {
                                        final pageController = PageController(initialPage: startPage);
                                        int currentPage = startPage;

                                        return GestureDetector(
                                          onTap: () => Navigator.of(context).pop(), // 바깥 탭 시 닫기
                                          child: SafeArea(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF3D83ED),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                              ),
                                              padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 12),
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // 상단 핸들
                                                      const Padding(
                                                        padding: EdgeInsets.only(bottom: 20),
                                                        child: Center(
                                                          child: _BottomSheetHandle(),
                                                        ),
                                                      ),

                                                      // ===== 캐러셀(브랜드 아이템) =====
                                                      SizedBox(
                                                        height: 260, // 이미지+텍스트 영역 높이
                                                        child: PageView.builder(
                                                          controller: pageController,
                                                          itemCount: brands.length,
                                                          onPageChanged: (i) => setState(() => currentPage = i),
                                                          itemBuilder: (context, i) {
                                                            final b = brands[i];
                                                            return Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                // 이미지
                                                                Container(
                                                                  width: 140,
                                                                  height: 140,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    color: Colors.white.withOpacity(0.08),
                                                                  ),
                                                                  clipBehavior: Clip.hardEdge,
                                                                  child: ExtendedImage.network(
                                                                    b.imageUrl ?? '',
                                                                    width: 140,
                                                                    height: 140,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 14),
                                                                // 타이틀
                                                                Text(
                                                                  (b.name ?? '상품 이름'),
                                                                  textAlign: TextAlign.center,
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 16,
                                                                    color: SDSColor.snowliveWhite,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                const SizedBox(height: 6),
                                                                // 설명
                                                                Text(
                                                                  b.description ?? '',
                                                                  textAlign: TextAlign.center,
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                    fontSize: 12,
                                                                    color: Colors.white.withOpacity(0.6),
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                      // 인디케이터(점)
                                                      const SizedBox(height: 12),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: List.generate(brands.length, (i) {
                                                          final active = i == currentPage;
                                                          return AnimatedContainer(
                                                            duration: const Duration(milliseconds: 200),
                                                            margin: const EdgeInsets.symmetric(horizontal: 3),
                                                            width: active ? 18 : 8,
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                              color: active ? Colors.white : Colors.white.withOpacity(0.4),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                          );
                                                        }),
                                                      ),

                                                      const SizedBox(height: 20),

                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '경품 구경하기',
                                        style: SDSTextStyle.bold.copyWith(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Image.asset(
                                        'assets/imgs/imgs/snowballShop/icon_snowballshop_arrow_b.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // ===== 브랜드 미션 선택 그리드 =====
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
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
                                    title: (item.name ?? '').toUpperCase(),
                                    subtitle: item.description ?? '',
                                    imageUrl: item.imageUrl ?? '',
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

                            const SizedBox(height: 60),
                            const _DrawHowTo(),
                            const SizedBox(height: 60),

                            // ===== 추가 경품 리스트 (기존 로직 유지) =====
                            const _ExtraPrizeTitle(),
                            const SizedBox(height: 20),
                            GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: Stack(
                                                children: [
                                                  Container(
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
                                                  if (item.itemCount == 0)
                                                    Positioned.fill(
                                                      child: Container(color: SDSColor.sBlue900.withOpacity(0.8)),
                                                    ),
                                                ],
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== 하단 응모 버튼 =====
                // ===== 하단 응모 버튼 =====
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        // ✅ 활성 조건: 모든 미션 완료 && 아직 응모 전 && 브랜드 선택됨
                        onPressed: (totalComplete && !isApplied && _selectedBrandId != null)
                            ? () async {
                          // 이미 위 조건에서 선택 여부 체크했지만, 방어 코드는 유지
                          if (_selectedBrandId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('응모할 브랜드를 선택해 주세요.')),
                            );
                            return;
                          }

                          CustomFullScreenDialog.showDialog();
                          try {
                            await _snowballShopViewModel.applyMission(_selectedBrandId!);
                            await _snowballShopViewModel.fetchMissionStatus();
                          } finally {
                            CustomFullScreenDialog.cancelDialog();
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('브랜드 미션 응모 완료!')),
                          );
                        }
                            : null,

                        // ── 3가지 상태별 색상/라벨 계산
                        style: () {
                          final bool hasSelection = _selectedBrandId != null;
                          final bool canApply = totalComplete && !isApplied && hasSelection;

                          // 배경/글자색
                          final Color bgColor = isApplied
                              ? const Color(0xFF172338)        // 응모완료: 남색 배경
                              : (canApply
                              ? const Color(0xFF3D83ED)     // 활성: 파랑
                              : const Color(0xFFDEDEDE));   // 비활성: 회색

                          final Color fgColor = isApplied
                              ? const Color(0xFF3D83ED)         // 응모완료: 파란 텍스트
                              : (canApply
                              ? Colors.white                 // 활성: 흰색
                              : const Color(0xFFB9C0CA));    // 비활성: 연회색

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
                          isApplied ? '응모 완료' : '브랜드 응모하기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            // 색상은 styleFrom의 foregroundColor가 적용됨
                          ),
                        ),
                      ),
                    ),
                  ),
                ),


              ],
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
    return const Text(
      '획득한 눈송이는 당일에 사용하지 않으면 모두 사라집니다',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3D83ED)),
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
        const Text(
          '브랜드 미션을 완수하라',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text('아래 미션을 완료하고, 원하는 브랜드 경품애 응모하세요!',
            style: TextStyle(fontSize: 13, color: const Color(0xFFFFFFFF).withOpacity(0.6))),
        const SizedBox(height: 2),
        Text('추첨을 통해 단 하나의 상품의 주인공이 되어 보세요!',
            style: TextStyle(fontSize: 13, color: const Color(0xFFFFFFFF).withOpacity(0.6))),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _missionBlock(
          imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission1.png',
          imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission1_end.png',
          title: vm.missionTitle('mission_1'),
          achieved: count.white ?? 0,
          required: 9,
        ),
        _missionBlock(
          imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission2.png',
          imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission2_end.png',
          title: vm.missionTitle('mission_2'),
          achieved: count.gold ?? 0,
          required: 1,
        ),
        _missionBlock(
          imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission3.png',
          imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission3_end.png',
          title: vm.missionTitle('mission_3'),
          achieved: count.white_on_slope ?? 0,
          required: 5,
        ),
        _mission4Block(
          imgNormal: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission4.png',
          imgDone: 'assets/imgs/imgs/snowballShop/icon_snowballshop_brandmission4_end.png',
          title: vm.missionTitle('mission_4'),
          done: vm.missionComplete('mission_4'),
        ),
      ],
    );
  }

  // ── 숫자 기반 미션 (1~3)
  Widget _missionBlock({
    required String imgNormal,
    required String imgDone,
    required String title,
    required int achieved,
    required int required,
  }) {
    final bool isDone = achieved >= required;
    final int safeAchieved = achieved.clamp(0, required);

    return Expanded(
      child: Column(
        children: [
          Image.asset(isDone ? imgDone : imgNormal, height: 150),
          const SizedBox(height: 4),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$safeAchieved',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const TextSpan(
                  text: ' / ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                TextSpan(
                  text: '$required',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 미션4 (달성/미달성)
  Widget _mission4Block({
    required String imgNormal,
    required String imgDone,
    required String title,
    required bool done,
  }) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(done ? imgDone : imgNormal, height: 150),
          const SizedBox(height: 4),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            done ? '달성' : '미달성',
            style: TextStyle(
              fontSize: 14,
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
        const Text('브랜드 미션 응모하기 버튼을 눌러주세요!',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('경품에 대한 자세한 정보는', style: TextStyle(fontSize: 13, color: const Color(0xFFFFFFFF).withOpacity(0.6))),
        const SizedBox(height: 2),
        Text('아래 경품 구경하기 버튼을 눌러주세요!', style: TextStyle(fontSize: 13, color: const Color(0xFFFFFFFF).withOpacity(0.6))),
      ],
    );
  }
}
class _BrandChoiceCard extends StatelessWidget {
  const _BrandChoiceCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
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
  final bool selected;
  final VoidCallback onTap;

  final bool showCheckbox; // 체크 아이콘 표시
  final bool disabled;     // 탭 비활성
  final bool dim;          // 디밍 처리
  final bool emphasized;   // 강조 처리

  @override
  Widget build(BuildContext context) {
    final borderColor = emphasized
        ? const Color(0xFF7FB2FF)
        : (selected ? const Color(0xFF5F94FF) : const Color(0xFF2A3F61));

    final Gradient? bgGradient = emphasized
        ? const LinearGradient(
      colors: [Color(0xFF14305E), Color(0xFF0F2444)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : null;

    final overlay = selected ? Colors.white.withOpacity(0.06) : Colors.transparent;

    Widget card = Container(
      decoration: BoxDecoration(
        color: emphasized ? null : const Color(0xFF11213D),
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: emphasized ? 3 : 2),
        boxShadow: emphasized
            ? const [BoxShadow(color: Color(0x66295BDB), blurRadius: 18, offset: Offset(0, 8))]
            : const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCheckbox) _CheckBadge(selected: selected) else const SizedBox(height: 26),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // 선택 시 하이라이트
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(color: overlay, borderRadius: BorderRadius.circular(22)),
              ),
            ),
          ),
        ],
      ),
    );

    if (dim) {
      card = Opacity(opacity: 0.35, child: card);
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
        color: selected ? const Color(0xFF295BDB) : Colors.transparent,
        border: Border.all(color: selected ? const Color(0xFF5F94FF) : const Color(0xFF37507D), width: 2),
      ),
      child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF3D83ED), borderRadius: BorderRadius.circular(20)),
            child: const Text('추첨 방법', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          const Text('14시까지 경품 수령처로 모여주세요!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF))),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF141F30), borderRadius: BorderRadius.circular(10)),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          '브랜드 미션 응모를 완료하셨다면,\n14시까지 경품 수령처로 모여주세요!\n현장에서 직접 당첨자 추첨을 진행합니다!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Text('상단에 표시된 추첨 번호를 확인해주세요',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14)),
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
        const Text('추가 경품 당첨 기회가 주어집니다!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF))),
        const SizedBox(height: 5),
        Text('브랜드 미션 응모 시, 자동으로 응모됩니다.',
            style: TextStyle(fontSize: 13, color: const Color(0xFFFFFFFF).withOpacity(0.6))),
      ],
    );
  }
}
//TODO: 추가 경품 리스트 상단 문구**************************************************


class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
    );
  }
}




