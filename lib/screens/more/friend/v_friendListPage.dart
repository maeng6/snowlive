import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/more/friend/v_friendDetailPage.dart';
import 'package:snowlive3/screens/more/friend/invitation/v_invitation_Screen_friend.dart';
import 'package:snowlive3/screens/more/friend/v_setting_friendList.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_userModelController.dart';
import 'v_searchUserPage.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({Key? key}) : super(key: key);

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {

  var _alarmStream;
  var _userStream;
  var _friendStream;

  @override
  void initState() {
    // TODO: implement initState
    _alarmStream = alarmStream();
    _userStream = userStream();
    _friendStream = friendStream();

  }

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  Stream<QuerySnapshot> alarmStream() {
    return FirebaseFirestore.instance
        .collection('newAlarm')
        .where('uid', isEqualTo: _userModelController.uid!)
        .snapshots();
  }

  Stream<QuerySnapshot> userStream() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: _userModelController.uid!)
        .snapshots();
  }

  Stream<QuerySnapshot> friendStream() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMe', arrayContains: _userModelController.uid!)
        .orderBy('displayName', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [

          StreamBuilder(
            stream: _alarmStream,
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return  Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () async{
                          CustomFullScreenDialog.showDialog();
                          try {
                            await _userModelController.deleteInvitationAlarm_friend(uid: _userModelController.uid);
                          }catch(e){}
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(()=>InvitationScreen_friend());
                        },
                        icon: Image.asset(
                          'assets/imgs/icons/icon_noti_off.png',
                          scale: 4,
                          width: 26,
                          height: 26,
                        ),
                      ),
                      Positioned(  // draw a red marble
                        top: 10,
                        left: 32,
                        child: new Icon(Icons.brightness_1, size: 6.0,
                            color:Colors.white),
                      )
                    ],
                  ),
                );
              }
              else if (snapshot.data!.docs.isNotEmpty) {
                final alarmDocs = snapshot.data!.docs;
                return  Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () async{
                          CustomFullScreenDialog.showDialog();
                          try {
                            await _userModelController.deleteInvitationAlarm_friend(uid: _userModelController.uid);
                          }catch(e){}
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(()=>InvitationScreen_friend());
                        },
                        icon: Image.asset(
                          'assets/imgs/icons/icon_noti_off.png',
                          scale: 4,
                          width: 26,
                          height: 26,
                        ),
                      ),
                      Positioned(  // draw a red marble
                        top: 10,
                        left: 32,
                        child: new Icon(Icons.brightness_1, size: 6.0,
                            color:
                            (alarmDocs[0]['newInvited_friend'] == true)
                                ?Color(0xFFD32F2F):Colors.white),
                      )
                    ],
                  ),
                );
              }
              else if (snapshot.connectionState == ConnectionState.waiting) {
                return  Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () async{
                          CustomFullScreenDialog.showDialog();
                          try {
                            await _userModelController.deleteInvitationAlarm_friend(uid: _userModelController.uid);
                          }catch(e){}
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(()=>InvitationScreen_friend());
                        },
                        icon: Image.asset(
                          'assets/imgs/icons/icon_noti_off.png',
                          scale: 4,
                          width: 26,
                          height: 26,
                        ),
                      ),
                      Positioned(  // draw a red marble
                        top: 10,
                        left: 32,
                        child: new Icon(Icons.brightness_1, size: 6.0,
                            color:Colors.white),
                      )
                    ],
                  ),
                );
              }
              return  Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: () async{
                        CustomFullScreenDialog.showDialog();
                        try {
                          await _userModelController.deleteInvitationAlarm_friend(uid: _userModelController.uid);
                        }catch(e){}
                        CustomFullScreenDialog.cancelDialog();
                        Get.to(()=>InvitationScreen_friend());
                      },
                      icon: Image.asset(
                        'assets/imgs/icons/icon_noti_off.png',
                        scale: 4,
                        width: 26,
                        height: 26,
                      ),
                    ),
                    Positioned(  // draw a red marble
                      top: 10,
                      left: 32,
                      child: new Icon(Icons.brightness_1, size: 6.0,
                          color:Colors.white),
                    )
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
                onPressed: (){
                  Get.to(()=>Setting_friendList());
                },
                icon: Image.asset(
                  'assets/imgs/icons/icon_settings.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
            ),
          )
        ],
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
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '친구',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: _statusBarSize + 58,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => SearchUserPage());
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xFFEFEFEF),
                  ),
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Color(0xFF666666),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '친구 검색',
                            style:
                                TextStyle(fontSize: 15, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            StreamBuilder(
              stream: _friendStream,
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder(
                      stream: _userStream,
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        try {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Text('즐겨찾는 친구를 등록하면, 홈화면에서'),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text('친구의 라이브 상태를 확인할 수 있어요.'),
                                ],
                              ),
                            );
                          } else if (snapshot.data!.docs.isNotEmpty) {
                            final myDoc = snapshot.data!.docs;
                            Size _size = MediaQuery.of(context).size;
                            return Row(
                              children: myDoc.map((myDoc) {
                                return Expanded(
                                  child: Obx(()=>Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children : [
                                        (myDoc.get('profileImageUrl').isNotEmpty)
                                            ? GestureDetector(
                                              onTap: () {
                                                Get.to(() => FriendDetailPage(
                                                    uid: _userModelController.uid,
                                                  favoriteResort: _userModelController.favoriteResort,));
                                              },
                                              child: Container(
                                                width: 70,
                                                child: Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                            width: 56,
                                                            height: 56,
                                                            child: ExtendedImage.network(_userModelController.profileImageUrl!,
                                                              enableMemoryCache: true,
                                                              shape: BoxShape.circle,
                                                              borderRadius: BorderRadius.circular(8),
                                                              width: 56,
                                                              height: 56,
                                                              fit: BoxFit.cover,
                                                            )),
                                                        (_userModelController.isOnLive == true)
                                                            ? Positioned(
                                                          child: Image.asset('assets/imgs/icons/icon_badge_live.png',
                                                            width: 32,
                                                          ),
                                                          right: 0,
                                                          bottom: 0,
                                                        )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            : GestureDetector(
                                              onTap: () {
                                                Get.to(() => FriendDetailPage(
                                                    uid: _userModelController.uid,
                                                  favoriteResort: _userModelController.favoriteResort,));
                                              },
                                              child: Container(
                                                width: 70,
                                                child: Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          width: 56,
                                                          height: 56,
                                                          child: ExtendedImage.asset(
                                                            'assets/imgs/profile/img_profile_default_circle.png',
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                            width: 56,
                                                            height: 56,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        (_userModelController.isOnLive == true)
                                                            ? Positioned(
                                                          child: Image.asset(
                                                            'assets/imgs/icons/icon_badge_live.png',
                                                            width: 32,
                                                          ),
                                                          right: 0,
                                                          bottom: 0,
                                                        )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        Column(
                                          mainAxisAlignment: _userModelController.displayName == ''
                                              ? MainAxisAlignment.center
                                              : MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_userModelController.displayName!,
                                              style: TextStyle(
                                                color: Color(0xFF111111),
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16),
                                            ),
                                            _userModelController.stateMsg == ''
                                            ? Container()
                                            : Text(
                                                _userModelController.stateMsg!,
                                                style: TextStyle(
                                                  color: Color(0xFF949494),
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                ),
                                              )
                                          ],
                                        ),

                                      ]
                                    ),
                                  )
                                  ),
                                );
                              }).toList(),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {}
                        } catch (e) {
                          Center(
                              child: Container(
                            height: 10,
                            width: 10,
                          ));
                        }
                        return Center(
                            child: Container(
                          height: 10,
                          width: 10,
                        ));
                      },
                    ), //내 프로필
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      child: Divider(
                        height: 1,
                        color: Color(0xFFFDEDEDE),
                      ),
                    ),
                    (friendDocs.isEmpty)
                    ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '친구',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: Color(0xFF949494)),
                            ),
                          ),
                          SizedBox(height: 100,),
                          Center(
                            child: Image.asset('assets/imgs/icons/icon_friend_add.png',
                            width: 72,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              '등록된 친구가 없습니다',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666)),
                            ),
                          ),
                          Center(
                            child: Text(
                              '친구를 검색해 추가해 보세요',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666)),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: OutlinedButton(
                              onPressed: () {
                                Get.to(()=>SearchUserPage());
                              },
                              child: Text('친구 추가하기',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF666666),
                                fontSize: 14
                              ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    width: 1,
                                    color: Color(0xFFDEDEDE)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                                )// 버튼 윤곽선의 색과 두께를 설정
                              ),
                            )
                            ,
                          )
                        ],
                      ),
                    )
                    : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('user')
                                      .where('whoResistMeBF', arrayContains: _userModelController.uid!)
                                      .orderBy('isOnLive', descending: true)
                                      .snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>snapshot) {
                                    try {
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return Container(
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                '즐겨찾는 친구를 등록하면, 홈화면에서',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF666666)),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                '친구의 라이브 상태를 확인할 수 있어요.',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF666666)),
                                              ),

                                            ],
                                          ),
                                        );
                                      } else if (snapshot.data!.docs.isNotEmpty) {
                                        final bestfriendDocs = snapshot.data!.docs;
                                        Size _size = MediaQuery.of(context).size;
                                        return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Text(
                                                    '즐겨찾기 ${bestfriendDocs.length}',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 13,
                                                        color: Color(0xFF949494)),
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 20),
                                                  child: Row(
                                                    children: bestfriendDocs.map((BFdoc) {
                                                      return (BFdoc.get('profileImageUrl').isNotEmpty)
                                                          ? GestureDetector(
                                                        onTap: () {
                                                          Get.to(() => FriendDetailPage(uid: BFdoc.get('uid'), favoriteResort: BFdoc.get('favoriteResort'),));
                                                        },
                                                        child: Container(
                                                          width: 72,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 16),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Stack(fit: StackFit.loose,
                                                                    children: [
                                                                      Container(
                                                                        alignment: Alignment.center,
                                                                        child:
                                                                        BFdoc.get('profileImageUrl').isNotEmpty?
                                                                        ExtendedImage.network(BFdoc.get('profileImageUrl'),
                                                                          enableMemoryCache: true,
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(8),
                                                                          width: 48,
                                                                          height: 48,
                                                                          fit: BoxFit.cover,
                                                                        )
                                                                        :ExtendedImage.asset(
                                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                                          enableMemoryCache: true,
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(8),
                                                                          width: 48,
                                                                          height: 48,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                      (BFdoc.get('isOnLive') == true)
                                                                          ? Positioned(
                                                                        child: Image.asset('assets/imgs/icons/icon_badge_live.png',
                                                                          width: 32,),
                                                                        right: 0,
                                                                        bottom: 0,
                                                                      )
                                                                          : Container()
                                                                    ]),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Container(
                                                                  width: 72,
                                                                  child: Text(BFdoc.get('displayName'),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        fontWeight:
                                                                        FontWeight.normal,
                                                                        color: Color(0xFF111111)),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                          : GestureDetector(
                                                        onTap: () {
                                                          Get.to(() =>
                                                              FriendDetailPage(uid: BFdoc.get('uid'), favoriteResort: BFdoc.get('favoriteResort'),));
                                                        },
                                                        child: Container(
                                                          width: 72,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 16),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Stack(
                                                                  fit: StackFit.loose,
                                                                  children: [
                                                                    Container(
                                                                      alignment: Alignment.center,
                                                                      child: ExtendedImage.asset(
                                                                        'assets/imgs/profile/img_profile_default_circle.png',
                                                                        enableMemoryCache: true,
                                                                        shape: BoxShape.circle,
                                                                        borderRadius: BorderRadius.circular(8),
                                                                        width: 48,
                                                                        height: 48,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                    (BFdoc.get('isOnLive') == true)
                                                                        ? Positioned(
                                                                      child: Image.asset(
                                                                        'assets/imgs/icons/icon_badge_live.png',
                                                                        width: 32,
                                                                      ),
                                                                      right: 0,
                                                                      bottom: 0,
                                                                    )
                                                                        : Container()
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Container(
                                                                    width: 72,
                                                                    child: Text(BFdoc.get('displayName'),
                                                                      textAlign: TextAlign.center,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.normal,
                                                                          color: Color(0xFF111111)),
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ));
                                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return Container(
                                        color: Colors.white,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 22),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '즐겨찾는 친구를 등록하면, 홈화면에서',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF949494)),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  '친구의 라이브 상태를 확인할 수 있어요.',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF949494)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                          ));
                                    }
                                    return Center(
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                        ));
                                  },
                                ),
                              ),
                            ],
                          ), //친한친구
                          Divider(
                            height: 1,
                            color: Color(0xFFFDEDEDE),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '친구 ${friendDocs.length}',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: Color(0xFF949494)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            children: friendDocs.map((doc) {
                              List whoResistMe = doc.get('whoResistMe');
                              List whoResistMeBF = doc.get('whoResistMeBF');
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Row(
                                    children: [
                                      (doc.get('profileImageUrl').isNotEmpty)
                                          ? GestureDetector(
                                        onTap: () {
                                          Get.to(() =>
                                              FriendDetailPage(uid: doc.get('uid'),
                                                favoriteResort: doc.get('favoriteResort'),));
                                        },
                                        child: Container(
                                          width: 56,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Stack(
                                                  fit: StackFit.loose,
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.center,
                                                      child: ExtendedImage.network(
                                                        doc.get('profileImageUrl'),
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.circle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ]),
                                            ],
                                          ),
                                        ),
                                      )
                                          : GestureDetector(
                                        onTap: () {
                                          Get.to(() =>
                                              FriendDetailPage(
                                                uid: doc.get('uid'), favoriteResort: doc.get('favoriteResort'),));
                                        },
                                        child: Container(
                                          width: 56,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Stack(
                                                fit: StackFit.loose,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    child: ExtendedImage.asset('assets/imgs/profile/img_profile_default_circle.png',
                                                      enableMemoryCache:
                                                      true,
                                                      shape: BoxShape.circle,
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                      width: 48,
                                                      height: 48,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  (doc.get('isOnLive') == true)
                                                      ? Positioned(
                                                    child: Image.asset(
                                                      'assets/imgs/icons/icon_badge_live.png',
                                                      width: 32,
                                                    ),
                                                    right: 0,
                                                    bottom: 0,
                                                  )
                                                      : Container()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Column(
                                          mainAxisAlignment: doc.get('stateMsg') == ''
                                              ? MainAxisAlignment.center
                                              : MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(doc.get('displayName'),
                                              style: TextStyle(
                                                  color: Color(0xFF111111),
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 15),
                                            ),
                                            if (doc.get('stateMsg') == '')
                                              SizedBox(height: 0)
                                            else
                                              Text(
                                                '${doc.get('stateMsg')}',
                                                style: TextStyle(
                                                    color: Color(0xFF949494),
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 13),
                                              ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                  (whoResistMeBF.contains(_userModelController.uid))
                                      ? Container(
                                    width: 56,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              List whoResistMeBF =
                                              doc.get('whoResistMeBF');
                                              HapticFeedback.lightImpact();
                                              if (whoResistMeBF.contains(_userModelController.uid)) {
                                                await _userModelController.deleteWhoResistMeBF(
                                                    friendUid: doc.get('uid'));
                                                print('친한친구 삭제완료!');
                                              } else {
                                                await _userModelController.updateWhoResistMeBF(
                                                    friendUid: doc.get('uid'));
                                                print('친한친구 등록완료!');
                                              }
                                            },
                                            child: Icon(
                                              Icons.star_rounded,
                                              color: Color(0xFFFDAF04),
                                            )),
                                        GestureDetector(
                                          onTap: () => showModalBottomSheet(
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return SafeArea(
                                                  child: Container(
                                                      height: 120,
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                        child: Column(
                                                          children: [
                                                            GestureDetector(
                                                                onTap: () {
                                                                  Get.dialog(
                                                                      AlertDialog(
                                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                        elevation: 0,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(10.0)),
                                                                        buttonPadding: EdgeInsets.symmetric(
                                                                            horizontal: 20,
                                                                            vertical: 0),
                                                                        content:
                                                                        Text(
                                                                          '친구목록에서 삭제하시겠습니까?',
                                                                          style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight.w600,
                                                                              fontSize: 15),
                                                                        ),
                                                                        actions: [
                                                                          Row(
                                                                            children: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                    Get.back();
                                                                                  },
                                                                                  child: Text(
                                                                                    '취소',
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF949494),
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  )),
                                                                              TextButton(
                                                                                  onPressed: () async {
                                                                                    CustomFullScreenDialog.showDialog();
                                                                                    await _userModelController.deleteFriend(friendUid: doc.get('uid'));
                                                                                    await _userModelController.getCurrentUser(_userModelController.uid);
                                                                                    Navigator.pop(context);
                                                                                    Navigator.pop(context);
                                                                                    CustomFullScreenDialog.cancelDialog();
                                                                                  },
                                                                                  child: Text(
                                                                                    '확인',
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF3D83ED),
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ))
                                                                            ],
                                                                            mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                          )
                                                                        ],
                                                                      ));
                                                                },
                                                                child: Center(
                                                                  child:
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                        24),
                                                                    child:
                                                                    Text(
                                                                      '친구 삭제',
                                                                      style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                        15,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                        color: Color(0xFFD63636)
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      )),
                                                );
                                              }),
                                          child: Icon(
                                            Icons.more_vert,
                                            color: Color(0xFFdedede),
                                            size: 24,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                      : Container(
                                    width: 56,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              List whoResistMeBF =
                                              doc.get('whoResistMeBF');
                                              HapticFeedback.lightImpact();
                                              if (whoResistMeBF.contains(
                                                  _userModelController.uid)) {
                                                await _userModelController.deleteWhoResistMeBF(
                                                    friendUid: doc.get('uid'));
                                                print('친한친구 삭제완료!');
                                              } else {
                                                await _userModelController.updateWhoResistMeBF(
                                                    friendUid: doc.get('uid'));
                                                print('친한친구 등록완료!');
                                              }
                                            },
                                            child: Icon(
                                              Icons.star_rounded,
                                              color: Color(0xFFdedede),
                                            )),
                                        GestureDetector(
                                          onTap: () => showModalBottomSheet(
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return SafeArea(
                                                  child: Container(
                                                      height: 120,
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 20.0,
                                                            vertical: 14),
                                                        child: Column(
                                                          children: [
                                                            GestureDetector(
                                                                onTap: () {
                                                                  Get.dialog(
                                                                      AlertDialog(
                                                                        contentPadding: EdgeInsets.only(
                                                                            bottom: 0,
                                                                            left: 20,
                                                                            right: 20,
                                                                            top: 30),
                                                                        elevation: 0,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                            BorderRadius.circular(10.0)),
                                                                        buttonPadding: EdgeInsets.symmetric(
                                                                            horizontal: 20,
                                                                            vertical: 0),
                                                                        content:
                                                                        Text(
                                                                          '친구목록에서 삭제하시겠습니까?',
                                                                          style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight.w600,
                                                                              fontSize: 15),
                                                                        ),
                                                                        actions: [
                                                                          Row(
                                                                            children: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text(
                                                                                    '취소',
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF949494),
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  )),
                                                                              TextButton(
                                                                                  onPressed: () async {
                                                                                    CustomFullScreenDialog.showDialog();
                                                                                    await _userModelController.deleteFriend(friendUid: doc.get('uid'));
                                                                                    await _userModelController.getCurrentUser(_userModelController.uid);
                                                                                    Navigator.pop(context);
                                                                                    Navigator.pop(context);
                                                                                    CustomFullScreenDialog.cancelDialog();
                                                                                  },
                                                                                  child: Text(
                                                                                    '확인',
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF3D83ED),
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ))
                                                                            ],
                                                                            mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                          )
                                                                        ],
                                                                      ));
                                                                },
                                                                child: Center(
                                                                  child:
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        top: 24),
                                                                    child: Text(
                                                                      '친구 삭제',
                                                                      style: TextStyle(
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                        color: Color(0xFFD63636)
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      )),
                                                );
                                              }),
                                          child: Icon(
                                            Icons.more_vert,
                                            color: Color(0xFFdedede),
                                            size: 24,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ), //친구목록
                        ],
                      ),
                    ),

                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
