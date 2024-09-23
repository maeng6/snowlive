import 'dart:ffi';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_crewList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchCrewView extends StatefulWidget {
  @override
  _SearchCrewViewState createState() => _SearchCrewViewState();
}

class _SearchCrewViewState extends State<SearchCrewView> {
  final SearchCrewViewModel _searchCrewViewModel = Get.find<SearchCrewViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();

  bool isSubmitButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    // TextEditingController의 변화를 감지하여 상태 업데이트
    _crewApplyViewModel.textEditingController.addListener(() {
      isSubmitButtonEnabled = _crewApplyViewModel.textEditingController.text.isNotEmpty;
    });
  }


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
            backgroundColor: SDSColor.snowliveWhite,
            appBar: AppBar(
              backgroundColor: SDSColor.snowliveWhite,
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  _searchCrewViewModel.textEditingController.clear();
                  _searchCrewViewModel.crewList.clear();
                  _searchCrewViewModel.showRecentSearch.value = true;
                  Get.back();
                },
              ),
              elevation: 0.0,
              titleSpacing: 0,
              centerTitle: true,
              title: Text(
                '크루 검색',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            body: Column(
              children: [
                Obx(
                      () => Padding(
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
                                if (val.isEmpty) {
                                  _searchCrewViewModel.showRecentSearch.value = true;  // 검색어 없을 때 최근 검색어 노출
                                } else {
                                  CustomFullScreenDialog.showDialog();
                                  _searchCrewViewModel.showRecentSearch.value = false;  // 검색 결과 표시
                                  await _searchCrewViewModel.searchCrews(val);
                                  await _searchCrewViewModel.saveRecentSearch(val);
                                  CustomFullScreenDialog.cancelDialog();
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
                                ),
                              ),
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
                        if (_searchCrewViewModel.showRecentSearch.value)
                          Row(
                            children: [
                              Text(
                                '최근 검색',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () async {
                                  CustomFullScreenDialog.showDialog();
                                  await _searchCrewViewModel.deleteAllRecentSearches();
                                  CustomFullScreenDialog.cancelDialog();
                                },
                                child: Text(
                                  '전체삭제',
                                  style: TextStyle(color: SDSColor.gray500),
                                ),
                              ),
                            ],
                          ),
                        if (!_searchCrewViewModel.showRecentSearch.value)
                          Text(
                            '검색 결과',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),

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
                          onTap: () async{
                            _searchCrewViewModel.textEditingController.text = recentSearch;
                            _searchCrewViewModel.search(recentSearch);
                            CustomFullScreenDialog.showDialog();
                            await _searchCrewViewModel.searchCrews(recentSearch);
                            CustomFullScreenDialog.cancelDialog();
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
                                CustomFullScreenDialog.showDialog();
                                await _crewDetailViewModel.fetchCrewDetail(
                                    data.crewId!, _friendDetailViewModel.seasonDate);
                                await _crewMemberListViewModel.fetchCrewMembers(crewId: data.crewId!);
                                CustomFullScreenDialog.cancelDialog();
                                Get.toNamed(AppRoutes.crewMain);
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
                                                  onTap: () {},
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
                                                Container(
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
                                                    '${crewDefaultLogoUrl['${data.color}']}',
                                                    enableMemoryCache: true,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(10),
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  ),
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
                                                  if (data.description!.isNotEmpty)
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
                                              if (_userViewModel.user.crew_id == null)
                                                GestureDetector(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true, // 전체 화면 크기 조절 가능
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(25.0),
                                                        ),
                                                      ),
                                                      builder: (BuildContext context) {
                                                        return WillPopScope(
                                                          onWillPop: () async{
                                                            _crewApplyViewModel.textEditingController.clear(); // 텍스트 클리어
                                                            _crewApplyViewModel.isSubmitButtonEnabled.value = false;
                                                            return true;
                                                          },
                                                          child: StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setState) {
                                                              return Container(
                                                                height: MediaQuery.of(context).size.height * 0.35,
                                                                child: Padding(
                                                                    padding: EdgeInsets.only(
                                                                      left: 16,
                                                                      right: 16,
                                                                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                                                                    ),
                                                                    child: Obx(()=>Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        SizedBox(height: 10),
                                                                        Container(
                                                                          width: 36,
                                                                          height: 4,
                                                                          margin: EdgeInsets.only(top: 8, bottom: 16),
                                                                          decoration: BoxDecoration(
                                                                            color: SDSColor.gray300,
                                                                            borderRadius: BorderRadius.circular(10),
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 10),
                                                                        Text(
                                                                          '해당 크루에 가입 신청을 하시겠어요? ',
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 20),
                                                                        TextFormField(
                                                                          controller: _crewApplyViewModel.textEditingController,
                                                                          onChanged: (value) {
                                                                            _crewApplyViewModel.isSubmitButtonEnabled.value = value.isNotEmpty; // 입력 여부에 따라 버튼 활성화 여부 결정
                                                                          },
                                                                          decoration: InputDecoration(
                                                                            hintText: '인사말을 남겨주세요.',
                                                                            hintStyle: TextStyle(color: SDSColor.gray500),
                                                                            filled: true,
                                                                            fillColor: SDSColor.gray100,
                                                                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                                            border: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              borderSide: BorderSide.none,
                                                                            ),
                                                                            focusedBorder: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              borderSide: BorderSide.none,
                                                                            ),
                                                                            enabledBorder: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              borderSide: BorderSide.none,
                                                                            ),
                                                                          ),
                                                                          maxLength: 100, // 최대 100자 제한
                                                                        ),
                                                                        SizedBox(height: 30),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: ElevatedButton(
                                                                                onPressed: () {
                                                                                  _crewApplyViewModel.textEditingController.clear();
                                                                                  _crewApplyViewModel.isSubmitButtonEnabled.value = false;
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text(
                                                                                  '돌아가기',
                                                                                  style: TextStyle(
                                                                                    color: Color(0xFFFFFFFF),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 16,
                                                                                  ),
                                                                                ),
                                                                                style: TextButton.styleFrom(
                                                                                  shape: const RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                  ),
                                                                                  elevation: 0,
                                                                                  splashFactory: InkRipple.splashFactory,
                                                                                  backgroundColor: Color(0xff7C899D),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 10),
                                                                            Expanded(
                                                                              child: ElevatedButton(
                                                                                onPressed: _crewApplyViewModel.isSubmitButtonEnabled.value == true
                                                                                    ? () async {
                                                                                  Navigator.pop(context);
                                                                                  CustomFullScreenDialog.showDialog();
                                                                                  await _crewApplyViewModel.applyForCrew(
                                                                                    data.crewId!,
                                                                                    _userViewModel.user.user_id,
                                                                                    _crewApplyViewModel.textEditingController.text,
                                                                                  );

                                                                                  _crewApplyViewModel.textEditingController.clear();
                                                                                  _crewApplyViewModel.isSubmitButtonEnabled.value = false;

                                                                                }
                                                                                    : null, // 버튼 비활성화 시 null
                                                                                child: Text(
                                                                                  '신청하기',
                                                                                  style: TextStyle(
                                                                                    color: Color(0xFFFFFFFF),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 16,
                                                                                  ),
                                                                                ),
                                                                                style: TextButton.styleFrom(
                                                                                  shape: const RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                  ),
                                                                                  elevation: 0,
                                                                                  splashFactory: InkRipple.splashFactory,
                                                                                  backgroundColor: _crewApplyViewModel.isSubmitButtonEnabled.value == true
                                                                                      ? SDSColor.snowliveBlue // 입력이 있을 때 버튼 활성화
                                                                                      : SDSColor.gray300, // 입력이 없을 때 버튼 비활성화
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),)
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 5, horizontal: 10), // 버튼 크기 설정
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
                                                      border: Border.all(
                                                        color: SDSColor.gray500, // 테두리 색상
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
                              ));
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
