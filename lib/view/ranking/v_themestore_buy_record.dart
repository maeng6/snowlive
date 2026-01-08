import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/themeStore/vm_themeStore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemestoreBuyRecordView extends StatefulWidget {
  @override
  State<ThemestoreBuyRecordView> createState() => _ThemestoreBuyRecordViewState();
}

class _ThemestoreBuyRecordViewState extends State<ThemestoreBuyRecordView> {
  late ThemeStoreViewModel _themeStoreViewModel;

  @override
  void initState() {
    super.initState();
    _themeStoreViewModel = Get.find<ThemeStoreViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeStoreViewModel.fetchMyBuyRecords();
    });
  }

  Future<void> _confirmAndDelete(record) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF2A3342),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '구매 취소',
          style: SDSTextStyle.bold.copyWith(
            color: SDSColor.snowliveWhite,
            fontSize: 16,
          ),
        ),
        content: Text(
          '해당 구매를 취소하시겠습니까?\n취소 후에는 되돌릴 수 없습니다.',
          style: SDSTextStyle.regular.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: false),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '아니요',
                      style: SDSTextStyle.bold.copyWith(
                        color: SDSColor.snowliveWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF3B3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '취소할게요',
                      style: SDSTextStyle.bold.copyWith(
                        color: SDSColor.snowliveWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await _themeStoreViewModel.deleteBuyRecord(
      themestoreBuyRecordId: record.themestoreBuyRecordId!,
    );

    if (res.success) {
      await _themeStoreViewModel.fetchMyBuyRecords();

      Get.dialog(
        AlertDialog(
          backgroundColor: SDSColor.snowliveWhite,
          contentPadding: const EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          buttonPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          content: SizedBox(
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '구매 취소 완료!',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '구매가 취소되었습니다.',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular.copyWith(
                    color: SDSColor.gray500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                width: 240,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF3D83ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.dialog(
        AlertDialog(
          backgroundColor: SDSColor.snowliveWhite,
          contentPadding: const EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          buttonPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          content: SizedBox(
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '취소 실패',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '구매 취소에 실패했습니다.',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular.copyWith(
                    color: SDSColor.gray500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                width: 240,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF3D83ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D242E),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            '내 구매 목록',
            style: SDSTextStyle.bold.copyWith(
              color: SDSColor.snowliveWhite,
              fontSize: 16,
            ),
          ),
          backgroundColor: const Color(0xFF1D242E),
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              color: SDSColor.snowliveWhite,
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Get.back();
            },
          ),
        ),
      ),
      body: Obx(
            () {
          if (_themeStoreViewModel.isFetchingRecords.value) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: SDSColor.gray100,
                color: const Color(0xFF3D83ED),
              ),
            );
          }

          if (_themeStoreViewModel.buyRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '구매 내역이 없습니다',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            backgroundColor: const Color(0xFF3D83ED),
            color: SDSColor.snowliveWhite,
            onRefresh: () async {
              await _themeStoreViewModel.fetchMyBuyRecords();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _themeStoreViewModel.buyRecords.length,
              itemBuilder: (context, index) {
                final record = _themeStoreViewModel.buyRecords[index];
                final item = record.themestoreItem;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3342),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // 상품 이미지
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.white,
                              child: (item?.imageUrl != null && item!.imageUrl!.isNotEmpty)
                                  ? ExtendedImage.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                              )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 상품 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item?.name ?? '상품명',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 16,
                                    color: SDSColor.snowliveWhite,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record.name ?? '',
                                      style: SDSTextStyle.regular.copyWith(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record.phoneNumber ?? '',
                                      style: SDSTextStyle.regular.copyWith(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          // ✅ 정보수정 버튼
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.toNamed(
                                    AppRoutes.themestoreEditInfo,
                                    arguments: record,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white.withOpacity(0.12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  '정보수정',
                                  style: SDSTextStyle.bold.copyWith(
                                    color: SDSColor.snowliveWhite,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // ✅ 구매취소(삭제) 버튼
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (record.themestoreBuyRecordId == null) return;
                                  await _confirmAndDelete(record);
                                  await _themeStoreViewModel.fetchThemeStoreMain();
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFFFF3B3B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  '구매취소',
                                  style: SDSTextStyle.bold.copyWith(
                                    color: SDSColor.snowliveWhite,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
