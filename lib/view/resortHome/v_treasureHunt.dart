import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TreasureHuntView extends StatefulWidget {
  @override
  State<TreasureHuntView> createState() => _TreasureHuntViewState();
}

class _TreasureHuntViewState extends State<TreasureHuntView> {
  ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  Timer? _timer;
  String _hours = '00';
  String _minutes = '00';
  String _seconds = '00';
  DateTime? _currentEndTime;

  final ScrollController _scrollController_treasure = ScrollController();
  bool _isAppBarCollapsed_treasure = false;

  @override
  void initState() {
    super.initState();
    _resortHomeViewModel.getInfo_treasureHunt();
    _resortHomeViewModel.getInfo_treasureHunt_findList();

    _scrollController_treasure.addListener(() {
      if (_scrollController_treasure.offset > 300 && !_isAppBarCollapsed_treasure) {
        setState(() {
          _isAppBarCollapsed_treasure = true;
        });
      } else if (_scrollController_treasure.offset <= 300 && _isAppBarCollapsed_treasure) {
        setState(() {
          _isAppBarCollapsed_treasure = false;
        });
      }
    });
    _checkUserTreasureStatusAndShowPopup();
  }

  Future<void> _checkUserTreasureStatusAndShowPopup() async {
    final hasActiveTreasure = await _resortHomeViewModel.checkUserTreasureStatus();
    if (hasActiveTreasure) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('보물 찾기 성공!'),
            content: Text('내가 찾은 보물이 무엇인지 확인하러 가볼까요?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  Get.toNamed(AppRoutes.treasureHuntMyPage);
                  await _resortHomeViewModel.fetchTreasureRecords(
                    userId: _userViewModel.user.user_id,
                  );
                  await _resortHomeViewModel.updateAllActiveToFalse();
                },
                child: Text('이동하기'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _scrollController_treasure.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime endTime) {
    _timer?.cancel();
    _currentEndTime = endTime;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _updateRemainingTime(endTime);
      });
    });
  }

  void _updateRemainingTime(DateTime endTime) {
    final currentTime = DateTime.now();
    final difference = endTime.difference(currentTime);

    if (difference.isNegative) {
      _hours = '00';
      _minutes = '00';
      _seconds = '00';
      _timer?.cancel();
    } else {
      _hours = _twoDigits(difference.inHours);
      _minutes = _twoDigits(difference.inMinutes.remainder(60));
      _seconds = _twoDigits(difference.inSeconds.remainder(60));
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Widget _buildSingleDigitDisplay(String value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.symmetric(vertical: 16),
      width: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(String value) {
    return Row(
      children: [
        _buildSingleDigitDisplay(value[0]),
        _buildSingleDigitDisplay(value[1]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Obx(()=> Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
              color: _isAppBarCollapsed_treasure ? SDSColor.gray900 : SDSColor.snowliveWhite,
            ),
            onTap: () {
              Get.back();
            },
          ),
          titleSpacing: 0,
          backgroundColor: _isAppBarCollapsed_treasure ? SDSColor.snowliveWhite : Colors.transparent,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _resortHomeViewModel.infoStream_treasureHunt.value,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final data = snapshot.data!.data();
            final List<dynamic> participantsList = data?['participant'] ?? [];
            final DateTime endTime = (data?['end_time'] as Timestamp).toDate();
            final remain_treasure_count = data?['remain_treasure_count'] ?? 0;

            if (data == null) {
              return Center(child: Text('No data available'));
            }

            if (_currentEndTime == null || _currentEndTime != endTime) {
              _startTimer(endTime);
            }

            return SingleChildScrollView(
              controller: _scrollController_treasure,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 참가자 및 남은 보물 정보
                  Stack(
                    children: [
                      // 배경 이미지
                      Positioned(
                        child: ExtendedImage.network(
                          data['mainImage'] ?? '', // Background image URL
                          fit: BoxFit.cover, // 이미지가 잘리지 않게 설정
                        ),
                      ),

                      // 참가자 및 남은 보물 정보
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '탐험대 참가자',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '${participantsList.length}명',
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
                                    '남은 보물',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '${remain_treasure_count}개',
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
                        ),
                      ),
                    ],
                  ),

                  // 남은 시간
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Text(
                          '남은 시간',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeDisplay(_hours),
                            Text(
                              ':',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            _buildTimeDisplay(_minutes),
                            Text(
                              ':',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            _buildTimeDisplay(_seconds),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 완료한 탐험대원 목록
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '보물찾기를 완료한 탐험대원',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _resortHomeViewModel.infoStream_treasureHunt_findList.value,
                    builder: (context, findListSnapshot) {
                      if (findListSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (findListSnapshot.hasError) {
                        return Center(child: Text('Error: ${findListSnapshot.error}'));
                      }

                      if (findListSnapshot.hasData) {
                        final docs = findListSnapshot.data!.docs;

                        return Column(
                          children: docs.map((doc) {
                            final memberData = doc.data();
                            final String displayName = memberData['display_name'];
                            final String prizeName = memberData['prize_name'];
                            final DateTime dateTime = (memberData['datetime'] as Timestamp).toDate();

                            return ListTile(
                              leading: ExtendedImage.network(
                                memberData['profile_image_url_user'],
                                shape: BoxShape.circle,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                    // 로딩 중일 때 로딩 인디케이터를 표시
                                      return Shimmer.fromColors(
                                        baseColor: SDSColor.gray200!,
                                        highlightColor: SDSColor.gray50!,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    case LoadState.completed:
                                    // 로딩이 완료되었을 때 이미지 반환
                                      return state.completedWidget;
                                    case LoadState.failed:
                                    // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                      return  ExtendedImage.network(
                                        '${profileImgUrlList[0].default_round}', // 대체 이미지 경로
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                      );
                                  }
                                },
                              ),
                              title: Text(displayName),
                              subtitle: Text(prizeName),
                              trailing: Text('${dateTime.hour}:${dateTime.minute}:${dateTime.second}'),
                            );
                          }).toList(),
                        );
                      } else {
                        return Center(child: Text('No data available'));
                      }
                    },
                  ),
                  // 버튼
                  GestureDetector(
                    onTap: () async{
                      Get.toNamed(AppRoutes.treasureHuntMyPage);
                      await _resortHomeViewModel.fetchTreasureRecords(
                        userId: _userViewModel.user.user_id,
                      );
                      await _resortHomeViewModel.updateAllActiveToFalse();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '내가 찾은 보물',
                            style: TextStyle(
                              fontSize: 16,
                              color: SDSColor.snowliveWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    ));
  }
}
