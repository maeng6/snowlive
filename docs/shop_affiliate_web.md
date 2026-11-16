# 추천 상품(쿠팡 파트너스) 웹 — 인수인계

웹 GNB **`추천 상품`** 메뉴(`#/shop`). 쿠팡 파트너스 제휴 링크를 카테고리별로 모아 보여주고,
카드를 누르면 쿠팡이 **새 탭**으로 열린다. 상세 화면은 없다.

## ⚡ 2026-11 업데이트 — 어드민 관리 + 서버 API 연동 완료
데이터는 이제 **서버 API**에서 온다(하드코딩 JSON 아님). 상품은 **어드민에서 관리**한다:
- 어드민 `/admin/affiliate/` **추천상품 관리** — 카테고리 선택 + **쿠팡 HTML 코드 붙여넣기** →
  단축링크·이미지·제목 자동 파싱 → 목록(순서/노출/삭제). 쿠팡 코드만 붙여넣으면 끝.
- 공개 API `GET /api/affiliate/products/` (JSON 모양은 아래 2번과 동일, `kind`·`embed_url` 추가).
- 프론트는 [ApiAffiliateProductRepository]를 쓴다(바인딩에서 교체 완료).
- **가격 표시**: 수동 입력값은 금방 틀려져서 안 띄운다. 쿠팡 **다이나믹 배너** 코드를 붙여넣으면
  그 상품은 `kind='widget'`이 되고, 카드 대신 쿠팡 위젯 iframe([coupang_widget.dart])으로 렌더돼
  **쿠팡이 실시간 가격**까지 그려준다(정책상 안전). 일반 상품 링크는 커스텀 카드(가격 없음).

- **어드민에서 붙여넣은 상품의 이미지**: '블로그용 태그'의 `<img>`는 상품 썸네일이 아니라
  쿠팡 **배너**(120×240, `/image/affiliate/banner/…@2x.jpg`)다 — 로고·제목·로켓배지·버튼이
  그림에 박혀 있다. 프론트는 이 URL(`shopIsBannerImage`)이면 배너 안 상품 사진 구간
  (세로 64~304/480)만 잘라 정사각 셀에 보인다(`shop_banner_image_web.dart`).
  ⚠️ 자르기는 **DOM(CSS) 안에서** 한다 — 쿠팡 CDN은 CORS가 없어 이미지가 DOM `<img>`
  플랫폼뷰로 그려지는데, 거기에 Flutter 쪽 ClipRect는 iOS Safari에서 안 먹어 배너 전체가
  셀 밖으로 넘쳐 칩 줄을 덮었다(카테고리 탭이 안 눌리고, 홈 화면 숏컷에선 새로고침 반복).
  같은 이유로 두 가지 더: 그리드 카드는 **상품 id로 키**를 준다(안 주면 카테고리를 바꿔도
  재사용된 `<img>`가 예전 사진을 그대로 든다), 배너 플랫폼뷰는 **IgnorePointer**로 감싼다
  (안 감싸면 플랫폼뷰의 제스처 인식기가 아레나에서 이겨 카드 탭이 안 먹는다).
  브랜드·소분류가 비면
  보조 줄에 카테고리를 넣어 카드 높이가 어긋나지 않게 한다. (서버가 링크 생성 화면의
  `product[image]` 썸네일을 저장해 주면 이 크롭은 자동으로 안 탄다.)
- **GNB 재진입**: 뷰모델이 라우트 스택에 남아 살아 있어서, 다른 탭 갔다가 돌아오면
  전에 고른 카테고리·목록이 그대로였다 → `ShopViewWeb.initState`에서
  `vm.enterFromGnb()`(전체로 + 재조회). 브라우저 뒤로가기로 돌아오는 건 그대로 유지.

아래 2~5번은 설계 당시 제안으로, 지금 구현과 거의 같다(참고용).

## 1. 파일

| 파일 | 역할 |
|---|---|
| `assets/json/affiliate_products.json` | **하드코딩 데이터.** 모양이 곧 API 응답 제안(아래 2번). 쿠팡 파트너스에서 수동으로 뽑은 16개 |
| `lib/core/model/m_affiliate_product.dart` | 모델 `AffiliateProduct` + `tryParse`(깨진 건 null) |
| `lib/web/data/affiliate_product_repository_web.dart` | `AffiliateProductRepository`(인터페이스) · `AssetAffiliateProductRepository`(JSON 에셋 구현) · `parseAffiliateProducts` |
| `lib/web/viewmodel/shop/vm_shop_web.dart` | `ShopViewModelWeb` — 목록·선택 카테고리·로딩·에러. 저장소만 주입받는다 |
| `lib/web/view/shop/shop_sections_web.dart` | 순수 규칙: 메뉴명 `kShopMenuLabel`, 카테고리 순서, 고지 문구, 가격 표시 플래그 `kShopShowsPrice`, 이미지 크기 치환 |
| `lib/web/view/shop/v_shop_web.dart` | 화면(타이틀 → 고지 → 칩 → 그리드 → 푸터) |
| `lib/web/view/shop/w_shop_card_web.dart` · `w_shop_grid_web.dart` · `w_shop_category_chips_web.dart` | 카드 · 그리드(+스켈레톤) · 칩 |
| `lib/web/routes/routes_web.dart` · `bindings_web.dart` | `WebRoutes.shop` · `WebShopBinding` |
| `lib/web/widget/gnb/w_gnb_nav_items.dart` | GNB 항목(중고거래 아래) · 아이콘 `assets/imgs/icons/icon_web_shop(_select).svg` |
| `test/shop_web_test.dart` | 파싱·카테고리·정렬·이미지 URL·카드·칩·그리드 열 수 |

## 2. 서버 API 제안

```
GET /api/affiliate/products/
    ?category=스키        (선택. 없으면 전체)
```

응답 — `assets/json/affiliate_products.json`과 **같은 모양**:

```json
{
  "products": [
    {
      "id": 1,
      "title": "[강원도/홍천/비발디] 비발디파크 오픈특가 리프트 할인!!!",
      "category": "리프트권·렌탈",
      "sub_category": "리프트권",
      "brand": "",
      "image_url": "https://thumbnail14.coupangcdn.com/thumbnails/remote/212x212ex/image/…png",
      "url": "https://link.coupang.com/a/iFxJnBVSE0",
      "note": "시즌 초 오픈 특가 리프트권",
      "origin_price": 37000,
      "sales_price": 36000,
      "order": 1,
      "active": true
    }
  ]
}
```

- `category`: `리프트권·렌탈` · `스키` · `보드` · `보호장비` · `의류` · `액세서리` · `여행·차량`.
  이 밖의 값이 와도 화면은 깨지지 않고 칩 맨 뒤에 붙는다(`kShopCategoryOrder`).
- `url`은 파트너스 **단축 링크**(`link.coupang.com/a/…`)여야 수수료가 잡힌다.
- `image_url`은 파트너스 링크 생성 화면이 주는 쿠팡 CDN 썸네일(212px). 화면은 `/212x212ex/`를
  `/492x492ex/`로 바꿔 요청하고 실패하면 원본으로 폴백한다.
- `active: false`는 화면에서 뺀다. `order` 오름차순(같으면 `id`).
- 필수: `id` `title` `category` `url`. 나머지는 비어도 된다.

### 프론트에서 바꿀 곳(서버 붙을 때)
1. `AffiliateProductRepository`를 구현하는 `ApiAffiliateProductRepository` 추가
   (`http` GET → `parseAffiliateProducts(jsonDecode(body))`).
2. `WebShopBinding`에서 `AssetAffiliateProductRepository()` → API 구현으로 교체. **끝.**
3. 실시간 가격을 주면 `kShopShowsPrice = true` — 카드에 `sales_price`가 뜬다
   (텍스트 블록 높이는 `shopCardTextBlockHeight()`가 알아서 늘린다).

## 3. 쿠팡 파트너스 규정 — 지켜야 할 것

- **고지 문구** `kShopDisclosure`를 상품이 보이는 화면에 반드시 노출(지금은 타이틀 바로 아래).
  문구를 바꾸면 안 된다: "이 포스팅은 쿠팡 파트너스 활동의 일환으로, 이에 따른 일정액의 수수료를 제공받습니다."
- **가격은 수동 데이터로 보여주지 않는다**(`kShopShowsPrice = false`). 쿠팡 가격이 바뀌면
  틀려지고 표시광고법 문제가 된다. API로 실시간 가격을 받을 때만 켠다.
- **이미지는 파트너스가 준 CDN URL만.** 상품 페이지 사진을 직접 받아 올리지 않는다.
- 링크는 새 탭(`LaunchMode.externalApplication`).
- 홈 등 다른 화면에 상품을 노출하면 거기에도 고지 문구가 같이 가야 한다.

## 4. 데이터 추가(파트너스 API 승인 전, 수동)

1. partners.coupang.com → 상품 검색 → 카드 hover → **링크 생성**.
2. 뜨는 화면에서 **단축 URL** 복사. 이미지 URL은 그 화면 주소의 `product[image]` 값
   (또는 검색 결과 카드 `<img alt="product">`의 `src`).
3. `assets/json/affiliate_products.json`에 한 건 추가(`id`는 안 겹치게, `order`로 순서).
4. `flutter test test/shop_web_test.dart` → QA 배포.

파트너스 Open API가 승인되면 `products/search` 응답을 위 JSON 모양으로 바꿔 서버에 넣는
배치가 가장 깔끔하다(프론트는 그대로).

## 5. 아직 없는 것

- 클릭 집계(GA). 웹에 GA 이벤트 공통이 없어 넣지 않았다. 필요하면 `ShopCardWeb.onTap`
  자리에서 서버 로그로 보내는 게 쉽다.
- 홈 섹션 노출. 상품이 50개쯤 쌓이면 붙이기로 했다(고지 문구 필수).
