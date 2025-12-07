import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/api/api_user.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';

class FriendDetailUpdateViewModel extends GetxController {
  final TextEditingController textEditingController_displayName = TextEditingController();
  final TextEditingController textEditingController_stateMsg = TextEditingController();
  final TextEditingController textEditingControllerYYYY = TextEditingController();
  final TextEditingController textEditingControllerMM = TextEditingController();
  final TextEditingController textEditingControllerDD = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxString _displayName = ''.obs;
  RxBool _isCheckedDisplayName = false.obs;
  RxBool _profileImage = false.obs;
  RxBool _activeCheckDisplaynameButton = false.obs;
  RxBool _hideProfile = false.obs;
  Rx<XFile?> _imageFile = Rx<XFile?>(null);
  Rx<XFile?> _croppedFile = Rx<XFile?>(null);
  RxString _profileImageUrl = ''.obs;
  RxString _selectedResortName = ''.obs;
  RxInt _selectedResortIndex = 99.obs;
  RxString _selectedSkiOrBoard = ''.obs;
  RxString _selectedSex = ''.obs;
  var _startSnowliveReturn;

  String get displayName => _displayName.value;
  bool get isCheckedDisplayName => _isCheckedDisplayName.value;
  bool get profileImage => _profileImage.value;
  bool get activeCheckDisplaynameButton => _activeCheckDisplaynameButton.value;
  bool get hideProfile => _hideProfile.value;
  XFile? get imageFile => _imageFile.value;
  XFile? get croppedFile => _croppedFile.value;
  String get profileImageUrl => _profileImageUrl.value;
  String get selectedResortName => _selectedResortName.value;
  String get selectedSkiOrBoard => _selectedSkiOrBoard.value;
  String get selectedSex => _selectedSex.value;
  int get selectedResortIndex => _selectedResortIndex.value;
  dynamic get startSnowliveReturn => _startSnowliveReturn;

  ImageController imageController = Get.find<ImageController>();

  // Setter for croppedFile
  void setCroppedFile(XFile? file) {
    _croppedFile.value = file;
    _profileImage.value = file != null; // Update profileImage based on croppedFile existence
  }

  // Setter for profileImageUrl
  void setProfileImageUrl(String url) {
    _profileImageUrl.value = url;
  }

  // Method to reset the image selection (cancel selected image)
  void cancelSelectedImage() {
    _profileImage.value = false;
    _croppedFile.value = null;
    _profileImageUrl.value = ''; // Also reset the profile image URL
  }

  void fetchFriendDetailUpdateData({
    required displayName,
    required state_msg,
    required profileImageUrl,
    required selectedResortName,
    required selectedResortIndex,
    required selectedSkiOrBoard,
    required selectedSex,
    required bool hideProfile
  })  {
    // Update text controllers and selected values
    this.textEditingController_displayName.text = displayName;
    this.textEditingController_stateMsg.text = state_msg??'';
    this._displayName.value = displayName;
    this._profileImageUrl.value = profileImageUrl??'';
    this._selectedResortName.value = selectedResortName;
    this._selectedResortIndex.value = selectedResortIndex;
    this._selectedSkiOrBoard.value = selectedSkiOrBoard;
    this._selectedSex.value = selectedSex;
    this._hideProfile.value = hideProfile;
    this._isCheckedDisplayName.value = true;
  }

  FriendDetailUpdateViewModel() {
    textEditingController_displayName.addListener(() {
      _isCheckedDisplayName.value = false;
    });
  }

  Future<void> uploadImage(ImageSource source) async {
    try {
      _imageFile.value = await imageController.getSingleImage(source);
      if (_imageFile.value != null) _croppedFile.value = await imageController.cropImage(_imageFile.value);
      if (_croppedFile.value != null) _profileImage.value = true;
    } catch (e) {
      // 에러 처리
      print('Image upload error: $e');
    }
  }


  Future<void> getImageUrl({String? oldUrl}) async {
    // 기본값은 현재 값 유지
    String currentUrl = _profileImageUrl.value;

    try {
      // 1) 새로 크롭된 이미지가 있으면 → 업로드 후 새 URL 받기
      if (_croppedFile.value != null) {
        final newUrl = await imageController.setNewImage(_croppedFile.value!);
        currentUrl = newUrl;

        // 2) 이전 URL이 있고, 기본이미지가 아니면 → 스토리지에서 삭제
        if (oldUrl != null && oldUrl.isNotEmpty && oldUrl != newUrl) {
          try {
            final oldRef = FirebaseStorage.instance.refFromURL(oldUrl);
            await oldRef.delete();
            print('Old profile image deleted: $oldUrl');
          } catch (e) {
            print('Failed to delete old profile image: $e');
          }
        }
      } else {
        // 3) 크롭 파일이 없는데, 사용자가 삭제 버튼으로 기본이미지로 만든 경우
        //    (네 코드에서 setProfileImageUrl('') 호출했을 때)
        if (_profileImageUrl.value.isEmpty &&
            oldUrl != null &&
            oldUrl.isNotEmpty) {
          try {
            final oldRef = FirebaseStorage.instance.refFromURL(oldUrl);
            await oldRef.delete();
            print('Old profile image deleted (reset to default): $oldUrl');
          } catch (e) {
            print('Failed to delete old profile image when reset: $e');
          }
        }
      }
    } catch (e) {
      print('Profile image upload error: $e');
    }

    // 4) 최종 URL 반영
    _profileImageUrl.value = currentUrl;
  }


  void toggleActiveCheckDisplaynameButton(bool active) {
    _activeCheckDisplaynameButton.value = active;
  }

  void toggleIsCheckedDisplayName(bool active) {
    _isCheckedDisplayName.value = active;
  }

  void selectResortInfo(int selectedIndex) {
    _selectedResortIndex.value = selectedIndex;
    _selectedResortName.value = resortNameList[selectedIndex]!;
  }

  void selectSkiOrBoard(String selected) {
    _selectedSkiOrBoard.value = selected;
  }

  void selectSex(String selected) {
    _selectedSex.value = selected;
  }

  void toggleHideProfile(bool value) {
    _hideProfile.value = value;
  }


  Future<void> checkDisplayName(body) async {
    ApiResponse response = await LoginAPI().checkDisplayName(body);
    if (response.success) {
      print(response.data['message']);
      _isCheckedDisplayName.value = true;
      _displayName.value = textEditingController_displayName.text;
    } else {
      _isCheckedDisplayName.value = false;
    }
  }

  Future<bool> updateFriendDetail(Map<String, dynamic> body) async {
    ApiResponse response = await UserAPI().updateUserInfo(body);

    if (response.success) {
      print('유저 정보 수정 완료');
      return true; // 성공
    } else {
      CustomFullScreenDialog.cancelDialog();
      Get.snackbar(
        '프로필 수정 실패',
        '잠시 후 다시 시도해주세요.',
      );
      print('유저 정보 수정 실패: ${response.error}');
      return false; // 실패
    }
  }

}

