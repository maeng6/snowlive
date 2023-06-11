import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/vm_timeStampController.dart';
import '../../../controller/vm_userModelController.dart';

class FriendDetailPage extends StatefulWidget {
  FriendDetailPage({Key? key, required this.uid}) : super(key: key);

  String? uid;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  //TODO: Dependency Injection**************************************************
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  UserModelController _userModelController = Get.find<UserModelController>();

  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: widget.uid )
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    if (!snapshot.hasData || snapshot.data == null) {}
    else if (snapshot.data!.docs.isNotEmpty) {
      final friendDocs = snapshot.data!.docs;
      return Scaffold(
        body: Stack(
          children: [
            AppBar(
              backgroundColor: Color(0xFF3D83ED),
              leading: GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(top: _statusBarSize - 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/imgs/icons/icon_snowLive_back.png',
                        scale: 4,
                        width: 26,
                        height: 26,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0.0,
              titleSpacing: 0,
              centerTitle: true,
              toolbarHeight: 200.0, // 이 부분은 AppBar의 높이를 조절합니다.
            ),
            Padding(
              padding: EdgeInsets.only(top: 200.0),
              // 이 부분은 AppBar 높이에 따라 조절해야 합니다.
              child: Container(
                color: Colors.white,
                // 필요한 내용을 여기에 작성하세요.
              ),
            ),
            Positioned(
                top: 140,
                left: _size.width/ 4,
                child: Column(
                  children: [
                    (friendDocs[0]['profileImageUrl'].isNotEmpty)
                        ? GestureDetector(
                      onTap: () {},
                      child: Container(
                          width: 120,
                          height: 120,
                          child: ExtendedImage.network(
                            friendDocs[0]['profileImageUrl'],
                            enableMemoryCache: true,
                            shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(8),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )),
                    )
                        : GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 120,
                        height: 120,
                        child: ExtendedImage.asset(
                          'assets/imgs/profile/img_profile_default_circle.png',
                          enableMemoryCache: true,
                          shape: BoxShape.circle,
                          borderRadius: BorderRadius.circular(8),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text('${friendDocs[0]['displayName']}'),
                    Text('${friendDocs[0]['stateMsg']}'),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Column(
                          children: [
                            IconButton(
                                onPressed: (){},
                                iconSize: _size.width/10 ,
                                icon: Image.asset('assets/imgs/icons/icon_edit_profile.png')
                            ),
                            Text('프로필 수정')
                          ],
                        ),
                        SizedBox(
                          width: _size.width/20,
                        ),
                        Column(
                          children: [
                            IconButton(
                                onPressed: (){},
                                iconSize: _size.width/10 ,
                                icon: Image.asset('assets/imgs/icons/icon_liveCrew.png')
                            ),
                            Text('라이브 크루')
                          ],
                        ),

                      ],
                    )

                  ],
                )),
          ],
        ),
      );
    }
    else if (snapshot.connectionState == ConnectionState.waiting) {}
    return Center(
      child: CircularProgressIndicator(),
    );

      },
    );
  }
}
