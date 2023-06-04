import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_timeStampController.dart';
import 'package:snowlive3/screens/more/v_noticeDetailPage.dart';
import 'package:snowlive3/screens/more/v_setProfileImage_moreTab.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

import '../../../controller/vm_userModelController.dart';
import 'v_searchUserPage.dart';


class FriendListPage extends StatefulWidget {
  const FriendListPage({Key? key}) : super(key: key);

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {

  //TODO: Dependency Injection**************************************************
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text('친구',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(height:_statusBarSize+58 ,),
            GestureDetector(
              onTap: (){
                Get.to(()=>SearchUserPage());
              },
              child: Container(
                height: 50,
                color: Color(0xFFEFEFEF),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('친구 검색',
                        style: TextStyle(
                          color: Colors.grey
                        ),),
                      Icon(Icons.search,color: Colors.grey,)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('whoResistMe', arrayContains: _userModelController.uid!)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: Colors.white,
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final friendDocs = snapshot.data!.docs;
                Size _size = MediaQuery.of(context).size;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    ListTile(
                      onTap: (){},
                      leading: (_userModelController.profileImageUrl!.isNotEmpty)
                          ? GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 52,
                          height: 52,
                          child: ExtendedImage.network(
                                _userModelController.profileImageUrl!,
                                enableMemoryCache: true,
                            shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(8),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )

                        ),
                      )
                          : GestureDetector(
                        onTap: () => Get.to(() => SetProfileImage_moreTab()),
                        child: Container(
                          width: 52,
                          height: 52,
                          child:  ExtendedImage.asset(
                            'assets/imgs/profile/img_profile_default_circle.png',
                            enableMemoryCache: true,
                            shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(8),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        _userModelController.displayName!,
                        style: TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      subtitle: Text(
                        '상태메세지 내용',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w300,
                            fontSize: 15),
                      ),
                    ), //내 프로필
                      Divider(
                        height: 3,
                        color: Color(0xFFFDEDEDE),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('친한친구',),
                          SizedBox(height: 20,),
                          Container(
                            height: 80,
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('user')
                                  .where('whoResistMeBF', arrayContains: _userModelController.uid!)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {

                                if (!snapshot.hasData || snapshot.data == null){
                                  return Container(
                                    color: Colors.white,
                                    child: Text('친한친구를 등록해주세요.'),
                                  );
                                }
                                  else if (snapshot.data!.docs.isNotEmpty) {

                                  final bestfriendDocs = snapshot.data!.docs;
                                  Size _size = MediaQuery.of(context).size;
                                  return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: bestfriendDocs.map((BFdoc) {
                                          return (BFdoc.get('profileImageUrl').isNotEmpty)
                                              ? GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: 102,
                                              height: 82,
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    children : [
                                                      ExtendedImage.network(
                                                        BFdoc.get('profileImageUrl'),
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.circle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      (BFdoc.get('isOnLive') == true)
                                                          ? Positioned(
                                                        child: Text('live'),
                                                        right: 0,
                                                        top: 20,
                                                      )
                                                          : Text('')
                                                    ]
                                                  ),
                                                  Text(BFdoc.get('displayName'))
                                                ],
                                              ),
                                            ),
                                          )
                                              : GestureDetector(
                                            onTap: (){},
                                            child: Container(
                                              width: 102,
                                              height: 82,
                                              child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            ExtendedImage.asset(
                                                              'assets/imgs/profile/img_profile_default_circle.png',
                                                              enableMemoryCache: true,
                                                              shape: BoxShape.circle,
                                                              borderRadius: BorderRadius.circular(8),
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit.cover,
                                                            ),

                                                            (BFdoc.get('isOnLive') == true)
                                                                ? Positioned(
                                                              child: Text('live'),
                                                              right: 0,
                                                              top: 20,
                                                            )
                                                                : Text('')
                                                          ],
                                                        ),
                                                        Text(BFdoc.get('displayName'))
                                                ],
                                              ),

                                            ),
                                          );
                                        }).toList(),
                                      )
                                  );
                                } else if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Container(
                                  color: Colors.white,
                                  child: Text('친한친구를 등록해주세요.',
                                  style: TextStyle(color: Colors.grey),),
                                );
                              },
                            ),
                          ),
                        ],
                      ), //친한친구
                      Divider(
                        height: 3,
                        color: Color(0xFFFDEDEDE),
                      ),
                      Column(
                        children: friendDocs.map((doc) {
                          List whoResistMe = doc.get('whoResistMe');
                          List whoResistMeBF = doc.get('whoResistMeBF');
                          return ListTile(
                            onTap: () async{
                              },
                            leading: (doc.get('profileImageUrl').isNotEmpty)
                                ? GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 52,
                                height: 52,
                                child:  ExtendedImage.network(
                                  doc.get('profileImageUrl'),
                                  enableMemoryCache: true,
                                  shape: BoxShape
                                      .circle,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      8),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),

                              ),
                            )
                                : GestureDetector(
                              onTap: (){},
                              child: Container(
                                width: 52,
                                height: 52,
                                child:  ExtendedImage.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  enableMemoryCache: true,
                                  shape: BoxShape.circle,
                                  borderRadius: BorderRadius.circular(8),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              doc.get('displayName'),
                              style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            subtitle: Text(
                              '상태메세지 내용',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15),
                            ),
                            trailing: (whoResistMeBF.contains(_userModelController.uid))
                                ? Container(
                              width: 50,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                      onTap: () async{
                                        List whoResistMeBF = doc.get('whoResistMeBF');
                                        HapticFeedback.lightImpact();
                                        if(whoResistMeBF.contains(_userModelController.uid)){
                                          await _userModelController.deleteWhoResistMeBF(friendUid: doc.get('uid'));
                                          print('친한친구 삭제완료!');
                                        } else {
                                          await _userModelController.updateWhoResistMeBF(
                                              friendUid: doc.get('uid'));
                                          print('친한친구 등록완료!');
                                        }
                                      },
                                      child: Icon(Icons.star)),
                                      GestureDetector(
                                        onTap: () => showModalBottomSheet(
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return Padding(
                                                padding: EdgeInsets.only(top:50),
                                                child: Container(
                                                  height: 200,
                                                  child: GestureDetector(
                                                      onTap: (){
                                                        Get.dialog(AlertDialog(
                                                          contentPadding: EdgeInsets.only(
                                                              bottom: 0,
                                                              left: 20,
                                                              right: 20,
                                                              top: 30),
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0)),
                                                          buttonPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 0),
                                                          content: Text(
                                                            '친구목록에서 삭제하시겠습니까?',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 15),
                                                          ),
                                                          actions: [
                                                            Row(
                                                              children: [
                                                                TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      '취소',
                                                                      style: TextStyle(
                                                                        fontSize: 15,
                                                                        color: Color(
                                                                            0xFF949494),
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    )),
                                                                TextButton(
                                                                    onPressed: () async {
                                                                      CustomFullScreenDialog.showDialog();
                                                                      await _userModelController.deleteWhoResistMe(friendUid: doc.get('uid'));
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);
                                                                      CustomFullScreenDialog.cancelDialog();
                                                                    },
                                                                    child: Text(
                                                                      '확인',
                                                                      style: TextStyle(
                                                                        fontSize: 15,
                                                                        color: Color(
                                                                            0xFF3D83ED),
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ))
                                                              ],
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.end,
                                                            )
                                                          ],
                                                        ));
                                                      },
                                                      child: Text('친구 삭제'))

                                                ),
                                              );
                                            }),
                                        child: Icon(
                                          Icons.more_vert_rounded,
                                          size: 26,
                                          color: Color(0xFF111111),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                                : Container(
                              width: 50,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                      onTap: () async{
                                        List whoResistMeBF = doc.get('whoResistMeBF');
                                        HapticFeedback.lightImpact();
                                        if(whoResistMeBF.contains(_userModelController.uid)){
                                          await _userModelController.deleteWhoResistMeBF(friendUid: doc.get('uid'));
                                          print('친한친구 삭제완료!');
                                        } else {
                                          await _userModelController.updateWhoResistMeBF(
                                              friendUid: doc.get('uid'));
                                          print('친한친구 등록완료!');
                                        }
                                      },
                                      child: Icon(Icons.star_border)),
                                      GestureDetector(
                                        onTap: () => showModalBottomSheet(
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return Padding(
                                                padding: EdgeInsets.only(top:50),
                                                child: Container(
                                                    height: 200,
                                                    child: GestureDetector(
                                                        onTap: (){
                                                          Get.dialog(AlertDialog(
                                                            contentPadding: EdgeInsets.only(
                                                                bottom: 0,
                                                                left: 20,
                                                                right: 20,
                                                                top: 30),
                                                            elevation: 0,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    10.0)),
                                                            buttonPadding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 20,
                                                                vertical: 0),
                                                            content: Text(
                                                              '친구목록에서 삭제하시겠습니까?',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 15),
                                                            ),
                                                            actions: [
                                                              Row(
                                                                children: [
                                                                  TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                        '취소',
                                                                        style: TextStyle(
                                                                          fontSize: 15,
                                                                          color: Color(
                                                                              0xFF949494),
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                        ),
                                                                      )),
                                                                  TextButton(
                                                                      onPressed: () async {
                                                                        CustomFullScreenDialog.showDialog();
                                                                        await _userModelController.deleteWhoResistMe(friendUid: doc.get('uid'));
                                                                        Navigator.pop(context);
                                                                        Navigator.pop(context);
                                                                        CustomFullScreenDialog.cancelDialog();
                                                                      },
                                                                      child: Text(
                                                                        '확인',
                                                                        style: TextStyle(
                                                                          fontSize: 15,
                                                                          color: Color(
                                                                              0xFF3D83ED),
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                        ),
                                                                      ))
                                                                ],
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.end,
                                                              )
                                                            ],
                                                          ));
                                                        },
                                                        child: Text('친구 삭제'))

                                                ),
                                              );
                                            }),
                                        child: Icon(
                                          Icons.more_vert_rounded,
                                          size: 26,
                                          color: Color(0xFF111111),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                          );
                        }).toList(),
                      ), //친구목록
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
