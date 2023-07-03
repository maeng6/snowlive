import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
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
    return Column(
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
              return Expanded(
                child: ListView.builder(
                  itemCount: crewMemberDocs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Container(
                          height: 64,
                          child: Center(
                            child: ListTile(
                              leading:  (crewMemberDocs[index]['profileImageUrl'].isNotEmpty)
                                  ? GestureDetector(
                                onTap: () {
                                  Get.to(() => FriendDetailPage(uid: crewMemberDocs[index]['uid']));
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
                                    )),
                              )
                                  : GestureDetector(
                                onTap: () {
                                  Get.to(() => FriendDetailPage(uid: crewMemberDocs[index]['uid']));
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              onTap: () {},
                              title: Text(
                                crewMemberDocs[index]['displayName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              trailing:
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
                                }, child: Text('내보내기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFffffff),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    side: BorderSide(
                                        color: Color(0xFFDEDEDE))
                                ),)
                              : SizedBox(
                                width: 200,
                                height: 50,
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
                                      }, child: Text('친구추가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFffffff),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)),
                                          side: BorderSide(
                                              color: Color(0xFFDEDEDE))
                                      ),), //친추
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
                                      }, child: Text('내보내기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                                      style: ElevatedButton.styleFrom(
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
                              :SizedBox(height: 10, width: 10, child: Container())
                                  :
                              (_userModelController.friendUidList!.contains(crewMemberDocs[index]['uid']) || _userModelController.uid == crewMemberDocs[index]['uid'])
                              ? SizedBox(height: 10, width: 10, child: Container())
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
                                }, child: Text('친구추가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFffffff),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    side: BorderSide(
                                        color: Color(0xFFDEDEDE))
                                ),) //친추
                            ),
                          ),
                        ),
                        if (index != crewMemberDocs.length - 1)
                          Container(
                            color: Color(0xFFF5F5F5),
                            height: 1,
                            width: _size.width -32,
                          )
                      ],
                    );
                  },
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
    );
  }
}
