import 'dart:io';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/model/m_fleaMarketModel.dart';
import '../../controller/vm_imageController.dart';
import '../../controller/vm_userModelController.dart';
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
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _itemNameTextEditingController = TextEditingController();
  TextEditingController _itemPriceTextEditingController = TextEditingController();
  TextEditingController _itemDescribTextEditingController = TextEditingController();
  bool? isCategorySelected = false;
  bool? isLocationSelected = false;
  bool? isMethodSelected = false;
  String? SelectedCategory = '';
  String? SelectedLocation = '';
  String? SelectedMethod = '';
  String? title = '';
  final _formKey = GlobalKey<FormState>();

  ListTile buildCategoryListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${fleaCategoryList[index]}'),
      onTap: () async {
        isCategorySelected = true;
        SelectedCategory = fleaCategoryList[index];
        Navigator.pop(context);
        setState(() {});
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
        SelectedLocation = fleaLocationList[index];
        Navigator.pop(context);
        setState(() {});
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
        SelectedMethod = fleaMethodList[index];
        Navigator.pop(context);
        setState(() {});
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_imageFiles);
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
                        await _imageController.setNewMultiImage(_imageFiles, _userModelController.fleaCount);
                        await _fleaModelController.uploadFleaItem(
                            displayName: _userModelController.displayName,
                            uid: _userModelController.uid,
                            profileImageUrl: _userModelController.profileImageUrl,
                            itemImagesUrls: _imageController.imagesUrlList,
                            title: _titleTextEditingController.text,
                            category: SelectedCategory,
                            itemName: _itemNameTextEditingController.text,
                            price: int.parse(_itemPriceTextEditingController.text),
                            location: SelectedLocation,
                            method: SelectedMethod,
                            description: _itemDescribTextEditingController.text,
                            fleaCount: _userModelController.fleaCount,
                            resortNickname: _userModelController.resortNickname
                        );
                        Navigator.pop(context);
                        CustomFullScreenDialog.cancelDialog();
                      }
                      _imageController.imagesUrlList.clear();

                    },
                    child: Text('수정완료'))
              ],
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          CustomFullScreenDialog.showDialog();
                          try {
                            _imageFiles = await _imageController
                                .getMultiImage(ImageSource.gallery);
                            CustomFullScreenDialog.cancelDialog();
                            fleaImageSelected = true;
                            imageLength = _imageFiles.length;
                            print(_imageFiles);
                            setState(() {});
                          } catch (e) {
                            CustomFullScreenDialog.cancelDialog();
                          }
                        },
                        child: Container(
                          height: 80,
                          width: 70,
                          child: Column(
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    CustomFullScreenDialog.showDialog();
                                    try {
                                      _imageFiles = await _imageController
                                          .getMultiImage(ImageSource.gallery);
                                      if(_imageFiles.length <= 5){
                                        CustomFullScreenDialog.cancelDialog();
                                        fleaImageSelected = true;
                                        imageLength = _imageFiles.length;
                                        setState(() {});
                                        print(_imageFiles);
                                      }else{
                                        CustomFullScreenDialog.cancelDialog();
                                        Get.dialog(
                                            AlertDialog(
                                              title: Text('사진 개수 초과'),
                                        )
                                        );
                                      }

                                    } catch (e) {
                                      CustomFullScreenDialog.cancelDialog();
                                    }
                                  },
                                  icon: Icon(Icons.camera_alt_rounded)),
                              Text('$imageLength/5'),
                            ],
                          ),
                          decoration: BoxDecoration(border: Border.all()),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
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
                                          border: Border.all(color: Colors.grey)),
                                      height: 80,
                                      width: 70,
                                      child: Image.file(
                                        File(_imageFiles[index].path),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: IconButton(
                                          onPressed: () {
                                            _imageFiles.removeAt(index);
                                            imageLength = _imageFiles.length;
                                            print(_imageFiles);
                                            print(imageLength);
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.cancel)),
                                    ),
                                  ]),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    height: 1,
                    color: Colors.black87,
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
                      controller: _titleTextEditingController..text = '${_fleaModelController.title}',
                      strutStyle: StrutStyle(leading: 0.3),
                      decoration: InputDecoration(
                        errorStyle: TextStyle(
                          fontSize: 12,
                        ),
                        hintStyle:
                        TextStyle(color: Color(0xff949494), fontSize: 16),
                        hintText: '글 제목 입력',
                        labelText: '글 제목',
                        contentPadding: EdgeInsets.all(10),
                        border: InputBorder.none,
                      ),
                      validator: (val) {
                        if (val!.length <= 20 && val.length >= 1) {
                          return null;
                        } else if (val.length == 0) {
                          return '글 제목을 입력해주세요.';
                        } else {
                          return '최대 입력 가능한 글자 수를 초과했습니다.';
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black87,
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 5.0, right: 5.0, bottom: 5.0),
                      child: Column(
                        children: [
                          if (isCategorySelected==true)
                            Text(
                              '카테고리',
                              style:
                              TextStyle(color: Color(0xff949494), fontSize: 12),
                            ),
                          TextButton(
                              onPressed: () {
                                showMaterialModalBottomSheet(
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        color: Colors.white,
                                        height: _size.height * 0.5,
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
                                                  itemCount: 5,
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
                              child: (isCategorySelected!)
                                  ? Text('$SelectedCategory')
                                  : Text('${_fleaModelController.category}')),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black87,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Color(0xff377EEA),
                      cursorHeight: 16,
                      cursorWidth: 2,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _itemNameTextEditingController..text='${_fleaModelController.itemName}',
                      strutStyle: StrutStyle(leading: 0.3),
                      decoration: InputDecoration(
                        errorStyle: TextStyle(
                          fontSize: 12,
                        ),
                        hintStyle:
                        TextStyle(color: Color(0xff949494), fontSize: 16),
                        hintText: '물품명 입력',
                        labelText: '물품명',
                        contentPadding: EdgeInsets.all(10),
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
                      height: 1,
                      color: Colors.black87,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Color(0xff377EEA),
                      cursorHeight: 16,
                      cursorWidth: 2,
                      controller: _itemPriceTextEditingController..text='${_fleaModelController.price}',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        // CurrencyTextInputFormatter(
                        //   locale: 'ko',
                        //   decimalDigits: 0,
                        //   symbol: '',
                        // ),
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '판매가격',
                        prefixIcon: Image.asset('assets/imgs/icons/icon_won.png',
                         color:
                         (_itemPriceTextEditingController.text.trim().isEmpty)
                         ? Colors.grey[350]
                         : Colors.black87,
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
                    Divider(
                      height: 1,
                      color: Colors.black87,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, right: 5.0, bottom: 5.0),
                      child: Column(
                        children: [
                          if (isLocationSelected==true)
                            Text(
                              '거래장소',
                              style:
                              TextStyle(color: Color(0xff949494), fontSize: 12),
                            ),
                          TextButton(
                              onPressed: () {
                                showMaterialModalBottomSheet(
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        color: Colors.white,
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
                              child: (isLocationSelected!)
                                  ? Text('$SelectedLocation')
                                  : Text('${_fleaModelController.location}')),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black87,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, right: 5.0, bottom: 5.0),
                      child: Column(
                        children: [
                          if (isMethodSelected==true)
                            Text(
                              '거래방식',
                              style:
                              TextStyle(color: Color(0xff949494), fontSize: 12),
                            ),
                          TextButton(
                              onPressed: () {
                                showMaterialModalBottomSheet(
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        color: Colors.white,
                                        height: _size.height * 0.5,
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
                              child: (isMethodSelected!)
                                  ? Text('$SelectedMethod')
                                  : Text('${_fleaModelController.method}')),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black87,
                    ),
                    Container(
                      height: 200,
                      child: Column(
                        children: [
                          Expanded(
                            child: TextFormField(
                              maxLines: 10,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Color(0xff377EEA),
                              cursorHeight: 16,
                              cursorWidth: 2,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _itemDescribTextEditingController..text = '${_fleaModelController.description}',
                              strutStyle: StrutStyle(leading: 0.3),
                              decoration: InputDecoration(
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                ),
                                hintStyle:
                                TextStyle(color: Color(0xff949494), fontSize: 16),
                                hintText: '상세설명 입력',
                                labelText: '상세설명',
                                contentPadding: EdgeInsets.all(10),
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
                          Divider(
                            height: 1,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                  )
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
