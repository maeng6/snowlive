import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/public/vm_imageController.dart';
import 'package:com.snowlive/controller/public/vm_urlLauncherController.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_gallery_viewer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/liveCrew/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/ranking/vm_liveMapController.dart';
import 'package:com.snowlive/controller/resort/vm_resortModelController.dart';
import 'package:com.snowlive/screens/common/v_profileImageScreen.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../controller/alarm/vm_alarmCenterController.dart';
import '../../controller/ranking/vm_rankingTierModelController.dart';
import '../../controller/liveCrew/vm_streamController_liveCrew.dart';
import '../../data/imgaUrls/Data_url_image.dart';
import '../../model/m_alarmCenterModel.dart';
import '../../model/m_crewLogoModel.dart';
import '../more/friend/v_friendDetailPage.dart';

class CrewDetailPage_home extends StatefulWidget {
  CrewDetailPage_home({Key? key, }) : super(key: key);

  @override
  State<CrewDetailPage_home> createState() => _CrewDetailPage_homeState();
}

class _CrewDetailPage_homeState extends State<CrewDetailPage_home> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  StreamController_liveCrew _streamController_liveCrew = Get.find<StreamController_liveCrew>();
  //TODO: Dependency Injection**************************************************

  var assetCrew;

  Map? crewRankingMap;

  List? crewDocs;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamController_liveCrew.getCrewDocs();

  }


  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    Get.put(ImageController(), permanent: true);

    if(_liveCrewModelController.baseResort == 12 || _liveCrewModelController.baseResort == 2 || _liveCrewModelController.baseResort == 0) {
      crewDocs = _rankingTierModelController.rankingDocs_crew;
      crewRankingMap = _rankingTierModelController.crewRankingMap;
    } else{
      crewDocs = _rankingTierModelController.rankingDocs_crew_integrated;
      crewRankingMap = _rankingTierModelController.crewRankingMap_integrated;
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<QuerySnapshot>(
          stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_home_currentCrew(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return SizedBox.shrink();
            }
            else if(snapshot.connectionState == ConnectionState.waiting){
              return SizedBox.shrink();
            }
            else if (snapshot.data!.docs.isNotEmpty) {
              final crewDocs = snapshot.data!.docs;
              final List memberUidList = crewDocs[0]['memberUidList'];
              DateTime date = crewDocs[0]['resistDate'].toDate();
              String year = DateFormat('yy').format(date);
              String month = DateFormat('MM').format(date);
              String day = DateFormat('dd').format(date);

              for (var crewLogo in crewLogoList) {
                if (crewLogo.crewColor == crewDocs[0]['crewColor']) {
                  assetCrew = crewLogo.crewLogoAsset;
                  break;
                }
              }

              return StreamBuilder<QuerySnapshot>(
                  stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_home_currentUser(crewDocs[0].get('leaderUid')),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return SizedBox.shrink();
                    }
                    else if(snapshot.connectionState == ConnectionState.waiting){
                      return SizedBox.shrink();
                    }
                    else if(snapshot.data!.docs.isNotEmpty){

                      final userDoc = snapshot.data!.docs;

                      return Container(
                        width: _size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(memberUidList.contains(_userModelController.uid) && crewDocs[0]['notice'] != '')
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ExtendedImage.asset(
                                            'assets/imgs/icons/icon_liveCrew_notice.png',
                                            width: 20,
                                            height: 20,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            '${crewDocs[0]['notice']}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF111111)
                                            ),),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    color: Color(crewDocs[0]['crewColor']),
                                    padding: EdgeInsets.only(top: 16, bottom: 16),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 24, right: 24 ),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  (crewDocs[0]['profileImageUrl'].isNotEmpty)
                                                      ? GestureDetector(
                                                    onTap: () {
                                                      Get.to(() => ProfileImagePage(
                                                          CommentProfileUrl: crewDocs[0]['profileImageUrl']));
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black12,
                                                              spreadRadius: 0,
                                                              blurRadius: 16,
                                                              offset: Offset(0, 2), // changes position of shadow
                                                            ),
                                                          ],
                                                        ),
                                                        width: 35,
                                                        height: 35,
                                                        child: ExtendedImage.network(
                                                          crewDocs[0]['profileImageUrl'],
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.rectangle,
                                                          borderRadius: BorderRadius.circular(10),
                                                          width: 35,
                                                          height: 35,
                                                          fit: BoxFit.cover,
                                                        )),
                                                  )
                                                      : GestureDetector(
                                                    onTap: () {},
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black12,
                                                            spreadRadius: 0,
                                                            blurRadius: 16,
                                                            offset: Offset(0, 2), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      width: 35,
                                                      height: 35,
                                                      child: ExtendedImage.network(
                                                        assetCrew,
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(10),
                                                        width: 35,
                                                        height: 35,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${crewDocs[0]['crewName']}',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFFFFFFFF),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${userDoc[0]['displayName']}',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF5DDEBF)
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                              SizedBox(width: 5),
                                                              Text(
                                                                '•', // 점 추가
                                                                style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Color(0xFF5DDEBF),
                                                                ),
                                                              ),
                                                              SizedBox(width: 5),
                                                              Text(
                                                                '${_resortModelController.getResortName(crewDocs[0]['baseResortNickName'])}',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF5DDEBF )
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Expanded(child: SizedBox()),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '${memberUidList.length}',
                                                          style: GoogleFonts.bebasNeue(
                                                            color: Color(0xFFFFFFFF),
                                                            fontSize: 35,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: ' 명',
                                                          style: GoogleFonts.bebasNeue(
                                                            color: Color(0xFF5DDEBF),
                                                            fontSize: 12, // 숫자보다 작은 폰트 크기
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if(crewDocs[0]['description'] != '')
                                              Column(
                                                children: [
                                                  Divider(
                                                    color: Color(0xFF111111).withOpacity(0.2),
                                                    thickness: 1.0,
                                                    height: 30,
                                                  ),
                                                  Row(children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 텍스트와 박스 간의 간격 설정
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFF000000).withOpacity(0.2), // 배경 색상과 투명도 설정
                                                        borderRadius: BorderRadius.circular(8), // 모서리 둥글게 설정
                                                      ),
                                                      child: Text(
                                                        '크루소개',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Text(
                                                      '${crewDocs[0]['description']}',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFF111111)
                                                      ),),
                                                  ],),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                width: _size.width,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '크루 갤러리',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF111111),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_home_currentCrew(),
                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                          if (snapshot.hasError) {
                                            return Text('이미지 로드 실패');
                                          }

                                          if (snapshot.data == null || !snapshot.hasData) {
                                            return SizedBox.shrink();
                                          }

                                          if(snapshot.connectionState == ConnectionState.waiting){
                                            return SizedBox.shrink();
                                          }

                                          List<String> galleryUrlList = [];
                                          for (var doc in snapshot.data!.docs) {
                                            galleryUrlList.addAll(List<String>.from(doc['galleryUrlList'] ?? []));
                                          }

                                          if (galleryUrlList.isEmpty) {
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 40, bottom: 10),
                                                child: Text(
                                                  '이미지가 없습니다',
                                                  style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                                                ),
                                              ),
                                            );
                                          }

                                          return GridView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: galleryUrlList.length > 6 ? 6 : galleryUrlList.length,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 1, // Horizontal gap
                                              mainAxisSpacing: 1, // Vertical gap
                                            ),
                                            itemBuilder: (BuildContext context, int index) {
                                              String imageUrl = galleryUrlList.reversed.toList()[index];
                                              return GestureDetector(
                                                onTap: (){
                                                  List<String> visibleImages = galleryUrlList.reversed.toList().sublist(0, galleryUrlList.length > 6 ? 6 : galleryUrlList.length);
                                                  Get.to(()=>PhotoViewerPage(
                                                    photoList: visibleImages,
                                                    initialIndex: index,
                                                  ));
                                                },
                                                child: ExtendedImage.network(
                                                  imageUrl,
                                                  cacheHeight: 300,
                                                  fit: BoxFit.cover,
                                                  cache: true,
                                                  loadStateChanged: (ExtendedImageState state) {
                                                    switch (state.extendedImageLoadState) {
                                                      case LoadState.loading:
                                                        return SizedBox.shrink();
                                                      case LoadState.completed:
                                                        return null;
                                                      case LoadState.failed:
                                                        return Icon(Icons.error);
                                                      default:
                                                        return null;
                                                    }
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      )

                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                                  child: Row(
                                    children: [
                                      if(memberUidList.contains(_userModelController.uid) == false)
                                        Expanded(
                                            child:  Padding(
                                              padding: const EdgeInsets.only(right: 10.0),
                                              child: ElevatedButton(
                                                onPressed:
                                                    () {
                                                  if(_userModelController.liveCrew!.isEmpty || _userModelController.liveCrew == ''){
                                                    Get.dialog(AlertDialog(
                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                      content: Text(
                                                        '가입신청을 하시겠습니까?',
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
                                                                  if(_userModelController.applyCrewList!.contains(_liveCrewModelController.crewID)){
                                                                    Get.dialog(AlertDialog(
                                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                      elevation: 0,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10.0)),
                                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                      content: Text(
                                                                        '이미 요청중입니다.',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: 15),
                                                                      ),
                                                                      actions: [
                                                                        Row(
                                                                          children: [
                                                                            TextButton(
                                                                                onPressed: () async {
                                                                                  Navigator.pop(context);
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text(
                                                                                  '확인',
                                                                                  style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    color: Color(0xff377EEA),
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                )),
                                                                          ],
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                        )
                                                                      ],
                                                                    ));
                                                                  } else{
                                                                    CustomFullScreenDialog.showDialog();
                                                                    await _liveCrewModelController.updateInvitation_crew(crewID: _liveCrewModelController.crewID);
                                                                    await _liveCrewModelController.updateInvitationAlarm_crew(leaderUid: _liveCrewModelController.leaderUid);
                                                                    String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.crewApplyKey];
                                                                    await _alarmCenterController.sendAlarm(
                                                                        alarmCount: 'crew',
                                                                        receiverUid: _liveCrewModelController.leaderUid,
                                                                        senderUid: _userModelController.uid,
                                                                        senderDisplayName: _userModelController.displayName,
                                                                        timeStamp: Timestamp.now(),
                                                                        category: alarmCategory,
                                                                        msg: '${_userModelController.displayName}님으로부터 $alarmCategory이 도착했습니다.',
                                                                        content: '',
                                                                        docName: '',
                                                                        liveTalk_uid : '',
                                                                        liveTalk_commentCount : '',
                                                                        bulletinRoomUid :'',
                                                                        bulletinRoomCount :'',
                                                                        bulletinCrewUid : '',
                                                                        bulletinCrewCount : '',
                                                                        bulletinFreeUid : '',
                                                                        bulletinFreeCount : '',
                                                                        bulletinEventUid : '',
                                                                        bulletinEventCount : '',
                                                                        originContent: 'crew',
                                                                        bulletinLostUid: '',
                                                                        bulletinLostCount: ''
                                                                    );
                                                                    await _userModelController.getCurrentUser(_userModelController.uid);
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    Navigator.pop(context);
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
                                                  }else{
                                                    Get.dialog(AlertDialog(
                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                      content: Text('라이브 크루는 1개만 가입할 수 있습니다.',
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

                                                  }
                                                },
                                                child: Text(
                                                  '가입하기',
                                                  style: TextStyle(
                                                      color: Color(crewDocs[0]['crewColor']),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                style: TextButton.styleFrom(
                                                    splashFactory: InkRipple.splashFactory,
                                                    elevation: 0,
                                                    minimumSize: Size(100, 56),
                                                    backgroundColor: Color(crewDocs[0]['crewColor']).withOpacity(0.2),
                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                              ),
                                            )

                                        ),
                                      if (_liveCrewModelController.sns!.isNotEmpty && _liveCrewModelController.sns != '')
                                        Expanded(
                                            child:ElevatedButton(
                                              onPressed:
                                                  () {
                                                if(_liveCrewModelController.sns!.isNotEmpty && _liveCrewModelController.sns != '' ) {
                                                  _urlLauncherController.otherShare(contents: '${_liveCrewModelController.sns}');
                                                }else{
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
                                                      '연결된 SNS 계정이 없습니다.',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15),
                                                    ),
                                                    actions: [
                                                      Row(
                                                        children: [
                                                          TextButton(
                                                              onPressed: () async {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text(
                                                                '확인',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(0xff377EEA),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              )),
                                                        ],
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                      )
                                                    ],
                                                  ));
                                                }
                                              },
                                              child: Text(
                                                'SNS 바로가기',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              style: TextButton.styleFrom(
                                                  splashFactory: InkRipple.splashFactory,
                                                  elevation: 0,
                                                  minimumSize: Size(100, 56),
                                                  backgroundColor: Color(crewDocs[0]['crewColor']),
                                                  padding: EdgeInsets.symmetric(horizontal: 0)),
                                            )
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox.shrink();

                  }
              );
            }
            return SizedBox.shrink();
          }
      ),
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

