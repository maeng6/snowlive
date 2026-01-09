import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_themeStore.dart';
import 'package:com.snowlive/viewmodel/themeStore/vm_themeStore.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ThemestoreEditInfoView extends StatefulWidget {
  @override
  State<ThemestoreEditInfoView> createState() => _ThemestoreEditInfoViewState();
}

class _ThemestoreEditInfoViewState extends State<ThemestoreEditInfoView> {
  final ThemeStoreViewModel _themeStoreViewModel = Get.find<ThemeStoreViewModel>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late ThemeStoreBuyRecord record;

  @override
  void initState() {
    super.initState();
    record = Get.arguments as ThemeStoreBuyRecord;
    _nameController.text = record.name ?? '';
    _phoneController.text = record.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatWon(int? value) {
    if (value == null) return '';
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    CustomFullScreenDialog.showDialog();

    final result = await _themeStoreViewModel.updateBuyRecord(
      themestoreBuyRecordId: record.themestoreBuyRecordId!,
      body: {
        'name': _nameController.text,
        'phone_number': _phoneController.text,
      },
    );

    await _themeStoreViewModel.fetchMyBuyRecords();
    CustomFullScreenDialog.cancelDialog();

    if (result.success) {
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
                  '수정 완료!',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '구매 정보가 수정되었습니다.',
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
                  onPressed: () {
                    Get.back(); // 다이얼로그 닫기
                    Get.back(); // 수정 페이지 닫기
                  },
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
                  '수정 실패',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '정보 수정에 실패했습니다.',
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
                  onPressed: () {
                    Get.back(); // 다이얼로그 닫기
                  },
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
    final item = record.themestoreItem;

    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            '구매 정보 수정',
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
            onTap: () => Get.back(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품 정보
              Row(
                children: [
                  // 이미지
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: SDSColor.gray200, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ExtendedImage.network(
                          item?.imageUrl ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item?.brandName ?? ''}',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 12,
                            color: SDSColor.snowliveBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item?.name ?? '',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlack,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (item?.priceEvent != null && (item?.priceEvent ?? 0) > 0)
                          Row(
                            children: [
                              Text(
                                '${_formatWon(item?.priceOrigin)}원',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.5),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item?.discountPerct ?? 0}%',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFFFF3B3B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatWon(item?.priceEvent)}원',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.snowliveBlack,
                                ),
                              ),
                            ],
                          ),
                        if (item?.priceEvent == null || (item?.priceEvent ?? 0) == 0)
                          Text(
                            '${_formatWon(item?.priceOrigin)}원',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 13,
                              color: SDSColor.snowliveBlack,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 이름 입력
              Text(
                '이름',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 13,
                  color: SDSColor.snowliveBlack,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: SDSColor.snowliveBlack),
                decoration: InputDecoration(
                  hintText: '홍길동',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '이름을 입력해주세요';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // 전화번호 입력
              Text(
                '전화번호',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 13,
                  color: SDSColor.snowliveBlack,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: SDSColor.snowliveBlack),
                decoration: InputDecoration(
                  hintText: '010-1234-5678',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _PhoneNumberFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return '전화번호를 입력해주세요';
                  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.length < 10) return '전화번호를 정확히 입력해주세요';
                  return null;
                },
              ),

              const SizedBox(height: 50),

              // 제출 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF3D83ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '수정하기',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 16,
                      color: SDSColor.snowliveWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 전화번호 자동 하이픈 포맷터 (010-1234-5678 / 02-123-4567 등)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted;

    // 02 지역번호 처리
    if (digits.startsWith('02')) {
      if (digits.length <= 2) {
        formatted = digits;
      } else if (digits.length <= 5) {
        formatted = '${digits.substring(0, 2)}-${digits.substring(2)}';
      } else if (digits.length <= 9) {
        formatted =
        '${digits.substring(0, 2)}-${digits.substring(2, digits.length - 4)}-${digits.substring(digits.length - 4)}';
      } else {
        formatted =
        '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6, 10)}';
      }
    } else {
      // 휴대폰/기타 지역번호(3자리)
      if (digits.length <= 3) {
        formatted = digits;
      } else if (digits.length <= 7) {
        formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
      } else if (digits.length <= 11) {
        formatted =
        '${digits.substring(0, 3)}-${digits.substring(3, digits.length - 4)}-${digits.substring(digits.length - 4)}';
      } else {
        // 11자리 이상은 잘라서 11자리까지만
        formatted = '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 11)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
