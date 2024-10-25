import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Banner_treasureHunt extends StatefulWidget {
  @override
  _Banner_treasureHuntState createState() => _Banner_treasureHuntState();
}

class _Banner_treasureHuntState extends State<Banner_treasureHunt> {
  ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void initState() {
    super.initState();
    _resortHomeViewModel.getInfo_treasureHunt(); // Firebase에서 banner 가져오는 함수
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: _resortHomeViewModel.infoStream_treasureHunt.value,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // 데이터 로드 중이라면
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }
        // 오류가 발생했다면
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var data = snapshot.data?.data() as Map<String, dynamic>?;
        // open 필드가 true인지 확인
        bool isOpen = data?['open'] ?? false;

        // to_everyone 필드가 true인지 확인
        bool isToEveryone = data?['to_everyone'] ?? false;

        // crew_list 필드가 리스트인지 확인하고, 유저의 크루가 리스트에 포함되어 있는지 확인
        List<dynamic> crewList = data?['crew_list'] ?? [];
        bool isUserInCrewList = _userViewModel.user.crew_id != null && crewList.contains(_userViewModel.user.crew_id);


        if (data != null) {
          String? bannerImageUrl = data['banner']; // banner 필드에 있는 이미지 경로

          if (isOpen == true && (isToEveryone || isUserInCrewList) && bannerImageUrl != null && bannerImageUrl.isNotEmpty) {
            return Container(
              width: _size.width,
              margin: EdgeInsets.only(bottom: 10.0),
              child: ExtendedImage.network(
                bannerImageUrl,
                cache: true,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return SizedBox.shrink(); // banner 필드가 없거나 비어있으면 빈 공간 반환
          }
        } else {
          return Center(
            child: Text('No banner data available'),
          );
        }
      },
    );
  }
}
