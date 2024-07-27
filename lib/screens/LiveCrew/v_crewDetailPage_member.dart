import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../controller/liveCrew/vm_liveCrewModelController.dart';
import '../../controller/liveCrew/vm_streamController_liveCrew.dart';
import '../more/friend/v_friendDetailPage.dart';
import '../snowliveDesignStyle.dart';

class CrewDetailPage_member extends StatefulWidget {
  CrewDetailPage_member({Key? key }) : super(key: key);

  @override
  State<CrewDetailPage_member> createState() => _CrewDetailPage_memberState();
}

class _CrewDetailPage_memberState extends State<CrewDetailPage_member> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  StreamController_liveCrew _streamController_liveCrew = Get.find<StreamController_liveCrew>();
  //TODO: Dependency Injection**************************************************


  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder(
            stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_member(),
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

                String leaderUid = leaderDoc.data()!['uid'];

                _userModelController.getCurrentUser(_userModelController.uid);

                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10,),
                      Text('멤버 ${crewMemberDocs.length}명',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: SDSColor.snowliveBlack
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
                            if(crewMemberDocs.isNotEmpty || crewMemberDocs != null)
                            {
                              return Column(
                                children: [
                                  InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: (){
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20), // 다이얼로그 모서리를 둥글게 설정
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            content: Stack(
                                              children: [
                                                Container(
                                                  width: 300,
                                                  height: 500,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage('assets/imgs/liveCrew/img_liveCrew_profileCard.png'), // 이미지 경로
                                                      fit: BoxFit.fill,
                                                    ),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 40),
                                                      Center(
                                                        child: (crewMemberDocs[index]['profileImageUrl'].isNotEmpty)
                                                            ? Stack(
                                                          children: [
                                                            Container(
                                                              width: 80,
                                                              height: 80,
                                                              decoration: BoxDecoration(
                                                                color: Color(0xFFDFECFF),
                                                                borderRadius: BorderRadius.circular(50),
                                                              ),
                                                              child: ExtendedImage.network(
                                                                crewMemberDocs[index]['profileImageUrl'],
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                cacheHeight: 150,
                                                                borderRadius: BorderRadius.circular(8),
                                                                width: 80,
                                                                height: 80,
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
                                                                        width: 80,
                                                                        height: 80,
                                                                        fit: BoxFit.cover,
                                                                      ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                    default:
                                                                      return null;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            if (crewMemberDocs[index]['isOnLive'] == true)
                                                              Positioned(
                                                                child: Image.asset(
                                                                  'assets/imgs/icons/icon_badge_live.png',
                                                                  width: 32,
                                                                ),
                                                                right: 0,
                                                                bottom: 0,
                                                              ),
                                                          ],
                                                        )
                                                            : Stack(
                                                          children: [
                                                            Container(
                                                              width: 80,
                                                              height: 80,
                                                              child: ExtendedImage.asset(
                                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                borderRadius: BorderRadius.circular(8),
                                                                width: 80,
                                                                height: 80,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                            if (crewMemberDocs[index]['isOnLive'] == true)
                                                              Positioned(
                                                                child: Image.asset(
                                                                  'assets/imgs/icons/icon_badge_live.png',
                                                                  width: 32,
                                                                ),
                                                                right: 0,
                                                                bottom: 0,
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Container(
                                                        width: MediaQuery.of(context).size.width - 260,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              crewMemberDocs[index]['displayName'],
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 20,
                                                                color: SDSColor.snowliveWhite,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: SDSColor.snowliveWhite,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                          '크루원 | ALLDOMAN',
                                                          style: TextStyle(
                                                            color: SDSColor.snowliveBlack,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 50),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                '크루 랭킹',
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Text(
                                                                '11등',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
                                                              ExtendedImage.asset(
                                                                'assets/imgs/ranking/icon_ranking_tier_S.png',
                                                                width: 37,
                                                                height: 37,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text(
                                                                '참여도 랭킹',
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Text(
                                                                '6등',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
                                                              ExtendedImage.asset(
                                                                'assets/imgs/ranking/icon_ranking_tier_S.png',
                                                                width: 37,
                                                                height: 37,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 20),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                '주종목',
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Text(
                                                                '해머라이딩',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text(
                                                                '가입일',
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Text(
                                                                '24.12.02',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 16, right: 16),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Colors.white, // 버튼 배경색
                                                            onPrimary: Colors.black, // 버튼 텍스트 색상
                                                            minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기 설정 (가로: 최대, 세로: 50)
                                                          ),
                                                          onPressed: () {
                                                            Get.to(() => FriendDetailPage(
                                                              uid: crewMemberDocs[index]['uid'],
                                                              favoriteResort: crewMemberDocs[index]['favoriteResort'],
                                                            ));
                                                          },
                                                          child: Text(
                                                            '프로필 보기',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: IconButton(
                                                    icon: ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_liveCrew_save.png',
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(8),
                                                      width: 25,
                                                      height: 25,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    onPressed: () {

                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );


                                        },
                                      );

                                    },
                                    child: Container(
                                      width: _size.width,
                                      child: Row(
                                        children: [
                                          (crewMemberDocs[index]['profileImageUrl'].isNotEmpty)
                                              ? Stack(
                                            children: [
                                              Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFDFECFF),
                                                      borderRadius: BorderRadius.circular(50)
                                                  ),
                                                  child: ExtendedImage.network(
                                                    crewMemberDocs[index]['profileImageUrl'],
                                                    enableMemoryCache: true,
                                                    shape: BoxShape.circle,
                                                    cacheHeight: 150,
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
                                              (crewMemberDocs[index]['isOnLive'] == true)
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
                                              Container(
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
                                              (crewMemberDocs[index]['isOnLive'] == true)
                                                  ? Positioned(
                                                child: Image.asset('assets/imgs/icons/icon_badge_live.png',
                                                  width: 32,),
                                                right: 0,
                                                bottom: 0,
                                              )
                                                  : Container()
                                            ],
                                          ),
                                          SizedBox(width: 15,),
                                          Container(
                                            width: _size.width - 260,
                                            child: Column(
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
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                              ],
                                            ),
                                          ),
                                          if(crewMemberDocs[index]['uid'] == leaderUid)
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: SDSColor.blue500,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                '크루장',
                                                style: SDSTextStyle.bold.copyWith(
                                                  color: SDSColor.snowliveWhite,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),

                                          Expanded(child: SizedBox()),
                                          Text('5회',
                                          style: TextStyle(
                                            fontSize: 19
                                          ),
                                          ),
                                          SizedBox(width: 5,),
                                          ExtendedImage.asset(
                                            'assets/imgs/ranking/icon_ranking_tier_S.png',
                                            width: 37,
                                            height: 37,
                                            fit: BoxFit.cover,
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index != crewMemberDocs.length - 1)
                                    SizedBox(height: 15,)
                                ],
                              );
                            }
                            else{
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
                                          '가입된 멤버가 없습니다',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
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
