import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Entrance_snowballShop extends StatefulWidget {
  @override
  _Entrance_snowballShopState createState() => _Entrance_snowballShopState();
}

class _Entrance_snowballShopState extends State<Entrance_snowballShop> {
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();

  @override
  void initState() {
    super.initState();
    _snowballShopViewModel.getInfo_snowballMarket_entrance(); // Firebase에서 banner 가져오는 함수
    _snowballShopViewModel.fetchSnowballSummary();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: _snowballShopViewModel.infoStream_snowballShop_entrance.value,
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


        if (isOpen == true && (isToEveryone || isUserInCrewList)) {
          return Obx(()=>Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A2E), // 배경색
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오픈!',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '눈송이 상점',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '눈송이를 찾아라!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.ac_unit, color: Colors.blue, size: 18), // 하얀 눈송이 아이콘
                            SizedBox(width: 4),
                            Text(
                              '${_snowballShopViewModel.snowballSummary.value.white}', // 하얀 눈송이 개수
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        Row(
                          children: [
                            Icon(Icons.circle, color: Colors.amber, size: 18), // 황금 눈송이 아이콘
                            SizedBox(width: 4),
                            Text(
                              '${_snowballShopViewModel.snowballSummary.value.gold}', // 황금 눈송이 개수
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                            onTap: (){
                              _snowballShopViewModel.fetchSnowballSummary();
                            },
                            child: Icon(Icons.refresh, color: Colors.white, size: 20)), // 새로고침 아이콘
                      ],
                    ),
                    SizedBox(height: 20,),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.treasureHunt);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '입장하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ));
        } else {
          return SizedBox.shrink(); // banner 필드가 없거나 비어있으면 빈 공간 반환
        }

      },
    );
  }
}
