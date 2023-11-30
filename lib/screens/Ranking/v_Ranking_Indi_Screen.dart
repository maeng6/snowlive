import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_liveMapController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_indi_All_Screen.dart';
import '../../controller/vm_allCrewDocsController.dart';
import '../../controller/vm_allUserDocsController.dart';
import '../../controller/vm_myRankingController.dart';
import '../../controller/vm_rankingTierModelController.dart';
import '../../controller/vm_refreshController.dart';
import '../../controller/vm_resortModelController.dart';
import '../../data/imgaUrls/Data_url_image.dart';
import '../../model/m_rankingTierModel.dart';
import '../more/friend/v_friendDetailPage.dart';

class RankingIndiScreen extends StatefulWidget {
  RankingIndiScreen({Key? key, required this.isKusbf}) : super(key: key);

  bool isKusbf = false;

  @override
  State<RankingIndiScreen> createState() => _RankingIndiScreenState();
}

class _RankingIndiScreenState extends State<RankingIndiScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  RefreshController _refreshController = Get.find<RefreshController>();
  AllCrewDocsController _allCrewDocsController = Get.find<AllCrewDocsController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  //TODO: Dependency Injection**************************************************

  var _rankingStream;
  Map? userRankingMap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _allCrewDocsController.startListening().then((result){
      setState(() {});
    });
    _rankingStream = rankingStream();

  }

  @override
  void dispose() {
    _allCrewDocsController.stopListening();
    super.dispose();
  }



  Stream<QuerySnapshot> myRankingDocStream() {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .where('uid', isEqualTo: _userModelController.uid )
        .snapshots();
  }

  Stream<QuerySnapshot> rankingStream() {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    _userModelController.getCurrentUser_crew(_userModelController.uid);
    _myRankingController.getMyRankingData(_userModelController.uid);

    return  StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('liveCrew')
            .where('kusbf', isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (snapshot.hasError) {
            return SizedBox.shrink();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return SizedBox.shrink();
          }

          // 'liveCrew' 컬렉션의 모든 문서에서 'memberUidList' 필드를 가져와서 합칩니다.
          List<dynamic> allMemberUidList = [];
          for (var doc in snapshot.data!.docs) {
            List<dynamic> memberUidList = doc['memberUidList'];
            allMemberUidList.addAll(memberUidList);
          }
          print(allMemberUidList.length);

          return StreamBuilder<QuerySnapshot>(
            stream: _rankingStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Container(
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Scaffold(
                        backgroundColor: Colors.white,
                        body: Text("오류가 발생했습니다")),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Scaffold(
                        backgroundColor: Colors.white,
                        body: Text("")),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Scaffold(
                      backgroundColor: Colors.white,
                      body: Container(
                        height: _size.height - 200,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ExtendedImage.asset(
                                'assets/imgs/icons/icon_rankin_indi_nodata.png',
                                enableMemoryCache: true,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(7),
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                              Text("데이터가 없습니다"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              final document = snapshot.data!.docs;
              // 동점자인 경우 lastPassTime을 기준으로 최신 순으로 정렬
              final filteredDocuments = document.where((doc) {
                final uid = doc['uid'];
                return allMemberUidList.contains(uid);
              }).toList();
              print(filteredDocuments.length);

              final documents = widget.isKusbf == true ? filteredDocuments : document;

              documents.sort((a, b) {
                final aTotalScore = a['totalScore'] as int;
                final bTotalScore = b['totalScore'] as int;
                final aLastPassTime = a['lastPassTime'] as Timestamp?;
                final bLastPassTime = b['lastPassTime'] as Timestamp?;

                if (aTotalScore == bTotalScore) {
                  if (aLastPassTime != null && bLastPassTime != null) {
                    return bLastPassTime.compareTo(aLastPassTime);
                  }
                }

                return bTotalScore.compareTo(aTotalScore);
              });

              userRankingMap =  _liveMapController.calculateRankIndiAll2(userRankingDocs: documents);

              return Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (widget.isKusbf == false)
                                          ?'${_userModelController.resortNickname} 상위 TOP 3 유저' : 'KUSBF 상위 TOP 3 유저',
                                      style: TextStyle(
                                          color: Color(0xFF949494),
                                          fontSize: 12
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if(documents.length > 0)
                                          StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('user')
                                                .where('uid', isEqualTo: documents[0].get('uid'))
                                                .snapshots(),
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                              if (!snapshot.hasData || snapshot.data == null) {
                                                return  Container(
                                                  height: 154,
                                                  width: (_size.width - 40) / 3,
                                                );
                                              }
                                              else if (snapshot.data!.docs.isNotEmpty) {
                                                final userDoc = snapshot.data!.docs;
                                                return GestureDetector(
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userDoc[0]['uid'], favoriteResort: userDoc[0]['favoriteResort'],));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFDBE9FF),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    height: 154,
                                                    width: (_size.width - 48) / 3,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                            ? Container(
                                                          width: 58,
                                                          height: 58,
                                                          child: ExtendedImage.network(
                                                            userDoc[0]['profileImageUrl'],
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            width: 100,
                                                            height: 100,
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
                                                                    enableMemoryCache: true,
                                                                    shape: BoxShape.circle,
                                                                    width: 58,
                                                                    height: 58,
                                                                    fit: BoxFit.cover,
                                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                default:
                                                                  return null;
                                                              }
                                                            },
                                                          ),
                                                        )
                                                            : ExtendedImage.network(
                                                          '${profileImgUrlList[0].default_round}',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          width: 58,
                                                          height: 58,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        SizedBox(height: 14,),
                                                        ExtendedImage.asset(
                                                          'assets/imgs/icons/icon_crown_1.png',
                                                          width: 28,
                                                          height: 28,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                                          child: Text(
                                                            userDoc[0]['displayName'],
                                                            style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              else if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container(
                                                  height: 154,
                                                  width: (_size.width - 48) / 3,
                                                );
                                              } else {
                                                return Container(
                                                  height: 154,
                                                  width: (_size.width - 48) / 3,
                                                );
                                              }
                                            },
                                          ),
                                        SizedBox(width: 8,),
                                        if(documents.length > 1)

                                          StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('user')
                                                .where('uid', isEqualTo: documents[1].get('uid'))
                                                .snapshots(),
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                              if (!snapshot.hasData || snapshot.data == null) {
                                                return Center();
                                              } else if (snapshot.data!.docs.isNotEmpty) {
                                                final userDoc = snapshot.data!.docs;
                                                return GestureDetector(
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userDoc[0]['uid'], favoriteResort: userDoc[0]['favoriteResort'],));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFDBE9FF),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    height: 154,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                            ? Container(
                                                          width: 58,
                                                          height: 58,
                                                          child: ExtendedImage.network(
                                                            userDoc[0]['profileImageUrl'],
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            width: 100,
                                                            height: 100,
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
                                                                    enableMemoryCache: true,
                                                                    shape: BoxShape.circle,
                                                                    width: 58,
                                                                    height: 58,
                                                                    fit: BoxFit.cover,
                                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                default:
                                                                  return null;
                                                              }
                                                            },
                                                          ),
                                                        )
                                                            : ExtendedImage.network(
                                                          '${profileImgUrlList[0].default_round}',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          width: 58,
                                                          height: 58,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        SizedBox(height: 14,),
                                                        ExtendedImage.asset(
                                                          'assets/imgs/icons/icon_crown_2.png',
                                                          width: 28,
                                                          height: 28,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                                          child: Text(
                                                            userDoc[0]['displayName'],
                                                            style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    width: (_size.width - 48) / 3,
                                                  ),
                                                );
                                              } else if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container(
                                                  height: 154,
                                                  width: (_size.width - 48) / 3,
                                                );
                                              } else {
                                                return Container(
                                                  height: 154,
                                                  width: (_size.width - 48) / 3,
                                                );
                                              }
                                            },
                                          ),
                                        SizedBox(width: 8,),
                                        if(documents.length > 2)

                                          StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('user')
                                                .where('uid', isEqualTo: documents[2].get('uid'))
                                                .snapshots(),
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                              if (!snapshot.hasData || snapshot.data == null) {
                                                return Center();
                                              } else if (snapshot.data!.docs.isNotEmpty) {
                                                final userDoc = snapshot.data!.docs;
                                                return GestureDetector(
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userDoc[0]['uid'], favoriteResort: userDoc[0]['favoriteResort'],));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFDBE9FF),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    height: 154,
                                                    width: (_size.width - 48) / 3,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                            ? Container(
                                                          width: 58,
                                                          height: 58,
                                                          child: ExtendedImage.network(
                                                            userDoc[0]['profileImageUrl'],
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            width: 100,
                                                            height: 100,
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
                                                                    enableMemoryCache: true,
                                                                    shape: BoxShape.circle,
                                                                    width: 58,
                                                                    height: 58,
                                                                    fit: BoxFit.cover,
                                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                default:
                                                                  return null;
                                                              }
                                                            },
                                                          ),
                                                        )
                                                            : ExtendedImage.network(
                                                          '${profileImgUrlList[0].default_round}',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          width: 58,
                                                          height: 58,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        SizedBox(height: 14,),
                                                        ExtendedImage.asset(
                                                          'assets/imgs/icons/icon_crown_3.png',
                                                          width: 28,
                                                          height: 28,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                                          child: Text(
                                                            userDoc[0]['displayName'],
                                                            style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container(
                                                  height: 154,
                                                  width: (_size.width - 48) / 3,
                                                );
                                              } else {
                                                return Container(
                                                  height: 154,
                                                  width: (_size.width - 48) / 3,
                                                );
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 40,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if(widget.isKusbf == true)
                                          Text('KUSBF 개인 랭킹 TOP 100',
                                            style: TextStyle(
                                                color: Color(0xFF111111),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        if(widget.isKusbf == false)
                                          Text('${_userModelController.resortNickname} 개인 랭킹 TOP 100',
                                            style: TextStyle(
                                                color: Color(0xFF111111),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        GestureDetector(
                                          onTap: () async{
                                            Get.to(()=> RankingIndiAllScreen(isKusbf: widget.isKusbf,));
                                          },
                                          child: Text('전체 보기',
                                            style: TextStyle(
                                                color: Color(0xFF949494),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 18,),
                                    Container(
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: documents.length < 100 ? documents.length : 100,
                                        itemBuilder: (context, index) {
                                          final document = documents[index];
                                          return StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('user')
                                                .where('uid', isEqualTo: document.get('uid'))
                                                .snapshots(),
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                              if (!snapshot.hasData || snapshot.data == null) {
                                                return SizedBox.shrink();
                                              }
                                              final userDoc = snapshot.data!.docs;
                                              final userData = userDoc.isNotEmpty ? userDoc[0] : null;

                                              String? crewName = _allCrewDocsController.findCrewName(userData!['liveCrew'], _allCrewDocsController.allCrewDocs);

                                              if (userData == null) {
                                                return SizedBox.shrink();
                                              }

                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: InkWell(
                                                  highlightColor: Colors.transparent,
                                                  splashColor: Colors.transparent,
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        '${userRankingMap!['${userDoc[0]['uid']}']}',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                            color: Color(0xFF111111)
                                                        ),
                                                      ),
                                                      SizedBox(width: 14),
                                                      Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                            color: Color(0xFFDFECFF),
                                                            borderRadius: BorderRadius
                                                                .circular(50)
                                                        ),
                                                        child: userData['profileImageUrl'].isNotEmpty
                                                            ? ExtendedImage.network(
                                                          userData['profileImageUrl'],
                                                          enableMemoryCache: true,
                                                          cacheHeight: 200,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 48,
                                                          height: 48,
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
                                                                  enableMemoryCache: true,
                                                                  shape: BoxShape.circle,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  width: 48,
                                                                  height: 48,
                                                                  fit: BoxFit.cover,
                                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                              default:
                                                                return null;
                                                            }
                                                          },
                                                        )
                                                            : ExtendedImage.network(
                                                          '${profileImgUrlList[0].default_round}',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 3),
                                                        child: Container(
                                                          width: _size.width - 240,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(userData['displayName'],
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    color: Color(0xFF111111)
                                                                ),
                                                              ),
                                                              if(userData['liveCrew'] != '')
                                                                Text(crewName,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize: 12,
                                                                      color: Color(0xFF949494)
                                                                  ),)
                                                              // StreamBuilder<QuerySnapshot>(
                                                              //   stream: FirebaseFirestore.instance
                                                              //       .collection('liveCrew')
                                                              //       .where('crewID', isEqualTo: userData['liveCrew'])
                                                              //       .snapshots(),
                                                              //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                              //     if (snapshot.hasError) {
                                                              //       return Text("오류가 발생했습니다");
                                                              //     }
                                                              //
                                                              //     if (snapshot.connectionState == ConnectionState.waiting) {
                                                              //       return SizedBox.shrink();
                                                              //     }
                                                              //
                                                              //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                              //       return SizedBox.shrink();
                                                              //     }
                                                              //
                                                              //     var crewData = snapshot.data!.docs.first.data() as Map<String, dynamic>?;
                                                              //
                                                              //     // 크루명 가져오기
                                                              //     String crewName = crewData?['crewName'] ?? '';
                                                              //
                                                              //     return Text(crewName,
                                                              //       style: TextStyle(
                                                              //           fontSize: 12,
                                                              //           color: Color(0xFF949494)
                                                              //       ),
                                                              //     );
                                                              //   },
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(child: SizedBox()),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '${document.get('totalScore').toString()}점',
                                                            style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.normal,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          Transform.translate(
                                                            offset: Offset(6, 2),
                                                            child: ExtendedImage.network(
                                                              _rankingTierModelController.getBadgeAsset(
                                                                  percent: userRankingMap!['${userDoc[0]['uid']}']/(documents.length),
                                                                  totalScore: document.get('totalScore'),
                                                                  rankingTierList: rankingTierList
                                                              ),
                                                              enableMemoryCache: true,
                                                              fit: BoxFit.cover,
                                                              width: 40,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                    ],
                                                  ),
                                                ),

                                              );

                                            },
                                          );

                                        },
                                      ),
                                    ),
                                    SizedBox(height: 90),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: (){
                            Get.to(() => FriendDetailPage(uid: _userModelController.uid, favoriteResort: _userModelController.favoriteResort,));
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 0,
                                    blurRadius: 6,
                                    offset: Offset(0, 0), // changes position of shadow
                                  ),],
                                color: Color(0xFF3D83ED),
                              ),
                              height: 80,
                              child:  Obx(() => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child:
                                  (userRankingMap?['${_userModelController.uid}'] != null )
                                      ? Obx(() => Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${userRankingMap?['${_userModelController.uid}']}',
                                        style: TextStyle(
                                          color: Color(0xFFffffff),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        child: _userModelController.profileImageUrl!.isNotEmpty
                                            ? ExtendedImage.network(
                                          _userModelController.profileImageUrl!,
                                          enableMemoryCache: true,
                                          shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(8),
                                          width: 48,
                                          height: 48,
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
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.circle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                              default:
                                                return null;
                                            }
                                          },
                                        )
                                            : ExtendedImage.network(
                                          '${profileImgUrlList[0].default_round}',
                                          enableMemoryCache: true,
                                          shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(8),
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Container(
                                        width: _size.width - 246,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_userModelController.displayName}',
                                              style: TextStyle(
                                                color: Color(0xFFffffff),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 2,),
                                            if(_userModelController.stateMsg != '')
                                              Container(
                                                child: Text('${_userModelController.stateMsg}',
                                                  style: TextStyle(
                                                      color: Color(0xFFffffff).withOpacity(0.6),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.normal
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                width: _size.width - 246,
                                              )
                                          ],
                                        ),
                                      ),
                                      Expanded(child: SizedBox()),
                                      Obx(()=>Row(
                                        children: [
                                          Text(
                                            '${_myRankingController.totalScore}점',
                                            style: TextStyle(
                                              color: Color(0xFFffffff),
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(6, 2),
                                            child: ExtendedImage.network(
                                             _rankingTierModelController.getBadgeAsset(
                                                 percent:  userRankingMap?['${_userModelController.uid}'] / documents.length,
                                                 totalScore: _myRankingController.totalScore,
                                                 rankingTierList: rankingTierList
                                             ),
                                              enableMemoryCache: true,
                                              fit: BoxFit.cover,
                                              width: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ),
                                    ],
                                  ))
                                      : Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '',
                                        style: TextStyle(
                                          color: Color(0xFFffffff),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => FriendDetailPage(uid: _userModelController.uid, favoriteResort: _userModelController.favoriteResort,));
                                        },
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          child: _userModelController.profileImageUrl!.isNotEmpty
                                              ? ExtendedImage.network(
                                            _userModelController.profileImageUrl!,
                                            enableMemoryCache: true,
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: 48,
                                            height: 48,
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
                                                    enableMemoryCache: true,
                                                    shape: BoxShape.circle,
                                                    borderRadius: BorderRadius.circular(8),
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                default:
                                                  return null;
                                              }
                                            },
                                          )
                                              : ExtendedImage.network(
                                            '${profileImgUrlList[0].default_round}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_userModelController.displayName}',
                                            style: TextStyle(
                                              color: Color(0xFFffffff),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 2,),
                                          if(_userModelController.stateMsg != '')
                                            Container(
                                              child: Text('${_userModelController.stateMsg}',
                                                style: TextStyle(
                                                    color: Color(0xFFffffff).withOpacity(0.6),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              width: _size.width - 246,
                                            )
                                        ],
                                      ),
                                      Expanded(child: SizedBox()),
                                      Row(
                                        children: [
                                          Text(
                                            '점수가 없습니다.',
                                            style: TextStyle(
                                              color: Color(0xFFffffff),
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  )
                              ))
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }
}
