import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';

// 폼 필드 위젯(WebFormTextField/WebFormDropdownField/…)은 커뮤니티 작성 화면과
// 공용이라 lib/web/widget/으로 올렸다. 기존 import 경로가 계속 동작하도록 re-export한다.
export 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';

/// 중고거래 글 올리기/수정 폼에서 쓰는 선택지 목록.
/// (모바일 lib/widget/w_category_main_fleamarket.dart 등과 동일한 값)
const List<String> kFleamarketCategoryMainList = ['스키', '스노보드'];
const List<String> kFleamarketCategorySubSkiList = ['플레이트', '바인딩', '부츠', '의류', '기타'];
const List<String> kFleamarketCategorySubBoardList = ['데크', '바인딩', '부츠', '의류', '기타'];
const List<String> kFleamarketTradeMethodList = ['직거래', '택배거래', '무관'];
final List<String> kFleamarketTradeSpotList = FleamarketCategory_spot.values
    .where((e) => e != FleamarketCategory_spot.total)
    .map((e) => e.korean)
    .toList();

const String kFleamarketCategoryMainPlaceholder = '상위 카테고리';
const String kFleamarketCategorySubPlaceholder = '하위 카테고리';
const String kFleamarketTradeMethodPlaceholder = '거래방법 선택';
const String kFleamarketTradeSpotPlaceholder = '거래장소 선택';
