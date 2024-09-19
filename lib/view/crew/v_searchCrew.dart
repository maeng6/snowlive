import 'dart:ffi';

import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_crewList.dart';
import 'package:com.snowlive/model/m_fleamarket.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SearchCrewView extends StatelessWidget {

  final SearchCrewViewModel _searchCrewViewModel = Get.find<SearchCrewViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  Get.back();
                  _searchCrewViewModel.textEditingController.clear(); // 텍스트 필드 클리어
                  _searchCrewViewModel.crewList.clear();
                  _searchCrewViewModel.showRecentSearch.value = true;  // 입력이 없으면 최근 검색어 보여주기
                },
              ),
              elevation: 0.0,
              titleSpacing: 0,
              centerTitle: true,
              title: Text('크루 검색',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            body: Column(
              children: [
                Obx(()=>Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _searchCrewViewModel.formKey,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextFormField(
                            onFieldSubmitted: (val) async {
                              if(val.isEmpty) {
                                _searchCrewViewModel.showRecentSearch.value = true;  // 검색어 없을 때 최근 검색어 노출
                              } else {
                                _searchCrewViewModel.showRecentSearch.value = false;  // 검색 결과 표시
                                await _searchCrewViewModel.searchCrews(val);
                                await _searchCrewViewModel.saveRecentSearch(val);
                              }
                            },
                            autofocus: true,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Color(0xff949494),
                            cursorHeight: 18,
                            cursorWidth: 2,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _searchCrewViewModel.textEditingController,
                            decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                prefixIcon: Icon(Icons.search, color: Color(0xFF666666)),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                ),
                                labelStyle: TextStyle(color: Color(0xff666666), fontSize: 15),
                                hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                hintText: ' 크루 검색',
                                labelText: '크루 검색',
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                                fillColor: Color(0xFFEFEFEF),
                                hoverColor: Colors.transparent,
                                filled: true,
                                focusColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                )),
                            validator: (val) {
                              if (val!.length <= 20 && val.length >= 1) {
                                return null;
                              } else if (val.length == 0) {
                                return '검색어를 입력해주세요.';
                              } else {
                                return '최대 입력 가능한 글자 수를 초과했습니다.';
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      if(_searchCrewViewModel.showRecentSearch.value)
                        Row(
                          children: [
                            Text('최근 검색',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            GestureDetector(
                                onTap: () async{
                                  await _searchCrewViewModel.deleteAllRecentSearches();
                                },
                                child: Text('전체삭제',
                                  style: TextStyle(
                                      color: SDSColor.gray500
                                  ),
                                )),
                          ],
                        ),
                      if(!_searchCrewViewModel.showRecentSearch.value)
                        Text('검색 결과',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        )
                    ],
                  ),
                ),),

                SizedBox(height: 20),
                Obx(
                      () => _searchCrewViewModel.showRecentSearch.value &&
                      _searchCrewViewModel.recentSearches.isNotEmpty
                      ? Expanded(
                    child: ListView.builder(
                      itemCount: _searchCrewViewModel.recentSearches.length,
                      itemBuilder: (context, index) {
                        String recentSearch = _searchCrewViewModel.recentSearches[index];
                        return ListTile(
                          title: Text(recentSearch),
                          trailing: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchCrewViewModel.deleteRecentSearch(recentSearch);
                            },
                          ),
                          onTap: () {
                            _searchCrewViewModel.textEditingController.text = recentSearch;
                            _searchCrewViewModel.search(recentSearch);
                            _searchCrewViewModel.searchCrews(recentSearch);
                            _searchCrewViewModel.showRecentSearch.value = false;  // 검색 결과로 전환
                          },
                        );
                      },
                    ),
                  )
                      : Container(),
                ),

                Expanded(
                  child: Obx(
                        () => (_searchCrewViewModel.crewList.isNotEmpty)
                        ? Scrollbar(
                      controller: _searchCrewViewModel.scrollController,
                      child: ListView.builder(
                        controller: _searchCrewViewModel.scrollController, // ScrollController 연결
                        itemCount: _searchCrewViewModel.crewList.length,
                        itemBuilder: (context, index) {
                          Crew data = _searchCrewViewModel.crewList[index];

                          return GestureDetector(
                              onTap: () async {
                                Get.toNamed(AppRoutes.crewMain);
                                await _crewDetailViewModel.fetchCrewDetail(
                                    data.crewId!, _friendDetailViewModel.seasonDate);
                                await _crewMemberListViewModel.fetchCrewMembers(
                                    crewId:  data.crewId!);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (data.crewLogoUrl!.isNotEmpty)
                                                GestureDetector(
                                                  onTap: () {
                                                  },
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          spreadRadius: 0,
                                                          blurRadius: 16,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    width: 40,
                                                    height: 40,
                                                    child: ExtendedImage.network(
                                                      data.crewLogoUrl!,
                                                      enableMemoryCache: true,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(10),
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              if (data.crewLogoUrl!.isEmpty)
                                                ExtendedImage.asset(
                                                  'assets/imgs/profile/img_profile_default_.png',
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.crewName!,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: SDSColor.snowliveBlack,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  if(data.description!.isNotEmpty)
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          data.description!,
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            color: SDSColor.gray500,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                              Expanded(child: SizedBox()),
                                              if(_userViewModel.user.crew_id == null)
                                                GestureDetector(
                                                  onTap: () {
                                                    // 버튼 클릭 시 실행할 동작
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), // 버튼 크기 설정
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
                                                      border: Border.all(
                                                        color: SDSColor.gray500, // 테두리 색상 (검정색으로 설정)
                                                        width: 0.5, // 테두리 두께 설정
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '가입신청',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold, // 텍스트 스타일 설정
                                                        color: Colors.black, // 텍스트 색상 설정
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_searchCrewViewModel.crewList.length != index + 1)
                                      SizedBox(height: 15,)
                                  ],
                                ),
                              )
                          );
                        },
                        padding: EdgeInsets.only(bottom: 80),
                      ),
                    )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
