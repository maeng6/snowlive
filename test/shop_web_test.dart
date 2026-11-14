import 'package:com.snowlive/core/model/m_affiliate_product.dart';
import 'package:com.snowlive/web/data/affiliate_product_repository_web.dart';
import 'package:com.snowlive/web/view/shop/shop_sections_web.dart';
import 'package:com.snowlive/web/view/shop/w_shop_card_web.dart';
import 'package:com.snowlive/web/view/shop/w_shop_category_chips_web.dart';
import 'package:com.snowlive/web/view/shop/w_shop_grid_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _raw(
  int id, {
  String category = '스키',
  String sub = '고글',
  String brand = 'SMIRIA',
  int order = 0,
  bool active = true,
  String url = 'https://link.coupang.com/a/abc',
  String image = 'https://thumbnail14.coupangcdn.com/thumbnails/remote/212x212ex/image/x.png',
}) =>
    {
      'id': id,
      'title': '상품 $id',
      'category': category,
      'sub_category': sub,
      'brand': brand,
      'image_url': image,
      'url': url,
      'note': '',
      'origin_price': 10000,
      'sales_price': 9000,
      'order': order,
      'active': active,
    };

AffiliateProduct _p(int id, {String category = '스키', int order = 0}) =>
    AffiliateProduct.tryParse(_raw(id, category: category, order: order))!;

Widget _wrap(Widget child, {double width = 1440}) => MediaQuery(
      data: MediaQueryData(size: Size(width, 900)),
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(width: width, child: SingleChildScrollView(child: child)),
        ),
      ),
    );

/// 카드 하나를 셀 폭(240)으로 왼쪽 위에 놓는다 — 기본 테스트 뷰(800x600) 안에 들어오게.
Widget _card(Widget card) =>
    _wrap(Align(alignment: Alignment.topLeft, child: SizedBox(width: 240, child: card)), width: 800);

/// 추천 상품(쿠팡 파트너스) 화면의 가공 규칙과 카드·칩 표시.
void main() {
  group('응답 파싱', () {
    test('정상 항목은 모델로, 필수값이 빠진 항목은 건너뛴다', () {
      final items = parseAffiliateProducts({
        'products': [
          _raw(1),
          {'id': 2, 'title': '', 'category': '스키', 'url': 'https://x'}, // 제목 없음
          {'id': 3, 'title': '링크 없음', 'category': '스키', 'url': 'abc'}, // http 아님
          'not a map',
          _raw(4, active: false), // 내려간 상품
          _raw(5),
        ],
      });
      expect(items.map((p) => p.id), [1, 5]);
      expect(items.first.subCategory, '고글');
      expect(items.first.salesPrice, 9000);
    });

    test('products 키 없이 배열만 와도 읽는다 · 빈 응답은 빈 목록', () {
      expect(parseAffiliateProducts([_raw(1)]), hasLength(1));
      expect(parseAffiliateProducts(null), isEmpty);
      expect(parseAffiliateProducts(const {'products': 'oops'}), isEmpty);
    });
  });

  group('카테고리·정렬', () {
    test('전체 + 데이터에 있는 카테고리만 정해진 순서로, 모르는 카테고리는 뒤에', () {
      final items = [
        _p(1, category: '의류'),
        _p(2, category: '리프트권·렌탈'),
        _p(3, category: '신규카테고리'),
        _p(4, category: '스키'),
      ];
      expect(shopCategories(items), ['전체', '리프트권·렌탈', '스키', '의류', '신규카테고리']);
      expect(shopCategories(const []), ['전체']);
    });

    test('선택 카테고리만 남기고 order → id 순으로 정렬한다', () {
      final items = [
        _p(3, category: '스키', order: 2),
        _p(1, category: '보드', order: 1),
        _p(2, category: '스키', order: 1),
        _p(4, category: '스키', order: 1),
      ];
      expect(shopVisibleItems(items, '스키').map((p) => p.id), [2, 4, 3]);
      expect(shopVisibleItems(items, '전체').map((p) => p.id), [1, 2, 4, 3]);
      expect(shopVisibleItems(items, '의류'), isEmpty);
    });
  });

  group('이미지 URL', () {
    test('쿠팡 CDN 썸네일의 크기 구간만 바꾼다', () {
      expect(
        shopImageUrlAt('https://t.coupangcdn.com/thumbnails/remote/212x212ex/image/a.png', 492),
        'https://t.coupangcdn.com/thumbnails/remote/492x492ex/image/a.png',
      );
      // 크기 구간이 없으면 손대지 않는다.
      expect(shopImageUrlAt('https://x.com/a.png', 492), 'https://x.com/a.png');
    });
  });

  group('카드', () {
    testWidgets('제목·브랜드·소분류·쿠팡 링크 문구를 그리고 가격은 숨긴다', (tester) async {
      await tester.pumpWidget(_card(ShopCardWeb(product: _p(1), onTap: () {})));
      await tester.pump();
      expect(find.text('상품 1'), findsOneWidget);
      expect(find.text('SMIRIA · 고글'), findsOneWidget);
      expect(find.text('쿠팡에서 보기'), findsOneWidget);
      // 수동 수집 가격은 화면에 내지 않는다(kShopShowsPrice = false).
      expect(find.textContaining('원'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('카드를 누르면 onTap이 불린다', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_card(ShopCardWeb(product: _p(1), onTap: () => tapped++)));
      await tester.pump();
      await tester.tap(find.text('상품 1'));
      expect(tapped, 1);
    });
  });

  group('칩', () {
    testWidgets('선택한 칩을 알려주고 누르면 콜백이 온다', (tester) async {
      String? picked;
      await tester.pumpWidget(_wrap(
        ShopCategoryChipsWeb(
          categories: const ['전체', '스키', '보드'],
          selected: '스키',
          onSelected: (c) => picked = c,
        ),
        width: 375,
      ));
      await tester.pump();
      expect(find.text('전체'), findsOneWidget);
      await tester.tap(find.text('보드'));
      expect(picked, '보드');
      expect(tester.takeException(), isNull);
    });
  });

  group('그리드', () {
    for (final (width, expectedColumns) in [(1440, 5), (800, 5), (375, 2)]) {
      testWidgets('$width 폭에서 $expectedColumns열, 예외 없음', (tester) async {
        tester.view.physicalSize = Size(width.toDouble(), 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        final items = [for (var i = 1; i <= 6; i++) _p(i)];
        await tester.pumpWidget(_wrap(ShopGridWeb(items: items), width: width.toDouble()));
        await tester.pump();
        expect(tester.takeException(), isNull);
        final firstY = tester.getTopLeft(find.text('상품 1')).dy;
        final nextRowY = tester.getTopLeft(find.text('상품 ${expectedColumns + 1}')).dy;
        final lastInRowY = tester.getTopLeft(find.text('상품 $expectedColumns')).dy;
        expect(lastInRowY, firstY); // 같은 줄
        expect(nextRowY, greaterThan(firstY)); // 다음 줄
      });
    }

    testWidgets('스켈레톤은 예외 없이 그려진다', (tester) async {
      await tester.pumpWidget(_wrap(const ShopGridSkeleton(itemCount: 5)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
