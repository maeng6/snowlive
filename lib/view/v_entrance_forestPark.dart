import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Entrance_forestPark extends StatefulWidget {
  @override
  _Entrance_forestParkState createState() => _Entrance_forestParkState();
}

class _Entrance_forestParkState extends State<Entrance_forestPark> {

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  ForestParkViewModel _forestParkViewModel = Get.find<ForestParkViewModel>();


  @override
  void initState() {
    super.initState();
    _forestParkViewModel.getInfo_forestPark_entrance();
  }


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: _forestParkViewModel.infoStream_forestPark_entrance.value,
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
        String entranceImage = data?['entranceImage'] ?? '';

        if (isOpen == true && (isToEveryone || isUserInCrewList)) {
          return GestureDetector(
            onTap: () async {
              Get.toNamed(AppRoutes.forestParkHome);
            },
            child: Container(
              height: _size.width - 32,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ExtendedImage.network(
                      entranceImage,
                      width: double.infinity,
                      height: null, // 높이 비율 유지
                      fit: BoxFit.fitWidth,
                      loadStateChanged: (state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Container(
                              height: 200,
                              color: Colors.grey.shade100,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            );
                          case LoadState.failed:
                            return Container(
                              height: 200,
                              color: Colors.grey.shade100,
                              alignment: Alignment.center,
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          case LoadState.completed:
                            return null;
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: SDSColor.snowliveWhite
                        ),
                        width: 160,
                        height: 42,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('이벤트 입장하기',
                            style: SDSTextStyle.extraBold.copyWith(
                              fontSize: 14,
                              color: SDSColor.snowliveBlack
                            ),),
                            Image.asset(
                              'assets/imgs/icons/icon_arrow_round_black.png',
                              fit: BoxFit.cover,
                              width: 18,
                              height: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return SizedBox.shrink(); // banner 필드가 없거나 비어있으면 빈 공간 반환
        }

      },
    );
  }
}
