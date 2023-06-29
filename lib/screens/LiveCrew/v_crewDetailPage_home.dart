import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import '../../../controller/vm_userModelController.dart';
import '../../controller/vm_timeStampController.dart';

class CrewDetailPage_home extends StatefulWidget {
  CrewDetailPage_home({Key? key, }) : super(key: key);

  @override
  State<CrewDetailPage_home> createState() => _CrewDetailPage_homeState();
}

class _CrewDetailPage_homeState extends State<CrewDetailPage_home> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          body: StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: _liveCrewModelController.crewID )
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (!snapshot.hasData || snapshot.data == null) {}
      else if (snapshot.data!.docs.isNotEmpty) {
        final crewDocs = snapshot.data!.docs;
        final List memberUidList = crewDocs[0]['memberUidList'];
      return Padding(
        padding: EdgeInsets.only(top: _statusBarSize + 58),
        child: Stack(
          children: [
            Container(
              height: _size.height - 160,
              width: _size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFEEEEF5)
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.only(top: 30, bottom: 16),
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                (crewDocs[0]['profileImageUrl'].isNotEmpty)
                                    ? GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: crewDocs[0]['profileImageUrl']));
                                  },
                                  child: Container(
                                      width: 100,
                                      height: 100,
                                      child: ExtendedImage.network(
                                        crewDocs[0]['profileImageUrl'],
                                        enableMemoryCache: true,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )),
                                )
                                    : GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: ''));
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    child: ExtendedImage.asset(
                                      'assets/imgs/profile/img_profile_default_circle.png',
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '크루 이름 : ${crewDocs[0]['crewName']}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                    Text(
                                      '크루 마스터 : ${crewDocs[0]['crewLeader']}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                    Text(
                                      '크루 소개 : ${crewDocs[0]['description']}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                    if(memberUidList.contains(_userModelController.uid))
                                   Text(
                                      '공지사항 : ${crewDocs[0]['notice']}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                    Text(
                                      '멤버수 : ${memberUidList.length}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                    Text(
                                      '창단일 : ${_timeStampController.yyyymmddFormat(crewDocs[0]['resistDate'])}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                    Text(
                                      '베이스 : ${_resortModelController.getResortName(crewDocs[0]['baseResortNickName'])}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if(memberUidList.contains(_userModelController.uid) == false)
                        Expanded(
                          child:
                          ElevatedButton(
                            onPressed:
                                () {},
                            child: Text(
                              '가입하기',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                                splashFactory: InkRipple.splashFactory,
                                elevation: 0,
                                minimumSize: Size(100, 56),
                                backgroundColor: Color(0xff555555),
                                padding: EdgeInsets.symmetric(horizontal: 0)),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child:
                          ElevatedButton(
                            onPressed:
                                () {},
                            child: Text(
                              'SNS 링크',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                                splashFactory: InkRipple.splashFactory,
                                elevation: 0,
                                minimumSize: Size(100, 56),
                                backgroundColor: Color(0xff555555),
                                padding: EdgeInsets.symmetric(horizontal: 0)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      }
      else if (snapshot.connectionState == ConnectionState.waiting) {}
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    ),
        )
      );
  }
}

// if (!snapshot.hasData || snapshot.data == null) {}
// else if (snapshot.data!.docs.isNotEmpty) {
// Column(
// children: [
//
// ],
// );
// }
// else if (snapshot.connectionState == ConnectionState.waiting) {}
// return Center(
// child: CircularProgressIndicator(),
// );

