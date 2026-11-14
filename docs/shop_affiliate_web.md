# 추천 상품(쿠팡 파트너스) 웹 — 인수인계

웹 GNB **`추천 상품`** 메뉴(`#/shop`). 쿠팡 파트너스 제휴 링크를 카테고리별로 모아 보여주고,
카드를 누르면 쿠팡이 **새 탭**으로 열린다. 상세 화면은 없다.

지금은 **프론트만** 있고 데이터는 하드코딩(JSON 에셋)이다. 서버 작업은 이 문서대로 붙이면
화면·뷰모델은 손대지 않아도 된다.

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
