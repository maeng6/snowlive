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

  String _formatWon(int? value) {
    if (value == null) return '';
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Future<void> _confirmAndDelete(record) async {
    final confirmed = await Get.dialog<bool>(
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
                '구매 취소',
                textAlign: TextAlign.center,
                style: SDSTextStyle.bold.copyWith(
                  color: SDSColor.gray900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '해당 구매를 취소하시겠습니까?',
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
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF3D83ED),
                    foregroundColor: Colors.white,
                    splashFactory: NoSplash.splashFactory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '취소할게요',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: false),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: SDSColor.gray900,
                    shadowColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '아니요',
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: SDSColor.snowliveBlack),
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
            height: 60,
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
                    splashFactory: NoSplash.splashFactory,
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
            height: 60,
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
                    splashFactory: NoSplash.splashFactory,
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
      backgroundColor: SDSColor.snowliveWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            '구매 예약 내역',
            style: SDSTextStyle.bold.copyWith(
              color: SDSColor.snowliveBlack,
              fontSize: 16,
            ),
          ),
          backgroundColor: SDSColor.snowliveWhite,
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              color: SDSColor.snowliveBlack,
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
                  Image.asset(
                    'assets/imgs/icons/icon_nodata.png',
                    scale: 4,
                    width: 64,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '구매 예약한 내역이 없어요',
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
              itemCount: _themeStoreViewModel.buyRecords.length + 1,
              itemBuilder: (context, index) {
                // 마지막 아이템: 하단 안내 문구
                if (index == _themeStoreViewModel.buyRecords.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      '연락이 없을 경우, 스노우라이브 카카오톡 채널로 문의해주세요.',
                      textAlign: TextAlign.center,
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 13,
                        color: SDSColor.gray500,
                      ),
                    ),
                  );
                }

                final record = _themeStoreViewModel.buyRecords[index];
                final item = record.themestoreItem;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == _themeStoreViewModel.buyRecords.length - 1 ? 50 : 30,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // 상품 이미지
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 64,
                              height: 64,
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
                                  item?.brandName ?? '브랜드 이름',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 12,
                                    color: SDSColor.snowliveBlack,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item?.name ?? '상품명',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    color: SDSColor.snowliveBlack,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      '${_formatWon(item!.priceOrigin)}원',
                                      style: SDSTextStyle.regular.copyWith(
                                        fontSize: 14,
                                        color: Colors.black.withOpacity(0.3),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.black.withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.discountPerct ?? 0}%',
                                      style: SDSTextStyle.bold.copyWith(
                                        fontSize: 14,
                                        color: const Color(0xFFFF3B3B),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${_formatWon(item.priceEvent)}원',
                                      style: SDSTextStyle.bold.copyWith(
                                        fontSize: 14,
                                        color: SDSColor.snowliveBlack,
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
                      Text('구매 예약 완료된 상품은 입력해주신 정보로 브랜드에서 직접 연락 드릴 예정입니다. 24시간 이내에 최종 결제 완료해야 하며, 완료되지 않은 상품은 자동으로 구매 예약 취소 처리됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF000000).withOpacity(0.6)
                      ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          SizedBox(
                            height: 32,
                            child: OutlinedButton(
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.themestoreEditInfo,
                                  arguments: record,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: SDSColor.gray300, // 연한 회색 테두리
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // pill 느낌
                                ),
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 2),
                              ),
                              child: Text(
                                '정보 수정',
                                style: SDSTextStyle.bold.copyWith(
                                  color: SDSColor.snowliveBlack,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 8),

                          SizedBox(
                            height: 32,
                            child: OutlinedButton(
                              onPressed: () async {
                                if (record.themestoreBuyRecordId == null) return;
                                await _confirmAndDelete(record);
                                await _themeStoreViewModel.fetchThemeStoreMain();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: SDSColor.gray300,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                '구매 취소',
                                style: SDSTextStyle.bold.copyWith(
                                  color: SDSColor.snowliveBlack,
                                  fontSize: 13,
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
