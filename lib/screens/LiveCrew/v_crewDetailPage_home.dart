import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/public/vm_imageController.dart';
import 'package:com.snowlive/controller/public/vm_urlLauncherController.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_gallery_viewer.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewNoticePage.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewTodayPage.dart';
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
import '../../widget/w_verticalDivider.dart';
import '../more/friend/v_friendDetailPage.dart';
import '../snowliveDesignStyle.dart';

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

  bool showSlopeGraph = true;


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
                                GestureDetector(
                                  onTap: (){
                                    Get.to(()=> CrewNoticePage());
                                  },
                                  child: Padding(
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
                              SizedBox(height: 20,),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16),
                                child: Row(
                                  children: [
                                    Text(
                                      '라이브ON 11',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF111111),
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    OutlinedButton(
                                      onPressed: () {
                                        Get.to(()=> CrewTodayPage());
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: SDSColor.snowliveWhite,
                                        side: BorderSide(color: SDSColor.gray300), // 회색 테두리
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5), // 모서리를 둥글게 설정
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        minimumSize: Size(0, 0),
                                      ),
                                      child: Text(
                                        '오늘의 현황',
                                        style: TextStyle(
                                          color: SDSColor.snowliveBlack, // 텍스트 색상
                                          fontSize: 13, // 텍스트 크기
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5,),
                              StreamBuilder(
                                stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_home_liveOn(),
                                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return SizedBox.shrink();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                    final crewDocs = snapshot.data!.docs;
                                    return SizedBox(
                                      height: _size.width * 0.3, // 세로 높이 지정
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(), // 스크롤을 부드럽게
                                        scrollDirection: Axis.horizontal, // 가로 스크롤
                                        itemCount: crewDocs.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // 가로 패딩 추가
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                (crewDocs[index]['profileImageUrl'].isNotEmpty)
                                                    ? GestureDetector(
                                                  onTap: () {
                                                    Get.to(() => FriendDetailPage(
                                                      uid: crewDocs[index]['uid'],
                                                      favoriteResort: crewDocs[index]['favoriteResort'],
                                                    ));
                                                  },
                                                  child: Container(
                                                    width: _size.width * 0.15,
                                                    height: _size.width * 0.15,
                                                    decoration: BoxDecoration(
                                                        color: Color(0xFFDFECFF),
                                                        borderRadius: BorderRadius.circular(50)),
                                                    child: Stack(
                                                      children: [
                                                        ExtendedImage.network(
                                                          crewDocs[index]['profileImageUrl'],
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: _size.width * 0.15,
                                                          height: _size.width * 0.15,
                                                          fit: BoxFit.cover,
                                                          loadStateChanged: (ExtendedImageState state) {
                                                            switch (state.extendedImageLoadState) {
                                                              case LoadState.loading:
                                                                return SizedBox.shrink();
                                                              case LoadState.completed:
                                                                return state.completedWidget;
                                                              case LoadState.failed:
                                                                return ExtendedImage.network(
                                                                  '${profileImgUrlList[0].default_round}',
                                                                  shape: BoxShape.circle,
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  width: 24,
                                                                  height: 24,
                                                                  fit: BoxFit.cover,
                                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                              default:
                                                                return null;
                                                            }
                                                          },
                                                        ),
                                                        Positioned(
                                                          child: Image.asset(
                                                            'assets/imgs/icons/icon_badge_live.png',
                                                            width: 32,
                                                          ),
                                                          right: 0,
                                                          bottom: 0,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                    : GestureDetector(
                                                  onTap: () {
                                                    Get.to(() => FriendDetailPage(
                                                      uid: crewDocs[index]['uid'],
                                                      favoriteResort: crewDocs[index]['favoriteResort'],
                                                    ));
                                                  },
                                                  child: Container(
                                                    width: _size.width * 0.15,
                                                    height: _size.width * 0.15,
                                                    child: Stack(
                                                      children: [
                                                        ExtendedImage.network(
                                                          '${profileImgUrlList[0].default_round}',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: _size.width * 0.15,
                                                          height: _size.width * 0.15,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Positioned(
                                                          child: Image.asset(
                                                            'assets/imgs/icons/icon_badge_live.png',
                                                            width: 32,
                                                          ),
                                                          right: 0,
                                                          bottom: 0,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  width: _size.width * 0.2,
                                                  child: Text(
                                                    '${crewDocs[index]['displayName']}',
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 14, color: Color(0xFF111111)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      height: 154,
                                      width: (_size.width - 48) / 3,
                                    );
                                  }
                                },
                              ),
                              Container(
                                width: _size.width,
                                height: 10,
                                color: SDSColor.gray50,
                              ),
                              SizedBox(height: 30,),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  '크루 라이딩 통계',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111111),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: _size.width - 32,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        color: SDSColor.gray50, // 선택된 옵션의 배경을 흰색으로 설정
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '1',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 3),
                                                  child: Text(
                                                    '통합 랭킹',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      color: Color(0xFF111111).withOpacity(0.5),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          buildVerticalDivider_ranking_indi_Screen(),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '73,045',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 3),
                                                  child: Text(
                                                    '총 점수',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      color: Color(0xFF111111).withOpacity(0.5),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20,),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  '크루 라이딩 누적 통계',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF111111),
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              StreamBuilder(
                                stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_home_currentCrew(),
                                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return SizedBox.shrink();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                                    return SizedBox.shrink();
                                  } else if (snapshot.data!.docs.isNotEmpty) {
                                    final crewDocs = snapshot.data!.docs;
                                    Map<String, dynamic>? passCountData = crewDocs[0].data().containsKey('passCountData')
                                        ? crewDocs[0]['passCountData'] as Map<String, dynamic>?
                                        : null;
                                    if (passCountData == null || passCountData.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                                          child: Text(
                                            '슬로프 이용기록이 없습니다',
                                            style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                                          ),
                                        ),
                                      );
                                    } else {
                                      Map<String, dynamic>? passCountTimeData = crewDocs[0]['passCountTimeData'] as Map<String, dynamic>?;
                                      List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataPassCount(passCountData);
                                      List<Map<String, dynamic>> barData2 = _liveMapController.calculateBarDataSlot(passCountTimeData);

                                      return Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16),
                                        child: Container(
                                          padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: SDSColor.blue50,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '총 라이딩 횟수',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      color: SDSColor.snowliveBlack,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                                                    child: Text(
                                                      '${crewDocs[0]['totalPassCount']}회',
                                                      style: SDSTextStyle.extraBold.copyWith(
                                                        color: SDSColor.snowliveBlack,
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '라이딩 횟수',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      color: SDSColor.snowliveBlack,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Divider(
                                                    color: Color(0xFFCBE0FF), // 구분선 색상
                                                    thickness: 1, // 구분선 두께
                                                  ),
                                                  SizedBox(height: 10,),
                                                  if(showSlopeGraph == true)
                                                  Container(
                                                    height: 7 * 24.0,
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: barData.map((data) {
                                                          String slopeName = data['slopeName'];
                                                          int passCount = data['passCount'];
                                                          double barWidthRatio = data['barHeightRatio'];
                                                          Color barColor = data['barColor'];
                                                          return Padding(
                                                            padding: EdgeInsets.only(bottom: 8),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 40,
                                                                  child: Text(
                                                                    slopeName,
                                                                    style: SDSTextStyle.bold.copyWith(
                                                                      fontSize: 11,
                                                                      color: SDSColor.gray900,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 16,
                                                                  width: (MediaQuery.of(context).size.width - 170) * barWidthRatio,
                                                                  decoration: BoxDecoration(
                                                                    color: barColor,
                                                                    borderRadius: BorderRadius.only(
                                                                      topRight: Radius.circular(4),
                                                                      bottomRight: Radius.circular(4),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.only(left: 6),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      color: passCount == barData.map((d) => d['passCount']).reduce((a, b) => a > b ? a : b) ? SDSColor.gray900 : Colors.transparent,
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                    child: AutoSizeText(
                                                                      passCount != 0 ? '$passCount' : '',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        fontSize: 12,
                                                                        fontWeight: passCount == barData.map((d) => d['passCount']).reduce((a, b) => a > b ? a : b) ? FontWeight.w900 : FontWeight.w300,
                                                                        color: passCount == barData.map((d) => d['passCount']).reduce((a, b) => a > b ? a : b) ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                                                      ),
                                                                      maxLines: 1,
                                                                      minFontSize: 6,
                                                                      overflow: TextOverflow.visible,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                  if(showSlopeGraph == false)
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: barData2.map((data) {
                                                        String slotName = data['slotName'];
                                                        int passCount = data['passCount'];
                                                        double barHeightRatio = data['barHeightRatio'];
                                                        Color barColor = data['barColor'];
                                                        int maxPassCount = barData2.map((data) => data['passCount']).reduce((a, b) => a > b ? a : b);

                                                        return Container(
                                                          width: 33,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  color: passCount == maxPassCount ? SDSColor.gray900 : Colors.transparent,
                                                                ),
                                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                child: AutoSizeText(
                                                                  passCount != 0 ? '$passCount' : '',
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 12,
                                                                    color: passCount == maxPassCount ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                                                    fontWeight: passCount == maxPassCount ? FontWeight.w900 : FontWeight.w300,
                                                                  ),
                                                                  minFontSize: 6,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.visible,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.only(top: passCount == maxPassCount ? 6 : 0),
                                                                child: Container(
                                                                  width: 16,
                                                                  height: 140 * barHeightRatio,
                                                                  decoration: BoxDecoration(
                                                                    color: barColor,
                                                                    borderRadius: BorderRadius.only(
                                                                      topRight: Radius.circular(4),
                                                                      topLeft: Radius.circular(4),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 8),
                                                                child: Container(
                                                                  width: 20,
                                                                  child: Text(
                                                                    _resortModelController.getSlotName(slotName),
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 11,
                                                                      color: SDSColor.gray900,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFD2DFF4),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            showSlopeGraph = true;
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: showSlopeGraph ? SDSColor.snowliveWhite : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            '슬로프별',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              color: showSlopeGraph ? SDSColor.gray900 : SDSColor.gray600,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            showSlopeGraph = false;
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: !showSlopeGraph ? SDSColor.snowliveWhite : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            '시간대별',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              color: !showSlopeGraph ? SDSColor.gray900 : SDSColor.gray600,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )

                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                                      child: Text(
                                        '슬로프 이용기록이 없습니다',
                                        style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                                      ),
                                    ),
                                  );
                                },
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

