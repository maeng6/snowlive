import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_userModelController.dart';
import '../../controller/vm_liveCrewModelController.dart';
import '../more/friend/v_friendDetailPage.dart';

class CrewDetailPage_member extends StatefulWidget {
   CrewDetailPage_member({Key? key }) : super(key: key);

   @override
  State<CrewDetailPage_member> createState() => _CrewDetailPage_memberState();
}

class _CrewDetailPage_memberState extends State<CrewDetailPage_member> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************


  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('user')
                .where('liveCrew', isEqualTo: _liveCrewModelController.crewID)
                .orderBy('displayName', descending: false)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Container();
              } else if (snapshot.data!.docs.isNotEmpty) {
                final crewMemberDocs = snapshot.data!.docs;

                // leader 정보를 찾는 로직 추가
                DocumentSnapshot<Map<String, dynamic>>? leaderDoc;
                for (var doc in crewMemberDocs) {
                  if (doc.id == _liveCrewModelController.leaderUid) {
                    leaderDoc = doc;
                    break;
                  }
                }

                if (leaderDoc == null) {
                  // 리더 정보를 찾지 못했을 때의 처리
                  return Container();
                }

                // leader 정보를 가진 leaderDoc를 이용한 로직 수행
                String leaderProfileImage = leaderDoc.data()!['profileImageUrl'];
                String leaderName = leaderDoc.data()!['displayName'];
                String leaderUid = leaderDoc.data()!['uid'];
                String leaderMsg = leaderDoc.data()!['stateMsg'];
                int leaderFavoriteResort = leaderDoc.data()!['favoriteResort'];

                _userModelController.getCurrentUser(_userModelController.uid);

                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('크루장',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF949494)
                      ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        width: _size.width,
                        child: Row(
                          children: [
                            (leaderProfileImage.isNotEmpty)
                                ? GestureDetector(
                              onTap: () {
                                Get.to(() => FriendDetailPage(uid: leaderUid, favoriteResort: leaderFavoriteResort,));
                              },
                              child: Container(
                                  width: 50,
                                  height: 50,
                                  child: ExtendedImage.network(
                                    leaderProfileImage,
                                    enableMemoryCache: true,
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(8),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    loadStateChanged: (ExtendedImageState state) {
                                      switch (state.extendedImageLoadState) {
                                        case LoadState.loading:
                                          return SizedBox.shrink();
                                        case LoadState.completed:
                                          return state.completedWidget;
                                        case LoadState.failed:
                                          return ExtendedImage.asset(
                                            'assets/imgs/profile/img_profile_default_circle.png',
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                        default:
                                          return null;
                                      }
                                    },
                                  )),
                            )
                                : GestureDetector(
                              onTap: () {
                                Get.to(() => FriendDetailPage(uid: leaderUid, favoriteResort: leaderFavoriteResort,));
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                child: ExtendedImage.asset(
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
                            SizedBox(width: 15,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(leaderName,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF111111)
                                ),
                                ),
                                if(leaderMsg.isNotEmpty)
                                Text(leaderMsg,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF949494)
                                ),
                                )
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            if(_userModelController.uid != leaderUid && !_userModelController.friendUidList!.contains(leaderUid))
                            ElevatedButton(
                              onPressed: (){
                                Get.dialog(AlertDialog(
                                  contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                  content: Text(
                                    '$leaderName 님에게 친구요청을 보내시겠습니까?',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                                              try{
                                                await _userModelController.getCurrentUser(_userModelController.uid);
                                                if(_userModelController.whoIinvite!.contains(leaderUid)){
                                                  Get.dialog(AlertDialog(
                                                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                    buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                    content: Text('이미 요청중인 회원입니다.',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,
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
                                                              child: Text('확인',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(0xFF949494),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              )),
                                                        ],
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                      )
                                                    ],
                                                  ));
                                                }else if(_userModelController.friendUidList!.contains(leaderUid)){
                                                  Get.dialog(AlertDialog(
                                                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0)),
                                                    buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                    content: Text('이미 추가된 친구입니다.',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,
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
                                                              child: Text('확인',
                                                                style: TextStyle(fontSize: 15,
                                                                  color: Color(0xFF949494),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              )),
                                                        ],
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                      )
                                                    ],
                                                  ));
                                                } else{
                                                  CustomFullScreenDialog.showDialog();
                                                  await _userModelController.updateInvitation(friendUid: leaderUid);
                                                  await _userModelController.getCurrentUser(_userModelController.uid);
                                                  Navigator.pop(context);
                                                  CustomFullScreenDialog.cancelDialog();
                                                }
                                              }catch(e){
                                                Navigator.pop(context);
                                              }
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
                                      mainAxisAlignment: MainAxisAlignment.end,
                                    )
                                  ],
                                ));
                              }, child: Text('친구추가',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF949494)),),
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
                                  backgroundColor: Color(0xFFffffff),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide(
                                      color: Color(0xFFDEDEDE))
                              ),),
                            if(_userModelController.uid == leaderUid || _userModelController.friendUidList!.contains(leaderUid))
                            SizedBox.shrink()
                          ],
                        ),
                      ),
                      Divider(
                        color: Color(0xFFDEDEDE),
                        height: 24,
                        thickness: 0.5,
                      ),
                      SizedBox(height: 5,),
                      Text('크루원 ${crewMemberDocs.length -1}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF949494)
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        width : _size.width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: crewMemberDocs.length,
                          itemBuilder: (BuildContext context, int index) {
                            if(crewMemberDocs[index]['uid'] != leaderUid){
                              return Column(
                                children: [
                                  Container(
                                    width: _size.width,
                                    child: Row(
                                      children: [
                                        (crewMemberDocs[index]['profileImageUrl'].isNotEmpty)
                                            ? GestureDetector(
                                          onTap: () {
                                            Get.to(() => FriendDetailPage(uid: crewMemberDocs[index]['uid'], favoriteResort: crewMemberDocs[index]['favoriteResort'],));
                                          },
                                          child: Container(
                                              width: 50,
                                              height: 50,
                                              child: ExtendedImage.network(
                                                crewMemberDocs[index]['profileImageUrl'],
                                                enableMemoryCache: true,
                                                shape: BoxShape.circle,
                                                borderRadius: BorderRadius.circular(8),
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                loadStateChanged: (ExtendedImageState state) {
                                                  switch (state.extendedImageLoadState) {
                                                    case LoadState.loading:
                                                      return SizedBox.shrink();
                                                    case LoadState.completed:
                                                      return state.completedWidget;
                                                    case LoadState.failed:
                                                      return ExtendedImage.asset(
                                                        'assets/imgs/profile/img_profile_default_circle.png',
                                                        shape: BoxShape.circle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                    default:
                                                      return null;
                                                  }
                                                },
                                              )),
                                        )
                                            : GestureDetector(
                                          onTap: () {
                                            Get.to(() => FriendDetailPage(uid: crewMemberDocs[index]['uid'], favoriteResort: crewMemberDocs[index]['favoriteResort'],));
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            child: ExtendedImage.asset(
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
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(crewMemberDocs[index]['displayName'],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF111111)
                                              ),
                                            ),
                                            if(crewMemberDocs[index]['stateMsg'].isNotEmpty)
                                              Text(crewMemberDocs[index]['stateMsg'],
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF949494)
                                                ),
                                              )
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        (_liveCrewModelController.leaderUid == _userModelController.uid)
                                            ?
                                        ( _userModelController.uid != crewMemberDocs[index]['uid'])
                                            ?
                                        (_userModelController.friendUidList!.contains(crewMemberDocs[index]['uid']))
                                            ? ElevatedButton(
                                          onPressed: (){
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    color: Colors.white,
                                                    height: 180,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            height: 30,
                                                          ),
                                                          Text(
                                                            '${crewMemberDocs[index]['displayName']}님을 크루에서 내보내시겠습니까?',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF111111)),
                                                          ),
                                                          SizedBox(
                                                            height: 30,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: Text(
                                                                    '취소',
                                                                    style: TextStyle(
                                                                        color: Color(0xFF3D83ED),
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.bold),
                                                                  ),
                                                                  style: TextButton.styleFrom(
                                                                      splashFactory: InkRipple.splashFactory,
                                                                      elevation: 0,
                                                                      minimumSize: Size(100, 56),
                                                                      backgroundColor: Color(0xff3D83ED).withOpacity(0.2),
                                                                      padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                  onPressed: () async {
                                                                    try{
                                                                      Navigator.pop(context);
                                                                      CustomFullScreenDialog.showDialog();
                                                                      await _liveCrewModelController.deleteCrewMember(
                                                                          crewID: _liveCrewModelController.crewID,
                                                                          memberUid: crewMemberDocs[index]['uid']
                                                                      );
                                                                      CustomFullScreenDialog.cancelDialog();
                                                                    }catch(e){
                                                                      Navigator.pop(context);
                                                                    }
                                                                  },
                                                                  child: Text(
                                                                    '확인',
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.bold),
                                                                  ),
                                                                  style: TextButton.styleFrom(
                                                                      splashFactory: InkRipple.splashFactory,
                                                                      elevation: 0,
                                                                      minimumSize: Size(100, 56),
                                                                      backgroundColor: Color(0xff3D83ED),
                                                                      padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          }, child: Text('내보내기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF949494)),),
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
                                              backgroundColor: Color(0xFFffffff),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8)),
                                              side: BorderSide(
                                                  color: Color(0xFFDEDEDE))
                                          ),)
                                            : SizedBox(
                                          child: Row(children: [
                                            ElevatedButton(
                                              onPressed: (){
                                                Get.dialog(AlertDialog(
                                                  contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                  content: Text(
                                                    '${crewMemberDocs[index]['displayName']}님에게 친구요청을 보내시겠습니까?',
                                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                                                              try{
                                                                await _userModelController.getCurrentUser(_userModelController.uid);
                                                                if(_userModelController.whoIinvite!.contains(crewMemberDocs[index]['uid'])){
                                                                  Get.dialog(AlertDialog(
                                                                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                    elevation: 0,
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                                    buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                    content: Text('이미 요청중인 회원입니다.',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.w600,
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
                                                                              child: Text('확인',
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Color(0xFF949494),
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              )),
                                                                        ],
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                      )
                                                                    ],
                                                                  ));
                                                                }else if(_userModelController.friendUidList!.contains(crewMemberDocs[index]['uid'])){
                                                                  Get.dialog(AlertDialog(
                                                                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                    elevation: 0,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(10.0)),
                                                                    buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                    content: Text('이미 추가된 친구입니다.',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.w600,
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
                                                                              child: Text('확인',
                                                                                style: TextStyle(fontSize: 15,
                                                                                  color: Color(0xFF949494),
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              )),
                                                                        ],
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                      )
                                                                    ],
                                                                  ));
                                                                } else{

                                                                  CustomFullScreenDialog.showDialog();
                                                                  await _userModelController.updateInvitation(friendUid: crewMemberDocs[index]['uid']);
                                                                  await _userModelController.updateInvitationAlarm(friendUid:crewMemberDocs[index]['uid']);
                                                                  await _userModelController.getCurrentUser(_userModelController.uid);
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.cancelDialog();

                                                                }
                                                              }catch(e){
                                                                Navigator.pop(context);
                                                              }
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
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                    )
                                                  ],
                                                ));
                                              }, child: Text('친구추가',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Color(0xFF949494)),),
                                              style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
                                                  backgroundColor: Color(0xFFffffff),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                  side: BorderSide(
                                                      color: Color(0xFFDEDEDE))
                                              ),), //친추
                                            SizedBox(width: 8,),
                                            ElevatedButton(
                                              onPressed: (){
                                                showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) {
                                                      return Container(
                                                        color: Colors.white,
                                                        height: 180,
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              Text(
                                                                '${crewMemberDocs[index]['displayName']}님을 크루에서 내보내시겠습니까?',
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  Expanded(
                                                                    child: ElevatedButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text(
                                                                        '취소',
                                                                        style: TextStyle(
                                                                            color: Color(0xFF3D83ED),
                                                                            fontSize: 15,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                      style: TextButton.styleFrom(
                                                                          splashFactory: InkRipple.splashFactory,
                                                                          elevation: 0,
                                                                          minimumSize: Size(100, 56),
                                                                          backgroundColor: Color(0xff3D83ED).withOpacity(0.2),
                                                                          padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: ElevatedButton(
                                                                      onPressed: () async {
                                                                        try{
                                                                          Navigator.pop(context);
                                                                          CustomFullScreenDialog.showDialog();
                                                                          await _liveCrewModelController.deleteCrewMember(
                                                                              crewID: _liveCrewModelController.crewID,
                                                                              memberUid: crewMemberDocs[index]['uid']
                                                                          );
                                                                          CustomFullScreenDialog.cancelDialog();
                                                                        }catch(e){
                                                                          Navigator.pop(context);
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                        '확인',
                                                                        style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: 15,
                                                                            fontWeight:
                                                                            FontWeight.bold),
                                                                      ),
                                                                      style: TextButton.styleFrom(
                                                                          splashFactory: InkRipple.splashFactory,
                                                                          elevation: 0,
                                                                          minimumSize: Size(100, 56),
                                                                          backgroundColor: Color(0xff2C97FB),
                                                                          padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              }, child: Text('내보내기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF949494)),),
                                              style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
                                                  backgroundColor: Color(0xFFffffff),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                  side: BorderSide(
                                                      color: Color(0xFFDEDEDE))
                                              ),) //내보내기
                                          ],
                                          ),
                                        )
                                            :SizedBox(child: Container())
                                            :
                                        (_userModelController.friendUidList!.contains(crewMemberDocs[index]['uid']) || _userModelController.uid == crewMemberDocs[index]['uid'])
                                            ? SizedBox(child: Container())
                                            :ElevatedButton(
                                          onPressed: (){
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              content: Text(
                                                '${crewMemberDocs[index]['displayName']}님에게 친구요청을 보내시겠습니까?',
                                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                                                          try{
                                                            await _userModelController.getCurrentUser(_userModelController.uid);
                                                            if(_userModelController.whoIinvite!.contains(crewMemberDocs[index]['uid'])){
                                                              Get.dialog(AlertDialog(
                                                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                elevation: 0,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                content: Text('이미 요청중인 회원입니다.',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
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
                                                                          child: Text('확인',
                                                                            style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: Color(0xFF949494),
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          )),
                                                                    ],
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                  )
                                                                ],
                                                              ));
                                                            }else if(_userModelController.friendUidList!.contains(crewMemberDocs[index]['uid'])){
                                                              Get.dialog(AlertDialog(
                                                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                elevation: 0,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(10.0)),
                                                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                content: Text('이미 추가된 친구입니다.',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
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
                                                                          child: Text('확인',
                                                                            style: TextStyle(fontSize: 15,
                                                                              color: Color(0xFF949494),
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          )),
                                                                    ],
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                  )
                                                                ],
                                                              ));
                                                            } else{
                                                              CustomFullScreenDialog.showDialog();
                                                              await _userModelController.updateInvitation(friendUid: crewMemberDocs[index]['uid']);
                                                              await _userModelController.getCurrentUser(_userModelController.uid);
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.cancelDialog();
                                                            }
                                                          }catch(e){
                                                            Navigator.pop(context);
                                                          }
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
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                )
                                              ],
                                            ));
                                          }, child: Text('친구추가',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF949494)),),
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
                                              backgroundColor: Color(0xFFffffff),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8)),
                                              side: BorderSide(
                                                  color: Color(0xFFDEDEDE))
                                          ),) //친추
                                      ],
                                    ),
                                  ),
                                  if (index != crewMemberDocs.length - 1)
                                    SizedBox(height: 15,)
                                ],
                              );
                            }else if(crewMemberDocs.isEmpty || crewMemberDocs == null || crewMemberDocs.length ==1){
                             return Container(
                               height: _size.height - 400,
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Center(
                                     child: Image.asset('assets/imgs/icons/icon_no_member.png',
                                       width: 100,
                                     ),
                                   ),
                                   SizedBox(height: 12),
                                   Center(
                                     child: Padding(
                                       padding: const EdgeInsets.only(bottom: 50),
                                       child: Text(
                                         '가입된 크루원이 없습니다',
                                         style: TextStyle(
                                             fontSize: 14,
                                             color: Color(0xFF666666)),
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             );
                            } return SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Container();
            },
          )


        ],
      ),
    );
  }
}
