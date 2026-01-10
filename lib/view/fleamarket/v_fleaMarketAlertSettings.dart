import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_fleamarket_alert.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketAlert.dart';
import 'package:com.snowlive/widget/w_category_main_fleamarket.dart';
import 'package:com.snowlive/widget/w_category_sub_ski_fleamarket.dart';
import 'package:com.snowlive/widget/w_category_sub_board_fleamarket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FleamarketAlertSettingsView extends StatefulWidget {
  const FleamarketAlertSettingsView({Key? key}) : super(key: key);

  @override
  State<FleamarketAlertSettingsView> createState() => _FleamarketAlertSettingsViewState();
}

class _FleamarketAlertSettingsViewState extends State<FleamarketAlertSettingsView>
    with SingleTickerProviderStateMixin {
  final FleamarketAlertViewModel _alertViewModel = Get.find<FleamarketAlertViewModel>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _alertViewModel.fetchAllAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: SDSColor.snowliveBlue,
          unselectedLabelColor: SDSColor.gray500,
          indicatorColor: SDSColor.snowliveBlue,
          labelStyle: SDSTextStyle.bold.copyWith(fontSize: 14),
          unselectedLabelStyle: SDSTextStyle.regular.copyWith(fontSize: 14),
          tabs: const [
            Tab(text: '키워드 알림'),
            Tab(text: '카테고리 알림'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKeywordTab(),
          _buildCategoryTab(),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '등록된 키워드',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray600,
                  ),
                ),
                Text(
                  '${keywords.length}/${FleamarketAlertViewModel.maxKeywordCount}',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 14,
                    color: SDSColor.snowliveBlue,
                  ),
                ),
              ],
            ),
          ),

          // 키워드 목록
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
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
                    '+ 키워드 추가',
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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '등록된 카테고리',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray600,
                  ),
                ),
                Text(
                  '${categories.length}/${FleamarketAlertViewModel.maxCategoryCount}',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 14,
                    color: SDSColor.snowliveBlue,
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 목록
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
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
                    '+ 카테고리 추가',
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
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: SDSColor.gray300,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              keyword.keyword ?? '',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 15,
                color: SDSColor.gray900,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteKeywordDialog(keyword),
            child: Icon(
              Icons.close,
              size: 20,
              color: SDSColor.gray500,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 아이템 위젯
  Widget _buildCategoryItem(CategoryAlert category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
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
                color: SDSColor.gray900,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteCategoryDialog(category),
            child: Icon(
              Icons.close,
              size: 20,
              color: SDSColor.gray500,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '키워드 알림 추가',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '알림 받고 싶은 키워드를 입력해주세요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: '예: 버튼, 플레이트',
                hintStyle: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray400,
                ),
                filled: true,
                fillColor: SDSColor.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                counterText: '',
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    '취소',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray500),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final keyword = textController.text.trim();
                    if (keyword.isEmpty) {
                      Get.snackbar('알림', '키워드를 입력해주세요.');
                      return;
                    }
                    Get.back();
                    await _alertViewModel.createKeywordAlert(keyword: keyword);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.snowliveBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    '등록',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
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
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryMainFleamarketWidget(),
    );

    if (categoryMain == null || categoryMain.isEmpty) return;

    // 2. 하위 카테고리 선택 (상위 카테고리에 따라 다름)
    final categorySub = await showModalBottomSheet<String>(
      context: context,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '키워드 삭제',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '"${keyword.keyword}" 키워드를\n삭제하시겠습니까?',
          style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    '취소',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray500),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await _alertViewModel.deleteKeywordAlert(
                      keywordAlertId: keyword.keywordAlertId!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    '삭제',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 카테고리 삭제 확인 다이얼로그
  void _showDeleteCategoryDialog(CategoryAlert category) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '카테고리 삭제',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '"${category.categoryMain} > ${category.categorySub}"\n카테고리를 삭제하시겠습니까?',
          style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    '취소',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray500),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await _alertViewModel.deleteCategoryAlert(
                      categoryAlertId: category.categoryAlertId!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    '삭제',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
