import 'dart:io';

import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/web/data/slope_craft_maps_web.dart';
import 'package:com.snowlive/web/view/ranking/w_slopecraft_list_web.dart';
import 'package:com.snowlive/web/view/ranking/w_slopecraft_map_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SlopeRushItem _slope(String name, {List<(String, double)> crews = const []}) =>
    SlopeRushItem.fromJson({
      'slope_fullname': name,
      'slope_nickname': name,
      'crews': [
        for (final (crewName, ratio) in crews)
          {
            'crew_id': crewName.hashCode & 0xffff,
            'crew_name': crewName,
            'crew_logo_url': '',
            'description': '$crewName 소개',
            'count': (ratio * 1000).round(),
            'ratio': ratio,
          },
      ],
    });

void main() {
  group('지도 정적 데이터 (앱에서 옮긴 표)', () {
    test('모든 리조트에 슬러그·기본 지도 이미지가 있다', () {
      for (final resort in kSlopeCraftResorts) {
        final asset = slopeCraftDefaultAsset(resort.id);
        expect(asset, isNotNull, reason: '${resort.name} 슬러그 없음');
        expect(File(asset!).existsSync(), isTrue, reason: '$asset 파일 없음');
      }
    });

    test('마커 좌표의 모든 슬로프에 강조 이미지가 있다', () {
      var count = 0;
      kSlopeCraftMarkerPos.forEach((resortId, positions) {
        positions.forEach((key, offset) {
          count++;
          final asset = slopeCraftSlopeAsset(resortId, key);
          expect(asset, isNotNull);
          expect(File(asset!).existsSync(), isTrue, reason: '$asset 파일 없음');
          // 좌표는 0~1 비율이어야 지도 크기와 무관하게 맞는다.
          expect(offset.dx, inInclusiveRange(0, 1));
          expect(offset.dy, inInclusiveRange(0, 1));
        });
      });
      // 앱에서 옮긴 개수(146)가 줄어들면 표가 깨진 것이다.
      expect(count, 146);
    });

    test('마커 키는 슬로프명 표에도 있어야 라벨을 만들 수 있다', () {
      kSlopeCraftMarkerPos.forEach((resortId, positions) {
        for (final key in positions.keys) {
          expect(
            slopeCraftSlopeName(resortId, key),
            isNotNull,
            reason: '리조트 $resortId 의 $key 라벨 없음',
          );
        }
      });
    });

    test('서버 슬로프명 → 키 → 이름 왕복', () {
      // 휘닉스파크(13) 실측 슬로프명.
      final key = slopeCraftSlopeKey(13, '파노(휘)');
      expect(key, isNotNull);
      expect(slopeCraftSlopeName(13, key!), '파노(휘)');
      expect(slopeCraftSlopeKey(13, '없는슬로프'), isNull);
    });
  });

  group('점령률 표기', () {
    test('서버 0~1 비율을 퍼센트로', () {
      expect(slopeCraftRatioLabel(0.425), '42.5%');
      expect(slopeCraftRatioLabel(0.23), '23%');
      expect(slopeCraftRatioLabel(1.0), '100%');
      expect(slopeCraftRatioLabel(0), '0%');
    });
  });

  group('레이아웃 (1440 · 800 · 375)', () {
    final items = [
      _slope('도도', crews: [('GOM', 0.425), ('스타크', 0.3)]),
      _slope('듀크', crews: [('스키갤러리', 0.51)]),
      _slope('디지'), // 미점령
    ];

    SlopeCrew? leaderOf(SlopeRushItem item) {
      if (item.crews.isEmpty) return null;
      final sorted = [...item.crews]..sort((a, b) => b.ratio.compareTo(a.ratio));
      return sorted.first;
    }

    Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
      tester.view.physicalSize = Size(width, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    for (final width in [1440.0, 800.0, 375.0]) {
      testWidgets('지도가 ${width.toInt()}폭에서 마커까지 그려진다', (tester) async {
        await pumpAt(
          tester,
          width,
          SlopeCraftMapWeb(
            resortId: 13,
            resortName: '휘닉스파크',
            items: items,
            selectedSlopeKey: null,
            slopeKeyOf: (item) => slopeCraftSlopeKey(13, item.slopeNickname),
            leaderOf: leaderOf,
            onSelectSlope: (_) {},
            onSelectResort: (_) {},
          ),
        );
        expect(find.text('휘닉스파크'), findsOneWidget);
        expect(find.text('전체'), findsOneWidget);
        // 점령한 슬로프는 이름, 그 외에는 `미점령`(휘닉스 마커 17개 중 2개만 점령).
        expect(find.text('도도'), findsOneWidget);
        expect(find.text('미점령'), findsWidgets);
      });

      testWidgets('스키장 드롭다운을 눌러도 레이아웃이 깨지지 않는다 (${width.toInt()})', (tester) async {
        await pumpAt(
          tester,
          width,
          SlopeCraftMapWeb(
            resortId: 13,
            resortName: '휘닉스파크',
            items: items,
            selectedSlopeKey: null,
            slopeKeyOf: (item) => slopeCraftSlopeKey(13, item.slopeNickname),
            leaderOf: leaderOf,
            onSelectSlope: (_) {},
            onSelectResort: (_) {},
          ),
        );
        await tester.tap(find.text('휘닉스파크'));
        await tester.pumpAndSettle();
        // ⚠️ 앵커 context를 헤더 전체로 넘기면 `BoxConstraints ... NOT NORMALIZED`로
        // 화면이 죽었다(실측) → 트리거만 앵커여야 한다.
        expect(tester.takeException(), isNull);
        expect(find.text('용평리조트'), findsOneWidget);
      });

      testWidgets('점령 현황 목록이 ${width.toInt()}폭에서 그려진다', (tester) async {
        await pumpAt(
          tester,
          width,
          SlopeCraftListWeb(
            title: '휘닉스파크 점령 현황',
            items: items,
            selectedSlope: null,
            leaderOf: leaderOf,
            onSlopeTap: (_) {},
            onShowAll: () {},
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('휘닉스파크 점령 현황'), findsOneWidget);
        expect(find.text('GOM'), findsOneWidget);
        expect(find.text('42.5%'), findsOneWidget);
        // 슬로프를 고르지 않았으면 `전체 슬로프 보기` 버튼이 없다.
        expect(find.text('전체 슬로프 보기'), findsNothing);
      });
    }

    testWidgets('슬로프를 고르면 그 슬로프의 크루 전체 + 전체 보기 버튼', (tester) async {
      await pumpAt(
        tester,
        1440,
        SlopeCraftListWeb(
          title: '도도 점령 현황',
          items: items,
          selectedSlope: items.first,
          leaderOf: leaderOf,
          onSlopeTap: (_) {},
          onShowAll: () {},
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('전체 슬로프 보기'), findsOneWidget);
      // 점령률 내림차순으로 전부 보여준다.
      expect(find.text('GOM'), findsOneWidget);
      expect(find.text('스타크'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('아무도 점령하지 않은 슬로프는 안내 문구', (tester) async {
      await pumpAt(
        tester,
        800,
        SlopeCraftListWeb(
          title: '디지 점령 현황',
          items: items,
          selectedSlope: items.last,
          leaderOf: leaderOf,
          onSlopeTap: (_) {},
          onShowAll: () {},
        ),
      );
      expect(find.text('아직 아무도 점령하지 않은 슬로프예요.'), findsOneWidget);
    });
  });
}
