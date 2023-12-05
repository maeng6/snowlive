import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
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
import '../../controller/vm_rankingTierModelController.dart';
import '../../data/imgaUrls/Data_url_image.dart';
import '../../model/m_rankingTierModel.dart';
import '../more/friend/v_friendDetailPage.dart';

class RankingMyCrewScreen extends StatefulWidget {
  const RankingMyCrewScreen({Key? key}) : super(key: key);

  @override
  State<RankingMyCrewScreen> createState() => _RankingMyCrewScreenState();
}

class _RankingMyCrewScreenState extends State<RankingMyCrewScreen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  AllCrewDocsController _allCrewDocsController = Get.find<AllCrewDocsController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  //TODO: Dependency Injection**************************************************

  ScrollController _scrollController = ScrollController();

  Map<String, GlobalKey> itemKeys = {};

  GlobalKey myItemKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // GlobalKey for my item (logged-in user)
    myItemKey = GlobalKey();
  }

  Map? userRankingMap;

  void _scrollToMyRanking() {
    final myRanking = userRankingMap![_userModelController.uid];

    if (myRanking != null) {
      Scrollable.ensureVisible(myItemKey.currentContext!,
          duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
      print('My user ID: ${_userModelController.uid}'); // 현재 로그인된 사용자 ID 출력
      print('My ranking: $myRanking');
    }
  }

  Future<void> _refreshData() async {
    await _rankingTierModelController.getRankingDocs_crew();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    final document = _rankingTierModelController.rankingDocs_crewMember;
    final documents_all = _rankingTierModelController.rankingDocs;

    final userRankingMap =   _rankingTierModelController.userRankingMap;
    final userRankingMap_all = _rankingTierModelController.userRankingMap;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          GestureDetector(
            onTap: _scrollToMyRanking,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'My 랭킹',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D83ED)),
                ),
              ),
            ),
          ),
        ],
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
        title: Text(
          '크루원 랭킹',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: document!.map((document) {
                final itemKey = document['uid'] == _userModelController.uid
                    ? myItemKey
                    : GlobalKey();

                final userDoc = _allUserDocsController.allUserDocs;
                final Map<String, dynamic> userData = userDoc.isNotEmpty
                    ? userDoc.firstWhere(
                        (doc) => doc['uid'] == document['uid'],
                    orElse: () => <String, dynamic>{} // 빈 맵을 반환
                )
                    : <String, dynamic>{};

                return Padding(
                  key: itemKey, // Apply the key here
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: (){
                      Get.to(() =>
                          FriendDetailPage(uid: userData['uid'],
                            favoriteResort: userData['favoriteResort'],));
                    },
                    child: Row(
                      children: [
                        Text(
                          '${userRankingMap!['${userData['uid']}']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF111111)),
                        ),
                        SizedBox(width: 14),
                        Container(
                          width: 48,
                          height: 48,
                          child: userData['profileImageUrl'].isNotEmpty
                              ? Stack(
                            children: [
                              ExtendedImage.network(
                                userData['profileImageUrl'],
                                enableMemoryCache: true,
                                cacheHeight: 100,
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(8),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                loadStateChanged: (
                                    ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return SizedBox.shrink();
                                    case LoadState.completed:
                                      return state.completedWidget;
                                    case LoadState.failed:
                                      return ExtendedImage.network(
                                        '${profileImgUrlList[0].default_round}',
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(
                                            8),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                    default:
                                      return null;
                                  }
                                },
                              ),
                              (userData['isOnLive'] == true)
                                  ? Positioned(
                                child: Image.asset('assets/imgs/icons/icon_badge_live.png',
                                  width: 32,),
                                right: 0,
                                bottom: 0,
                              )
                                  : Container()
                            ],
                          )
                              : Stack(
                            children: [
                              ExtendedImage.network(
                                '${profileImgUrlList[0].default_round}',
                                enableMemoryCache: true,
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(8),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                              (userData['isOnLive'] == true)
                                  ? Positioned(
                                child: Image.asset('assets/imgs/icons/icon_badge_live.png',
                                  width: 32,),
                                right: 0,
                                bottom: 0,
                              )
                                  : Container()
                            ],
                          ),
                        ),
                        SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['displayName'],
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF111111)),
                              ),
                              if(userData['stateMsg'].isNotEmpty)
                                Text(userData['stateMsg'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF949494)
                                  ),)
                              // StreamBuilder<QuerySnapshot>(
                              //   stream: FirebaseFirestore.instance
                              //       .collection('liveCrew')
                              //       .where('crewID',
                              //       isEqualTo: userData['liveCrew'])
                              //       .snapshots(),
                              //   builder: (context,
                              //       AsyncSnapshot<QuerySnapshot> snapshot) {
                              //     if (snapshot.hasError) {
                              //       return Text("오류가 발생했습니다");
                              //     }
                              //
                              //     if (snapshot.connectionState ==
                              //         ConnectionState.waiting) {
                              //       return CircularProgressIndicator();
                              //     }
                              //
                              //     if (!snapshot.hasData ||
                              //         snapshot.data!.docs.isEmpty) {
                              //       return SizedBox();
                              //     }
                              //
                              //     var crewData = snapshot.data!.docs.first
                              //         .data() as Map<String, dynamic>?;
                              //
                              //     // 크루명 가져오기
                              //     String crewName =
                              //         crewData?['crewName'] ?? '';
                              //
                              //     return Text(
                              //       crewName,
                              //       style: TextStyle(
                              //           fontSize: 12,
                              //           color: Color(0xFF949494)),
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Text(
                          '${document['totalScore'].toString()}점',
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
                                percent: userRankingMap_all!['${userData['uid']}']/(documents_all!.length),
                                totalScore: document['totalScore'],
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

                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
