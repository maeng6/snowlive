import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kpostal/kpostal.dart';
import 'package:shimmer/shimmer.dart';

class RewardExchangeView extends StatefulWidget {
  const RewardExchangeView({Key? key}) : super(key: key);

  @override
  State<RewardExchangeView> createState() => _RewardExchangeViewState();
}

class _RewardExchangeViewState extends State<RewardExchangeView> {
  final SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // 각 컨트롤러에 리스너 추가
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _postalCodeController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _detailAddressController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _nameController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _postalCodeController.text.isNotEmpty &&
          _addressController.text.isNotEmpty &&
          _detailAddressController.text.isNotEmpty;
    });
  }

  void _searchAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalView(
          callback: (Kpostal result) {
            setState(() {
              _postalCodeController.text = result.postCode;
              _addressController.text = result.address;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () => Navigator.pop(context),
            ),
            title: Text(
              '경품 교환',
              style: SDSTextStyle.extraBold.copyWith(
                  color: SDSColor.gray900,
                  fontSize: 18),
            ),
            backgroundColor: SDSColor.snowliveWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 0.0,
          ),
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 상단 경품 정보 박스
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1D242E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ExtendedImage.network(
                            _snowballShopViewModel.selectedItem.value.imageUrl!,
                            enableMemoryCache: true,
                            borderRadius: BorderRadius.circular(4),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            loadStateChanged: (ExtendedImageState state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Shimmer.fromColors(
                                    baseColor: SDSColor.gray200!,
                                    highlightColor: SDSColor.gray50!,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                case LoadState.completed:
                                  return state.completedWidget;
                                case LoadState.failed:
                                  return Image.asset(
                                    'assets/imgs/profile/img_profile_default_.png',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_snowballShopViewModel.selectedItem.value.name}',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${_snowballShopViewModel.selectedItem.value.color} 눈송이 ${_snowballShopViewModel.selectedItem.value.snowballCount}개',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      '상품 수령을 위해 아래 정보를 입력해주세요.',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 13,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 이름 입력
                  Padding(
                    padding: const EdgeInsets.only(top: 14, left: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('이름',
                          style: SDSTextStyle.regular.copyWith(
                              fontSize: 13,
                              color: SDSColor.gray900
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2, top: 2),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: SDSColor.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    cursorColor: SDSColor.snowliveBlue,
                    cursorHeight: 16,
                    cursorWidth: 2,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15),
                    strutStyle: StrutStyle(fontSize: 14, leading: 0),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                      errorMaxLines: 2,
                      labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintText: '이름을 입력해 주세요.',
                      labelText: '이름',
                      contentPadding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 12, right: 12),
                      fillColor: SDSColor.gray50,
                      hoverColor: SDSColor.snowliveBlue,
                      filled: true,
                      focusColor: SDSColor.snowliveBlue,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.gray50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  // 연락처 입력
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('연락처 (- 없이 입력)', style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: SDSColor.gray900
                        ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2, top: 2),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: SDSColor.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: SDSColor.snowliveBlue,
                    cursorHeight: 16,
                    cursorWidth: 2,
                    controller: _phoneController,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15),
                    strutStyle: StrutStyle(fontSize: 14, leading: 0),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorMaxLines: 2,
                      errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                      labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintText: '전화번호를 입력해 주세요.',
                      labelText: '전화번호',
                      contentPadding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 12, right: 12),
                      fillColor: SDSColor.gray50,
                      hoverColor: SDSColor.snowliveBlue,
                      filled: true,
                      focusColor: SDSColor.snowliveBlue,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.gray50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  // 주소 입력
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('경품 수령 주소지',
                          style: SDSTextStyle.regular.copyWith(
                              fontSize: 13,
                              color: SDSColor.gray900
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2, top: 2),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: SDSColor.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: SDSColor.snowliveBlue,
                          cursorHeight: 16,
                          cursorWidth: 2,
                          controller: _postalCodeController,
                          readOnly: true,
                          style: SDSTextStyle.regular.copyWith(fontSize: 15),
                          strutStyle: StrutStyle(fontSize: 14, leading: 0),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            errorMaxLines: 2,
                            errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                            labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintText: '우편번호를 검색해 주세요.',
                            labelText: '우편번호',
                            contentPadding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 12, right: 12),
                            fillColor: SDSColor.gray50,
                            hoverColor: SDSColor.snowliveBlue,
                            filled: true,
                            focusColor: SDSColor.snowliveBlue,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: SDSColor.gray50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _searchAddress,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                          backgroundColor: SDSColor.snowliveBlue,
                          foregroundColor: SDSColor.snowliveWhite,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: Text(
                          '검색하기',
                          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: SDSColor.snowliveBlue,
                    cursorHeight: 16,
                    cursorWidth: 2,
                    controller: _addressController,
                    readOnly: true,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15),
                    strutStyle: StrutStyle(fontSize: 14, leading: 0),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorMaxLines: 2,
                      errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                      labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintText: '주소를 입력해 주세요.',
                      labelText: '주소',
                      contentPadding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 12, right: 12),
                      fillColor: SDSColor.gray50,
                      hoverColor: SDSColor.snowliveBlue,
                      filled: true,
                      focusColor: SDSColor.snowliveBlue,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.gray50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: SDSColor.snowliveBlue,
                    cursorHeight: 16,
                    cursorWidth: 2,
                    controller: _detailAddressController,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15),
                    strutStyle: StrutStyle(fontSize: 14, leading: 0),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorMaxLines: 2,
                      errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                      labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintText: '상세 주소를 입력해 주세요.',
                      labelText: '상세 주소',
                      contentPadding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 12, right: 12),
                      fillColor: SDSColor.gray50,
                      hoverColor: SDSColor.snowliveBlue,
                      filled: true,
                      focusColor: SDSColor.snowliveBlue,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.gray50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: SDSColor.gray100,
                    height: 60,
                  ),

                  // 안내사항
                  Text(
                    '안내사항',
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: _size.width - 32,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('•',
                              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text('모든 상품은 1인당 구매 횟수가 1회로 제한됩니다.',
                                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•',
                              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text('각 상품은 선착순으로 구매 가능하며, 모두 소진 시 경품 교환이 어려운 점 양해 부탁드립니다.',
                                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•',
                              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text('상품 수령을 위해 입력하신 개인정보는 상품 발송 완료 후 일주일 이내에 삭제됩니다.',
                                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  // 다음 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid
                          ? () {

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque, // 화면 바깥 클릭 감지
                              onTap: () {
                                Navigator.of(context).pop(); // 바텀시트 닫기
                              },
                              child: SafeArea(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                    color: SDSColor.snowliveWhite,
                                  ),
                                  padding: EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 드래그 핸들
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: Container(
                                            height: 4,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: SDSColor.gray200,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 제목
                                      Text(
                                        '주문 상세 내역',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      // 상단 상품 정보 박스
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1D242E),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: ExtendedImage.network(
                                                _snowballShopViewModel.selectedItem.value.imageUrl!,
                                                enableMemoryCache: true,
                                                borderRadius: BorderRadius.circular(4),
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                                loadStateChanged: (ExtendedImageState state) {
                                                  switch (state.extendedImageLoadState) {
                                                    case LoadState.loading:
                                                    // 로딩 중일 때 로딩 인디케이터를 표시
                                                      return Shimmer.fromColors(
                                                        baseColor: SDSColor.gray200!,
                                                        highlightColor: SDSColor.gray50!,
                                                        child: Container(
                                                          width: 48,
                                                          height: 48,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                        ),
                                                      );
                                                    case LoadState.completed:
                                                    // 로딩이 완료되었을 때 이미지 반환
                                                      return state.completedWidget;
                                                    case LoadState.failed:
                                                    // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                      return Image.asset(
                                                        'assets/imgs/profile/img_profile_default_.png',
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                      );
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _snowballShopViewModel.selectedItem.value.name ?? '상품 이름',
                                                    style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_snowballShopViewModel.selectedItem.value.color ?? ''} 눈송이 ${_snowballShopViewModel.selectedItem.value.snowballCount ?? 0}개',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 12,
                                                      color: Colors.white.withOpacity(0.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      // 주문 정보
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '주문자명',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                _nameController.text ?? '',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '경품 수령 주소',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${_postalCodeController.text} ${_addressController.text} \n ${_detailAddressController.text}',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '전화번호',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                _phoneController.text ?? '',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(height: 32, thickness: 1, color: SDSColor.gray100),
                                      // 교환 상세 정보
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '교환 상품명',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                _snowballShopViewModel.selectedItem.value.name ?? '',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '눈송이 가격',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${_snowballShopViewModel.selectedItem.value.color ?? ''} 눈송이 ${_snowballShopViewModel.selectedItem.value.snowballCount ?? 0}개',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(height: 32, thickness: 1, color: SDSColor.gray100),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          '수집된 개인 정보는 상품 발송 후 일주일 뒤에 바로 삭제됩니다.',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  FocusScope.of(context).unfocus();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor: Color(0xFF7C899D),
                                                  padding: EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                ),
                                                child: Text(
                                                  '다시 입력하기',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {

                                                  // 교환하기 로직
                                                  CustomFullScreenDialog.showDialog(); // 로딩 다이얼로그 표시
                                                  await _snowballShopViewModel.purchaseSnowballItem(
                                                    snowballItemId: _snowballShopViewModel.selectedItem.value.snowballItemId!,
                                                    address: '${_postalCodeController.text} ${_addressController.text} ${_detailAddressController.text}',
                                                    name: _nameController.text,
                                                    phoneNumber: _phoneController.text,
                                                  );
                                                  CustomFullScreenDialog.cancelDialog(); // 로딩 다이얼로그 닫기
                                                  // 교환 완료 팝업 띄우기
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false, // 바깥 터치로 닫히지 않게 설정
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        backgroundColor: SDSColor.snowliveWhite,
                                                        contentPadding: EdgeInsets.only(left: 28, right: 28, top: 36),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                        content: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              '경품 교환 완료!',
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  color: SDSColor.gray900,
                                                                  fontSize: 16
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              '${_snowballShopViewModel.selectedItem.value.color} 눈송이 ${_snowballShopViewModel.selectedItem.value.snowballCount}개로 경품 교환을 완료했어요. 교환하신 상품은 구매 목록을 통해 확인해 주세요.',
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                color: SDSColor.gray500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            )
                                                          ],
                                                        ),
                                                        actions: [
                                                          Center(
                                                            child: TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context); // 팝업 닫기
                                                                  Get.back(); // 이전 화면으로 돌아가기
                                                                  Future.delayed(Duration(milliseconds: 100), () {
                                                                    if (Navigator.canPop(context)) {
                                                                      Navigator.pop(context);
                                                                    }
                                                                  });
                                                                },
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                ),
                                                                child: Text('확인',
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 17,
                                                                    color: SDSColor.snowliveBlue,
                                                                  ),
                                                                )
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,

                                                  backgroundColor: SDSColor.snowliveBlue,
                                                  padding: EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                ),
                                                child: Text(
                                                  '교환하기',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                          : null, // 비활성화 상태 처리
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: SDSColor.snowliveBlue,
                      ),
                      child: Text(
                        '다음',
                        style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
