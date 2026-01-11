import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_fleamarket_alert.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketAlert.dart';
import 'package:com.snowlive/widget/w_category_main_fleamarket.dart';
import 'package:com.snowlive/widget/w_category_sub_ski_fleamarket.dart';
import 'package:com.snowlive/widget/w_category_sub_board_fleamarket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FleamarketAlertSettingsView extends StatefulWidget {
  const FleamarketAlertSettingsView({Key? key}) : super(key: key);

  @override
  State<FleamarketAlertSettingsView> createState() => _FleamarketAlertSettingsViewState();
}

class _FleamarketAlertSettingsViewState extends State<FleamarketAlertSettingsView> {
  final FleamarketAlertViewModel _alertViewModel = Get.find<FleamarketAlertViewModel>();
  String _currentTab = '키워드 알림';

  @override
  void initState() {
    super.initState();
    _alertViewModel.fetchAllAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
        surfaceTintColor: SDSColor.snowliveWhite,
        elevation: 0,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Get.back();
          },
        ),
        title: Text(
          '키워드 알림 설정',
          style: SDSTextStyle.bold.copyWith(
            color: SDSColor.gray900,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 탭 메뉴
          Stack(
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  width: _size.width,
                  height: 1,
                  color: SDSColor.gray100,
                ),
              ),
              Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      _buildTabButton('키워드 알림', '키워드 알림'),
                      _buildTabButton('카테고리 알림', '카테고리 알림'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 탭 콘텐츠
          Expanded(
            child: _currentTab == '키워드 알림'
                ? _buildKeywordTab()
                : _buildCategoryTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, String tabName) {
    bool isSelected = _currentTab == tabName;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentTab = tabName;
                });
              },
              child: Text(
                title,
                style: SDSTextStyle.bold.copyWith(
                  color: isSelected ? SDSColor.gray900 : SDSColor.gray400,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(40, 40),
                backgroundColor: SDSColor.snowliveWhite,
                surfaceTintColor: Colors.transparent,
                overlayColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          Container(
            height: 3,
            width: 72,
            color: isSelected ? Color(0xFF111111) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  /// 키워드 알림 탭
  Widget _buildKeywordTab() {
    return Obx(() {
      final keywords = _alertViewModel.keywordAlerts;
      final isLoading = _alertViewModel.isKeywordLoading.value;

      return Column(
        children: [
          // 상단 안내 + 등록 개수
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '등록된 키워드',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${keywords.length}',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 14,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                    Text(
                      ' / ${FleamarketAlertViewModel.maxKeywordCount}',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 키워드 목록
          Expanded(
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: SDSColor.snowliveBlue,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : keywords.isEmpty
                    ? _buildEmptyState('등록된 키워드가 없습니다.\n관심 키워드를 등록해보세요!')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: keywords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildKeywordItem(keywords[index]);
                        },
                      ),
          ),

          // 키워드 추가 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: keywords.length >= FleamarketAlertViewModel.maxKeywordCount
                      ? null
                      : () => _showAddKeywordDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.snowliveBlue,
                    disabledBackgroundColor: SDSColor.gray200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '키워드 추가',
                    style: SDSTextStyle.bold.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 카테고리 알림 탭
  Widget _buildCategoryTab() {
    return Obx(() {
      final categories = _alertViewModel.categoryAlerts;
      final isLoading = _alertViewModel.isCategoryLoading.value;

      return Column(
        children: [
          // 상단 안내 + 등록 개수
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '등록된 카테고리',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${categories.length}',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 14,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                    Text(
                      ' / ${FleamarketAlertViewModel.maxCategoryCount}',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 카테고리 목록
          Expanded(
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: SDSColor.snowliveBlue,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : categories.isEmpty
                    ? _buildEmptyState('등록된 카테고리가 없습니다.\n관심 카테고리를 등록해보세요!')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildCategoryItem(categories[index]);
                        },
                      ),
          ),

          // 카테고리 추가 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: categories.length >= FleamarketAlertViewModel.maxCategoryCount
                      ? null
                      : () => _showAddCategoryDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.snowliveBlue,
                    disabledBackgroundColor: SDSColor.gray200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '카테고리 추가',
                    style: SDSTextStyle.bold.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/imgs/icons/icon_nodata.png',
            width: 72,
            height: 72,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: SDSTextStyle.regular.copyWith(
              fontSize: 14,
              color: SDSColor.gray500,
            ),
          ),
        ],
      ),
    );
  }

  /// 키워드 아이템 위젯
  Widget _buildKeywordItem(KeywordAlert keyword) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 10, top: 8, bottom: 8),
      decoration: BoxDecoration(
        // color: SDSColor.blue50,
        border: Border.all(color: SDSColor.gray100, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              keyword.keyword ?? '',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 15,
                color: SDSColor.snowliveBlack,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteKeywordDialog(keyword),
            child: Container(
              width: 32,
              height: 32,
              child: Icon(
                Icons.cancel,
                size: 18,
                color: SDSColor.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 아이템 위젯
  Widget _buildCategoryItem(CategoryAlert category) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 10, top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: SDSColor.gray100, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: SDSColor.snowliveBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category.categoryMain ?? '',
              style: SDSTextStyle.bold.copyWith(
                fontSize: 12,
                color: SDSColor.snowliveBlue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.categorySub ?? '',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 15,
                color: SDSColor.snowliveBlack,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteCategoryDialog(category),
            child: Container(
              width: 32,
              height: 32,
              child: Icon(
                Icons.cancel,
                size: 18,
                color: SDSColor.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 키워드 추가 다이얼로그
  void _showAddKeywordDialog() {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '키워드 알림 추가',
              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              '알림 받고 싶은 키워드를 입력해주세요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: textController,
              autofocus: true,
              maxLength: 20,
              cursorColor: SDSColor.snowliveBlue,
              decoration: InputDecoration(
                hintText: '예: 버튼, 플레이트',
                hintStyle: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray400,
                ),
                filled: true,
                fillColor: SDSColor.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: SDSColor.snowliveBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                counterText: '',
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 6, right: 6, bottom: 0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(
                      '취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray500),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final keyword = textController.text.trim();
                      if (keyword.isEmpty) {
                        Get.snackbar('알림', '키워드를 입력해주세요.');
                        return;
                      }
                      Get.back();
                      await _alertViewModel.createKeywordAlert(keyword: keyword);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(
                      '등록',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 추가 다이얼로그 (상위 → 하위 선택)
  void _showAddCategoryDialog() async {
    // 1. 상위 카테고리 선택
    final categoryMain = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryMainFleamarketWidget(),
    );

    if (categoryMain == null || categoryMain.isEmpty) return;

    // 2. 하위 카테고리 선택 (상위 카테고리에 따라 다름)
    final categorySub = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (categoryMain == '스키') {
          return CategorySubSkiFleamarketWidget(categoryMain: categoryMain);
        } else {
          return CategorySubBoardFleamarketWidget(categoryMain: categoryMain);
        }
      },
    );

    if (categorySub == null || categorySub.isEmpty) return;

    // 3. 카테고리 등록
    await _alertViewModel.createCategoryAlert(
      categoryMain: categoryMain,
      categorySub: categorySub,
    );
  }

  /// 키워드 삭제 확인 다이얼로그
  void _showDeleteKeywordDialog(KeywordAlert keyword) {
    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '"${keyword.keyword}" 키워드를\n삭제하시겠습니까?',
              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 6, right: 6, bottom: 0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(
                      '취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray500),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Get.back();
                      await _alertViewModel.deleteKeywordAlert(
                        keywordAlertId: keyword.keywordAlertId!,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(
                      '삭제',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 삭제 확인 다이얼로그
  void _showDeleteCategoryDialog(CategoryAlert category) {
    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '"${category.categoryMain} > ${category.categorySub}"\n카테고리를 삭제하시겠습니까?',
              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 6, right: 6, bottom: 0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(
                      '취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray500),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Get.back();
                      await _alertViewModel.deleteCategoryAlert(
                        categoryAlertId: category.categoryAlertId!,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(
                      '삭제',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
