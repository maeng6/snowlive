import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_snowball.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/ranking/w_snowball_web_common.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_snowball_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 눈송이 상점 홈 — `#/snowball-market`.
/// 앱 [SnowballMarketHomeView]와 동일한 구성·문구·애셋을 세로(폰) 레이아웃으로 재현.
class SnowballMarketHomeViewWeb extends StatefulWidget {
  const SnowballMarketHomeViewWeb({super.key});

  @override
  State<SnowballMarketHomeViewWeb> createState() =>
      _SnowballMarketHomeViewWebState();
}

class _SnowballMarketHomeViewWebState extends State<SnowballMarketHomeViewWeb> {
  final SnowballShopViewModelWeb vm = Get.find<SnowballShopViewModelWeb>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await vm.fetchHome();
    await vm.fetchUserRecords();
  }

  @override
  Widget build(BuildContext context) {
    return SnowballPhoneScaffold(
      bottomBar: Obx(() => vm.canEnterShop ? _bottomBar() : const SizedBox.shrink()),
      child: Obx(() {
        // 상점 공개 게이트 — 어드민 설정(Firestore)이 로드될 때까지 로딩, 이후 입장 판정.
        if (!vm.marketLoaded) {
          return const Center(
            child: SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white54)),
          );
        }
        if (!vm.canEnterShop) {
          return _closedState(!vm.shopOpen
              ? '아직 눈송이 상점이 열리지 않았어요.'
              : '이 계정은 아직 눈송이 상점 이용 대상이 아니에요.');
        }
        if (vm.isLoading.value && vm.summary.isEmpty) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white54),
            ),
          );
        }
        return RefreshIndicator(
          color: Colors.white,
          backgroundColor: SDSColor.snowliveBlue,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              _hero(),
              const SizedBox(height: 20),
              // 어드민에서 '브랜드 미션 노출'을 끄면 이 영역 전체를 숨긴다.
              Obx(() => vm.brandMissionVisible
                  ? Column(children: [_brandMissionSection(), const SizedBox(height: 96)])
                  : const SizedBox(height: 20)),
              _myRecordsSection(),
              const SizedBox(height: 16),
              _useStoreCard(),
              const SizedBox(height: 96),
              _storySection(),
              const SizedBox(height: 96),
              _sponsorSection(),
              const SizedBox(height: 60),
              _noticeSection(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // ── 입장 불가/준비중 상태
  Widget _closedState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(snowAsset('icon_snb_nodata.png'), width: 72, height: 72,
              errorBuilder: (_, __, ___) => const Icon(Icons.ac_unit, color: Colors.white38, size: 56)),
          const SizedBox(height: 14),
          Text(message,
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(color: Colors.white.withOpacity(0.8), fontSize: 15, height: 1.5)),
        ]),
      ),
    );
  }

  // ── 어드민 이미지 오버라이드 헬퍼 ──
  /// 영역 키 오버라이드(Firestore)가 있으면 그 URL, 없으면 번들 에셋 ImageProvider.
  ImageProvider _imgProvider(String key, String asset) {
    final url = vm.imgUrl(key);
    return url != null ? NetworkImage(url) : AssetImage(snowAsset(asset));
  }

  /// 오버라이드 반영 이미지 위젯. images 맵 변경 시 갱신되도록 Obx로 감싼다.
  Widget _img(String key, String asset, {double? width, double? height, BoxFit? fit}) {
    return Obx(() {
      final url = vm.imgUrl(key);
      return url != null
          ? Image.network(url, width: width, height: height, fit: fit)
          : Image.asset(snowAsset(asset), width: width, height: height, fit: fit);
    });
  }

  /// 하얀/황금 눈송이(색상 한글 '하얀'=하얀, 그 외=황금). 오버라이드 반영.
  Widget _ball(String? color, {double? height}) => _img(
        color == '하얀' ? 'white_ball' : 'gold_ball',
        color == '하얀' ? kWhiteBall : kGoldBall,
        height: height,
      );

  // ── 상단 히어로(일러스트 + 타이틀 + 잔량 + 황금 공지)
  Widget _hero() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _img('hero_bg', 'img_snowballshop_store.png',
            width: double.infinity, fit: BoxFit.fitWidth),
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: _img('hero_title', 'icon_snowballshop_store_title.png',
                height: 95),
          ),
        ),
        Positioned(
          top: 118,
          left: 0,
          right: 0,
          child: Center(
            child: Text('휘닉스 파크에서 눈송이를 찾아라!',
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: Colors.white)),
          ),
        ),
        Positioned(
          top: 154,
          left: 0,
          right: 0,
          child: SnowballBalancePills(white: vm.whiteRemaining, gold: vm.goldRemaining),
        ),
        Positioned(
          bottom: -10,
          left: 0,
          right: 0,
          child: Obx(() {
            final data = vm.goldNotice.value;
            final ment = (data?['ment'] as String?) ?? '';
            if (data == null || data.isEmpty || ment.isEmpty) {
              return Center(
                child: Text('황금 눈송이 소식이 아직 없네요..',
                    style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13)),
              );
            }
            return Center(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: _img('gold_bubble', 'icon_snowballshop_bubble.png', width: 17),
                ),
                IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(ment,
                        style: SDSTextStyle.bold
                            .copyWith(color: SDSColor.snowliveBlack, fontSize: 13)),
                  ),
                ),
              ]),
            );
          }),
        ),
      ],
    );
  }

  // ── 브랜드 미션
  Widget _brandMissionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(children: [
        const SizedBox(height: 60),
        const Text('브랜드 미션',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text('주어진 미션을 빠르게 완수하고,',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        Text('25/26 신상 의류의 주인이 될 기회를 잡아라!',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _goBrand,
          child: _img('brand_banner', 'icon_snowballshop_store_brand.png'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goBrand,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('브랜드 미션 보러가기',
                    style: SDSTextStyle.extraBold.copyWith(color: Colors.black, fontSize: 13)),
                _img('brand_arrow', 'icon_snowballshop_arrow_b.png', width: 16, height: 16),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _goBrand() async {
    await vm.fetchMissionStatus();
    Get.toNamed(WebRoutes.snowballMarketBrand);
  }

  // ── 내가 획득한 눈송이(최대 3개 + 새로고침/자세히)
  Widget _myRecordsSection() {
    return Column(children: [
      const Text('내가 획득한 눈송이',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          final records = vm.userSnowballRecords;
          final preview = records.take(3).toList();
          return Column(children: [
            if (preview.isEmpty)
              _recordBox(null)
            else
              for (final r in preview) ...[_recordBox(r), const SizedBox(height: 8)],
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: () async {
                  await vm.fetchUserRecords();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C899D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('새로고침',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _showRecordsDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('자세히 보기',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13)),
              ),
            ]),
          ]);
        }),
      ),
    ]);
  }

  Widget _recordBox(SnowballRecord? r) {
    final empty = r == null;
    String timeText = '';
    if (!empty) {
      final dt = DateTime.tryParse(r.passTime ?? '') ?? DateTime.now();
      timeText =
          '${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
            image: _imgProvider('record_box_bg', 'icon_snowballshop_store_box_1.png'),
            fit: BoxFit.cover),
      ),
      child: Row(children: [
        if (!empty)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _ball(r.color, height: 20),
          ),
        Expanded(
          child: Text(
            empty
                ? '아직 획득한 눈송이가 없어요!'
                : '${r.slopeName}에서 ${r.color} 눈송이 1개 획득',
            style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack, fontSize: 14),
          ),
        ),
        if (!empty)
          Text(timeText,
              style: SDSTextStyle.regular
                  .copyWith(color: SDSColor.snowliveBlack.withOpacity(0.4), fontSize: 12)),
      ]),
    );
  }

  void _showRecordsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('내가 획득한 눈송이',
                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
              const SizedBox(height: 16),
              Flexible(
                child: Obx(() {
                  final records = vm.userSnowballRecords;
                  if (records.isEmpty) {
                    return Center(
                      child: Text('아직 획득한 눈송이가 없어요',
                          style:
                              SDSTextStyle.regular.copyWith(color: SDSColor.gray500, fontSize: 14)),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = records[i];
                      final dt = DateTime.tryParse(r.passTime ?? '') ?? DateTime.now();
                      final f =
                          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
                      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _ball(r.color, height: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${r.slopeName}에서 ${r.color} 눈송이 1개를 획득했습니다.',
                                style: SDSTextStyle.regular
                                    .copyWith(color: SDSColor.gray900, fontSize: 14)),
                            Text(f,
                                style: SDSTextStyle.regular
                                    .copyWith(color: SDSColor.gray500, fontSize: 13)),
                          ]),
                        ),
                      ]);
                    },
                  );
                }),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── 눈송이 상점 이용하기 카드
  Widget _useStoreCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration:
            BoxDecoration(color: const Color(0xFF18273E), borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Column(children: [
          _img('use_store_banner', 'icon_snowballshop_store_banner.png', height: 100),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 16),
            child: Text('눈송이 상점 이용하기',
                style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 16)),
          ),
          Text('획득한 눈송이로 경품을 교환할 수 있어요.\n호크 리프트 옆 눈송이 상점을 방문해 주세요.',
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 8),
          Text('경품 교환 후 취소 및 변경이 불가능하니\n신중하게 골라주세요!',
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(color: const Color(0xFFBDD7FF), fontSize: 13)),
        ]),
      ),
    );
  }

  // ── 눈송이 상점 이야기
  Widget _storySection() {
    return Column(children: [
      const Text('눈송이 상점 이야기',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text('눈송이를 모아 스노빌리지 친구들이\n여름을 날 수 있도록 도와주세요!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(children: [
          _img('story_bg', 'img_snowballshop_store_bottom_image2.png'),
          Positioned.fill(
            bottom: 20,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  '안녕하세요?\n저는 눈송이를 찾아 전국을 유랑하는\n상인 하람이에요.\n\n저의 고향 스노빌리지에서는\n제가 눈송이를 가득 싣고 오기를\n애타게 기다리고 있어요.\n\n눈송이가 왜 필요하냐구요?\n\n눈송이는 우리 스노 친구들이 더운 여름을 견디기 위해 꼭 필요한 자원이랍니다.\n그래서 저는 이번 겨울 최대한 많은 눈송이를 모으기 위해 전국을 유랑하고 있어요.\n\n그런데 이번 겨울 휘닉스 파크에서 대량의 눈송이가 내린다는 예보가 있지 뭐에요?\n제가 다양한 선물을 가지고 왔으니, 여러분이 힘을 합쳐 눈송이를 모아서 가져와주세요!\n\n눈송이 값은 섭섭치 않게 쳐드릴게요~',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF111111), fontSize: 14),
                ),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  // ── 함께 하는 브랜드
  Widget _sponsorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Text('함께 하는 브랜드',
            style: SDSTextStyle.bold.copyWith(fontSize: 20, color: Colors.white)),
        const SizedBox(height: 20),
        Obx(() {
          final list = vm.sponsors;
          if (list.isEmpty) return const SizedBox.shrink();
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 1 / 0.9,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return GestureDetector(
                onTap: () {
                  if ((s.landingUrl ?? '').isNotEmpty) otherShare(contents: s.landingUrl!);
                },
                child: Column(children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFF141F30),
                          borderRadius: BorderRadius.circular(4)),
                      child: WebNetworkImage(
                        url: s.logoUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 4,
                        fallback: Image.asset('assets/imgs/imgs/img_flea_default.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(s.name ?? '브랜드 이름',
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 14, color: Colors.white)),
                ]),
              );
            },
          );
        }),
      ]),
    );
  }

  // ── 안내사항
  Widget _noticeSection() {
    final style = TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('안내사항',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('· 교환이 완료된 경품은 취소나 변경이 불가합니다.', style: style),
        const SizedBox(height: 5),
        Text('· 앱에서 교환한 경품은 반드시 현장 행사 부스에서 실물 경품으로 교환해야 합니다.', style: style),
        const SizedBox(height: 5),
        Text('· 당일 획득한 눈송이는 반드시 당일에 모두 사용해야 합니다.\n사용하지 않은 눈송이는 다음 날 자동으로 소멸되니 꼭 모두 사용해 주세요.',
            style: style),
      ]),
    );
  }

  /// 비로그인 유저에게 로그인 유도 다이얼로그를 띄운다.
  void _promptLogin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('로그인이 필요합니다',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('눈송이 Pay는 로그인 후 이용할 수 있어요.\n로그인하시겠어요?',
            style: TextStyle(fontSize: 14, color: SDSColor.gray700, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('닫기', style: TextStyle(color: SDSColor.gray500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.toNamed(WebRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D83ED),
              elevation: 0,
            ),
            child: const Text('로그인하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── 하단 바(눈송이 pay / 눈송이 상점)
  Widget _bottomBar() {
    return Container(
      color: const Color(0xFF050E1B),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // 비로그인(게스트)은 유저 식별이 안 되므로 Pay QR을 띄우지 않고
                // 로그인으로 유도한다(QR 데이터에 user_id가 들어가기 때문).
                if (!vm.isLoggedIn) {
                  _promptLogin();
                  return;
                }
                showSnowballPayQrDialog(context,
                    userId: vm.myUserId, eventDate: vm.eventDate.value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C899D),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('눈송이 pay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _showStoreSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D83ED),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('눈송이 상점',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showStoreSelect() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _storeCard(
                ctx,
                title: '프리미엄 눈송이 상점',
                subtitle: '랭킹 등급 골드 이상 이용 가능',
                image: _imgProvider('store_premium', 'img_snowballshop_store_premium.png'),
                route: WebRoutes.snowballMarketPremium,
              ),
              const SizedBox(width: 12),
              _storeCard(
                ctx,
                title: '일반 눈송이 상점',
                subtitle: '누구나 이용 가능',
                image: _imgProvider('store_public', 'img_snowballshop_store_public.png'),
                route: WebRoutes.snowballMarketPublic,
              ),
            ]),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                vm.fetchPurchaseHistory();
                Get.toNamed(WebRoutes.snowballMarketBuyRecord);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('경품 교환 목록',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _storeCard(BuildContext ctx,
      {required String title,
      required String subtitle,
      required ImageProvider image,
      required String route}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.of(ctx).pop();
          Get.toNamed(route);
        },
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image(image: image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
      ),
    );
  }
}
