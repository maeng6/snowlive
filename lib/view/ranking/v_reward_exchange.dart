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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '경품 교환',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ExtendedImage.network(
                            _snowballShopViewModel.selectedItem.value.imageUrl!,
                            enableMemoryCache: true,
                            cacheHeight: 150,
                            borderRadius: BorderRadius.circular(8),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            loadStateChanged: (ExtendedImageState state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Shimmer.fromColors(
                                    baseColor: SDSColor.gray200!,
                                    highlightColor: SDSColor.gray50!,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                case LoadState.completed:
                                  return state.completedWidget;
                                case LoadState.failed:
                                  return Image.asset(
                                    'assets/imgs/profile/img_profile_default_circle.png',
                                    width: 32,
                                    height: 32,
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ' ${_snowballShopViewModel.selectedItem.value.color} 눈송이 ${_snowballShopViewModel.selectedItem.value.snowballCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    '상품 수령을 위해 아래 정보를 입력해주세요.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 이름 입력
                  const Text(
                    '이름',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '이름을 입력해 주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 연락처 입력
                  const Text(
                    '연락처',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: '전화번호를 입력해 주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 주소 입력
                  const Text(
                    '경품 수령 주소지',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _postalCodeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '우편번호',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            filled: true,
                            fillColor: Colors.grey[300],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _searchAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: const Text(
                          '검색하기',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: '주소를 입력해 주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailAddressController,
                    decoration: InputDecoration(
                      hintText: '상세 주소를 입력해 주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 안내사항
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '안내사항\n\n'
                          '• 모든 상품은 1인당 구매 횟수가 1회로 제한됩니다.\n'
                          '• 각 상품은 선착순으로 구매 가능하며, 모두 소진 시 경품 교환이 어려운 점 양해 부탁드립니다.\n'
                          '• 상품 수령을 위해 입력하신 개인정보는 상품 발송 완료 후 일주일 이내에 삭제됩니다.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 다음 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid
                          ? () async{
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Center(
                                child: Text(
                                  '경품 교환 완료!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_snowballShopViewModel.selectedItem.value.color} 눈송이 ${_snowballShopViewModel.selectedItem.value.snowballCount}개로 경품 교환을 완료했어요.\n\n교환하신 상품은 구매 목록을 통해 확인해 주세요.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                              actions: [
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // 팝업 닫기
                                      Get.back(); // 이전 화면으로 돌아가기
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: Text(
                                      '확인',
                                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                          : null, // 비활성화 상태 처리
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        '다음',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
