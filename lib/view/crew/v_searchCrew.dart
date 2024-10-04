
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_crewList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

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
  final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();
  final AlarmCenterViewModel _alarmCenterViewModel = Get.find<AlarmCenterViewModel>();

  bool isSubmitButtonEnabled = false;

  FocusNode textFocus = FocusNode();

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

    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        textFocus.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: SDSColor.snowliveWhite,
          appBar: AppBar(
            backgroundColor: SDSColor.snowliveWhite,
            foregroundColor: SDSColor.snowliveWhite,
            surfaceTintColor: SDSColor.snowliveWhite,
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
            toolbarHeight: 44,
            title: Text(
              '크루 검색',
              style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18,
              ),
            ),
          ),
          body: Column(
            children: [
              Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _searchCrewViewModel.formKey,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 10),
                        child: Stack(
                          children: [
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextFormField(
                                onFieldSubmitted: (val) async {
                                  if (val.isNotEmpty) {
                                    CustomFullScreenDialog.showDialog();
                                    _searchCrewViewModel.showRecentSearch.value = false;  // 검색 결과 표시
                                    await _searchCrewViewModel.searchCrews(val);
                                    await _searchCrewViewModel.saveRecentSearch(val);
                                    CustomFullScreenDialog.cancelDialog();
                                  } else {}
                                },
                                autofocus: false,
                                focusNode: textFocus,
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor: SDSColor.snowliveBlue,
                                cursorHeight: 16,
                                cursorWidth: 2,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: SDSTextStyle.regular.copyWith(fontSize: 14),
                                controller: _searchCrewViewModel.textEditingController,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  errorMaxLines: 1,
                                  errorStyle: SDSTextStyle.regular.copyWith(fontSize: 0, color: SDSColor.red),
                                  labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                  hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                  hintText: ' 크루 검색',
                                  labelText: '크루 검색',
                                  contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 36, right: 12),
                                  fillColor: SDSColor.gray50,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: SDSColor.gray50),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: SDSColor.snowliveBlue, width: 1.5),
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
                            Positioned(
                              top: 0,
                              bottom: 0,
                              child: Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: Image.asset(
                                  'assets/imgs/icons/icon_search.png',
                                  width: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_searchCrewViewModel.showRecentSearch.value)
                      Row(
                        children: [
                          Text(
                            '최근 검색어',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray900,
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: () async {
                              textFocus.unfocus();
                              CustomFullScreenDialog.showDialog();
                              await _searchCrewViewModel.deleteAllRecentSearches();
                              CustomFullScreenDialog.cancelDialog();
                            },
                            child: Text(
                              '전체삭제',
                              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                            ),
                          ),
                        ],
                      ),
                    if (!_searchCrewViewModel.showRecentSearch.value)
                      Text(
                        '검색 결과',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
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
                      return GestureDetector(
                        onTap: () async {
                          textFocus.unfocus();
                          _searchCrewViewModel.textEditingController.text = recentSearch;
                          _searchCrewViewModel.search(recentSearch);
                          CustomFullScreenDialog.showDialog();
                          await _searchCrewViewModel.searchCrews(recentSearch);
                          CustomFullScreenDialog.cancelDialog();
                          _searchCrewViewModel.showRecentSearch.value = false; // 검색 결과로 전환
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16, right: 8),
                              child: Image.asset(
                                'assets/imgs/icons/icon_search.png',
                                color: SDSColor.gray400,
                                width: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                recentSearch,
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 16,
                                  color: SDSColor.gray900,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: SDSColor.gray500,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchCrewViewModel.deleteRecentSearch(recentSearch);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                )
                    : Container(),
              ),
              Obx(() => (_searchCrewViewModel.crewList.isNotEmpty)
                  ? Expanded(
                child: Scrollbar(
                  controller: _searchCrewViewModel.scrollController,
                  child: ListView.builder(
                    controller: _searchCrewViewModel.scrollController, // ScrollController 연결
                    itemCount: _searchCrewViewModel.crewList.length,
                    itemBuilder: (context, index) {
                      Crew data = _searchCrewViewModel.crewList[index];

                      Size _size = MediaQuery.of(context).size;

                      return GestureDetector(
                          onTap: () async {
                            textFocus.unfocus();
                            Get.toNamed(AppRoutes.crewMain);
                            await _crewMemberListViewModel.fetchCrewMembers(crewId: data.crewId!);
                            await _crewDetailViewModel.fetchCrewDetail(
                                data.crewId!, _friendDetailViewModel.seasonDate);
                            if(_userViewModel.user.crew_id == data.crewId!)
                              await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                                  data.crewId!,
                                  '${DateTime.now().year}'
                              );

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
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (data.crewLogoUrl!.isNotEmpty)
                                            GestureDetector(
                                              onTap: () async{
                                                textFocus.unfocus();
                                                Get.toNamed(AppRoutes.crewMain);
                                                await _crewMemberListViewModel.fetchCrewMembers(crewId: data.crewId!);
                                                await _crewDetailViewModel.fetchCrewDetail(
                                                    data.crewId!, _friendDetailViewModel.seasonDate);
                                                if(_userViewModel.user.crew_id == _crewDetailViewModel.crewDetailInfo.crewId!)
                                                  await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                                                      _crewDetailViewModel.crewDetailInfo.crewId!,
                                                      '${DateTime.now().year}'
                                                  );

                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                        color: SDSColor.gray100
                                                    )
                                                ),
                                                width: 44,
                                                height: 44,
                                                child: ExtendedImage.network(
                                                  data.crewLogoUrl!,
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(10),
                                                  width: 44,
                                                  height: 44,
                                                  fit: BoxFit.cover,
                                                  loadStateChanged: (ExtendedImageState state) {
                                                    switch (state.extendedImageLoadState) {
                                                      case LoadState.loading:
                                                      // 로딩 중일 때 로딩 인디케이터를 표시
                                                        return Shimmer.fromColors(
                                                          baseColor: SDSColor.gray200!,
                                                          highlightColor: SDSColor.gray50!,
                                                          child: Container(
                                                            width: 110,
                                                            height: 110,
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
                                                        return ExtendedImage.network(
                                                          '${crewDefaultLogoUrl['${data.color}']}', // 대체 이미지 경로
                                                          width: 110,
                                                          height: 110,
                                                          fit: BoxFit.cover,
                                                        );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          if (data.crewLogoUrl!.isEmpty)
                                            GestureDetector(
                                              onTap: () async{
                                                textFocus.unfocus();
                                                Get.toNamed(AppRoutes.crewMain);
                                                await _crewMemberListViewModel.fetchCrewMembers(crewId: data.crewId!);
                                                await _crewDetailViewModel.fetchCrewDetail(
                                                    data.crewId!, _friendDetailViewModel.seasonDate);

                                                if(_userViewModel.user.crew_id == _crewDetailViewModel.crewDetailInfo.crewId!)
                                                  await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                                                      _crewDetailViewModel.crewDetailInfo.crewId!,
                                                      '${DateTime.now().year}'
                                                  );

                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                        color: SDSColor.gray100
                                                    )
                                                ),
                                                width: 44,
                                                height: 44,
                                                child: ExtendedImage.network(
                                                  '${crewDefaultLogoUrl['${data.color}']}',
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(10),
                                                  width: 44,
                                                  height: 44,
                                                  fit: BoxFit.cover,
                                                  loadStateChanged: (ExtendedImageState state) {
                                                    switch (state.extendedImageLoadState) {
                                                      case LoadState.loading:
                                                      // 로딩 중일 때 로딩 인디케이터를 표시
                                                        return Shimmer.fromColors(
                                                          baseColor: SDSColor.gray200!,
                                                          highlightColor: SDSColor.gray50!,
                                                          child: Container(
                                                            width: 110,
                                                            height: 110,
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
                                                        return ExtendedImage.network(
                                                          '${crewDefaultLogoUrl['${data.color}']}', // 대체 이미지 경로
                                                          width: 110,
                                                          height: 110,
                                                          fit: BoxFit.cover,
                                                        );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          SizedBox(width: 12),
                                          Container(
                                            height: 44,
                                            width: _size.width - 180,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  data.crewName!,
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 15,
                                                    color: SDSColor.gray900,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                if (data.description != '' && data.description !=null)
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        data.description ?? '',
                                                        style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 12,
                                                          color: SDSColor.gray500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          if (_userViewModel.user.crew_id == null)
                                            GestureDetector(
                                              onTap: () {
                                                textFocus.unfocus();
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  context: context,
                                                  builder: (context) => WillPopScope(
                                                    onWillPop: () async {
                                                      _crewApplyViewModel.textEditingController.clear(); // 텍스트 클리어
                                                      _crewApplyViewModel.isSubmitButtonEnabled.value = false;
                                                      return true;
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                          color: SDSColor.snowliveWhite,
                                                        ),
                                                        padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                                                        height: 290,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(bottom: 20),
                                                                  child: Container(
                                                                    height: 4,
                                                                    width: 36,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      color: SDSColor.gray200,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '해당 크루에 가입 신청을 하시겠어요?',
                                                                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(height: 8),
                                                                Text(
                                                                  '프로필 이미지를 나중에 설정 하시려면,\n기본 이미지로 설정해주세요.',
                                                                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500, height: 1.4),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                TextFormField(
                                                                  controller: _crewApplyViewModel.textEditingController,
                                                                  textAlignVertical: TextAlignVertical.center,
                                                                  cursorColor: SDSColor.snowliveBlue,
                                                                  cursorHeight: 16,
                                                                  cursorWidth: 2,
                                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                  style: SDSTextStyle.regular.copyWith(fontSize: 15),
                                                                  strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                                                  onChanged: (value) {
                                                                    _crewApplyViewModel.isSubmitButtonEnabled.value = value.isNotEmpty; // 입력 여부에 따라 버튼 활성화 여부 결정
                                                                  },
                                                                  decoration: InputDecoration(
                                                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                    errorMaxLines: 2,
                                                                    errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                                                    labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                                                    hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                                                    hintText: '인사말을 남겨주세요.',
                                                                    contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
                                                                    fillColor: SDSColor.gray50,
                                                                    hoverColor: SDSColor.snowliveBlue,
                                                                    filled: true,
                                                                    focusColor: SDSColor.snowliveBlue,
                                                                    border: OutlineInputBorder(
                                                                      borderSide: BorderSide(color: SDSColor.gray50),
                                                                      borderRadius: BorderRadius.circular(6),
                                                                    ),
                                                                    errorBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(color: Colors.transparent),
                                                                      borderRadius: BorderRadius.circular(6),
                                                                    ),
                                                                  ),
                                                                  maxLength: 50, // 최대 100자 제한
                                                                  validator: (val) {
                                                                    if (val!.length <= 50) {
                                                                      return null;
                                                                    }  else {
                                                                      return '최대 입력 가능한 글자 수를 초과했습니다.';
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            Expanded(child: Container()),
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      _crewApplyViewModel.textEditingController.clear();
                                                                      _crewApplyViewModel.isSubmitButtonEnabled.value = false;
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      '돌아가기',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                          color: SDSColor.snowliveWhite,
                                                                          fontSize: 16),
                                                                    ),
                                                                    style: TextButton.styleFrom(
                                                                        shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                        ),
                                                                        splashFactory: InkRipple.splashFactory,
                                                                        elevation: 0,
                                                                        minimumSize: Size(100, 56),
                                                                        backgroundColor: SDSColor.sBlue500
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed:  () async {
                                                                      Navigator.pop(context); // 팝업 닫기
                                                                      CustomFullScreenDialog.showDialog();
                                                                      await _crewApplyViewModel.applyForCrew(
                                                                          data.crewId!,
                                                                          _userViewModel.user.user_id,
                                                                          _crewApplyViewModel.textEditingController.text,
                                                                          data.crewLeaderUserId!
                                                                      );
                                                                      _crewApplyViewModel.textEditingController.clear();
                                                                      _crewApplyViewModel.isSubmitButtonEnabled.value = false;
                                                                    },
                                                                    child: Text(
                                                                      '신청하기',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                          color: SDSColor.snowliveWhite,
                                                                          fontSize: 16),
                                                                    ),
                                                                    style: TextButton.styleFrom(
                                                                        shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                        ),
                                                                        splashFactory: InkRipple.splashFactory,
                                                                        elevation: 0,
                                                                        minimumSize: Size(100, 56),
                                                                        backgroundColor:  SDSColor.snowliveBlue // 입력이 있을 때 버튼 활성화
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 10,),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 32,
                                                width: 70,
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: SDSColor.gray200
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '가입신청',
                                                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (_searchCrewViewModel.crewList.length != index + 1)
                                  SizedBox(height: 18)
                              ],
                            ),
                          ));
                    },
                    padding: EdgeInsets.only(bottom: 60),
                  ),
                ),
              )
                  :
              (_searchCrewViewModel.showRecentSearch.value == false)
                  ? Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/imgs/icons/icon_nodata.png',
                        scale: 4,
                        width: 73,
                        height: 73,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text('"${_searchCrewViewModel.textEditingController.text}"에 대한 검색 결과가 없습니다.',
                        style: SDSTextStyle.regular.copyWith(
                            fontSize: 14,
                            color: SDSColor.gray600,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text('다른 검색어를 입력해 보세요',
                        style: SDSTextStyle.regular.copyWith(
                            fontSize: 14,
                            color: SDSColor.gray600
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Container()
              ),
            ],
          ),
        ),
      ),
    );
  }
}
