import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// GNB 사이드바(240)와 같은 폭 — 너무 넓지 않게(요청, 기존 280).
const double kFleamarketSidebarWidth = 240;
final _sidebarPriceFormat = NumberFormat('###,###,###,###');

/// 데스크탑 전용 우측 열: 키워드 알림 설정 + 최근 본 상품 + 찜 목록.
class FleamarketSidebarWeb extends StatelessWidget {
  const FleamarketSidebarWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final myActivityVm = Get.find<FleamarketMyActivityViewModel>();

    return Container(
      width: kFleamarketSidebarWidth,
      // 콘텐츠와의 간격(40)은 홈 레이아웃의 SizedBox가 담당한다 — 내부 left 패딩 없음.
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 버튼 높이 48 (피그마 32:18009). hover 시 배경색 80% 불투명도.
          ElevatedButton(
            onPressed: () => Get.toNamed(WebRoutes.fleamarketUpload),
            style: ButtonStyle(
              // hover 색 전환을 애니메이션 없이 즉시 적용.
              animationDuration: Duration.zero,
              elevation: const WidgetStatePropertyAll(0),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
              shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? SDSColor.snowliveBlue.withValues(alpha: 0.8)
                    : SDSColor.snowliveBlue,
              ),
            ),
            child: Text('중고거래 물품 올리기', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite)),
          ),
          const SizedBox(height: SDSSpacing.sm),
          // 피그마에는 없지만 기능 진입점이라 유지한다(요청 전까지).
          // hover 시 텍스트만 60% 불투명도(보더·배경은 그대로).
          OutlinedButton(
            onPressed: () => Get.toNamed(WebRoutes.fleamarketAlert),
            style: ButtonStyle(
              // hover 색 전환을 애니메이션 없이 즉시 적용.
              animationDuration: Duration.zero,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              side: WidgetStatePropertyAll(BorderSide(color: SDSColor.gray200)),
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
              shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? SDSColor.gray900.withValues(alpha: 0.6)
                    : SDSColor.gray900,
              ),
            ),
            // 색은 foregroundColor가 상태별로 입힌다(여기서 지정하면 hover가 안 먹는다).
            child: Text('키워드 알림 설정', style: SDSTextStyle.bold.copyWith(fontSize: 16)),
          ),
          // 인기 검색어(_PopularKeywords)는 서버 집계 API가 준비되면 다시 켠다.
          // 켤 때: 버튼 ↔ 인기 검색어 30, 섹션 간 40 (피그마 32:18013).
          // const SizedBox(height: 30),
          // const _PopularKeywords(),
          const SizedBox(height: 40),
          Obx(() {
            final bool isLoading = myActivityVm.isLoading.value;
            final recent = myActivityVm.recentViewed.toList();
            return _ActivitySection(
              title: '최근 본 상품',
              items: recent,
              // 로딩 중에 "없어요"를 먼저 보여줬다가 데이터로 바뀌면 빈 상태가 깜빡인다.
              // 조회가 끝난 뒤에만 빈 상태로 판단한다.
              isLoading: isLoading,
              isEmpty: recent.isEmpty,
              emptyText: '최근 본 상품이 없어요',
            );
          }),
          const SizedBox(height: 40),
          Obx(() {
            final bool isLoading = myActivityVm.isLoading.value;
            final favorites = myActivityVm.favoriteList.toList();
            return _ActivitySection(
              title: favorites.isEmpty ? '찜 목록' : '찜 목록 ${favorites.length}',
              items: favorites,
              isLoading: isLoading,
              isEmpty: favorites.isEmpty,
              emptyText: '찜 목록이 없어요',
            );
          }),
        ],
      ),
    );
  }
}

/// 인기 검색어(피그마 32:18013) — 칩을 누르면 그 키워드로 목록을 검색한다.
/// 서버 집계 API가 준비되면 빌드에서 다시 켠다(위 주석 참고).
// ignore: unused_element
class _PopularKeywords extends StatelessWidget {
  const _PopularKeywords();

  // [개발용 더미] 서버 인기 검색어 API 연동 전 임시 목록. 배포 전 확인.
  static const List<String> _keywords = [
    '데크', '스노우보드', '스키', '신상품', '2324', '이월상품 할인', '나눔',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('인기 검색어',
            style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
        // 제목 ↔ 칩 12 (피그마).
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 8,
          children: [
            for (final keyword in _keywords)
              _KeywordChip(
                label: keyword,
                onTap: () {
                  final userId = Get.find<UserViewModel>().user.user_id;
                  Get.find<FleamarketPaginationViewModelWeb>()
                      .loadFirstPage(userId: userId, searchQuery: keyword);
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// 칩: 높이 31(패딩 10/7), Regular 14, gray50 배경, radius 6 (피그마).
class _KeywordChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _KeywordChip({required this.label, required this.onTap});

  @override
  State<_KeywordChip> createState() => _KeywordChipState();
}

class _KeywordChipState extends State<_KeywordChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? SDSColor.gray100 : SDSColor.gray50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
          ),
        ),
      ),
    );
  }
}

/// 최근 본 상품/찜 목록 한 줄 — 탭하면 상세로 이동(상세 화면이 id로 재조회).
/// hover 시 텍스트가 60% 불투명도로 살짝 죽는다(요청).
class _ActivityRow extends StatefulWidget {
  final FleamarketMyActivityItem item;

  const _ActivityRow({required this.item});

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        _hovered ? SDSColor.gray900.withValues(alpha: 0.6) : SDSColor.gray900;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(WebRoutes.fleamarketDetail,
            parameters: {'id': '${widget.item.fleaId}'}),
        child: Row(
          children: [
            // 썸네일 48, radius 6 (피그마).
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(kFleamarketDefaultImage,
                  width: 48, height: 48, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 14, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_sidebarPriceFormat.format(widget.item.price)}원',
                    style:
                        SDSTextStyle.bold.copyWith(fontSize: 14, color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final List<FleamarketMyActivityItem> items;
  final bool isLoading;
  final bool isEmpty;
  final String emptyText;

  const _ActivitySection({
    required this.title,
    required this.items,
    required this.isLoading,
    required this.isEmpty,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목 Bold 14, 제목 ↔ 리스트 15 (피그마).
        Text(title, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
        const SizedBox(height: 10),
        if (isLoading && items.isEmpty)
          const ActivityListSkeleton()
        else if (isEmpty)
          Text(emptyText, style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400)),
        for (var i = 0; i < items.length; i++) ...[
          // 아이템 사이 1px 구분선, 상하 10 (피그마).
          if (i > 0) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: SDSColor.gray50),
            const SizedBox(height: 10),
          ],
          _ActivityRow(item: items[i]),
        ],
      ],
    );
  }
}
