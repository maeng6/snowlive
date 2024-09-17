import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/view/friend/v_profilePageCalendar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/public/vm_DialogController_resortHome.dart';
import 'package:com.snowlive/controller/friends/vm_friendsCommentController.dart';
import 'package:com.snowlive/controller/ranking/vm_liveMapController.dart';
import 'package:com.snowlive/controller/resort/vm_resortModelController.dart';
import 'package:com.snowlive/controller/public/vm_timeStampController.dart';
import 'package:com.snowlive/screens/common/v_profileImageScreen.dart';
import '../../../controller/alarm/vm_alarmCenterController.dart';
import '../../../controller/user/vm_allUserDocsController.dart';
import '../../../controller/liveCrew/vm_liveCrewModelController.dart';
import '../../../controller/ranking/vm_rankingTierModelController.dart';
import '../../../controller/friends/vm_streamController_friend.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model_2/m_alarmCenterModel.dart';
import '../../../model/m_crewLogoModel.dart';
import '../../../model_2/m_rankingTierModel.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../../LiveCrew/v_crewDetailPage_screen.dart';
import '../../snowliveDesignStyle.dart';
import '../v_setProfileImage_moreTab.dart';

class FriendDetailPage extends StatefulWidget {
  FriendDetailPage({Key? key, required this.uid, required this.favoriteResort}) : super(key: key);

  String? uid;
  int? favoriteResort;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {

  //TODO: Dependency Injection**************************************************
  StreamController_Friend _streamController_Friend = Get.find<StreamController_Friend>();
  //TODO: Dependency Injection**************************************************


  final _formKeyProfile = GlobalKey<FormState>();
  final _formKeyProfile2 = GlobalKey<FormState>();
  final _formKeyProfile4 = GlobalKey<FormState>();
  final _stateMsgController = TextEditingController();
  final _friendTalkController = TextEditingController();
  final _displayNameController = TextEditingController();
  var _newComment = '';
  bool edit= false;
  String _initStateMsg='';
  String _initialDisplayName='';
  bool isPassDataZero=false;
  Map? userRankingMap;
  var myCrewAsset;
  String? lastPassTimeString;
  bool? isCheckedDispName;

  List<bool> isTap = [
    true,
    false,
  ];

  List<bool> isTapStats = [
    true,
    false,
    false
  ];

  Map? userRankingMap_all;
  List? documents_all;

  List<String> dateItems = []; // 날짜 아이템 목록

  var _selectedDateName = '';

  String? lastDateItem;



  Future<void> _onRefresh() async {
    CustomFullScreenDialog.showDialog();
    await _userModelController.getCurrentUser(_userModelController.uid);

    if (mounted) setState(() {});
    CustomFullScreenDialog.cancelDialog();
  }

  @override
  void initState() {
    super.initState();
    fetchDateItems();
    _stateMsgController.text = '';
    _friendTalkController.text = '';
    _displayNameController.text = '';
    _initStateMsg = _userModelController.stateMsg!;
    _initialDisplayName = _userModelController.displayName!;

  }

  Future<void> fetchDateItems() async {
    List<String> filteredDateItems = await _streamController_Friend.fetchFilteredDateItems(widget.uid!, widget.favoriteResort!);
    setState(() {
      dateItems = filteredDateItems;
      _selectedDateName = dateItems.isNotEmpty ? dateItems.last : '데이터 없음';
    });
  }


  _showCupertinoPicker() async {
    List<String> filteredData = dateItems; // 초기에는 전체 데이터를 보여줍니다.
    String today = DateFormat('yyyyMMdd').format(DateTime.now());

    await showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 200,
          maxHeight: 520,
        ),
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // 전체를 보여주기 위해 날짜 목록을 초기화합니다.
                      setState(() {
                        filteredData = dateItems;
                        _selectedDateName = dateItems.isNotEmpty ? dateItems.last : '데이터 없음';
                        isTapStats[0] = true;
                        isTapStats[1] = false;
                        isTapStats[2] = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('전체'),
                  ),
                  for (String date in dateItems)
                    CupertinoActionSheetAction(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        // 선택한 날짜에 따라 필터링된 데이터를 업데이트합니다.
                        setState(() {
                          filteredData = [date];
                          _selectedDateName = date;
                          isTapStats[0] = false;
                          isTapStats[1] = true;
                          isTapStats[2] = true;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(date), // 각 날짜 항목을 별도의 타일로 표시합니다.
                    ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('닫기'),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      // 필터링된 데이터를 사용하여 화면을 업데이트합니다.
      _streamController_Friend.setupStreams_friendDetailPage_rank_daily(widget.favoriteResort!, dateItems, _selectedDateName, widget.uid!);
    });
  }




  //TODO: Dependency Injection**************************************************
  DialogController _dialogController = Get.find<DialogController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  FriendsCommentModelController _friendsCommentModelController = Get.find<FriendsCommentModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading:
          (edit == false)
              ? GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
              ],
            ),
            onTap: () {
              Get.back();
            },
          )
              : GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('취소', style: TextStyle(fontSize: 16, color: Color(0xFF111111), fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                edit=false;
              });
            },
          ),
          actions: [
            if(edit == true)
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('완료', style: TextStyle(fontSize: 16, color: Color(0xFF111111), fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                onTap: () async{
                  CustomFullScreenDialog.showDialog();
                  try {
                    if(_displayNameController.text == '' || _displayNameController.text ==null) {
                      await _userModelController.updateNickname(_userModelController.displayName);
                    }else{
                      await _userModelController.updateNickname(_displayNameController.text);
                    }
                    await _userModelController.updateStateMsg(_stateMsgController.text);
                    await _userModelController.getCurrentUser(_userModelController.uid);
                    _stateMsgController.clear();
                    _displayNameController.clear();
                    await _allUserDocsController.getAllUserDocs();
                  } catch (e) {
                    CustomFullScreenDialog.cancelDialog();
                  }
                  setState(() {
                    edit=false;
                  });
                  CustomFullScreenDialog.cancelDialog();
                  print('프로필 변경완료');
                },
              ),
          ],
          elevation: 0.0,
          titleSpacing: 0,
          centerTitle: true,
          toolbarHeight: 58.0, // 이 부분은 AppBar의 높이를 조절합니다.
        ),
        body: RefreshIndicator(
          strokeWidth: 2,
          edgeOffset: 40,
          onRefresh: _onRefresh,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Container(
                height: _size.height,
                width: _size.width,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: (){
                        FocusScope.of(context).unfocus();
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            StreamBuilder(
                                stream: _streamController_Friend.setupStreams_friendDetailPage_user(widget.uid!),
                                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                                    return SizedBox.shrink();
                                  }
                                  final friendDocs = snapshot.data!.docs;
                                  final List whoInviteMe = friendDocs[0]['whoInviteMe'];
                                  return  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Column(
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  children: [
                                                    (friendDocs[0]['profileImageUrl'].isNotEmpty)
                                                        ? GestureDetector(
                                                      onTap: () {
                                                        if(edit == true){
                                                          Get.to(() => SetProfileImage_moreTab());
                                                        }
                                                        else {
                                                          Get.to(() =>
                                                              ProfileImageView(
                                                                  userProfileUrl: friendDocs[0]['profileImageUrl']));
                                                        }
                                                      },
                                                      child: Container(
                                                          width: 110,
                                                          height: 110,
                                                          decoration: BoxDecoration(
                                                              color: Color(0xFFDFECFF),
                                                              borderRadius: BorderRadius.circular(80)
                                                          ),
                                                          child: ExtendedImage.network(
                                                            friendDocs[0]['profileImageUrl'],
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            borderRadius: BorderRadius.circular(8),
                                                            width: 110,
                                                            height: 110,
                                                            fit: BoxFit.cover,
                                                            loadStateChanged: (ExtendedImageState state) {
                                                              switch (state.extendedImageLoadState) {
                                                                case LoadState.loading:
                                                                  return SizedBox.shrink();
                                                                case LoadState.completed:
                                                                  return state.completedWidget;
                                                                case LoadState.failed:
                                                                  return ExtendedImage.network(
                                                                    'https://i.esdrop.com/d/f/yytYSNBROy/NIlGn0N46O.png',
                                                                    shape: BoxShape.circle,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    width: 110,
                                                                    height: 110,
                                                                    fit: BoxFit.cover,
                                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                default:
                                                                  return null;
                                                              }
                                                            },
                                                          )),
                                                    )
                                                        :  GestureDetector(
                                                      onTap: () {
                                                        if(edit == true){
                                                          Get.to(() => SetProfileImage_moreTab());
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 110,
                                                        height: 110,
                                                        child: ExtendedImage.network(
                                                          'https://i.esdrop.com/d/f/yytYSNBROy/NIlGn0N46O.png',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 110,
                                                          height: 110,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    if(edit == true)
                                                      Positioned(
                                                        top: 68,
                                                        left: 68,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            Get.to(() => SetProfileImage_moreTab());
                                                          },
                                                          icon: Image.asset(
                                                            'assets/imgs/icons/icon_profile_add.png',
                                                            height: 24,
                                                            width: 24,
                                                          ),
                                                          style: TextButton.styleFrom(
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                  side: BorderSide(color: Color(0xFFDEDEDE))
                                                              ),
                                                              elevation: 0,
                                                              splashFactory: InkRipple.splashFactory,
                                                              minimumSize: Size(82, 36),
                                                              backgroundColor:
                                                              Color(0xffffffff)),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 6),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            (edit == true)
                                                                ? Text(_initialDisplayName,
                                                              style: TextStyle(
                                                                  fontSize: 22,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFF111111)
                                                              ),)
                                                                : Text('${friendDocs[0]['displayName']}',
                                                              style: TextStyle(
                                                                  fontSize: 22,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFF111111)
                                                              ),),
                                                            if(friendDocs[0]['displayName'] == 'SNOWLIVE')
                                                              Padding(
                                                                padding: const EdgeInsets.only(left : 2.0),
                                                                child: Image.asset(
                                                                  'assets/imgs/icons/icon_snowlive_operator.png',
                                                                  scale: 5.5,
                                                                ),
                                                              ),
                                                            if(edit == true)
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    _displayNameController.clear();
                                                                    showModalBottomSheet(
                                                                      context: context,
                                                                      isScrollControlled: true,
                                                                      builder: (BuildContext context) {
                                                                        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                                                                        return SafeArea(
                                                                          child: Container(
                                                                            height: 224 + keyboardHeight,
                                                                            child: Padding(
                                                                              padding: EdgeInsets.only(left: 20, right: 20),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    height: 24,
                                                                                  ),
                                                                                  Text(
                                                                                    '변경할 활동명을 입력해주세요.',
                                                                                    style: TextStyle(
                                                                                        fontSize: 16,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: Color(
                                                                                            0xFF111111)),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 18,
                                                                                  ),
                                                                                  Container(
                                                                                    height: 100,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      children: [
                                                                                        Form(
                                                                                          key: _formKeyProfile,
                                                                                          child:
                                                                                          TextFormField(
                                                                                            onTap: (){
                                                                                              _displayNameController.selection =
                                                                                                  TextSelection.fromPosition(
                                                                                                      TextPosition(offset: _displayNameController.text.length));
                                                                                            },
                                                                                            cursorColor: Color(0xff377EEA),
                                                                                            cursorHeight: 16,
                                                                                            cursorWidth: 2,
                                                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                            controller: _displayNameController..text = _initialDisplayName,
                                                                                            strutStyle:
                                                                                            StrutStyle(leading: 0.3),
                                                                                            decoration: InputDecoration(
                                                                                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                errorStyle: TextStyle(fontSize: 12,),
                                                                                                labelStyle: TextStyle(color: Color(0xff666666), fontSize: 15),
                                                                                                hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                                                                                hintText: '활동명 입력',
                                                                                                labelText: '활동명',
                                                                                                contentPadding: EdgeInsets.only(
                                                                                                    top: 14, bottom: 8, left: 16, right: 16),
                                                                                                fillColor: Color(0xFFEFEFEF),
                                                                                                hoverColor: Colors.transparent,
                                                                                                filled: true,
                                                                                                focusColor: Colors.transparent,
                                                                                                border: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                                                                                  borderRadius: BorderRadius.circular(6),
                                                                                                ),
                                                                                                errorBorder:  OutlineInputBorder(
                                                                                                  borderSide: BorderSide(color: Colors.transparent),
                                                                                                ),
                                                                                                focusedBorder:  OutlineInputBorder(
                                                                                                  borderSide: BorderSide(color: Colors.transparent),
                                                                                                ),
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(color: Colors.transparent),
                                                                                                  borderRadius: BorderRadius.circular(6),
                                                                                                )),
                                                                                            validator: (val) {
                                                                                              if (val!.length <= 8 && val.length >= 1) {
                                                                                                return null;
                                                                                              } else if (val.length == 0) {
                                                                                                return '닉네임을 입력해주세요.';
                                                                                              } else {
                                                                                                return '최대 글자 수를 초과했습니다.';
                                                                                              }
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(top: 8),
                                                                                          child: Text(
                                                                                            '최대 8글자까지 입력 가능합니다.',
                                                                                            style: TextStyle(
                                                                                                color: Color(0xff949494),
                                                                                                fontSize: 12),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: InkWell(
                                                                                          child: ElevatedButton(
                                                                                            onPressed: () {
                                                                                              _displayNameController.text =
                                                                                              _userModelController.displayName!;
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text(
                                                                                              '취소',
                                                                                              style: TextStyle(
                                                                                                  color: Color(0xFF3D83ED),
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            style: TextButton.styleFrom(
                                                                                                splashFactory: InkRipple.splashFactory,
                                                                                                elevation: 0,
                                                                                                minimumSize: Size(100, 56),
                                                                                                backgroundColor: Color(0xFF3D83ED).withOpacity(0.2),
                                                                                                padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: 10,
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: InkWell(
                                                                                          child:
                                                                                          ElevatedButton(
                                                                                            onPressed: () async{
                                                                                              if (_formKeyProfile.currentState!.validate()) {
                                                                                                isCheckedDispName =  await _userModelController.checkDuplicateDisplayName(_displayNameController.text);
                                                                                                if (isCheckedDispName == true) {
                                                                                                  setState(() {
                                                                                                    _initialDisplayName = _displayNameController.text;
                                                                                                  });
                                                                                                  FocusScope.of(context).unfocus();
                                                                                                  Navigator.pop(context);
                                                                                                } else {
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
                                                                                                      '이미 존재하는 활동명입니다.\n다른 활동명을 입력해주세요.',
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
                                                                                                }
                                                                                              } else {
                                                                                                Get.snackbar(
                                                                                                    '입력 실패',
                                                                                                    '올바른 활동명을 입력해 주세요',
                                                                                                    snackPosition: SnackPosition.BOTTOM,
                                                                                                    margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                                                                                    backgroundColor: Colors.black87,
                                                                                                    colorText: Colors.white,
                                                                                                    duration: Duration(milliseconds: 3000));
                                                                                              }
                                                                                            },
                                                                                            child: Text('변경',
                                                                                              style: TextStyle(
                                                                                                  color: Colors.white,
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            style: TextButton.styleFrom(
                                                                                                splashFactory:
                                                                                                InkRipple.splashFactory,
                                                                                                elevation: 0,
                                                                                                minimumSize: Size(100, 56),
                                                                                                backgroundColor: Color(0xFF3D83ED),
                                                                                                padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        left: 4),
                                                                    child: Image.asset(
                                                                      'assets/imgs/icons/icon_edit_pencil.png',
                                                                      height: 20,
                                                                      width: 20,
                                                                    ),
                                                                  )),
                                                          ],
                                                        ),

                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 2),
                                                        child: Text(
                                                          '${_resortModelController.getResortName(friendDocs[0]['resortNickname'])} · ${_liveCrewModelController.crewName}',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color(0xFF949494),
                                                              fontWeight: FontWeight.normal),
                                                        ),
                                                      ),

                                                      if( _userModelController.uid == friendDocs[0]['uid'])
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 6),
                                                          child: Container(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                (edit == true)
                                                                    ? ConstrainedBox(
                                                                  constraints: BoxConstraints(
                                                                    maxWidth: _size.width * 0.5,
                                                                  ),
                                                                      child: Container(
                                                                  child: Text(_initStateMsg, style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: SDSColor.gray500),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                    )
                                                                    :
                                                                (_initStateMsg.isNotEmpty)
                                                                    ? ConstrainedBox(
                                                                  constraints: BoxConstraints(
                                                                    maxWidth: _size.width * 0.5,
                                                                  ),
                                                                      child: Container(
                                                                      child: Text('${friendDocs[0]['stateMsg']}', style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: SDSColor.gray500),
                                                                        maxLines: 2,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                ),
                                                                    )
                                                                    :SizedBox.shrink(),
                                                                if(edit == true)
                                                                  GestureDetector(
                                                                      onTap: () {
                                                                        _stateMsgController.clear();
                                                                        showModalBottomSheet(
                                                                          context: context,
                                                                          isScrollControlled: true,
                                                                          builder: (BuildContext context) {
                                                                            final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                                                                            return SafeArea(
                                                                              child: Container(
                                                                                height: 224 + keyboardHeight, // 키보드 높이만큼 추가 높이 적용
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.only(
                                                                                    left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom,),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        height: 24,
                                                                                      ),
                                                                                      Text(
                                                                                        '상태메세지를 입력해 주세요',
                                                                                        style: TextStyle(
                                                                                            fontSize: 16,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            color: SDSColor.gray500),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 18,
                                                                                      ),
                                                                                      Container(
                                                                                        height: 100,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Form(
                                                                                              key: _formKeyProfile2,
                                                                                              child:
                                                                                              TextFormField(
                                                                                                onTap: (){
                                                                                                  _stateMsgController.selection =
                                                                                                      TextSelection.fromPosition(
                                                                                                          TextPosition(offset: _stateMsgController.text.length));
                                                                                                },
                                                                                                cursorColor: Color(0xff377EEA),
                                                                                                cursorHeight: 16,
                                                                                                cursorWidth: 2,
                                                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                                controller: _stateMsgController..text = _initStateMsg,
                                                                                                strutStyle:
                                                                                                StrutStyle(leading: 0.3),
                                                                                                decoration: InputDecoration(
                                                                                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                    errorStyle: TextStyle(fontSize: 12,),
                                                                                                    labelStyle: TextStyle(color: Color(0xff666666), fontSize: 15),
                                                                                                    hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                                                                                    hintText: '상태메세지 입력',
                                                                                                    labelText: '상태메세지',
                                                                                                    contentPadding: EdgeInsets.only(
                                                                                                        top: 14, bottom: 8, left: 16, right: 16),
                                                                                                    fillColor: Color(0xFFEFEFEF),
                                                                                                    hoverColor: Colors.transparent,
                                                                                                    filled: true,
                                                                                                    focusColor: Colors.transparent,
                                                                                                    border: OutlineInputBorder(
                                                                                                      borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                                                                                      borderRadius: BorderRadius.circular(6),
                                                                                                    ),
                                                                                                    errorBorder:  OutlineInputBorder(
                                                                                                      borderSide: BorderSide(color: Colors.transparent),
                                                                                                    ),
                                                                                                    focusedBorder:  OutlineInputBorder(
                                                                                                      borderSide: BorderSide(color: Colors.transparent),
                                                                                                    ),
                                                                                                    enabledBorder: OutlineInputBorder(
                                                                                                      borderSide: BorderSide(color: Colors.transparent),
                                                                                                      borderRadius: BorderRadius.circular(6),
                                                                                                    )),
                                                                                                validator: (val) {
                                                                                                  if (val!.length <= 20 && val.length >= 0) {
                                                                                                    return null;
                                                                                                  } else if (val.length == 0) {
                                                                                                    return '상태메세지를 입력해주세요.';
                                                                                                  } else {
                                                                                                    return '최대 글자 수를 초과했습니다.';
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(top: 8),
                                                                                              child: Text(
                                                                                                '최대 20글자까지 입력 가능합니다.',
                                                                                                style: TextStyle(
                                                                                                    color: Color(0xff949494),
                                                                                                    fontSize: 12),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: InkWell(
                                                                                              child: ElevatedButton(
                                                                                                onPressed: () {
                                                                                                  _stateMsgController.text =
                                                                                                  _userModelController.stateMsg!;
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                child: Text(
                                                                                                  '취소',
                                                                                                  style: TextStyle(
                                                                                                      color: Color(0xFF3D83ED),
                                                                                                      fontSize: 15,
                                                                                                      fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                                style: TextButton.styleFrom(
                                                                                                    splashFactory: InkRipple.splashFactory,
                                                                                                    elevation: 0,
                                                                                                    minimumSize: Size(100, 56),
                                                                                                    backgroundColor: Color(0xFF3D83ED).withOpacity(0.2),
                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 10,
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: InkWell(
                                                                                              child:
                                                                                              ElevatedButton(
                                                                                                onPressed: () {
                                                                                                  if (_formKeyProfile2.currentState!.validate()) {
                                                                                                    setState(() {
                                                                                                      _initStateMsg = _stateMsgController.text;
                                                                                                    });
                                                                                                    FocusScope.of(context).unfocus();
                                                                                                    Navigator.pop(context);
                                                                                                  } else {
                                                                                                    Get.snackbar(
                                                                                                        '입력 실패',
                                                                                                        '올바른 상태메세지를 입력해주세요.',
                                                                                                        snackPosition: SnackPosition.BOTTOM,
                                                                                                        margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                                                                                        backgroundColor: Colors.black87,
                                                                                                        colorText: Colors.white,
                                                                                                        duration: Duration(milliseconds: 3000));
                                                                                                  }
                                                                                                },
                                                                                                child: Text('변경',
                                                                                                  style: TextStyle(
                                                                                                      color: Colors.white,
                                                                                                      fontSize: 15,
                                                                                                      fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                                style: TextButton
                                                                                                    .styleFrom(
                                                                                                    splashFactory:
                                                                                                    InkRipple.splashFactory,
                                                                                                    elevation: 0,
                                                                                                    minimumSize: Size(100, 56),
                                                                                                    backgroundColor: Color(0xFF3D83ED),
                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left: 4),
                                                                        child: Image.asset(
                                                                          'assets/imgs/icons/icon_edit_pencil.png',
                                                                          height: 20,
                                                                          width: 20,
                                                                        ),
                                                                      )),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if(_userModelController.uid != friendDocs[0]['uid'])
                                                        (friendDocs[0]['stateMsg'] != '')
                                                            ? Container(
                                                            child: Text('${friendDocs[0]['stateMsg']}', style: TextStyle(
                                                                fontSize: 14,
                                                                color: SDSColor.gray500),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                        )
                                                            : SizedBox.shrink(),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      (widget.uid == _userModelController.uid)
                                                          ? Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          if(edit == false)
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _initStateMsg = _userModelController.stateMsg!;
                                                                  _initialDisplayName = _userModelController.displayName!;
                                                                  edit = true;
                                                                });
                                                              }, child: Text('프로필 수정', style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.normal,
                                                                color: Color(0xFF666666)
                                                            ),
                                                            ),
                                                              style: TextButton.styleFrom(
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                      side: BorderSide(color: Color(0xFFDEDEDE))
                                                                  ),
                                                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                                                  elevation: 0,
                                                                  splashFactory: InkRipple.splashFactory,
                                                                  minimumSize: Size(82, 32),
                                                                  backgroundColor:
                                                                  Color(0xffffffff)),
                                                            ),
                                                        ],
                                                      )
                                                          : StreamBuilder(
                                                        stream: FirebaseFirestore.instance
                                                            .collection('user')
                                                            .where(
                                                            'uid', isEqualTo: _userModelController.uid)
                                                            .snapshots(),
                                                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                                          if (!snapshot.hasData || snapshot.data == null) {
                                                            return SizedBox.shrink();
                                                          }
                                                          else if (snapshot.data!.docs.isNotEmpty) {
                                                            final userDocs = snapshot.data!.docs;
                                                            return
                                                              (userDocs[0]['friendUidList'].contains(widget.uid))
                                                                  ? Container() //빈칸
                                                                  : (whoInviteMe.contains(_userModelController.uid))
                                                                  ? GestureDetector(
                                                                onTap: () {
                                                                  Get.dialog(AlertDialog(
                                                                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                    elevation: 0,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(10.0)),
                                                                    buttonPadding:
                                                                    EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                                                                              },
                                                                              child: Text(
                                                                                '확인',
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Color(0xFF3D83ED),
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              )),
                                                                        ],
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                      )
                                                                    ],
                                                                  ));
                                                                },
                                                                child: Container(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Column(
                                                                        children: [
                                                                          Text('친구등록 요청중', style: TextStyle(
                                                                              color: Color(0xFF949494)
                                                                          ),)
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                                  : ElevatedButton(
                                                                onPressed: () {
                                                                  Get.dialog(
                                                                      AlertDialog(
                                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                        elevation: 0,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(10.0)),
                                                                        buttonPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                                                        content: Text(
                                                                          '친구등록 요청을 보내시겠습니까?',
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
                                                                                  child: Text('취소',
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF949494),
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  )),
                                                                              TextButton(
                                                                                  onPressed: () async {
                                                                                    await _userModelController.getCurrentUser(_userModelController.uid);
                                                                                    if (_userModelController.whoInviteMe!.contains(widget.uid)) {
                                                                                      Navigator.pop(context);
                                                                                      Get.dialog(
                                                                                          AlertDialog(
                                                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                            elevation: 0,
                                                                                            shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.circular(10.0)),
                                                                                            buttonPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                                                                            content: Text(
                                                                                              '이미 친구 요청을 받은 회원입니다.',
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
                                                                                                      child: Text('확인',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 15,
                                                                                                          color: Color(0xFF3D83ED),
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                        ),
                                                                                                      )),
                                                                                                ],
                                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                              )
                                                                                            ],
                                                                                          ));
                                                                                    } else {
                                                                                      CustomFullScreenDialog.showDialog();
                                                                                      await _userModelController.updateInvitation(friendUid: widget.uid);
                                                                                      await _userModelController.updateInvitationAlarm(friendUid: widget.uid);
                                                                                      String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendRequestKey];
                                                                                      await _alarmCenterController.sendAlarm(
                                                                                          alarmCount: 'friend',
                                                                                          receiverUid: widget.uid,
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
                                                                                          originContent: 'friend',
                                                                                          bulletinLostUid: '',
                                                                                          bulletinLostCount: ''
                                                                                      );
                                                                                      await _userModelController.getCurrentUser(_userModelController.uid);
                                                                                      Navigator.pop(context);
                                                                                      CustomFullScreenDialog.cancelDialog();
                                                                                    }
                                                                                  },
                                                                                  child: Text('보내기',
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF3D83ED),
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  )),
                                                                            ],
                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                          )
                                                                        ],
                                                                      ));
                                                                }, child: Text('친구 추가', style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: SDSColor.snowliveBlack
                                                              ),
                                                              ),
                                                                style: TextButton.styleFrom(
                                                                    shape: const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                        side: BorderSide(color: Color(0xFFDEDEDE))
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                                                    elevation: 0,
                                                                    splashFactory: InkRipple.splashFactory,
                                                                    minimumSize: Size(82, 32),
                                                                    backgroundColor:
                                                                    Color(0xffffffff)),
                                                              ); //친구로등록하기
                                                          }
                                                          else if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return SizedBox.shrink();
                                                          }
                                                          return SizedBox.shrink();
                                                        },),
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      Column(children: [
                                        SafeArea(
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 44,
                                                child: Container(
                                                  width: _size.width,
                                                  height: 1,
                                                  color: Color(0xFFECECEC),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(bottom: 2, left: 20),
                                                            child: Container(
                                                              height: 40,
                                                              child: ElevatedButton(
                                                                child: Text(
                                                                  '라이딩 통계',
                                                                  style: TextStyle(
                                                                      color: (isTap[0])
                                                                          ? Color(0xFF111111)
                                                                          : Color(0xFFc8c8c8),
                                                                      fontWeight: (isTap[0])
                                                                          ? FontWeight.bold
                                                                          : FontWeight.normal,
                                                                      fontSize: 16),
                                                                ),
                                                                onPressed: () async{
                                                                  HapticFeedback.lightImpact();
                                                                  print('라이딩통계로 전환');
                                                                  setState(() {
                                                                    isTap[0] = true;
                                                                    isTap[1] = false;
                                                                    isTapStats[0] = true;
                                                                    isTapStats[1] = false;
                                                                    isTapStats[2] = false;
                                                                  });
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  padding: EdgeInsets.only(top: 0),
                                                                  minimumSize: Size(40, 10),
                                                                  backgroundColor: Color(0xFFFFFFFF),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(8)),
                                                                  elevation: 0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 20),
                                                            child: Container(
                                                              width: _size.width / 2 - 20,
                                                              height: 3,
                                                              color:
                                                              (isTap[0]) ? Color(0xFF111111) : Colors.transparent,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(bottom: 2),
                                                            child: Container(
                                                              height: 40,
                                                              child: ElevatedButton(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(right: 20),
                                                                  child: Text(
                                                                    '방명록',
                                                                    style: TextStyle(
                                                                        color: (isTap[1])
                                                                            ? Color(0xFF111111)
                                                                            : Color(0xFFc8c8c8),
                                                                        fontWeight:
                                                                        (isTap[1])
                                                                            ? FontWeight.bold
                                                                            : FontWeight.normal,
                                                                        fontSize: 16),
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  HapticFeedback.lightImpact();
                                                                  print('방명록으로 전환');
                                                                  setState(() {
                                                                    isTap[0] = false;
                                                                    isTap[1] = true;
                                                                  });
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  padding: EdgeInsets.only(top: 0),
                                                                  minimumSize: Size(40, 10),
                                                                  backgroundColor: Color(0xFFFFFFFF),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(8)),
                                                                  elevation: 0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 20),
                                                            child: Container(
                                                              width: _size.width / 2 - 20,
                                                              height: 3,
                                                              color:
                                                              (isTap[1]) ? Color(0xFF111111) : Colors.transparent,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 20,),
                                                  if(isTap[0]==true)
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 16, left: 16),
                                                      child: Text('24-25 시즌 정보',
                                                        style: SDSTextStyle.extraBold.copyWith(
                                                            fontSize: 15,
                                                            color: SDSColor.gray900
                                                        ),
                                                      ),
                                                    ),
                                                  if(isTap[0]==true)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 16, right: 16),
                                                    child: Container(
                                                      padding: const EdgeInsets.only(left: 24, right: 20, top: 24, bottom: 24),
                                                      decoration: BoxDecoration(
                                                        color: SDSColor.snowliveBlue,
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 92,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom: 6),
                                                                      child: Row(
                                                                        children: [
                                                                          ExtendedImage.asset(
                                                                            'assets/imgs/icons/icon_circle_black.png',
                                                                            fit: BoxFit.cover,
                                                                            width: 16,
                                                                            height: 16,
                                                                          ),
                                                                          SizedBox(width: 4),
                                                                          Text(
                                                                            '총 점수',
                                                                            style: SDSTextStyle.regular.copyWith(
                                                                              fontSize: 15,
                                                                              color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text('999점',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        color: SDSColor.snowliveWhite,
                                                                        fontSize: 20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 92,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom: 6),
                                                                      child: Row(
                                                                        children: [
                                                                          ExtendedImage.asset(
                                                                            'assets/imgs/icons/icon_circle_black.png',
                                                                            fit: BoxFit.cover,
                                                                            width: 16,
                                                                            height: 16,
                                                                          ),
                                                                          SizedBox(width: 4),
                                                                          Text(
                                                                            '통합 랭킹',
                                                                            style: SDSTextStyle.regular.copyWith(
                                                                              fontSize: 15,
                                                                              color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '999등',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        color: SDSColor.snowliveWhite,
                                                                        fontSize: 20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          ExtendedImage.asset(
                                                            'assets/imgs/ranking/icon_ranking_tier_S.png',
                                                            fit: BoxFit.cover,
                                                            width: 70,
                                                            height: 70,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if(isTap[0]==true)
                                                    SizedBox(height: 40,),
                                                  if(isTap[0]==true)
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 25, left: 0),
                                                      child: Container(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: SingleChildScrollView(
                                                                scrollDirection: Axis.horizontal,
                                                                child: Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap: (){
                                                                        HapticFeedback.lightImpact();
                                                                        setState(() {
                                                                          isTapStats[0] = true;
                                                                          isTapStats[1] = false;
                                                                          isTapStats[2] = false;

                                                                        });
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(left: 16),
                                                                        child: Container(
                                                                            decoration: BoxDecoration(
                                                                              color: (isTapStats[0] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                                                              borderRadius: BorderRadius.circular(30.0),
                                                                              border: Border.all(
                                                                                  color: (isTapStats[0] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                                                            ),
                                                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                            height: 33,
                                                                            child: Text('누적 통계',
                                                                              style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: (isTapStats[0] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                                                              ),)
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 6),
                                                                    GestureDetector(
                                                                      onTap: (){
                                                                        HapticFeedback.lightImpact();
                                                                        setState(() {
                                                                          isTapStats[0] = false;
                                                                          isTapStats[1] = true;
                                                                          isTapStats[2] = true;
                                                                          _selectedDateName = dateItems.isNotEmpty ? dateItems.last : '데이터 없음';
                                                                          _streamController_Friend.setupStreams_friendDetailPage_rank_daily(widget.favoriteResort!, dateItems, _selectedDateName, widget.uid!);
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                          decoration: BoxDecoration(
                                                                            color: (isTapStats[1] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                                                            borderRadius: BorderRadius.circular(30.0),
                                                                            border: Border.all(
                                                                                color: (isTapStats[1] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                                                          ),
                                                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                          height: 33,
                                                                          child: Text('일간 통계',
                                                                            style: TextStyle(
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: (isTapStats[1] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                                                            ),)
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 6),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            if(isTap[0]==true && isTapStats[1] == true)
                                                              GestureDetector(
                                                                onTap: () async{
                                                                  await _showCupertinoPicker();
                                                                },
                                                                child: Container(
                                                                  color: Colors.white,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(right: 20),
                                                                    child: Container(
                                                                        decoration: BoxDecoration(
                                                                          color: (isTapStats[2] == true) ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF),
                                                                          borderRadius: BorderRadius.circular(6),
                                                                          border: Border.all(
                                                                              color: (isTapStats[2] == true) ? Color(0xFFDEDEDE) : Color(0xFFDEDEDE)),
                                                                        ),
                                                                        padding: EdgeInsets.only(right: 4, left: 12, top: 8, bottom: 8),
                                                                        height: 32,
                                                                        child:(isTapStats[2] == true)
                                                                            ? Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(_selectedDateName,
                                                                                style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: (isTapStats[2] == true) ? Color(0xFF777777) : Color(0xFF777777))),
                                                                            Container(
                                                                              height: 18,
                                                                              width: 18,
                                                                              child: Icon(
                                                                                Icons.arrow_drop_down_sharp,
                                                                                size: 16,
                                                                                color: Color(0xFF666666),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                            : Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 4),
                                                                              child:  ExtendedImage.network(
                                                                                '${IconAssetUrlList[0].filter}',
                                                                                enableMemoryCache: true,
                                                                                shape: BoxShape.rectangle,
                                                                                width: 12,
                                                                                loadStateChanged: (ExtendedImageState state) {
                                                                                  switch (state.extendedImageLoadState) {
                                                                                    case LoadState.loading:
                                                                                      return SizedBox.shrink();
                                                                                    default:
                                                                                      return null;
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Text('필터',
                                                                                style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color(0xFF777777)))
                                                                          ],
                                                                        )

                                                                    ),
                                                                  ),
                                                                ),

                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if(isTap[0]==true && isTapStats[0] == true)
                                                    StreamBuilder<DocumentSnapshot>(
                                                        stream: _streamController_Friend.setupStreams_friendDetailPage_rank(widget.favoriteResort!, widget.uid!),
                                                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                          if (snapshot.hasError) {
                                                            return Text("오류가 발생했습니다");
                                                          }
                                                          else if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return SizedBox.shrink();
                                                          }

                                                          Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
                                                          Map<String, dynamic>? passCountData = data?['passCountData'] as Map<String, dynamic>?;
                                                          Map<String, dynamic>? passCountTimeData = data?['passCountTimeData'] as Map<String, dynamic>?;

                                                          try{
                                                            Timestamp lastPassTime = data?['lastPassTime'];
                                                            lastPassTimeString = _timeStampController.getAgoTime(lastPassTime);
                                                          }catch(e){
                                                            lastPassTimeString = '정보 없음';
                                                          }

                                                          List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataPassCount(passCountData);
                                                          List<Map<String, dynamic>> barData2 = _liveMapController.calculateBarDataSlot(passCountTimeData);
                                                          isPassDataZero = _liveMapController.areAllSlotValuesZero(passCountTimeData);

                                                          return
                                                            (passCountData != null && passCountTimeData != null)
                                                                ? Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [

                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    SizedBox(height: 6),
                                                                    Row(
                                                                      children: [
                                                                        Padding(
                                                                            padding: EdgeInsets.only(left: 20),
                                                                            child: Text('라이딩 횟수',
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 16,
                                                                                  color: Color(0xFF111111)
                                                                              ),)),
                                                                        Expanded(child: SizedBox()),
                                                                        if(data != null)
                                                                          Padding(
                                                                            padding: EdgeInsets.only(right: 20),
                                                                            child: Text('${data['totalPassCount']}회',
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.normal,
                                                                                  fontSize: 16,
                                                                                  color: Color(0xFF111111)
                                                                              ),),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 10,),
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: barData.length < 4 ? 20 : 20),
                                                                      width: _size.width,
                                                                      height: 214,
                                                                      decoration: BoxDecoration(
                                                                        color: Color(0xFFDFECFF),
                                                                        borderRadius: BorderRadius.circular(14),
                                                                      ),
                                                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Container(
                                                                              margin: EdgeInsets.only(top: 6),
                                                                              child: passCountData?.entries.isEmpty ?? true
                                                                                  ? Center(child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Image.asset(
                                                                                    'assets/imgs/icons/icon_profile_nodata_1.png',
                                                                                    scale: 4,
                                                                                    width: 43,
                                                                                    height: 32,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  Text('데이터가 없습니다', style: TextStyle(
                                                                                      color: Color(0xFF7A89A0)
                                                                                  ),),
                                                                                ],
                                                                              ))
                                                                                  : SingleChildScrollView(
                                                                                scrollDirection: Axis.horizontal,
                                                                                child: Row(
                                                                                  mainAxisAlignment:
                                                                                  barData.length < 2
                                                                                      ? MainAxisAlignment.center
                                                                                      : MainAxisAlignment.spaceBetween,
                                                                                  children: barData.map((data) {
                                                                                    String slopeName = data['slopeName'];
                                                                                    int passCount = data['passCount'];
                                                                                    double barHeightRatio = data['barHeightRatio'];
                                                                                    Color barColor = data['barColor'];
                                                                                    return Container(
                                                                                      padding: EdgeInsets.only(bottom: 2),
                                                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                                                      width: barData.length < 5 ? _size.width / 5 - 32 : _size.width / 5 - 32,
                                                                                      height: 195,
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Text(
                                                                                            passCount != 0 ? '$passCount' : '',
                                                                                            style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                color: Color(0xFF111111),
                                                                                                fontWeight: FontWeight.bold
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(height: 4),
                                                                                          Container(
                                                                                            width: 58,
                                                                                            height: 140 * barHeightRatio,
                                                                                            child: Container(
                                                                                              width: 58,
                                                                                              height: 140 * barHeightRatio,
                                                                                              decoration: BoxDecoration(
                                                                                                  color: barColor,
                                                                                                  borderRadius: BorderRadius.only(
                                                                                                      topRight: Radius.circular(4),
                                                                                                      topLeft: Radius.circular(4)
                                                                                                  )
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(height: 10),
                                                                                          Text(
                                                                                            slopeName,
                                                                                            style: TextStyle(fontSize: 12, color: Color(0xFF111111)),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  }).toList(),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),

                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 32),
                                                                    Padding(
                                                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                                                        child: Text('시간대별 라이딩 횟수',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                              color: Color(0xFF111111)
                                                                          ),)),
                                                                    SizedBox(height: 10),
                                                                    Container(
                                                                      height: 234,
                                                                      decoration: BoxDecoration(
                                                                        color: Color(0xFFDFECFF),
                                                                        borderRadius: BorderRadius.circular(14),
                                                                      ),
                                                                      padding: EdgeInsets.only(bottom: 12),
                                                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                              child: Container(
                                                                                child: isPassDataZero
                                                                                    ? Center(
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(top: 20),
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Image.asset(
                                                                                            'assets/imgs/icons/icon_profile_nodata_1.png',
                                                                                            scale: 4,
                                                                                            width: 43,
                                                                                            height: 32,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Text('데이터가 없습니다', style: TextStyle(
                                                                                              color: Color(0xFF7A89A0)
                                                                                          ),),
                                                                                        ],
                                                                                      ),
                                                                                    ))
                                                                                    : SingleChildScrollView(
                                                                                  scrollDirection: Axis.horizontal,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: barData2.map((data) {
                                                                                      String slotName = data['slotName'];
                                                                                      int passCount = data['passCount'];
                                                                                      double barHeightRatio = data['barHeightRatio'];
                                                                                      Color barColor = data['barColor'];

                                                                                      return Container(
                                                                                        margin: EdgeInsets.symmetric(horizontal: 5),
                                                                                        width: 25,
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                                          children: [
                                                                                            AutoSizeText(
                                                                                              passCount != 0 ? '$passCount' : '',
                                                                                              style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                color: Color(0xFF111111),
                                                                                                fontWeight: FontWeight.bold,
                                                                                              ),
                                                                                              minFontSize: 8,
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.visible,
                                                                                            ),
                                                                                            SizedBox(height: 4),
                                                                                            Container(
                                                                                              width: 25,
                                                                                              height: 140 * barHeightRatio,
                                                                                              child: Container(
                                                                                                width: 25,
                                                                                                height: 140 * barHeightRatio,
                                                                                                decoration: BoxDecoration(
                                                                                                    color: barColor,
                                                                                                    borderRadius: BorderRadius.only(
                                                                                                        topRight: Radius.circular(4),
                                                                                                        topLeft: Radius.circular(4)
                                                                                                    )
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(height: 10),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 3),
                                                                                              child: Text(
                                                                                                _resortModelController.getSlotName(slotName),
                                                                                                style: TextStyle(fontSize: 11, color: Color(0xFF111111)),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      );
                                                                                    }).toList(),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 7,),
                                                                    Padding(
                                                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                                                        child: Container(
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(right: 4),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                Text('마지막 라이딩',
                                                                                  style: TextStyle(
                                                                                      fontSize: 13,
                                                                                      color: Color(0xFF949494)
                                                                                  ),),
                                                                                SizedBox(
                                                                                  width: 4,
                                                                                ),
                                                                                isPassDataZero
                                                                                    ? Text('정보없음',
                                                                                  style: TextStyle(
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xFF949494)
                                                                                  ),)
                                                                                    : Text('${lastPassTimeString}',
                                                                                  style: TextStyle(
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xFF949494)
                                                                                  ),)
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          alignment: Alignment.bottomRight,
                                                                        )),
                                                                    //시간대별 라이딩 횟수
                                                                    SizedBox(height: 30),
                                                                  ],)
                                                              ],
                                                            )
                                                                : Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                SizedBox(
                                                                  height: _size.height / 5,
                                                                ),
                                                                Container(
                                                                  width: 48,
                                                                  child: ExtendedImage.asset(
                                                                    'assets/imgs/ranking/icon_ranking_nodata_2.png',
                                                                    enableMemoryCache: true,
                                                                    scale: 4,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Center(
                                                                  child: Text('라이딩 기록이 없어요',
                                                                    style: TextStyle(
                                                                        color: Color(0xFF666666),
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.normal
                                                                    ),),
                                                                ),
                                                              ],
                                                            );

                                                        }),
                                                  if(isTap[0]==true && isTapStats[1] == true)
                                                    ProfilePageCalendar(),
                                                  if(isTap[0]==true && isTapStats[1] == true)
                                                    StreamBuilder<QuerySnapshot>(
                                                        stream: _streamController_Friend.setupStreams_friendDetailPage_rank_daily(widget.favoriteResort!, dateItems, _selectedDateName, widget.uid!),
                                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                          if (snapshot.hasError) {
                                                            return Text("오류가 발생했습니다");
                                                          }
                                                          else if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return SizedBox.shrink();
                                                          }

                                                          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

                                                          if(documents.isEmpty){
                                                            return Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                SizedBox(
                                                                  height: _size.height / 5,
                                                                ),
                                                                Container(
                                                                  width: 48,
                                                                  child: ExtendedImage.asset(
                                                                    'assets/imgs/ranking/icon_ranking_nodata_2.png',
                                                                    enableMemoryCache: true,
                                                                    scale: 4,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Center(
                                                                  child: Text('라이딩 기록이 없어요',
                                                                    style: TextStyle(
                                                                        color: Color(0xFF666666),
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.normal
                                                                    ),),
                                                                ),
                                                              ],
                                                            );
                                                          }

                                                          QueryDocumentSnapshot document = documents[0]; // 예제로 첫 번째 문서를 가져옵니다.

                                                          Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
                                                          Map<String, dynamic>? passCountData = data?['passCountData'] as Map<String, dynamic>?;
                                                          Map<String, dynamic>? passCountTimeData = data?['passCountTimeData'] as Map<String, dynamic>?;

                                                          try{
                                                            Timestamp lastPassTime = data?['lastPassTime'];
                                                            lastPassTimeString = _timeStampController.getAgoTime(lastPassTime);
                                                          }catch(e){
                                                            lastPassTimeString = '정보 없음';
                                                          }

                                                          List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataPassCount(passCountData);
                                                          List<Map<String, dynamic>> barData2 = _liveMapController.calculateBarDataSlot(passCountTimeData);
                                                          isPassDataZero = _liveMapController.areAllSlotValuesZero(passCountTimeData);

                                                          return
                                                            (passCountData != null && passCountTimeData != null)
                                                                ? Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [

                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    SizedBox(height: 6),
                                                                    Row(
                                                                      children: [
                                                                        Padding(
                                                                            padding: EdgeInsets.only(left: 20),
                                                                            child: Text('라이딩 횟수',
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 16,
                                                                                  color: Color(0xFF111111)
                                                                              ),)),
                                                                        Expanded(child: SizedBox()),
                                                                        if(data != null)
                                                                          Padding(
                                                                            padding: EdgeInsets.only(right: 20),
                                                                            child: Text('${data['totalPassCount']}회',
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.normal,
                                                                                  fontSize: 16,
                                                                                  color: Color(0xFF111111)
                                                                              ),),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 10,),
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: barData.length < 4 ? 20 : 20),
                                                                      width: _size.width,
                                                                      height: 214,
                                                                      decoration: BoxDecoration(
                                                                        color: Color(0xFFDFECFF),
                                                                        borderRadius: BorderRadius.circular(14),
                                                                      ),
                                                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Container(
                                                                              margin: EdgeInsets.only(top: 6),
                                                                              child: passCountData?.entries.isEmpty ?? true
                                                                                  ? Center(child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Image.asset(
                                                                                    'assets/imgs/icons/icon_profile_nodata_1.png',
                                                                                    scale: 4,
                                                                                    width: 43,
                                                                                    height: 32,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  Text('데이터가 없습니다', style: TextStyle(
                                                                                      color: Color(0xFF7A89A0)
                                                                                  ),),
                                                                                ],
                                                                              ))
                                                                                  : SingleChildScrollView(
                                                                                scrollDirection: Axis.horizontal,
                                                                                child: Row(
                                                                                  mainAxisAlignment:
                                                                                  barData.length < 2
                                                                                      ? MainAxisAlignment.center
                                                                                      : MainAxisAlignment.spaceBetween,
                                                                                  children: barData.map((data) {
                                                                                    String slopeName = data['slopeName'];
                                                                                    int passCount = data['passCount'];
                                                                                    double barHeightRatio = data['barHeightRatio'];
                                                                                    Color barColor = data['barColor'];
                                                                                    return Container(
                                                                                      padding: EdgeInsets.only(bottom: 2),
                                                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                                                      width: barData.length < 5 ? _size.width / 5 - 32 : _size.width / 5 - 32,
                                                                                      height: 195,
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Text(
                                                                                            passCount != 0 ? '$passCount' : '',
                                                                                            style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                color: Color(0xFF111111),
                                                                                                fontWeight: FontWeight.bold
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(height: 4),
                                                                                          Container(
                                                                                            width: 58,
                                                                                            height: 140 * barHeightRatio,
                                                                                            child: Container(
                                                                                              width: 58,
                                                                                              height: 140 * barHeightRatio,
                                                                                              decoration: BoxDecoration(
                                                                                                  color: barColor,
                                                                                                  borderRadius: BorderRadius.only(
                                                                                                      topRight: Radius.circular(4),
                                                                                                      topLeft: Radius.circular(4)
                                                                                                  )
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(height: 10),
                                                                                          Text(
                                                                                            slopeName,
                                                                                            style: TextStyle(fontSize: 12, color: Color(0xFF111111)),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  }).toList(),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),

                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 32),
                                                                    Padding(
                                                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                                                        child: Text('시간대별 라이딩 횟수',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                              color: Color(0xFF111111)
                                                                          ),)),
                                                                    SizedBox(height: 10),
                                                                    Container(
                                                                      height: 234,
                                                                      decoration: BoxDecoration(
                                                                        color: Color(0xFFDFECFF),
                                                                        borderRadius: BorderRadius.circular(14),
                                                                      ),
                                                                      padding: EdgeInsets.only(bottom: 12),
                                                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                              child: Container(
                                                                                child: isPassDataZero
                                                                                    ? Center(
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(top: 20),
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Image.asset(
                                                                                            'assets/imgs/icons/icon_profile_nodata_1.png',
                                                                                            scale: 4,
                                                                                            width: 43,
                                                                                            height: 32,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Text('데이터가 없습니다', style: TextStyle(
                                                                                              color: Color(0xFF7A89A0)
                                                                                          ),),
                                                                                        ],
                                                                                      ),
                                                                                    ))
                                                                                    : SingleChildScrollView(
                                                                                  scrollDirection: Axis.horizontal,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: barData2.map((data) {
                                                                                      String slotName = data['slotName'];
                                                                                      int passCount = data['passCount'];
                                                                                      double barHeightRatio = data['barHeightRatio'];
                                                                                      Color barColor = data['barColor'];

                                                                                      return Container(
                                                                                        margin: EdgeInsets.symmetric(horizontal: 5),
                                                                                        width: 25,
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                                          children: [
                                                                                            AutoSizeText(
                                                                                              passCount != 0 ? '$passCount' : '',
                                                                                              style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                color: Color(0xFF111111),
                                                                                                fontWeight: FontWeight.bold,
                                                                                              ),
                                                                                              minFontSize: 8,
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.visible,
                                                                                            ),
                                                                                            SizedBox(height: 4),
                                                                                            Container(
                                                                                              width: 25,
                                                                                              height: 140 * barHeightRatio,
                                                                                              child: Container(
                                                                                                width: 25,
                                                                                                height: 140 * barHeightRatio,
                                                                                                decoration: BoxDecoration(
                                                                                                    color: barColor,
                                                                                                    borderRadius: BorderRadius.only(
                                                                                                        topRight: Radius.circular(4),
                                                                                                        topLeft: Radius.circular(4)
                                                                                                    )
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(height: 10),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 3),
                                                                                              child: Text(
                                                                                                _resortModelController.getSlotName(slotName),
                                                                                                style: TextStyle(fontSize: 11, color: Color(0xFF111111)),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      );
                                                                                    }).toList(),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 7,),
                                                                    Padding(
                                                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                                                        child: Container(
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(right: 4),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                Text('마지막 라이딩',
                                                                                  style: TextStyle(
                                                                                      fontSize: 13,
                                                                                      color: Color(0xFF949494)
                                                                                  ),),
                                                                                SizedBox(
                                                                                  width: 4,
                                                                                ),
                                                                                isPassDataZero
                                                                                    ? Text('정보없음',
                                                                                  style: TextStyle(
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xFF949494)
                                                                                  ),)
                                                                                    : Text('${lastPassTimeString}',
                                                                                  style: TextStyle(
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xFF949494)
                                                                                  ),)
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          alignment: Alignment.bottomRight,
                                                                        )),
                                                                    //시간대별 라이딩 횟수
                                                                    SizedBox(height: 30),
                                                                  ],)
                                                              ],
                                                            )
                                                                : Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                SizedBox(
                                                                  height: _size.height / 5,
                                                                ),
                                                                Container(
                                                                  width: 48,
                                                                  child: ExtendedImage.asset(
                                                                    'assets/imgs/ranking/icon_ranking_nodata_2.png',
                                                                    enableMemoryCache: true,
                                                                    scale: 4,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Center(
                                                                  child: Text('라이딩 기록이 없어요',
                                                                    style: TextStyle(
                                                                        color: Color(0xFF666666),
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.normal
                                                                    ),),
                                                                ),
                                                              ],
                                                            );

                                                        }),
                                                  if(isTap[1]==true)
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 20),
                                                            child: Column(
                                                              children: [
                                                                StreamBuilder(
                                                                  stream: _streamController_Friend.setupStreams_friendDetailPage_friendComment(widget.uid!),
                                                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                                    if (!snapshot.hasData || snapshot.data == null) {
                                                                      return Center(
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(20),
                                                                            child: Column(
                                                                              children: [
                                                                                SizedBox(
                                                                                  height: _size.height / 18,
                                                                                ),
                                                                                Image.asset(
                                                                                  'assets/imgs/icons/icon_nodata.png',
                                                                                  scale: 4,
                                                                                  width: 64,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 6,
                                                                                ),
                                                                                Text('친구톡이 없습니다',
                                                                                  style: TextStyle(
                                                                                    fontSize: 13, color: Color(
                                                                                    0xFF666666)),),
                                                                                SizedBox(
                                                                                  height: 30,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ));
                                                                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                                                                      return SizedBox.shrink();
                                                                    }
                                                                    else if (snapshot.data!.docs.isNotEmpty) {
                                                                      List commentDocs = snapshot.data!.docs;
                                                                      return Column(
                                                                        children: [
                                                                          ListView.builder(
                                                                            padding: EdgeInsets.only(top: 4),
                                                                            shrinkWrap: true,
                                                                            physics: NeverScrollableScrollPhysics(),
                                                                            itemCount: commentDocs.length,
                                                                            itemBuilder: (context, index) {
                                                                              final document = commentDocs[index];
                                                                              Timestamp timestamp = commentDocs[index].get('timeStamp');
                                                                              String formattedDate = DateFormat('yyyy.MM.dd').format(timestamp.toDate()); // 원하는 형식으로 날짜 변환
                                                                              return StreamBuilder(
                                                                                  stream:  FirebaseFirestore.instance
                                                                                      .collection('user')
                                                                                      .where('uid', isEqualTo: document['myUid'])
                                                                                      .snapshots(),
                                                                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                                                    if (!snapshot.hasData || snapshot.data == null) {
                                                                                      return ListTile(
                                                                                        title: Text(''),
                                                                                      );
                                                                                    }
                                                                                    final userDoc = snapshot.data!.docs;
                                                                                    final userData = userDoc.isNotEmpty ? userDoc[0] : null;
                                                                                    if (userData == null) {
                                                                                      return SizedBox();
                                                                                    }
                                                                                    return (_userModelController.repoUidList!.contains(commentDocs[index].get('myUid')))
                                                                                        ? Container(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                                                      decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          borderRadius: BorderRadius.circular(8)
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                                                          child: Text(
                                                                                            '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                                                                            style: TextStyle(
                                                                                                fontWeight: FontWeight.normal,
                                                                                                fontSize: 12,
                                                                                                color: Color(0xffc8c8c8)),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                        : Row(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      children: [
                                                                                        if (userData['profileImageUrl'] != "")
                                                                                          GestureDetector(
                                                                                            onTap: (){
                                                                                              Get.back();
                                                                                              setState(() {edit=false;});
                                                                                              Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                                                                            },
                                                                                            child: Container(
                                                                                              width: 40,
                                                                                              height: 40,
                                                                                              decoration: BoxDecoration(
                                                                                                  color: Color(0xFFDFECFF),
                                                                                                  borderRadius: BorderRadius.circular(50)
                                                                                              ),
                                                                                              child: ExtendedImage.network(
                                                                                                userData['profileImageUrl'],
                                                                                                cache: true,
                                                                                                shape: BoxShape.circle,
                                                                                                borderRadius:
                                                                                                BorderRadius.circular(20),
                                                                                                width: 40,
                                                                                                height: 40,
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
                                                                                                        width: 40,
                                                                                                        height: 40,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                                                    default:
                                                                                                      return null;
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        if (userData['profileImageUrl'] == "")
                                                                                          GestureDetector(
                                                                                            onTap: (){
                                                                                              Get.back();
                                                                                              setState(() {edit=false;});
                                                                                              Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                                                                            },
                                                                                            child: ExtendedImage.network(
                                                                                              '${profileImgUrlList[0].default_round}',
                                                                                              shape: BoxShape.circle,
                                                                                              borderRadius:
                                                                                              BorderRadius.circular(20),
                                                                                              width: 40,
                                                                                              height: 40,
                                                                                              fit: BoxFit.cover,
                                                                                            ),
                                                                                          ),
                                                                                        SizedBox(width: 12),
                                                                                        Column(
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(top: 10),
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Container(
                                                                                                            width: _size.width - 112,
                                                                                                            child: Text(commentDocs[index]['comment'],
                                                                                                              style: TextStyle(
                                                                                                                  fontSize: 14,
                                                                                                                  color: Color(0xFF111111)
                                                                                                              ),),
                                                                                                          ),
                                                                                                          (commentDocs[index]['myUid'] != _userModelController.uid)
                                                                                                              ? GestureDetector(
                                                                                                            onTap: () =>
                                                                                                                showModalBottomSheet(
                                                                                                                    enableDrag: false,
                                                                                                                    context: context,
                                                                                                                    builder: (context) {
                                                                                                                      return SafeArea(
                                                                                                                        child: Container(
                                                                                                                          height: (friendDocs[0]['uid'] == _userModelController.uid) ? 200 : 150,
                                                                                                                          child: Padding(
                                                                                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                                                                                            child: Column(
                                                                                                                              children: [
                                                                                                                                if(friendDocs[0]['uid'] == _userModelController.uid)
                                                                                                                                  GestureDetector(
                                                                                                                                    child: ListTile(
                                                                                                                                      contentPadding: EdgeInsets.zero,
                                                                                                                                      title: Center(
                                                                                                                                        child: Text(
                                                                                                                                          '삭제',
                                                                                                                                          style: TextStyle(
                                                                                                                                              fontSize: 15,
                                                                                                                                              fontWeight: FontWeight.bold,
                                                                                                                                              color: Color(
                                                                                                                                                  0xFFD63636)
                                                                                                                                          ),
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                      //selected: _isSelected[index]!,
                                                                                                                                      onTap: () async {
                                                                                                                                        Navigator.pop(context);
                                                                                                                                        showModalBottomSheet(
                                                                                                                                            context: context,
                                                                                                                                            builder: (context) {
                                                                                                                                              return Container(
                                                                                                                                                color: Colors.white,
                                                                                                                                                height: 180,
                                                                                                                                                child: Padding(
                                                                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                                                                                                                  child: Column(
                                                                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                                                    children: [
                                                                                                                                                      SizedBox(
                                                                                                                                                        height: 30,
                                                                                                                                                      ),
                                                                                                                                                      Text(
                                                                                                                                                        '삭제하시겠습니까?',
                                                                                                                                                        style: TextStyle(
                                                                                                                                                            fontSize: 20,
                                                                                                                                                            fontWeight: FontWeight.bold,
                                                                                                                                                            color: Color(0xFF111111)),
                                                                                                                                                      ),
                                                                                                                                                      SizedBox(
                                                                                                                                                        height: 30,
                                                                                                                                                      ),
                                                                                                                                                      Row(
                                                                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                                        children: [
                                                                                                                                                          Expanded(
                                                                                                                                                            child: ElevatedButton(
                                                                                                                                                              onPressed: () {
                                                                                                                                                                Navigator.pop(context);
                                                                                                                                                              },
                                                                                                                                                              child: Text('취소',
                                                                                                                                                                style: TextStyle(
                                                                                                                                                                    color: Colors.white,
                                                                                                                                                                    fontSize: 15,
                                                                                                                                                                    fontWeight: FontWeight.bold),
                                                                                                                                                              ),
                                                                                                                                                              style: TextButton.styleFrom(
                                                                                                                                                                  splashFactory: InkRipple.splashFactory,
                                                                                                                                                                  elevation: 0,
                                                                                                                                                                  minimumSize: Size(100, 56),
                                                                                                                                                                  backgroundColor: Color(0xff555555),
                                                                                                                                                                  padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                                                                            ),
                                                                                                                                                          ),
                                                                                                                                                          SizedBox(
                                                                                                                                                            width: 10,
                                                                                                                                                          ),
                                                                                                                                                          Expanded(
                                                                                                                                                            child: ElevatedButton(
                                                                                                                                                              onPressed: () async {
                                                                                                                                                                CustomFullScreenDialog.showDialog();
                                                                                                                                                                try {
                                                                                                                                                                  await FirebaseFirestore.instance.collection('user')
                                                                                                                                                                      .doc('${widget.uid}')
                                                                                                                                                                      .collection('friendsComment')
                                                                                                                                                                      .doc(commentDocs[index]['myUid'])
                                                                                                                                                                      .delete();
                                                                                                                                                                  String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendTalkKey];
                                                                                                                                                                  await _alarmCenterController.deleteAlarm(
                                                                                                                                                                      receiverUid: _userModelController.uid,
                                                                                                                                                                      senderUid: commentDocs[index]['myUid'],
                                                                                                                                                                      category: alarmCategory,
                                                                                                                                                                      alarmCount: 'friend'
                                                                                                                                                                  );
                                                                                                                                                                } catch (e) {}
                                                                                                                                                                print('삭제 완료');
                                                                                                                                                                Navigator.pop(context);
                                                                                                                                                                CustomFullScreenDialog.cancelDialog();
                                                                                                                                                              },
                                                                                                                                                              child: Text('확인',
                                                                                                                                                                style: TextStyle(
                                                                                                                                                                    color: Colors.white,
                                                                                                                                                                    fontSize: 15,
                                                                                                                                                                    fontWeight: FontWeight.bold),
                                                                                                                                                              ),
                                                                                                                                                              style: TextButton.styleFrom(
                                                                                                                                                                  splashFactory: InkRipple.splashFactory,
                                                                                                                                                                  elevation: 0,
                                                                                                                                                                  minimumSize: Size(100, 56),
                                                                                                                                                                  backgroundColor: Color(0xff2C97FB),
                                                                                                                                                                  padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                                                                            ),
                                                                                                                                                          ),
                                                                                                                                                        ],
                                                                                                                                                      )
                                                                                                                                                    ],
                                                                                                                                                  ),
                                                                                                                                                ),
                                                                                                                                              );
                                                                                                                                            });
                                                                                                                                      },
                                                                                                                                      shape: RoundedRectangleBorder(
                                                                                                                                          borderRadius: BorderRadius.circular(10)),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                GestureDetector(
                                                                                                                                  child: ListTile(
                                                                                                                                    contentPadding: EdgeInsets.zero,
                                                                                                                                    title: Center(
                                                                                                                                      child: Text('신고하기',
                                                                                                                                        style: TextStyle(
                                                                                                                                          fontSize: 15,
                                                                                                                                          fontWeight: FontWeight.bold,
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                    //selected: _isSelected[index]!,
                                                                                                                                    onTap: () async {
                                                                                                                                      Get.dialog(
                                                                                                                                          AlertDialog(
                                                                                                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                                                            elevation: 0,
                                                                                                                                            shape: RoundedRectangleBorder(
                                                                                                                                                borderRadius: BorderRadius.circular(10.0)),
                                                                                                                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                                                            content: Text(
                                                                                                                                              '이 회원을 신고하시겠습니까?',
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
                                                                                                                                                      },
                                                                                                                                                      child: Text('취소',
                                                                                                                                                        style: TextStyle(
                                                                                                                                                          fontSize: 15,
                                                                                                                                                          color: Color(0xFF949494),
                                                                                                                                                          fontWeight: FontWeight.bold,
                                                                                                                                                        ),
                                                                                                                                                      )),
                                                                                                                                                  TextButton(
                                                                                                                                                      onPressed: () async {
                                                                                                                                                        var repoUid = commentDocs[index].get('myUid');
                                                                                                                                                        await _userModelController.repoUpdate(repoUid);
                                                                                                                                                        Navigator.pop(context);
                                                                                                                                                        Navigator.pop(context);
                                                                                                                                                      },
                                                                                                                                                      child: Text(
                                                                                                                                                        '신고',
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
                                                                                                                                    },
                                                                                                                                    shape: RoundedRectangleBorder(
                                                                                                                                        borderRadius: BorderRadius.circular(10)),
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                                GestureDetector(
                                                                                                                                  child: ListTile(
                                                                                                                                    contentPadding: EdgeInsets.zero,
                                                                                                                                    title: Center(
                                                                                                                                      child: Text(
                                                                                                                                        '이 회원의 글 모두 숨기기',
                                                                                                                                        style: TextStyle(
                                                                                                                                          fontSize: 15,
                                                                                                                                          fontWeight: FontWeight.bold,
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                    //selected: _isSelected[index]!,
                                                                                                                                    onTap: () async {
                                                                                                                                      Get.dialog(
                                                                                                                                          AlertDialog(
                                                                                                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                                                            elevation: 0,
                                                                                                                                            shape: RoundedRectangleBorder(
                                                                                                                                                borderRadius: BorderRadius.circular(10.0)),
                                                                                                                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                                                            content:  Container(
                                                                                                                                              height: _size.width*0.17,
                                                                                                                                              child: Column(
                                                                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                                                children: [
                                                                                                                                                  Text(
                                                                                                                                                    '이 회원의 게시물을 모두 숨길까요?',
                                                                                                                                                    style: TextStyle(
                                                                                                                                                        fontWeight: FontWeight.w600,
                                                                                                                                                        fontSize: 15),
                                                                                                                                                  ),
                                                                                                                                                  SizedBox(
                                                                                                                                                    height: 10,
                                                                                                                                                  ),
                                                                                                                                                  Text(
                                                                                                                                                    '차단해제는 [더보기 - 친구 - 설정 - 차단목록]에서\n하실 수 있습니다.',
                                                                                                                                                    style: TextStyle(
                                                                                                                                                        fontWeight: FontWeight.w600,
                                                                                                                                                        fontSize: 12,
                                                                                                                                                        color: Color(0xFF555555)),
                                                                                                                                                  ),
                                                                                                                                                ],
                                                                                                                                              ),
                                                                                                                                            ),
                                                                                                                                            actions: [
                                                                                                                                              Row(
                                                                                                                                                children: [
                                                                                                                                                  TextButton(
                                                                                                                                                      onPressed: () {Navigator.pop(context);},
                                                                                                                                                      child: Text('취소',
                                                                                                                                                        style: TextStyle(
                                                                                                                                                          fontSize: 15,
                                                                                                                                                          color: Color(0xFF949494),
                                                                                                                                                          fontWeight: FontWeight.bold,
                                                                                                                                                        ),
                                                                                                                                                      )),
                                                                                                                                                  TextButton(
                                                                                                                                                      onPressed: () {
                                                                                                                                                        var repoUid = commentDocs[index].get('myUid');
                                                                                                                                                        _userModelController.updateRepoUid(repoUid);
                                                                                                                                                        Navigator.pop(context);
                                                                                                                                                        Navigator.pop(context);
                                                                                                                                                      },
                                                                                                                                                      child: Text('확인',
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
                                                                                                                                    },
                                                                                                                                    shape: RoundedRectangleBorder(
                                                                                                                                        borderRadius: BorderRadius.circular(10)),
                                                                                                                                  ),
                                                                                                                                )
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    }),
                                                                                                            child: Icon(
                                                                                                              Icons.more_horiz,
                                                                                                              color: Color(0xFFdedede),
                                                                                                              size: 20,
                                                                                                            ),
                                                                                                          )
                                                                                                              : GestureDetector(
                                                                                                            onTap: () =>
                                                                                                                showModalBottomSheet(
                                                                                                                    enableDrag: false,
                                                                                                                    context: context,
                                                                                                                    builder: (
                                                                                                                        context) {
                                                                                                                      return SafeArea(
                                                                                                                        child: Container(
                                                                                                                          height: 100,
                                                                                                                          child:
                                                                                                                          Padding(
                                                                                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                                                                                            child: Column(
                                                                                                                              children: [
                                                                                                                                GestureDetector(
                                                                                                                                  child: ListTile(
                                                                                                                                    contentPadding: EdgeInsets.zero,
                                                                                                                                    title: Center(
                                                                                                                                      child: Text('삭제',
                                                                                                                                        style: TextStyle(
                                                                                                                                            fontSize: 15,
                                                                                                                                            fontWeight: FontWeight.bold,
                                                                                                                                            color: Color(0xFFD63636)
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                    //selected: _isSelected[index]!,
                                                                                                                                    onTap: () async {
                                                                                                                                      Navigator.pop(context);
                                                                                                                                      showModalBottomSheet(
                                                                                                                                          context: context,
                                                                                                                                          builder: (context) {
                                                                                                                                            return Container(
                                                                                                                                              color: Colors.white,
                                                                                                                                              height: 180,
                                                                                                                                              child: Padding(
                                                                                                                                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                                                                                                                child: Column(
                                                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                                                  children: [
                                                                                                                                                    SizedBox(
                                                                                                                                                      height: 30,
                                                                                                                                                    ),
                                                                                                                                                    Text(
                                                                                                                                                      '삭제하시겠습니까?',
                                                                                                                                                      style: TextStyle(
                                                                                                                                                          fontSize: 20,
                                                                                                                                                          fontWeight: FontWeight.bold,
                                                                                                                                                          color: Color(0xFF111111)),
                                                                                                                                                    ),
                                                                                                                                                    SizedBox(
                                                                                                                                                      height: 30,
                                                                                                                                                    ),
                                                                                                                                                    Row(
                                                                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                                      children: [
                                                                                                                                                        Expanded(
                                                                                                                                                          child: ElevatedButton(
                                                                                                                                                            onPressed: () {
                                                                                                                                                              Navigator.pop(context);
                                                                                                                                                            },
                                                                                                                                                            child: Text(
                                                                                                                                                              '취소',
                                                                                                                                                              style: TextStyle(
                                                                                                                                                                  color: Colors.white,
                                                                                                                                                                  fontSize: 15,
                                                                                                                                                                  fontWeight: FontWeight.bold),
                                                                                                                                                            ),
                                                                                                                                                            style: TextButton.styleFrom(
                                                                                                                                                                splashFactory: InkRipple.splashFactory,
                                                                                                                                                                elevation: 0,
                                                                                                                                                                minimumSize: Size(100, 56),
                                                                                                                                                                backgroundColor: Color(0xff555555),
                                                                                                                                                                padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                                                                          ),
                                                                                                                                                        ),
                                                                                                                                                        SizedBox(
                                                                                                                                                          width: 10,
                                                                                                                                                        ),
                                                                                                                                                        Expanded(
                                                                                                                                                          child: ElevatedButton(
                                                                                                                                                            onPressed: () async {
                                                                                                                                                              CustomFullScreenDialog
                                                                                                                                                                  .showDialog();
                                                                                                                                                              try {
                                                                                                                                                                await FirebaseFirestore.instance
                                                                                                                                                                    .collection('user')
                                                                                                                                                                    .doc('${widget.uid}')
                                                                                                                                                                    .collection('friendsComment')
                                                                                                                                                                    .doc('${_userModelController.uid}')
                                                                                                                                                                    .delete();
                                                                                                                                                                String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendTalkKey];
                                                                                                                                                                await _alarmCenterController.deleteAlarm(
                                                                                                                                                                    receiverUid: widget.uid,
                                                                                                                                                                    senderUid: _userModelController.uid,
                                                                                                                                                                    category: alarmCategory,
                                                                                                                                                                    alarmCount: 'friend'
                                                                                                                                                                );
                                                                                                                                                              } catch (e) {}
                                                                                                                                                              print('친구톡 삭제 완료');
                                                                                                                                                              Navigator.pop(context);
                                                                                                                                                              CustomFullScreenDialog.cancelDialog();
                                                                                                                                                            },
                                                                                                                                                            child: Text(
                                                                                                                                                              '확인',
                                                                                                                                                              style: TextStyle(
                                                                                                                                                                  color: Colors.white,
                                                                                                                                                                  fontSize: 15,
                                                                                                                                                                  fontWeight: FontWeight.bold),
                                                                                                                                                            ),
                                                                                                                                                            style: TextButton.styleFrom(
                                                                                                                                                                splashFactory: InkRipple.splashFactory,
                                                                                                                                                                elevation: 0,
                                                                                                                                                                minimumSize: Size(100, 56),
                                                                                                                                                                backgroundColor: Color(0xff2C97FB),
                                                                                                                                                                padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                                                                          ),
                                                                                                                                                        ),
                                                                                                                                                      ],
                                                                                                                                                    )
                                                                                                                                                  ],
                                                                                                                                                ),
                                                                                                                                              ),
                                                                                                                                            );
                                                                                                                                          });
                                                                                                                                    },
                                                                                                                                    shape: RoundedRectangleBorder(
                                                                                                                                        borderRadius: BorderRadius.circular(10)),
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    }),
                                                                                                            child: Icon(
                                                                                                              Icons.more_horiz,
                                                                                                              color: Color(0xFFdedede),
                                                                                                              size: 20,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: 4,
                                                                                                      ),
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            userData['displayName'],
                                                                                                            style: TextStyle(
                                                                                                                fontSize: 13,
                                                                                                                color: Color(0xFF949494)
                                                                                                            ),),
                                                                                                          SizedBox(width: 6,),
                                                                                                          Text(formattedDate,
                                                                                                            style: TextStyle(
                                                                                                                fontSize: 13,
                                                                                                                color: Color(0xFF949494)
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),

                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(height: 12),
                                                                                            if (index != commentDocs.length - 1)
                                                                                              Container(
                                                                                                color: Color(0xFFF5F5F5),
                                                                                                height: 1,
                                                                                                width: _size.width - 92,
                                                                                              )
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  });
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height: 90,
                                                                          )
                                                                        ],
                                                                      );
                                                                    }
                                                                    return Center(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(20),
                                                                        child: Column(
                                                                          children: [
                                                                            SizedBox(
                                                                              height: _size.height / 18,
                                                                            ),
                                                                            Image.asset(
                                                                              'assets/imgs/icons/icon_nodata.png',
                                                                              scale: 4,
                                                                              width: 64,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 6,
                                                                            ),
                                                                            Text('친구톡이 없습니다', style: TextStyle(
                                                                                fontSize: 13, color: Color(
                                                                                0xFF666666)),),
                                                                            SizedBox(
                                                                              height: 30,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                )
                                                              ],
                                                            )
                                                        ),
                                                      ],),


                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    (isTap[1]==true && widget.uid != _userModelController.uid)
                        ? Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            key: _formKeyProfile4,
                            cursorColor: Color(0xff377EEA),
                            controller: _friendTalkController,
                            strutStyle: StrutStyle(leading: 0.3),
                            maxLines: 1,
                            enableSuggestions: false,
                            autocorrect: false,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                suffixIcon: IconButton(
                                  splashColor: Colors.transparent,
                                  onPressed: () async {
                                    if (_friendTalkController.text.trim().isEmpty) {
                                      return;
                                    }
                                    try {
                                      if (_userModelController.myFriendCommentUidList!.contains(widget.uid)
                                          && _userModelController.commentCheck! == false) {
                                        Get.dialog(
                                            AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                              content: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("친구톡을 새로 등록하면 이전에 등록된 친구톡은 삭제됩니다. 계속하시겠습니까?",
                                                    softWrap: true,
                                                    overflow: TextOverflow.visible,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF111111),
                                                        height: 1.4
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 24,
                                                  ),
                                                  Obx(() =>
                                                      GestureDetector(
                                                        onTap: (){
                                                          _dialogController.isChecked.value = !_dialogController.isChecked.value;
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              _dialogController.isChecked.value
                                                                  ? 'assets/imgs/icons/icon_check_filled.png'
                                                                  : 'assets/imgs/icons/icon_check_unfilled.png',
                                                              width: 24,
                                                              height: 24,
                                                            ),
                                                            // Checkbox(
                                                            //   value: _dialogController.isChecked.value,
                                                            //   onChanged: (newValue) {
                                                            //     _dialogController.isChecked.value = newValue!;
                                                            //   },
                                                            // ),
                                                            SizedBox(width: 8),
                                                            Text('다시 보지 않기',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ),
                                                  SizedBox(
                                                    height: 24,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            _dialogController.isChecked.value = false;
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text(
                                                            '취소',
                                                            style: TextStyle(
                                                                color: Color(0xff3D83ED),
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          style: TextButton.styleFrom(
                                                            splashFactory: InkRipple.splashFactory,
                                                            elevation: 0,
                                                            minimumSize: Size(100, 48),
                                                            backgroundColor: Color(0xFF3D83ED).withOpacity(0.2),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8,),
                                                      Obx(() => Expanded(
                                                        child: ElevatedButton(
                                                          style: TextButton.styleFrom(
                                                            splashFactory: InkRipple.splashFactory,
                                                            elevation: 0,
                                                            minimumSize: Size(100, 48),
                                                            backgroundColor: Color(0xFF3D83ED),
                                                          ),
                                                          child: Text("친구톡 등록",
                                                            style: TextStyle(
                                                                color: Color(0xffffffff),
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          onPressed: _dialogController.isChecked.value
                                                              ? () async {
                                                            CustomFullScreenDialog.showDialog();
                                                            await _userModelController.updateCommentCheck();
                                                            await _friendsCommentModelController.sendMessage(
                                                              displayName: _userModelController.displayName,
                                                              profileImageUrl: _userModelController.profileImageUrl,
                                                              comment: _newComment,
                                                              commentCount: _userModelController.commentCount,
                                                              resortNickname: _userModelController.resortNickname,
                                                              myUid: _userModelController.uid,
                                                              friendsUid: widget.uid,
                                                            );
                                                            String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendTalkKey];
                                                            await _alarmCenterController.sendAlarm(
                                                                alarmCount: 'friend',
                                                                receiverUid: widget.uid,
                                                                senderUid: _userModelController.uid,
                                                                senderDisplayName: _userModelController.displayName,
                                                                timeStamp: Timestamp.now(),
                                                                category: alarmCategory,
                                                                msg: '${_userModelController.displayName}님이 $alarmCategory을 등록했습니다.',
                                                                content: _newComment,
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
                                                                originContent: 'friend',
                                                                bulletinLostUid: '',
                                                                bulletinLostCount: ''
                                                            );
                                                            await _userModelController.getCurrentUser(
                                                                _userModelController.uid);
                                                            _friendTalkController.clear();
                                                            Navigator.pop(context);
                                                            FocusScope.of(context).unfocus();
                                                            CustomFullScreenDialog.cancelDialog();
                                                          }
                                                              : () async {
                                                            CustomFullScreenDialog.showDialog();
                                                            await _friendsCommentModelController.sendMessage(
                                                              displayName: _userModelController.displayName,
                                                              profileImageUrl: _userModelController.profileImageUrl,
                                                              comment: _newComment,
                                                              commentCount: _userModelController.commentCount,
                                                              resortNickname: _userModelController.resortNickname,
                                                              myUid: _userModelController.uid,
                                                              friendsUid: widget.uid,
                                                            );
                                                            String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendTalkKey];
                                                            await _alarmCenterController.sendAlarm(
                                                                alarmCount: 'friend',
                                                                receiverUid: widget.uid,
                                                                senderUid: _userModelController.uid,
                                                                senderDisplayName: _userModelController.displayName,
                                                                timeStamp: Timestamp.now(),
                                                                category: alarmCategory,
                                                                msg: '${_userModelController.displayName}님이 $alarmCategory을 등록했습니다.',
                                                                content: _newComment,
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
                                                                originContent: 'friend',
                                                                bulletinLostUid: '',
                                                                bulletinLostCount: ''
                                                            );
                                                            _friendTalkController.clear();
                                                            Navigator.pop(context);
                                                            FocusScope.of(context).unfocus();
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                        ),
                                                      ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                        );
                                        Get.dialog(
                                            AlertDialog()
                                        ); //빈 다이얼로그. 이거없으면 위 다이얼로그가 안나옴..

                                      } else {
                                        CustomFullScreenDialog.showDialog();
                                        await _friendsCommentModelController.sendMessage(
                                          displayName: _userModelController.displayName,
                                          profileImageUrl: _userModelController.profileImageUrl,
                                          comment: _newComment,
                                          commentCount: _userModelController.commentCount,
                                          resortNickname: _userModelController.resortNickname,
                                          myUid: _userModelController.uid,
                                          friendsUid: widget.uid,
                                        );
                                        await _userModelController
                                            .updateMyFriendCommentUidList(
                                            friendUid: widget.uid);
                                        String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendTalkKey];
                                        await _alarmCenterController.sendAlarm(
                                            alarmCount: 'friend',
                                            receiverUid: widget.uid,
                                            senderUid: _userModelController.uid,
                                            senderDisplayName: _userModelController.displayName,
                                            timeStamp: Timestamp.now(),
                                            category: alarmCategory,
                                            msg: '${_userModelController.displayName}님이 $alarmCategory을 등록했습니다.',
                                            content: _newComment,
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
                                            originContent: 'friend',
                                            bulletinLostUid: '',
                                            bulletinLostCount: ''
                                        );
                                        FocusScope.of(context).unfocus();
                                        _friendTalkController.clear();
                                      }
                                    } catch (e) {
                                      CustomFullScreenDialog.cancelDialog();
                                    }
                                    CustomFullScreenDialog.cancelDialog();
                                  },
                                  icon: (_friendTalkController.text.trim().isEmpty)
                                      ? Image.asset(
                                    'assets/imgs/icons/icon_livetalk_send_g.png',
                                    width: 27,
                                    height: 27,
                                  )
                                      : Image.asset(
                                    'assets/imgs/icons/icon_livetalk_send.png',
                                    width: 27,
                                    height: 27,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                ),
                                hintText: '친구톡 남기기',
                                contentPadding: EdgeInsets.only(
                                    top: 2, bottom: 2, left: 16, right: 16),
                                fillColor: Color(0xFFEFEFEF),
                                hoverColor: Colors.transparent,
                                filled: true,
                                focusColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder:  OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder:  OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                )),
                            onChanged: (value) {
                              setState(() {
                                _newComment = value;

                              });
                            },
                          ),
                        ),
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}

// if (!snapshot.hasData || snapshot.data == null) {}
// else if (snapshot.data!.docs.isNotEmpty) {
// Column('

// children: [
//
// ],
// );
// }
// else if (snapshot.connectionState == ConnectionState.waiting) {}
// return Center(
// child: CircularProgressIndicator(),
// );