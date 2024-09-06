
import 'package:com.snowlive/model_2/m_resortModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/viewmodel/vm_imageController.dart';
import '../api/ApiResponse.dart';
import '../api/api_login.dart';
import '../api/api_user.dart';

class SetProfileViewModel extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController textEditingControllerYYYY = TextEditingController();
  final TextEditingController textEditingControllerMM = TextEditingController();
  final TextEditingController textEditingControllerDD = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxString _displayName=''.obs;
  RxBool _isCheckedDisplayName= false.obs;
  RxBool _profileImage = false.obs;
  RxBool _activeCheckDisplaynameButton = false.obs;
  Rx<XFile?> _imageFile = Rx<XFile?>(null);
  Rx<XFile?> _croppedFile = Rx<XFile?>(null);
  RxString _profileImageUrl=''.obs;
  RxString _selectedResortName=''.obs;
  RxInt _selectedResortIndex=99.obs;
  RxString _selectedSkiOrBoard=''.obs;
  RxString _selectedSex=''.obs;
  var _startSnowliveReturn;

  String get displayName => _displayName.value;
  bool get isCheckedDisplayName => _isCheckedDisplayName.value;
  bool get profileImage => _profileImage.value;
  bool get activeCheckDisplaynameButton => _activeCheckDisplaynameButton.value;
  XFile? get imageFile => _imageFile.value;
  XFile? get croppedFile => _croppedFile.value;
  String get profileImageUrl => _profileImageUrl.value;
  String get selectedResortName => _selectedResortName.value;
  String get selectedSkiOrBoard => _selectedSkiOrBoard.value;
  String get selectedSex => _selectedSex.value;
  int get selectedResortIndex => _selectedResortIndex.value;
  dynamic get startSnowliveReturn => _startSnowliveReturn;

  // Dependency Injection

  final ImageController imageController = Get.put(ImageController());

  SetProfileViewModel() {
    textEditingController.addListener(() {
      _isCheckedDisplayName.value = false;
    });
  }

  Future<void> uploadImage(ImageSource source) async {
    try {
      _imageFile.value = await imageController.getSingleImage(source);
      if(_imageFile.value != null)
        _croppedFile.value = await imageController.cropImage(_imageFile.value);
       if(_croppedFile.value != null)
        _profileImage.value = true;

    } catch (e) {
      // 에러 처리
      print('Image upload error: $e');
    }
  }

  Future<void> getImageUrl() async {
    if (_croppedFile.value != null) {
      try {
        _profileImageUrl.value = await imageController.setNewImage(_croppedFile.value!);
      } catch (e) {
        print('Profile image upload error: $e');
      }
    }
  }

  Future<void> startSnowlive(Map<String, dynamic> body) async {
    if (formKey.currentState!.validate()){
    ApiResponse response = await LoginAPI().registerUser(body);
    _startSnowliveReturn = response.data;
    }
  }

  void cancelSelectedImage(){
    _profileImage.value = false;
    _croppedFile.value = null;
  }

  void toggleCheckDisplayname(bool active){
    _activeCheckDisplaynameButton.value = active;
  }

  void selectResortInfo(int selectedIndex){
    _selectedResortIndex.value = selectedIndex;
    _selectedResortName.value = resortNameList[selectedIndex]!;
  }

  void selectSkiOrBoard(String selected){
      _selectedSkiOrBoard.value = selected;
  }

  void selectSex(String selected){
    _selectedSex.value = selected;
  }


  Future<void> checkDisplayName(body) async{
    ApiResponse response = await LoginAPI().checkDisplayName(body);
    if(response.success){
      print(response.data['message']);
      _isCheckedDisplayName.value = true;
      _displayName.value = textEditingController.text;
    } else{
        _isCheckedDisplayName.value = false;

    }
  }



}

