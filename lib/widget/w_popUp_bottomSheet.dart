import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final ref = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

UserViewModel _userViewModel = Get.find<UserViewModel>();

Future<void> bottomPopUp() async {
  List addUidList = [];
  List addUidViewer = [];
  bool addUidBoolean = false;
  String? addUidLandingUrl = '';
  String? addUidImageUrl = '';
  String? addUidbottonMsg = '';

  List minusUidList = [];
  List totalViewer = [];
  bool isTotal = false;
  String? totalLandingUrl = '';
  String? totalImageUrl = '';
  String? totalbottonMsg = '';

  Future<void> getAddUidList() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await ref.collection('popUp').doc('resortHome_bottom_addUid').get();
    addUidList = documentSnapshot.get('addUidList');
    addUidBoolean = documentSnapshot.get('useAddUidPopUp');
    addUidLandingUrl = documentSnapshot.get('landingUrl');
    addUidImageUrl = documentSnapshot.get('imageUrl');
    addUidViewer = documentSnapshot.get('viewer');
    addUidbottonMsg = documentSnapshot.get('bottonMsg');
  }

  Future<void> getMinusUidList() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await ref.collection('popUp').doc('resortHome_bottom_total').get();
    minusUidList = documentSnapshot.get('minusUidList');
    isTotal = documentSnapshot.get('total');
    totalLandingUrl = documentSnapshot.get('landingUrl');
    totalImageUrl = documentSnapshot.get('imageUrl');
    totalViewer = documentSnapshot.get('viewer');
    totalbottonMsg = documentSnapshot.get('bottonMsg');
  }

  Future<void> updateTotalViewerUid() async {
    int userMe = _userViewModel.user.user_id;
    await ref.collection('popUp').doc('resortHome_bottom_total').update({
      'viewer': FieldValue.arrayUnion([userMe])
    });
  }

  Future<void> updateAddViewerUid() async {
    int userMe = _userViewModel.user.user_id;
    await ref.collection('popUp').doc('resortHome_bottom_addUid').update({
      'viewer': FieldValue.arrayUnion([userMe])
    });
  }

  await getAddUidList();
  await getMinusUidList();

  if (addUidBoolean == true &&
      addUidList.contains(_userViewModel.user.user_id) &&
      !addUidViewer.contains(_userViewModel.user.user_id)) {
    Get.bottomSheet(
      _buildBottomSheetContent(
        imageUrl: addUidImageUrl!,
        buttonText: addUidbottonMsg!,
        onDismiss: () async {
          await updateAddViewerUid();
          Get.back();
        },
        onAction: () async {
          try {
            await FirebaseAnalytics.instance.logEvent(
              name: 'tap_resortHome_bottom_addUid',
              parameters: {
                'user_id': _userViewModel.user.user_id,
                'user_name': _userViewModel.user.displayName!,
                'user_resort': _userViewModel.user.favorite_resort
              },
            );
          } catch (e, stackTrace) {
            print('GA 오류: $e');
            print('Stack trace: $stackTrace');
          }
          otherShare(contents: addUidLandingUrl!);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  } else if (isTotal == true &&
      !minusUidList.contains(_userViewModel.user.user_id) &&
      !totalViewer.contains(_userViewModel.user.user_id)) {
    Get.bottomSheet(
      _buildBottomSheetContent(
        imageUrl: totalImageUrl!,
        buttonText: totalbottonMsg!,
        onDismiss: () async {
          await updateTotalViewerUid();
          Get.back();
        },
        onAction: () async {
          try {
            await FirebaseAnalytics.instance.logEvent(
              name: 'tap_resortHome_bottom_total',
              parameters: {
                'user_id': _userViewModel.user.user_id,
                'user_name': _userViewModel.user.displayName!,
                'user_resort': _userViewModel.user.favorite_resort
              },
            );
          } catch (e, stackTrace) {
            print('GA 오류: $e');
            print('Stack trace: $stackTrace');
          }
          otherShare(contents: totalLandingUrl!);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

Widget _buildBottomSheetContent({
  required String imageUrl,
  required String buttonText,
  required VoidCallback onDismiss,
  required VoidCallback onAction,
}) {
  return WillPopScope(
    onWillPop: () async => false,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                height: Get.width,
                width: Get.width,
                child: ExtendedImage.network(
                  imageUrl,
                  cacheHeight: 500,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: (){
                    Get.back();
                  },
                  child: Image.asset(
                    'assets/imgs/icons/icon_profile_delete.png',
                    fit: BoxFit.cover,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(
                    '다시 보지 않기',
                    style: TextStyle(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Color(0xFFDEDEDE),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
        ],
      ),
    ),
  );
}
