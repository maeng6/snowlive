import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_themeStore.dart';
import 'package:com.snowlive/viewmodel/themeStore/vm_themeStore.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThemestoreInputInfoView extends StatefulWidget {
  @override
  State<ThemestoreInputInfoView> createState() => _ThemestoreInputInfoViewState();
}

class _ThemestoreInputInfoViewState extends State<ThemestoreInputInfoView> {
  final ThemeStoreViewModel _themeStoreViewModel = Get.find<ThemeStoreViewModel>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late ThemeStoreItem item;

  @override
  void initState() {
    super.initState();
    item = Get.arguments as ThemeStoreItem;
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

  Future<void> _showConfirmPurchasePopup() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: const EdgeInsets.only(bottom: 0, left: 24, right: 24, top: 24),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '최종 구매 예약 확인',
              style: SDSTextStyle.bold.copyWith(
                color: SDSColor.snowliveBlack,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
                    style: SDSTextStyle.bold.copyWith(
                      color: SDSColor.snowliveBlack,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (item.priceEvent != null && item.priceEvent! > 0) ...[
                        Text(
                          '${_formatWon(item.priceOrigin)}원',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.3),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.black.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.discountPerct ?? 0}%',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: const Color(0xFFFF3B3B),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${_formatWon(item.priceEvent)}원',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlack,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '${_formatWon(item.priceOrigin)}원',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlack,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${_nameController.text}',
                        style: SDSTextStyle.regular.copyWith(
                          color: SDSColor.snowliveBlack,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_phoneController.text}',
                        style: SDSTextStyle.regular.copyWith(
                          color: SDSColor.snowliveBlack,
                          fontSize: 13,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '버튼을 누르면 구매 예약이 최종 완료됩니다.',
              style: SDSTextStyle.regular.copyWith(
                color: SDSColor.gray500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                    '구매 완료',
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
                    '취소',
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: SDSColor.snowliveBlack),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitPurchaseFinal();
    }
  }

  Future<void> _submitPurchaseFinal() async {
    CustomFullScreenDialog.showDialog();

    final result = await _themeStoreViewModel.createBuyRecord(
      themestoreItemId: item.themestoreItemId!,
      name: _nameController.text,
      phoneNumber: _phoneController.text,
    );

    await _themeStoreViewModel.fetchThemeStoreMain();
    CustomFullScreenDialog.cancelDialog();

    if (result.success) {
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // ✅ 안드로이드 뒤로가기 막기
          child: AlertDialog(
            backgroundColor: SDSColor.snowliveWhite,
            contentPadding: const EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            buttonPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            content: SizedBox(
              height: 146,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '구매 완료!',
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.bold.copyWith(
                      color: SDSColor.gray900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '구매가 성공적으로 완료되었습니다. 구매 예약 완료된 상품은 입력해주신 정보로 연락을 드릴 예정입니다. 24시간 이내에 최종 구매 확정까지 진행해주셔야 되며, 완료되지 않은 상품은 자동 구매 취소 처리가 됩니다.',
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
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // 성공 팝업 닫기
                      Get.back(); // 입력 페이지 닫기 (홈으로)
                    },
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false, // ✅ 화면 바깥 터치로 닫히지 않게
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
                  '구매 실패',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '이미 품절된 상품입니다.',
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
            '구매 정보 입력',
            style: SDSTextStyle.bold.copyWith(
              color: SDSColor.snowliveBlack,
              fontSize: 16,
            ),
          ),
          backgroundColor: SDSColor.snowliveWhite,
          leading: GestureDetector(
            child: Padding(padding: EdgeInsets.all(14), child: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26, colorFilter: ColorFilter.mode(SDSColor.snowliveBlack, BlendMode.srcIn))),
            onTap: () => Get.back(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                              border: Border.all(color: SDSColor.gray200, width: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: ExtendedImage.network(
                                item.imageUrl ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.brandName ?? ''}',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 12,
                                  color: SDSColor.snowliveBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.name ?? '',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.snowliveBlack,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              if (item.priceEvent != null && item.priceEvent! > 0)
                                Row(
                                  children: [
                                    Text(
                                      '${_formatWon(item.priceOrigin)}원',
                                      style: SDSTextStyle.regular.copyWith(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(0.3),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.black.withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.discountPerct ?? 0}%',
                                      style: SDSTextStyle.bold.copyWith(
                                        fontSize: 13,
                                        color: const Color(0xFFFF3B3B),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${_formatWon(item.priceEvent)}원',
                                      style: SDSTextStyle.bold.copyWith(
                                        fontSize: 13,
                                        color: SDSColor.snowliveBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              if (item.priceEvent == null || item.priceEvent == 0)
                                Text(
                                  '${_formatWon(item.priceOrigin)}원',
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

                    const SizedBox(height: 30),

                    // 이름 입력
                    Text(
                      '이름',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 13,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      cursorColor: const Color(0xFF3D83ED),
                      style: TextStyle(color: SDSColor.snowliveBlack, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '이름을 입력해주세요',
                        hintStyle: TextStyle(color: Color(0xFFb7b7b7), fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 13,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      cursorColor: const Color(0xFF3D83ED),
                      style: TextStyle(color: SDSColor.snowliveBlack, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '- 없이 숫자만 입력해주세요',
                        hintStyle: TextStyle(color: Color(0xFFb7b7b7), fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // ✅ 숫자만
                        _PhoneNumberFormatter(), // ✅ 010-1234-5678 포맷
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return '전화번호를 입력해주세요';
                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length < 10) return '전화번호를 정확히 입력해주세요';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 제출 버튼 (하단 고정)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _showConfirmPurchasePopup,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF3D83ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '구매 예약 완료',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 16,
                      color: SDSColor.snowliveWhite,
                    ),
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

/// ✅ 전화번호 자동 하이픈 포맷터 (010-1234-5678 / 02-123-4567 등)
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
