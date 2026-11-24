import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_snowball.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/view/ranking/w_snowball_web_common.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_snowball_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 브랜드 미션 — `#/snowball-market/brand`.
/// 앱 [SnowballMarketBrandShopView]와 동일: 미션 현황 + 브랜드 선택 응모 + 추가 경품.
class SnowballMarketBrandViewWeb extends StatefulWidget {
  const SnowballMarketBrandViewWeb({super.key});

  @override
  State<SnowballMarketBrandViewWeb> createState() => _SnowballMarketBrandViewWebState();
}

class _SnowballMarketBrandViewWebState extends State<SnowballMarketBrandViewWeb> {
  final SnowballShopViewModelWeb vm = Get.find<SnowballShopViewModelWeb>();
  static const Color _bg = Color(0xFF081322);
  int? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    vm.fetchShop(isTierOnly: false, isForMission: true);
    vm.fetchMissionStatus();
  }

  void _toggle(int id) => setState(() => _selectedBrandId = (_selectedBrandId == id) ? null : id);

  @override
  Widget build(BuildContext context) {
    return SnowballPhoneScaffold(
      title: '브랜드 미션',
      appBarColor: _bg,
      backgroundColor: _bg,
      bottomBar: _applyBar(),
      child: Obx(() {
        final ms = vm.missionStatus;
        final isApplied = ms.isApplied == true;
        final appliedBrandId = ms.snowballItemBrandId;
        if (isApplied && appliedBrandId != null && _selectedBrandId != appliedBrandId) {
          _selectedBrandId = appliedBrandId;
        }
        return RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0xFF3D83ED),
          onRefresh: () async {
            await vm.fetchShop(isTierOnly: false, isForMission: true);
            await vm.fetchMissionStatus();
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 10),
              _badge(ms, isApplied),
              const SizedBox(height: 30),
              _heroText(),
              const SizedBox(height: 24),
              _missionRow(),
              const SizedBox(height: 100),
              _chooseTitle(),
              const SizedBox(height: 50),
              _brandGrid(ms, isApplied, appliedBrandId),
              const SizedBox(height: 80),
              _drawHowTo(),
              const SizedBox(height: 80),
              _extraTitle(),
              const SizedBox(height: 24),
              _extraGrid(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _badge(MissionStatus ms, bool isApplied) {
    final badgeUrl = ms.badgeUrl ?? '';
    return Stack(alignment: Alignment.center, children: [
      Image.asset(snowAsset('icon_snowballshop_brand_bg.png'), width: double.infinity),
      if (badgeUrl.isEmpty)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Image.asset(snowAsset('icon_snowballshop_brand_badge.png')),
        )
      else
        Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(alignment: Alignment.center, children: [
            WebNetworkImage(url: badgeUrl, width: 300, fit: BoxFit.contain, showPlaceholder: false),
            Positioned(
              bottom: 30,
              child: Text('${ms.missionApplyId ?? ''}',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ]),
          Text(vm.myDisplayName, style: const TextStyle(fontSize: 20, color: Colors.white)),
          Text(ms.sponsorEngName ?? '',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.4))),
        ]),
    ]);
  }

  Widget _heroText() {
    return Column(children: [
      Text('브랜드 미션을 완수하라',
          style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 18)),
      const SizedBox(height: 4),
      Text('아래 미션을 완료한 뒤 원하는 브랜드 경품에 응모하면',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.6))),
      Text('추첨을 통해 25/26 신상 의류를 드립니다',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.6))),
    ]);
  }

  Widget _missionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        for (int i = 1; i <= 4; i++) ...[
          if (i > 1) const SizedBox(width: 14),
          _missionBlock('mission_$i', 'icon_snowballshop_brandmission$i.png',
              'icon_snowballshop_brandmission${i}_end.png'),
        ],
      ]),
    );
  }

  Widget _missionBlock(String id, String imgNormal, String imgDone) {
    final done = vm.missionComplete(id);
    return Expanded(
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(snowAsset(done ? imgDone : imgNormal)),
        ),
        const SizedBox(height: 10),
        Text('MISSION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5))),
        const SizedBox(height: 2),
        Text(vm.missionTitle(id),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
        const SizedBox(height: 4),
        Text(done ? '달성' : '미달성',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: done ? Colors.white : Colors.white54)),
      ]),
    );
  }

  Widget _chooseTitle() {
    return Column(children: [
      const Text('원하는 브랜드의 경품을 선택하고',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const Text('브랜드 미션 응모하기 버튼을 눌러주세요',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('브랜드마다 다양한 경품 구성!',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.6))),
      Text('나에게 필요한 브랜드를 선택하세요',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.6))),
      const SizedBox(height: 8),
      Text('구성에 맞춰 상품을 직접 선택할 수 있어요',
          style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveBlue)),
    ]);
  }

  Widget _brandGrid(MissionStatus ms, bool isApplied, int? appliedBrandId) {
    final items = ms.brandItemPremium ?? [];
    return Padding(
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
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          final id = item.snowballItemBrandId ?? i;
          final selected = isApplied && appliedBrandId != null
              ? (id == appliedBrandId)
              : (_selectedBrandId == id);
          return _brandCard(
            title: (item.sponsor?.nameEng ?? '').toUpperCase(),
            subtitle: item.sponsor?.name ?? '',
            imageUrl: item.imageUrl ?? '',
            description: item.description ?? '',
            selected: selected,
            showCheckbox: !isApplied,
            disabled: isApplied,
            dim: isApplied && !selected,
            emphasized: isApplied && selected,
            onTap: () {
              if (isApplied) return;
              _toggle(id);
            },
          );
        },
      ),
    );
  }

  Widget _brandCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String description,
    required bool selected,
    required bool showCheckbox,
    required bool disabled,
    required bool dim,
    required bool emphasized,
    required VoidCallback onTap,
  }) {
    final borderColor =
        (emphasized || selected) ? const Color(0xFFA4C7FC) : const Color(0xFF324C73);
    Widget card = Container(
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFF3D83ED) : const Color(0xFF1F3553),
        gradient: emphasized
            ? const LinearGradient(
                colors: [Color(0xFF14305E), Color(0xFF0F2444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          right: -35,
          top: -18,
          bottom: 0,
          child: IgnorePointer(
            child: Image.network(imageUrl,
                width: 190, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showCheckbox)
              Image.asset(
                  snowAsset(selected
                      ? 'icon_brand_checkbox_selected.png'
                      : 'icon_brand_checkbox_unselected.png'),
                  width: 24,
                  height: 24)
            else
              const SizedBox(height: 26),
            const SizedBox(height: 16),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            Text(subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.55), fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(description,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
        ),
      ]),
    );
    if (dim) card = Opacity(opacity: 0.3, child: card);
    return IgnorePointer(
      ignoring: disabled,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }

  Widget _drawHowTo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration:
              BoxDecoration(color: const Color(0xFF3D83ED), borderRadius: BorderRadius.circular(20)),
          child: const Text('추첨 방법',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        const Text('19시까지 경품 수령처로 모여주세요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFF141F30), borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF324C73)),
                borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(children: [
              Text('브랜드 미션 응모를 완료하셨다면,\n19시까지 경품 수령처로 모여주세요!\n현장에서 직접 당첨자 추첨을 진행합니다!',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 12),
              Text('상단에 표시된 추첨 번호를 확인해주세요.',
                  style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 14)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _extraTitle() {
    return Column(children: [
      const Text('브랜드 미션에 응모하시면,',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const Text('추첨을 통해 아래 경품을 추가로 드립니다!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 4),
      Text('브랜드 미션 응모 시, 자동으로 응모됩니다.',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.6))),
    ]);
  }

  Widget _extraGrid() {
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 10,
            childAspectRatio: 11 / 16,
          ),
          itemCount: vm.shopItems.length,
          itemBuilder: (_, i) {
            final item = vm.shopItems[i];
            final soldOut = item.itemCount == 0;
            return GestureDetector(
              onTap: soldOut ? null : () => _showExtraSheet(item),
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
                        fallback:
                            Image.asset('assets/imgs/imgs/img_flea_default.png', fit: BoxFit.cover),
                      ),
                      if (soldOut) Container(color: SDSColor.sBlue900.withOpacity(0.8)),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                Text(item.name ?? '상품 이름',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.bold.copyWith(fontSize: 12, color: Colors.white)),
              ]),
            );
          },
        ));
  }

  void _showExtraSheet(SnowballShopItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF3D83ED),
      constraints: const BoxConstraints(maxWidth: kSnowballPhoneWidth),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 36,
                height: 4,
                decoration:
                    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            WebNetworkImage(
                url: item.imageUrl, width: 113, height: 113, fit: BoxFit.cover, borderRadius: 4),
            const SizedBox(height: 16),
            Text(item.name ?? '상품 이름',
                style: SDSTextStyle.bold.copyWith(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            Text(item.description ?? '',
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 32),
            if ((item.landingUrl ?? '').isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => otherShare(contents: item.landingUrl!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C3F70),
                    elevation: 0,
                    minimumSize: const Size(100, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('상세 정보 보기',
                      style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 16)),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _applyBar() {
    return Obx(() {
      final ms = vm.missionStatus;
      final isApplied = ms.isApplied == true;
      final totalComplete = ms.completeTotal == true;
      final canApply = totalComplete && !isApplied && _selectedBrandId != null;
      final bgColor = isApplied
          ? const Color(0xFF112139)
          : (canApply ? const Color(0xFF3D83ED) : const Color(0xFFC8C8C8));
      final fgColor = isApplied ? const Color(0xFF3D83ED) : Colors.white;
      return Container(
        color: _bg,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canApply ? _apply : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                disabledBackgroundColor: bgColor,
                disabledForegroundColor: fgColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(isApplied ? '응모 완료' : '브랜드 미션 응모하기',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _apply() async {
    final brands = vm.missionStatus.brandItemPremium ?? [];
    if (brands.isEmpty) {
      await showSnowballInfoDialog(context,
          title: '응모할 경품을 선택해주세요!', message: '응모할 경품을 선택 후.\n다시 응모 하기 버튼을 눌러주세요.');
      return;
    }
    await vm.applyMission(_selectedBrandId!);
    await vm.fetchMissionStatus();
    if (!mounted) return;
    await showSnowballInfoDialog(context,
        title: '브랜드 미션 응모 완료!',
        message: '상단에 표시된 추첨 번호를 확인해주세요.\n19시까지 경품 수령처로 모여주세요!');
  }
}
