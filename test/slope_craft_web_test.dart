import 'dart:io';

import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/web/data/slope_craft_marker_pos_generated_web.dart';
import 'package:com.snowlive/web/data/slope_craft_maps_web.dart';
import 'package:com.snowlive/web/view/ranking/v_slopeCraft_web.dart';
import 'package:com.snowlive/web/view/ranking/w_slopecraft_list_web.dart';
import 'package:com.snowlive/web/view/ranking/w_slopecraft_map_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
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
      // ⚠️ 크루 로고(기본 마크 포함)는 네트워크 이미지라 테스트에서는 영영 로딩 중이고,
      // 로딩 스켈레톤이 무한 애니메이션이라 pumpAndSettle이 끝나지 않는다.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
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
        await tester.pump(const Duration(milliseconds: 100));
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

    /// 목업 82:64717 실측값.
    testWidgets('목록 줄 치수가 목업과 같다 — 줄 48 · 로고 48 · 제목 아래 30', (tester) async {
      await pumpAt(
        tester,
        1440,
        SizedBox(
          width: 480,
          child: SlopeCraftListWeb(
            title: '휘닉스파크 점령 현황',
            items: items,
            selectedSlope: null,
            leaderOf: leaderOf,
            onSlopeTap: (_) {},
            onShowAll: () {},
          ),
        ),
      );

      final title = tester.getRect(find.text('휘닉스파크 점령 현황'));
      final rows = find.byType(InkWell);
      final first = tester.getRect(rows.at(0));
      final second = tester.getRect(rows.at(1));

      // 줄 높이 48 + 위아래 6 = 피치 60.
      expect(first.height, closeTo(48 + 12, 0.5));
      expect(second.top - first.top, closeTo(60, 0.5));

      // hover 배경(=줄 박스)은 내용 위아래로 **똑같이** 벌어진다.
      final logo = tester.getRect(find.byType(WebNetworkImage).first);
      expect(logo.top - first.top, closeTo(first.bottom - logo.bottom, 0.5));

      // hover 배경은 목록 폭(480)보다 좌우 12씩 넓고, 글자는 제자리다.
      expect(first.width, closeTo(480 + 24, 0.5));
      final slopeName = tester.getRect(find.text('도도'));
      expect(slopeName.left - first.left, closeTo(12, 0.5));

      // 제목 글자 ↔ 첫 줄 내용 20.5 — 목업은 30이지만 좁혀 쓴다(사용자 확정).
      // (제목 줄 36 안에서 글자가 세로 중앙 8.5 + 제목 아래 6 + 줄 위 여백 6)
      expect(logo.top - title.bottom, closeTo(20.5, 1.0));
    });

    /// 슬로프 선택 상태 목업 82:67418.
    testWidgets('슬로프 모드 — 제목 줄 36 · 전체 보기 버튼 36', (tester) async {
      await pumpAt(
        tester,
        1440,
        SizedBox(
          width: 480,
          child: SlopeCraftListWeb(
            title: '파노라마 점령 현황',
            items: items,
            selectedSlope: items.first,
            leaderOf: leaderOf,
            onSlopeTap: (_) {},
            onShowAll: () {},
          ),
        ),
      );

      final button = tester.getRect(find.widgetWithText(OutlinedButton, '전체 슬로프 보기'));
      expect(button.height, closeTo(36, 0.5));
      // 버튼은 제목 줄 오른쪽 끝에 붙는다.
      final header = tester.getRect(find.text('파노라마 점령 현황'));
      expect(button.center.dy, closeTo(header.center.dy, 1.0));

      // 줄 높이는 전체 모드와 같다(버튼도 InkWell이라 크루 줄로 좁혀 찾는다).
      final row = tester.getRect(find
          .ancestor(of: find.text('GOM'), matching: find.byType(InkWell))
          .first);
      expect(row.height, closeTo(48 + 12, 0.5));
    });

    /// 태블릿 목업 82:53523 — 지도 카드 안쪽이 카드 폭에 비례한다.
    testWidgets('지도 카드 내부는 카드 폭에 비례한다 (PC 640 기준)', (tester) async {
      // 환산값만 검증한다(실제 치수는 이 값을 곱해 나온다).
      expect(slopeCraftMapScale(640), closeTo(1.0, 0.001));
      expect(slopeCraftMapScale(760), closeTo(1.1875, 0.001));
      // 목업 실측과 대조: 마커 36→42.8, 이름표 60→71.2, 여백 20→24.
      expect(36 * slopeCraftMapScale(760), closeTo(42.75, 0.3));
      expect(60 * slopeCraftMapScale(760), closeTo(71.25, 0.3));
      expect(20 * slopeCraftMapScale(760), closeTo(23.75, 0.3));
      // 모바일은 비례하지 않고 **앱과 같은 고정값**을 쓴다(목업 19.3은 너무 작다).
      // SlopeCraftMarkerStyle 쪽에서 검증한다.
    });

    testWidgets('모바일 마커는 앱과 같은 고정 크기(24/36 · 글자 10)', (tester) async {
      late SlopeCraftMarkerStyle mobile;
      late SlopeCraftMarkerStyle desktop;
      await pumpAt(
        tester,
        375,
        Builder(builder: (context) {
          mobile = SlopeCraftMarkerStyle.of(context, 343);
          return const SizedBox();
        }),
      );
      expect(mobile.size, 24);
      expect(mobile.selectedSize, 36);
      expect(mobile.labelScale, 1, reason: '이름표 글자는 앱과 같은 10px');

      await pumpAt(
        tester,
        1440,
        Builder(builder: (context) {
          desktop = SlopeCraftMarkerStyle.of(context, 640);
          return const SizedBox();
        }),
      );
      expect(desktop.size, 36);
      expect(desktop.labelScale, 1);
    });

    testWidgets('좌표표는 모바일만 손 좌표, PC·태블릿은 정밀 좌표', (tester) async {
      late SlopeCraftMarkerStyle style;
      Future<void> at(double width, double mapWidth) => pumpAt(
            tester,
            width,
            Builder(builder: (context) {
              style = SlopeCraftMarkerStyle.of(context, mapWidth);
              return const SizedBox();
            }),
          );

      await at(375, 311);
      expect(style.precisePositions, isFalse, reason: '모바일은 앱과 눈이 같아야 한다');
      await at(800, 712);
      expect(style.precisePositions, isTrue);
      await at(1440, 600);
      expect(style.precisePositions, isTrue);
    });

    // hover로 커질 자리를 미리 비워 두기 때문에 `원 크기 ≠ 칸 크기`다.
    // 전에는 top에서 원 크기만 빼서 **선택 안 된 원이 hoverGrow/2 만큼 아래로** 밀렸다.
    for (final (width, mapWidth, selected) in [
      (1440.0, 600.0, false),
      (1440.0, 600.0, true),
      (375.0, 311.0, false),
    ]) {
      testWidgets(
          '마커 원 중심이 좌표에 온다 (${width.toInt()}폭'
          '${selected ? ' · 선택됨' : ''})', (tester) async {
        await pumpAt(
          tester,
          width,
          SlopeCraftMapWeb(
            resortId: 13,
            resortName: '휘닉스파크',
            items: [_slope('도도', crews: [('스노우', 1.0)])],
            selectedSlopeKey: selected ? 'dodo' : null,
            slopeKeyOf: (item) => slopeCraftSlopeKey(13, item.slopeNickname),
            leaderOf: leaderOf,
            onSelectSlope: (_) {},
            onSelectResort: (_) {},
          ),
        );

        // 지도 박스 = 마커가 얹히는 Stack 영역.
        final mapBox = find.byType(AspectRatio).first;
        final box = tester.getRect(mapBox);
        // 슬로프를 고르면 카드 머리글에도 같은 이름이 떠서, **지도 안쪽**으로 좁힌다.
        final column = find
            .ancestor(
              of: find.descendant(of: mapBox, matching: find.text('도도')),
              matching: find.byType(Column),
            )
            .first;
        final circle = tester.getRect(
          find.descendant(of: column, matching: find.byType(AnimatedContainer)).first,
        );

        late SlopeCraftMarkerStyle style;
        await pumpAt(
          tester,
          width,
          Builder(builder: (context) {
            style = SlopeCraftMarkerStyle.of(context, mapWidth);
            return const SizedBox();
          }),
        );
        final pos = slopeCraftMarkerPos(13, precise: style.precisePositions)['dodo']!;

        expect(circle.center.dy, closeTo(box.top + pos.dy * box.height, 0.5),
            reason: '세로 중심이 dy*h 에 와야 한다');
        expect(circle.center.dx, closeTo(box.left + pos.dx * box.width, 0.5),
            reason: '가로 중심은 이름표 길이와 무관해야 한다');
      });
    }

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

  // 지도가 큰 PC에서는 손 좌표의 비율 오차가 큰 픽셀 오차가 된다 → 하이라이트
  // 이미지에서 뽑은 표를 따로 쓴다. 생성기: tool/slope_craft/gen_marker_pos.py
  group('정밀 좌표표 (생성)', () {
    test('두 표의 키 집합이 완전히 같다', () {
      expect(kSlopeCraftMarkerPosPrecise.keys.toSet(),
          kSlopeCraftMarkerPos.keys.toSet());
      for (final resortId in kSlopeCraftMarkerPos.keys) {
        expect(
          kSlopeCraftMarkerPosPrecise[resortId]!.keys.toSet(),
          kSlopeCraftMarkerPos[resortId]!.keys.toSet(),
          reason: '리조트 $resortId — 한쪽에만 슬로프를 추가하면 그 마커가 폭에 따라 사라진다',
        );
      }
    });

    test('개수·범위·에셋이 손 좌표표와 같은 조건을 만족한다', () {
      var count = 0;
      kSlopeCraftMarkerPosPrecise.forEach((resortId, positions) {
        positions.forEach((key, offset) {
          count++;
          expect(slopeCraftSlopeAsset(resortId, key), isNotNull);
          expect(File(slopeCraftSlopeAsset(resortId, key)!).existsSync(), isTrue,
              reason: '$resortId/$key 하이라이트 이미지가 없다');
          expect(offset.dx, inInclusiveRange(0, 1));
          expect(offset.dy, inInclusiveRange(0, 1));
        });
      });
      expect(count, 146);
      // ⚠️ "좌표가 실제로 마스크 위에 있는가"는 PNG 디코드가 필요해 Dart에서 못 한다
      // (package:image 미의존). 생성기가 빈 마스크에서 실패하고 스냅으로 보장한다.
    });

    test('손보정은 생성값에 실제로 존재하는 슬로프만 가리킨다', () {
      kSlopeCraftMarkerPosOverride.forEach((resortId, positions) {
        final generated = kSlopeCraftMarkerPosGenerated[resortId];
        expect(generated, isNotNull, reason: '없는 리조트 $resortId 를 보정하고 있다');
        for (final key in positions.keys) {
          expect(generated!.containsKey(key), isTrue,
              reason: '$resortId/$key — 오타면 보정이 조용히 무시된다');
          expect(kSlopeCraftMarkerPosPrecise[resortId]![key], positions[key],
              reason: '손보정이 생성값을 이겨야 한다');
        }
      });
    });

    // 가까운 슬로프끼리 원·이름표가 겹쳐 보였다(PC 기준 30쌍) → 생성기가 코스 위에
    // 둔 채로 떼어 놓는다. 여기서는 그 결과가 유지되는지만 지킨다.
    // 치수는 tool/slope_craft/overlap.py 와 같은 값이어야 한다.
    test('PC에서 마커끼리 겹치지 않는다', () {
      const mapW = 600.0;                 // 콘텐츠 1160 안 4:3 → 카드 640 − 여백 40
      const mapH = mapW * 900 / 780;
      const scale = mapW / 640;
      const circle = 36 * scale;
      const slot = circle + 6 * scale;    // hover로 커질 자리
      const font = 10 * scale;
      const columnH = slot + 2 * scale + (font * 1.25 + 2 * scale);

      // Pretendard Bold 근사 — 한글·전각 1.0em, 나머지 0.55em.
      double textWidth(String t) =>
          t.runes.fold<double>(0, (w, c) => w + (c > 0x2000 ? 1.0 : 0.55)) * font;

      Rect boxOf(Offset o, String label) {
        final w = [circle, textWidth(label) + 2 * 3 * scale]
            .reduce((a, b) => a > b ? a : b);
        return Rect.fromLTWH(
            o.dx * mapW - w / 2, o.dy * mapH - slot / 2, w, columnH);
      }

      final clashes = <String>[];
      kSlopeCraftMarkerPosPrecise.forEach((resortId, positions) {
        final keys = positions.keys.toList();
        for (var i = 0; i < keys.length; i++) {
          for (var j = i + 1; j < keys.length; j++) {
            final a = boxOf(positions[keys[i]]!,
                slopeCraftSlopeName(resortId, keys[i]) ?? keys[i]);
            final b = boxOf(positions[keys[j]]!,
                slopeCraftSlopeName(resortId, keys[j]) ?? keys[j]);
            final hit = a.intersect(b);
            // 1px 미만으로 스치는 것은 눈에 안 띄므로 통과시킨다.
            if (hit.width > 1 && hit.height > 1) {
              clashes.add('$resortId ${keys[i]}↔${keys[j]} '
                  '(${hit.width.toStringAsFixed(1)}x${hit.height.toStringAsFixed(1)})');
            }
          }
        }
      });
      expect(clashes, isEmpty, reason: '겹치는 마커: ${clashes.join(', ')}');
    });

    test('slopeCraftMarkerPos가 폭에 맞는 표를 돌려준다', () {
      expect(slopeCraftMarkerPos(13, precise: false), kSlopeCraftMarkerPos[13]);
      expect(slopeCraftMarkerPos(13, precise: true),
          kSlopeCraftMarkerPosPrecise[13]);
      expect(slopeCraftMarkerPos(999, precise: true), isEmpty);
    });
  });

  // 4:3으로 쪼개면 지도는 콘텐츠의 약 0.57배만 받는다 → 좁은 PC에서는 지도가
  // 태블릿보다도 작아졌다(1023폭 935 → 1024폭 362, 2.6배 급감).
  group('좁은 PC는 태블릿처럼 세로로 쌓는다', () {
    test('콘텐츠가 설계폭에 닿아야 나란히 놓는다', () {
      expect(slopeCraftUsesSideBySide(kSlopeCraftContentMaxWidth), isTrue);
      expect(slopeCraftUsesSideBySide(kSlopeCraftContentMaxWidth - 1), isFalse);
    });

    test('PC 1440(사이드바 200)은 나란히, 1024는 쌓는다', () {
      // 콘텐츠 = min(뷰포트 - 사이드바 - 좌우여백 80, 1160)
      double content(double viewport, double rail) =>
          [viewport - rail - 80, kSlopeCraftContentMaxWidth].reduce((a, b) => a < b ? a : b);

      expect(slopeCraftUsesSideBySide(content(1440, 200)), isTrue);
      expect(slopeCraftUsesSideBySide(content(1024, 200)), isFalse);
      expect(slopeCraftUsesSideBySide(content(1280, 200)), isFalse);
      // 사이드바를 접으면 더 좁은 창에서도 나란히 선다.
      expect(slopeCraftUsesSideBySide(content(1309, 69)), isTrue);
    });

    test('쌓을 때 지도가 훨씬 넓어진다 — 이름표가 읽히는 크기가 된다', () {
      const cardPadding = 40.0; // 지도 카드 좌우 여백 20씩
      const mapToListGap = 40.0; // 화면의 _kMapToListGap (private라 여기 옮겨 적는다)
      double rowMap(double content) =>
          4 / 7 * (content - mapToListGap) - cardPadding;
      double colMap(double content) => content - cardPadding;

      const narrow = 744.0; // 뷰포트 1024, 사이드바 200
      expect(slopeCraftUsesSideBySide(narrow), isFalse);
      // 이름표는 10 * (지도폭/640).
      expect(10 * rowMap(narrow) / 640, lessThan(6), reason: '지금까지 이렇게 작았다');
      expect(10 * colMap(narrow) / 640, greaterThan(10), reason: '쌓으면 읽힌다');
    });
  });
}
