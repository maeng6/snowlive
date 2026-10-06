import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketAlert_web.dart'
    show openFleamarketAlert;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// GNB 사이드바(240)와 같은 폭 — 너무 넓지 않게.
/// 사이드바가 목록 첫 줄과 윗선을 맞추도록 내려오는 값(타이틀 줄 높이).
/// sticky 계산이 어긋나지 않게 **홈 레이아웃이 사이드바 바깥에서** 준다.
const double kFleamarketSidebarTopOffset = 56;

/// 웹 사이드바 공통 폭 — 220(2026-10-03 240에서 축소, 사용자 확정).
const double kFleamarketSidebarWidth = 220;
final _sidebarPriceFormat = NumberFormat('###,###,###,###');

/// 데스크탑 전용 우측 열: 키워드 알림 설정 + 최근 본 상품 + 찜 목록.
class FleamarketSidebarWeb extends StatelessWidget {
  /// 화면 폭에 따라 호출자가 줄여줄 수 있다(1024px에서 200까지).
  final double width;

  const FleamarketSidebarWeb({super.key, this.width = kFleamarketSidebarWidth});

  @override
  Widget build(BuildContext context) {
    final myActivityVm = Get.find<FleamarketMyActivityViewModel>();
    final buttonHeight = webActionButtonHeight(context);

    return Container(
      width: width,
      // 콘텐츠와의 간격(40)은 홈 레이아웃의 SizedBox가 담당한다 — 내부 left 패딩 없음.
      // 상단 오프셋(56)은 홈이 sticky 바깥에서 준다(kFleamarketSidebarTopOffset).
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 높이는 공용 webActionButtonHeight(PC 44). ⚠️ minimumSize만으로는
          // 웹 기본 visualDensity가 8을 깎아서 SizedBox로 겉에서 못 박는다.
          SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(WebRoutes.fleamarketUpload),
              style: ButtonStyle(
                // hover 색 전환을 애니메이션 없이 즉시 적용.
                animationDuration: Duration.zero,
                elevation: const WidgetStatePropertyAll(0),
                shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                minimumSize: WidgetStatePropertyAll(Size.fromHeight(buttonHeight)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? Color.alphaBlend(Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue)
                      : SDSColor.snowliveBlue,
                ),
              ),
              child: Text(
                '중고거래 물품 올리기',
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
              ),
            ),
          ),
          const SizedBox(height: SDSSpacing.sm),
          // 피그마에는 없지만 기능 진입점이라 유지한다(요청 전까지).
          // 공통 색 규칙(태블릿 하단바와 동일): 보더 없이 연회색(gray100) 채움.
          // hover 시 배경에 검정 10%를 섞어 어둡게.
          SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              // 미로그인이면 페이지 대신 로그인 유도 팝업(공통 처리).
              onPressed: () => openFleamarketAlert(context),
              style: ButtonStyle(
                // hover 색 전환을 애니메이션 없이 즉시 적용.
                animationDuration: Duration.zero,
                elevation: const WidgetStatePropertyAll(0),
                shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? Color.alphaBlend(Colors.black.withValues(alpha: 0.1), SDSColor.gray100)
                      : SDSColor.gray100,
                ),
                minimumSize: WidgetStatePropertyAll(Size.fromHeight(buttonHeight)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                foregroundColor: const WidgetStatePropertyAll(SDSColor.gray900),
              ),
              // 색은 foregroundColor가 입힌다(여기서 지정하면 상태별 색이 안 먹는다).
              child: Text('키워드 알림 설정', style: SDSTextStyle.bold.copyWith(fontSize: 14)),
            ),
          ),
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

/// 최근 본 상품/찜 목록 한 줄 — 탭하면 상세로 이동(상세 화면이 id로 재조회).
/// hover 시 텍스트가 60% 불투명도로 살짝 죽는다.
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
    final Color textColor = _hovered ? SDSColor.gray900.withValues(alpha: 0.6) : SDSColor.gray900;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            Get.toNamed(WebRoutes.fleamarketDetail, parameters: {'id': '${widget.item.fleaId}'}),
        child: Row(
          children: [
            // 썸네일 48, radius 6 (피그마).
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(kFleamarketDefaultImage, width: 48, height: 48, fit: BoxFit.cover),
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
                    style: SDSTextStyle.regular.copyWith(fontSize: 14, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_sidebarPriceFormat.format(widget.item.price)}원',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: textColor),
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
          Text(
            emptyText,
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
          ),
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
