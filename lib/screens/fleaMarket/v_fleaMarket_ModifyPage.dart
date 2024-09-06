import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/controller/fleaMarket/vm_fleaMarketController.dart';
import 'package:com.snowlive/model_2/m_fleaMarketModel.dart';
import '../../viewmodel/vm_imageController.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_ModifyPage extends StatefulWidget {
  const FleaMarket_ModifyPage({Key? key}) : super(key: key);

  @override
  State<FleaMarket_ModifyPage> createState() => _FleaMarket_ModifyPageState();
}

class _FleaMarket_ModifyPageState extends State<FleaMarket_ModifyPage> {
  List<XFile> _imageFiles = [];
  bool? fleaImageSelected = false;
  int i = 0;
  int imageLength = 0;
  int? _initPrice = 0;
  String? _initTitle ;
  String? _initItemName ;
  String? _initdescrip ;
  String? _initKakaoUrl ;
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _itemNameTextEditingController = TextEditingController();
  TextEditingController _itemPriceTextEditingController = TextEditingController();
  TextEditingController _itemDescribTextEditingController = TextEditingController();
  TextEditingController _kakaoUrlTextEditingController = TextEditingController();
  bool? isCategorySelected = false;
  bool? isLocationSelected = false;
  bool? isMethodSelected = false;
  bool? isModifiedImageSelected = false;
  RxString? SelectedCategory = ''.obs;
  RxString? SelectedLocation = ''.obs;
  RxString? SelectedMethod = ''.obs;
  String? title = '';
  final _formKey = GlobalKey<FormState>();
  RxList? _imageUrls=[].obs;



  ListTile buildCategoryListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${fleaCategoryList[index]}'),
      onTap: () async {
        isCategorySelected = true;
        SelectedCategory!.value = fleaCategoryList[index];
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${fleaLocationList[index]}'),
      onTap: () async {
        isLocationSelected = true;
        SelectedLocation!.value = fleaLocationList[index];
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ListTile buildMethodListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${fleaMethodList[index]}'),
      onTap: () async {
        isMethodSelected = true;
        SelectedMethod!.value = fleaMethodList[index];
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FleaModelController _fleaModelController = Get.find<FleaModelController>();
    _imageUrls!.addAll(_fleaModelController.itemImagesUrls!);
    SelectedCategory = _fleaModelController.category!.obs;
    SelectedLocation = _fleaModelController.location!.obs;
    SelectedMethod = _fleaModelController.method!.obs;
    _initPrice =_fleaModelController.price;
    _initTitle =_fleaModelController.title;
    _initItemName =_fleaModelController.itemName;
    _initdescrip =_fleaModelController.description;
    _initKakaoUrl =_fleaModelController.kakaoUrl;
  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    Get.put(ImageController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    FleaModelController _fleaModelController = Get.find<FleaModelController>();
    ImageController _imageController = Get.find<ImageController>();
    //TODO : ****************************************************************

    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              title: Text('내 물건 팔기'),
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
              actions: [
                TextButton(
                    onPressed: () async{
                      final isValid = _formKey.currentState!.validate();
                      if(isValid){
                        CustomFullScreenDialog.showDialog();
                        //await _imageController.setNewMultiImage(_imageFiles, _userModelController.fleaCount);
                        (isModifiedImageSelected==true)
                            ? await _fleaModelController.updateFleaItem(
                            displayName: _userModelController.displayName,
                            uid: _userModelController.uid,
                            profileImageUrl: _userModelController.profileImageUrl,
                            itemImagesUrls: _imageController.imagesUrlList,
                            title: _titleTextEditingController.text,
                            category: SelectedCategory!.value,
                            itemName: _itemNameTextEditingController.text,
                            price: int.parse(_itemPriceTextEditingController.text),
                            location: SelectedLocation!.value,
                            method: SelectedMethod!.value,
                            description: _itemDescribTextEditingController.text,
                            fleaCount: _fleaModelController.fleaCount,
                            resortNickname: _userModelController.resortNickname,
                            kakaoUrl: _kakaoUrlTextEditingController.text
                        )
                            : await _fleaModelController.updateFleaItem(
                            displayName: _userModelController.displayName,
                            uid: _userModelController.uid,
                            profileImageUrl: _userModelController.profileImageUrl,
                            itemImagesUrls: _imageUrls,
                            title: _titleTextEditingController.text,
                            category: SelectedCategory!.value,
                            itemName: _itemNameTextEditingController.text,
                            price: int.parse(_itemPriceTextEditingController.text),
                            location: SelectedLocation!.value,
                            method: SelectedMethod!.value,
                            description: _itemDescribTextEditingController.text,
                            fleaCount: _fleaModelController.fleaCount,
                            resortNickname: _userModelController.resortNickname,
                            kakaoUrl: _kakaoUrlTextEditingController.text
                        );
                        CustomFullScreenDialog.cancelDialog();
                        for(int i=0; i<2; i++){
                          Get.back();
                        }
                      }
                      _imageController.imagesUrlList.clear();

                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text('수정완료', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D83ED)
                      ),),
                    ))
              ],
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            CustomFullScreenDialog.showDialog();
                            try {
                              _imageFiles = await _imageController.getMultiImage(ImageSource.gallery);
                              CustomFullScreenDialog.cancelDialog();
                              if (_imageFiles.length <= 5) {
                                fleaImageSelected = true;
                                imageLength = _imageFiles.length;
                                setState(() {});
                                print(_imageFiles);
                              } else {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text('사진 개수 초과'),
                                  ),
                                );
                              }
                            } catch (e) {
                              CustomFullScreenDialog.cancelDialog();
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    CustomFullScreenDialog.showDialog();
                                    try {
                                      _imageFiles = await _imageController.getMultiImage(ImageSource.gallery);
                                      CustomFullScreenDialog.cancelDialog();
                                      if (_imageFiles.length <= 5) {
                                        fleaImageSelected = true;
                                        imageLength = _imageFiles.length;
                                        setState(() {});
                                        print(_imageFiles);
                                      } else {
                                        Get.dialog(
                                          AlertDialog(
                                            title: Text('사진 개수 초과'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      CustomFullScreenDialog.cancelDialog();
                                    }
                                  },
                                  icon: Icon(Icons.camera_alt_rounded),
                                  color: Color(0xFF949494),
                                ),
                                Transform.translate(
                                  offset: Offset(0, -10),
                                  child: Text(
                                    '$imageLength / 5',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF949494),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xFFececec),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        if(_imageUrls!.length==0 && _imageFiles.length==0)
                          Text('대표사진은 처음 선택한 \n사진으로 등록됩니다.',
                            style: TextStyle(
                                color: Color(0xff949494),
                                fontSize: 12
                            ),
                          ),

                        (isModifiedImageSelected==true)
                            ?Expanded(
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: imageLength,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Stack(children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Color(0xFFECECEC)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        height: 90,
                                        width: 90,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: Image.file(
                                            File(_imageFiles[index].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: IconButton(
                                          onPressed: () {
                                            _imageFiles.removeAt(index);
                                            imageLength = _imageFiles.length;
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.cancel), color: Color(0xFF111111),),
                                      ),
                                      if(index==0)
                                        Positioned(
                                          top: 68,
                                          child: Opacity(
                                            opacity:0.8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8)
                                                ),
                                                color: Colors.black87,
                                              ),
                                              height: 22,
                                              width: 90,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child: Text('대표사진',
                                                  style: TextStyle(color: Colors.white,
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ]),
                                    SizedBox(
                                      width: 8,
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                            :Expanded(
                          child: SizedBox(
                            height: 100,
                            child:
                            Obx(() => ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: _imageUrls!.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Stack(children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Color(0xFFECECEC)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        height: 90,
                                        width: 90,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: Image.network(
                                            '${_imageUrls![index]}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: IconButton(
                                          onPressed: () {
                                            _imageUrls!.removeAt(index);
                                            setState(() {
                                            });
                                          },
                                          icon: Icon(Icons.cancel), color: Color(0xFF111111),),
                                      ),
                                      if(index==0)
                                        Positioned(
                                          top: 68,
                                          child: Opacity(
                                            opacity:0.8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8)
                                                ),
                                                color: Colors.black87,
                                              ),
                                              height: 22,
                                              width: 90,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child: Text('대표사진',
                                                  style: TextStyle(color: Colors.white,
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ]),
                                    SizedBox(
                                      width: 8,
                                    )
                                  ],
                                );
                              },
                            )),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Form(
                        key: _formKey,
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Color(0xff377EEA),
                              cursorHeight: 16,
                              cursorWidth: 2,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _titleTextEditingController..text = '$_initTitle',
                              onChanged: (title){
                                _initTitle = title;
                              },
                              strutStyle: StrutStyle(leading: 0.3),
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                ),
                                labelStyle: TextStyle(
                                    color: Color(0xff949494)
                                ),
                                hintStyle:
                                TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                hintText: '글 제목을 입력해 주세요. (최대 50자)',
                                labelText: '글 제목',
                                contentPadding: EdgeInsets.symmetric(vertical: 2),
                                border: InputBorder.none,
                              ),
                              validator: (val) {
                                if (val!.length <= 50 && val.length >= 1) {
                                  return null;
                                } else if (val.length == 0) {
                                  return '글 제목을 입력해주세요.';
                                } else {
                                  return '최대 입력 가능한 글자 수를 초과했습니다.';
                                }
                              },
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: Color(0xFFDEDEDE),
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Color(0xff3D6FED),
                              cursorHeight: 16,
                              cursorWidth: 2,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _itemNameTextEditingController..text='$_initItemName',
                              onChanged: (itemName){
                                _initItemName = itemName;
                              },
                              strutStyle: StrutStyle(leading: 0.3),
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                ),
                                labelStyle: TextStyle(
                                    color: Color(0xff949494)
                                ),
                                hintStyle:
                                TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                hintText: '물품명을 입력해 주세요. (최대 20자)',
                                labelText: '물품명',
                                contentPadding: EdgeInsets.symmetric(vertical: 2),
                                border: InputBorder.none,
                              ),
                              validator: (val) {
                                if (val!.length <= 20 && val.length >= 1) {
                                  return null;
                                } else if (val.length == 0) {
                                  return '물품명을 입력해주세요.';
                                } else {
                                  return '최대 입력 가능한 글자 수를 초과했습니다.';
                                }
                              },
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: Color(0xFFDEDEDE),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: _size.width / 2 - 16,
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    cursorColor: Color(0xff377EEA),
                                    cursorHeight: 16,
                                    cursorWidth: 2,
                                    controller: _itemPriceTextEditingController..text='$_initPrice',
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                                    onChanged: (price){
                                      _initPrice = int.parse(price);
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(bottom: 14),
                                      border: InputBorder.none,
                                      hintText: '판매가격',
                                      prefixIcon: Image.asset('assets/imgs/icons/icon_won.png',
                                        color: Color(0xFF949494),
                                      ),
                                      prefixIconConstraints: BoxConstraints(maxWidth: 20),
                                    ),
                                    validator: (val) {
                                      if (val!.length <= 8 && val.length >= 1) {
                                        return null;
                                      } else if (val.length == 0) {
                                        return '가격을 입력해주세요.';
                                      } else {
                                        return '최대 입력 가능한 글자 수를 초과했습니다.';
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  width: _size.width / 2 - 26,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '거래방식',
                                        style:
                                        TextStyle(color: Color(0xff949494), fontSize: 12),
                                      ),
                                      Obx(() => TextButton(
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                                enableDrag: false,
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    color: Colors.white,
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 30),
                                                    height: _size.height * 0.45,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '거래방식을 선택해주세요.',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        Container(
                                                          color: Colors.white,
                                                          height: 30,
                                                        ),
                                                        Expanded(
                                                          child: ListView.builder(
                                                              padding: EdgeInsets.zero,
                                                              itemCount: 3,
                                                              itemBuilder: (context, index) {
                                                                return Builder(builder: (context) {
                                                                  return Column(
                                                                    children: [
                                                                      buildMethodListTile(index),
                                                                      Divider(
                                                                        height: 20,
                                                                        thickness: 0.5,
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Text('${SelectedMethod!.value}',
                                            style: TextStyle(
                                                fontSize: 16, color: Color(0xFF111111)
                                            ),))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: Color(0xFFDEDEDE),
                            ),


                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '카테고리',
                                  style:
                                  TextStyle(color: Color(0xff949494), fontSize: 12),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Obx(() => TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          enableDrag: false,
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 30),
                                              height: _size.height * 0.8,
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '카테고리를 선택해주세요.',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  Container(
                                                    color: Colors.white,
                                                    height: 30,
                                                  ),
                                                  Expanded(
                                                    child: ListView.builder(
                                                        padding: EdgeInsets.zero,
                                                        itemCount: fleaCategoryList.length,
                                                        itemBuilder: (context, index) {
                                                          return Builder(
                                                              builder: (context) {
                                                                return Column(
                                                                  children: [
                                                                    buildCategoryListTile(
                                                                        index),
                                                                    Divider(
                                                                      height: 20,
                                                                      thickness: 0.5,
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(0xFFD7F4FF),
                                      ),
                                      padding: EdgeInsets.only(right: 10, left: 10, top: 4, bottom: 6),
                                      child: Text('${SelectedCategory!.value}', style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF458BF5)
                                      ),),
                                    ))),
                              ],
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: Color(0xFFDEDEDE),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '거래장소',
                                  style:
                                  TextStyle(color: Color(0xff949494), fontSize: 12),
                                ),

                                SizedBox(
                                  height: 4,
                                ),

                                Obx(() => TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          enableDrag: false,
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 30),
                                              height: _size.height * 0.5,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '거래희망 장소를 선택해주세요.',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  Container(
                                                    color: Colors.white,
                                                    height: 30,
                                                  ),
                                                  Expanded(
                                                    child: ListView.builder(
                                                        padding: EdgeInsets.zero,
                                                        itemCount: 14,
                                                        itemBuilder: (context, index) {
                                                          return Builder(builder: (context) {
                                                            return Column(
                                                              children: [
                                                                buildResortListTile(index),
                                                                Divider(
                                                                  height: 20,
                                                                  thickness: 0.5,
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child:  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(0xFFD5F7E0),
                                      ),
                                      padding: EdgeInsets.only(right: 10, left: 10, top: 4, bottom: 6),
                                      child: Text('${SelectedLocation!.value}', style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF17AD4A)
                                      ),),
                                    )
                                )),
                              ],
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: Color(0xFFDEDEDE),
                            ),
                            Container(
                              height: 70,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      maxLines: 10,
                                      textAlignVertical: TextAlignVertical.center,
                                      cursorColor: Color(0xff377EEA),
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _kakaoUrlTextEditingController..text = '$_initKakaoUrl',
                                      onChanged: (kakaoUrl){
                                        _initKakaoUrl = kakaoUrl;
                                        print(_initKakaoUrl);
                                      },
                                      strutStyle: StrutStyle(leading: 0.3),
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                        labelStyle: TextStyle(
                                            color: Color(0xff949494)
                                        ),
                                        hintStyle:
                                        TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                        hintText: 'URL을 입력해주세요.(https:// 필수 입력)',
                                        labelText: '카카오 오픈채팅 URL',
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) {
                                        if (val!.length <= 1000 && val.length >= 0) {
                                          return null;
                                        } else {
                                          return '최대 입력 가능한 글자 수를 초과했습니다.';
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: _size.height-500,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      maxLines: null,
                                      textAlignVertical: TextAlignVertical.center,
                                      cursorColor: Color(0xff377EEA),
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _itemDescribTextEditingController..text = '$_initdescrip',
                                      onChanged: (descrip){
                                        _initdescrip = descrip;
                                        print(_initdescrip);
                                      },
                                      strutStyle: StrutStyle(leading: 0.3),
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                        labelStyle: TextStyle(
                                            color: Color(0xff949494)
                                        ),
                                        hintStyle:
                                        TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                        hintText: '게시글 내용을 작성해 주세요. (최대 1,000자)',
                                        labelText: '상세설명',
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) {
                                        if (val!.length <= 1000 && val.length >= 1) {
                                          return null;
                                        } else if (val.length == 0) {
                                          return '상세설명을 입력해주세요.';
                                        } else {
                                          return '최대 입력 가능한 글자 수를 초과했습니다.';
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
