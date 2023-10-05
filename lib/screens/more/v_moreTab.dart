import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/screens/more/friend/v_snowliveDetailPage.dart';
import 'package:com.snowlive/screens/more/v_eventPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/screens/LiveCrew/v_liveCrewHome.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import 'package:com.snowlive/screens/more/v_contactUsPage.dart';
import 'package:com.snowlive/screens/more/v_favoriteResort_moreTab.dart';
import 'package:com.snowlive/screens/more/friend/v_friendListPage.dart';
import 'package:com.snowlive/screens/more/v_licenseListPage.dart';
import 'package:com.snowlive/screens/more/v_noticeListPage.dart';
import 'package:com.snowlive/screens/more/v_resortTab.dart';
import 'package:com.snowlive/screens/more/v_setProfileImage_moreTab.dart';
import 'package:com.snowlive/screens/more/v_setting_moreTab.dart';
import 'package:com.snowlive/screens/v_webPage.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../controller/vm_liveCrewModelController.dart';
import '../../controller/vm_noticeController.dart';
import '../../controller/vm_userModelController.dart';
import '../LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';
import '../bulletin/v_bulletin_Screen.dart';
import '../fleaMarket/v_fleaMarket_Screen.dart';

class MoreTab extends StatefulWidget {
  MoreTab({Key? key}) : super(key: key);

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  TextEditingController _textEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection************************************************
    Get.put(NoticeController(), permanent: true);
    NoticeController _noticeController = Get.find<NoticeController>();
    //TODO: Dependency Injection************************************************

    _noticeController.getIsNewNotice();

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '',
                style: GoogleFonts.notoSans(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w900,
                    fontSize: 23),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: ListView(
            children: [
              SizedBox(
                height: 24,
              ),
              Obx(
                () => GestureDetector(
                  onTap: (){
                    (_userModelController.displayName == 'SNOWLIVE')
                    ? Get.to(SnowliveDetailPage())
                    : Get.to(FriendDetailPage(uid: _userModelController.uid, favoriteResort: _userModelController.favoriteResort));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Color(0xFFF1F1F3),
                      ),
                      width: _size.width - 32,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                (_userModelController.profileImageUrl!.isNotEmpty)
                                    ? Stack(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          child: Container(
                                              width: _size.width/5,
                                              height: _size.width/5,
                                              child: ExtendedImage.network(
                                                '${_userModelController.profileImageUrl}',
                                                enableMemoryCache: true,
                                                shape: BoxShape.circle,
                                                borderRadius: BorderRadius.circular(8),
                                                width: _size.width/5,
                                                height: _size.width/5,
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                      ],
                                    )
                                    : Stack(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
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
                                      ],
                                    ),
                              ],
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              width: _size.width - 144,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _userModelController.displayName!,
                                        style: TextStyle(
                                            color: Color(0xFF111111),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      // SizedBox(
                                      //   width: 2,
                                      // ),
                                      // Stack(children: [
                                      //   GestureDetector(
                                      //       onTap: () {
                                      //         _textEditingController.clear();
                                      //         showModalBottomSheet(
                                      //           context: context,
                                      //           isScrollControlled: true,
                                      //           builder: (BuildContext context) {
                                      //             return SingleChildScrollView(
                                      //               padding: EdgeInsets.only(
                                      //                   bottom:
                                      //                       MediaQuery.of(context)
                                      //                           .viewInsets
                                      //                           .bottom),
                                      //               child: Container(
                                      //                 height: 300,
                                      //                 child: Padding(
                                      //                   padding: EdgeInsets.only(
                                      //                       left: 20, right: 20),
                                      //                   child: Column(
                                      //                     crossAxisAlignment:
                                      //                         CrossAxisAlignment
                                      //                             .start,
                                      //                     mainAxisAlignment:
                                      //                         MainAxisAlignment
                                      //                             .start,
                                      //                     children: [
                                      //                       SizedBox(
                                      //                         height: 30,
                                      //                       ),
                                      //                       Text(
                                      //                         '변경할 활동명을 입력해주세요.',
                                      //                         style: TextStyle(
                                      //                             fontSize: 18,
                                      //                             fontWeight:
                                      //                                 FontWeight
                                      //                                     .bold,
                                      //                             color: Color(
                                      //                                 0xFF111111)),
                                      //                       ),
                                      //                       SizedBox(
                                      //                         height: 24,
                                      //                       ),
                                      //                       Container(
                                      //                         height: 130,
                                      //                         child: Column(
                                      //                           crossAxisAlignment:
                                      //                               CrossAxisAlignment
                                      //                                   .start,
                                      //                           mainAxisAlignment:
                                      //                               MainAxisAlignment
                                      //                                   .start,
                                      //                           children: [
                                      //                             Form(
                                      //                               key: _formKey,
                                      //                               child:
                                      //                                   TextFormField(
                                      //                                 cursorColor:
                                      //                                     Color(
                                      //                                         0xff377EEA),
                                      //                                 cursorHeight:
                                      //                                     16,
                                      //                                 cursorWidth:
                                      //                                     2,
                                      //                                 autovalidateMode:
                                      //                                     AutovalidateMode
                                      //                                         .onUserInteraction,
                                      //                                 controller:
                                      //                                     _textEditingController,
                                      //                                 strutStyle:
                                      //                                     StrutStyle(
                                      //                                         leading:
                                      //                                             0.3),
                                      //                                 decoration:
                                      //                                     InputDecoration(
                                      //                                         errorStyle:
                                      //                                             TextStyle(
                                      //                                           fontSize:
                                      //                                               12,
                                      //                                         ),
                                      //                                         hintStyle: TextStyle(
                                      //                                             color: Color(0xff949494),
                                      //                                             fontSize: 16),
                                      //                                         hintText:
                                      //                                             '활동명 입력',
                                      //                                         labelText:
                                      //                                             '활동명',
                                      //                                         contentPadding: EdgeInsets.only(
                                      //                                             top:
                                      //                                                 20,
                                      //                                             bottom:
                                      //                                                 20,
                                      //                                             left:
                                      //                                                 20,
                                      //                                             right:
                                      //                                                 20),
                                      //                                         border:
                                      //                                             OutlineInputBorder(
                                      //                                           borderSide:
                                      //                                               BorderSide(color: Color(0xFFDEDEDE)),
                                      //                                           borderRadius:
                                      //                                               BorderRadius.circular(6),
                                      //                                         ),
                                      //                                         enabledBorder:
                                      //                                             OutlineInputBorder(
                                      //                                           borderSide:
                                      //                                               BorderSide(color: Color(0xFFDEDEDE)),
                                      //                                           borderRadius:
                                      //                                               BorderRadius.circular(6),
                                      //                                         ),
                                      //                                         errorBorder:
                                      //                                             OutlineInputBorder(
                                      //                                           borderSide:
                                      //                                               BorderSide(color: Color(0xFFFF3726)),
                                      //                                           borderRadius:
                                      //                                               BorderRadius.circular(6),
                                      //                                         )),
                                      //                                 validator:
                                      //                                     (val) {
                                      //                                   if (val!.length <=
                                      //                                           20 &&
                                      //                                       val.length >=
                                      //                                           1) {
                                      //                                     return null;
                                      //                                   } else if (val
                                      //                                           .length ==
                                      //                                       0) {
                                      //                                     return '닉네임을 입력해주세요.';
                                      //                                   } else {
                                      //                                     return '최대 글자 수를 초과했습니다.';
                                      //                                   }
                                      //                                 },
                                      //                               ),
                                      //                             ),
                                      //                             SizedBox(
                                      //                               height: 6,
                                      //                             ),
                                      //                             Padding(
                                      //                               padding:
                                      //                                   const EdgeInsets
                                      //                                           .only(
                                      //                                       left:
                                      //                                           19),
                                      //                               child: Text(
                                      //                                 '최대 20글자까지 입력 가능합니다.',
                                      //                                 style: TextStyle(
                                      //                                     color: Color(
                                      //                                         0xff949494),
                                      //                                     fontSize:
                                      //                                         12),
                                      //                               ),
                                      //                             ),
                                      //                           ],
                                      //                         ),
                                      //                       ),
                                      //                       Row(
                                      //                         children: [
                                      //                           Expanded(
                                      //                             child: InkWell(
                                      //                               child:
                                      //                                   ElevatedButton(
                                      //                                 onPressed:
                                      //                                     () {
                                      //                                   Navigator.pop(
                                      //                                       context);
                                      //                                 },
                                      //                                 child: Text(
                                      //                                   '취소',
                                      //                                   style: TextStyle(
                                      //                                       color: Colors
                                      //                                           .white,
                                      //                                       fontSize:
                                      //                                           15,
                                      //                                       fontWeight:
                                      //                                           FontWeight.bold),
                                      //                                 ),
                                      //                                 style: TextButton.styleFrom(
                                      //                                     splashFactory:
                                      //                                         InkRipple
                                      //                                             .splashFactory,
                                      //                                     elevation:
                                      //                                         0,
                                      //                                     minimumSize:
                                      //                                         Size(
                                      //                                             100,
                                      //                                             56),
                                      //                                     backgroundColor:
                                      //                                         Color(
                                      //                                             0xff555555),
                                      //                                     padding: EdgeInsets.symmetric(
                                      //                                         horizontal:
                                      //                                             0)),
                                      //                               ),
                                      //                             ),
                                      //                           ),
                                      //                           SizedBox(
                                      //                             width: 10,
                                      //                           ),
                                      //                           Expanded(
                                      //                             child: InkWell(
                                      //                               child:
                                      //                                   ElevatedButton(
                                      //                                 onPressed:
                                      //                                     () async {
                                      //                                   setState(
                                      //                                       () {
                                      //                                     isLoading =
                                      //                                         true;
                                      //                                   });
                                      //                                   if (_formKey
                                      //                                       .currentState!
                                      //                                       .validate()) {
                                      //                                     await _userModelController
                                      //                                         .updateNickname(
                                      //                                             _textEditingController.text);
                                      //                                     Get.snackbar(
                                      //                                         '닉네임을 변경하였습니다.',
                                      //                                         '',
                                      //                                         snackPosition: SnackPosition
                                      //                                             .BOTTOM,
                                      //                                         margin: EdgeInsets.only(
                                      //                                             right:
                                      //                                                 20,
                                      //                                             left:
                                      //                                                 20,
                                      //                                             bottom:
                                      //                                                 12),
                                      //                                         backgroundColor: Colors
                                      //                                             .black87,
                                      //                                         colorText: Colors
                                      //                                             .white,
                                      //                                         duration:
                                      //                                             Duration(milliseconds: 3000));
                                      //                                     Navigator.pop(
                                      //                                         context);
                                      //                                   } else {
                                      //                                     Get.snackbar(
                                      //                                         '닉네임 저장 실패',
                                      //                                         '올바른 닉네임을 입력해주세요.',
                                      //                                         snackPosition: SnackPosition
                                      //                                             .BOTTOM,
                                      //                                         margin: EdgeInsets.only(
                                      //                                             right:
                                      //                                                 20,
                                      //                                             left:
                                      //                                                 20,
                                      //                                             bottom:
                                      //                                                 12),
                                      //                                         backgroundColor: Colors
                                      //                                             .black87,
                                      //                                         colorText: Colors
                                      //                                             .white,
                                      //                                         duration:
                                      //                                             Duration(milliseconds: 3000));
                                      //                                   }
                                      //                                   setState(
                                      //                                       () {
                                      //                                     isLoading =
                                      //                                         false;
                                      //                                   });
                                      //                                 },
                                      //                                 child: Text(
                                      //                                   '변경',
                                      //                                   style: TextStyle(
                                      //                                       color: Colors
                                      //                                           .white,
                                      //                                       fontSize:
                                      //                                           15,
                                      //                                       fontWeight:
                                      //                                           FontWeight.bold),
                                      //                                 ),
                                      //                                 style: TextButton.styleFrom(
                                      //                                     splashFactory:
                                      //                                         InkRipple
                                      //                                             .splashFactory,
                                      //                                     elevation:
                                      //                                         0,
                                      //                                     minimumSize:
                                      //                                         Size(
                                      //                                             100,
                                      //                                             56),
                                      //                                     backgroundColor:
                                      //                                         Color(
                                      //                                             0xff2C97FB),
                                      //                                     padding: EdgeInsets.symmetric(
                                      //                                         horizontal:
                                      //                                             0)),
                                      //                               ),
                                      //                             ),
                                      //                           ),
                                      //                         ],
                                      //                       )
                                      //                     ],
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             );
                                      //           },
                                      //         );
                                      //       },
                                      //       child: Image.asset(
                                      //         'assets/imgs/icons/icon_edit_pencil.png',
                                      //         height: 22,
                                      //         width: 22,
                                      //       )),
                                      // ])
                                    ],
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    _userModelController.userEmail!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Color(0xFF949494), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Get.to(()=> FriendListPage());
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Image.asset('assets/imgs/icons/icon_moretab_friends.png', width: 40,),
                                  Positioned(
                                    // draw a red marble
                                      bottom: 0,
                                      right: 0,
                                      child:
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('newAlarm')
                                            .where('uid', isEqualTo: _userModelController.uid!)
                                            .snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          if (!snapshot.hasData || snapshot.data == null) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          else if (snapshot.data!.docs.isNotEmpty) {
                                            final alarmDocs = snapshot.data!.docs;
                                            return
                                              (alarmDocs[0]['newInvited_friend'] == true)
                                          ? Container(
                                          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                          decoration: BoxDecoration(
                                          color: Color(0xFFD6382B),
                                          borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text('NEW',
                                          style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFFFFF)
                                          ),

                                          ),
                                          )
                                              :
                                          Container();
                                              new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: (alarmDocs[0]['newInvited_friend'] == true)
                                                    ? Color(0xFFD32F2F)
                                                    : Colors.white);
                                          }
                                          else if (snapshot.connectionState == ConnectionState.waiting) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          return new Icon(Icons.brightness_1,
                                              size: 7.0,
                                              color: Colors.white);
                                        },
                                      )
                                  )
                                ],
                              ),
                              SizedBox(height: 6),
                              Text('친구',style: TextStyle(
                                fontSize: 14,
                                  color: Color(0xFF555555)
                              ),)
                            ],
                          ),
                        ),
                        SizedBox(height: 25,),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async{
                            CustomFullScreenDialog.showDialog();
                            if(_userModelController.liveCrew!.isEmpty){
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(()=>FirstPage_createCrew());
                            }
                            else{
                              await _userModelController.getCurrentUser_crew(_userModelController.uid);
                              await _liveCrewModelController.deleteInvitationAlarm_crew(leaderUid: _userModelController.uid);
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(()=>LiveCrewHome());
                            }
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 40),
                                  Positioned(
                                    // draw a red marble
                                      top: 0,
                                      right: 0.0,
                                      child:
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('newAlarm')
                                            .where('uid', isEqualTo: _userModelController.uid!)
                                            .snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          if (!snapshot.hasData || snapshot.data == null) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          else if (snapshot.data!.docs.isNotEmpty) {
                                            final alarmDocs = snapshot.data!.docs;
                                            return
                                              (alarmDocs[0]['newInvited_crew'] == true)
                                              ? Container(
                                              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFD6382B),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text('NEW',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFFFFFFF)
                                                ),
                                              ),
                                            )
                                               : Container();
                                              // new Icon(Icons.brightness_1,
                                              //   size: 7.0,
                                              //   color: (alarmDocs[0]['newInvited_crew'] == true)
                                              //       ? Color(0xFFD32F2F)
                                              //       : Colors.white);
                                          }
                                          else if (snapshot.connectionState == ConnectionState.waiting) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          return new Icon(Icons.brightness_1,
                                              size: 7.0,
                                              color: Colors.white);
                                        },
                                      )
                                  )
                                ],
                              ),
                              SizedBox(height: 6),
                              Text('라이브크루',style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555)
                              ),)
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Get.to(()=>BulletinScreen());
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/imgs/icons/icon_moretab_room.png', width: 40),
                              SizedBox(height: 6),
                              Text('커뮤니티', style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555)
                              ),)
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Get.to(()=>EventPage());
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              children: [
                                Image.asset('assets/imgs/icons/icon_moretab_event.png', width: 40),
                                SizedBox(height: 6),
                                Text('이벤트', style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF555555)
                                ),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: (){
                    //         Get.to(()=>FleaMarketScreen());
                    //       },
                    //       child: Column(
                    //         children: [
                    //           Image.asset('assets/imgs/icons/icon_moretab_snowmarket.png', width: 40),
                    //           SizedBox(height: 2),
                    //           Text('스노우마켓',style: TextStyle(
                    //               fontSize: 14
                    //           ),)
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Container(height: 1,color: Color(0xFFECECEC),),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '스키장',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D83ED)),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => FavoriteResort_moreTab());
                },
                title: Text(
                  '자주가는 스키장',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => ResortTab());
                },
                title: Text(
                  '스키장 모아보기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '고객센터',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D83ED)),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => NoticeList());
                },
                title: Stack(
                  children: [
                    Text(
                      '공지사항',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF111111)),
                    ),
                    Positioned(  // draw a red marble
                      top: 1,
                      left: 58,
                      child: new Icon(Icons.brightness_1, size: 6.0,
                          color:
                          (_noticeController.isNewNotice == true)
                              ?Color(0xFFD32F2F):Colors.white),
                    )
                  ],
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  _liveCrewModelController.otherShare(contents: 'http://pf.kakao.com/_LxnDdG/chat');
                },
                title: Stack(
                  children: [
                    Text(
                      '1:1 고객 문의',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF111111)),
                    ),
                  ],
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '설정',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D83ED)),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => SnowliveDetailPage());
                },
                title: Text(
                  'SNOWLIVE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => setting_moreTab());
                },
                title: Text(
                  '설정',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 36),
            ],
          ),
        ));
  }
}
