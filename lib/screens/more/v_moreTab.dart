import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/more/v_contactUsPage.dart';
import 'package:snowlive3/screens/more/v_favoriteResort_moreTab.dart';
import 'package:snowlive3/screens/more/v_licenseListPage.dart';
import 'package:snowlive3/screens/more/v_noticeListPage.dart';
import 'package:snowlive3/screens/more/v_resortTab.dart';
import 'package:snowlive3/screens/more/v_setProfileImage_moreTab.dart';
import 'package:snowlive3/screens/more/v_setting_moreTab.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import '../../controller/vm_userModelController.dart';

class MoreTab extends StatefulWidget {
  MoreTab({Key? key}) : super(key: key);

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  TextEditingController _textEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '',
                style: GoogleFonts.notoSans(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w900,
                    fontSize: 23),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: ListView(
            children: [
              SizedBox(
                height: 24,
              ),
              Obx(() => UserAccountsDrawerHeader(
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                accountName: Row(
                  children: [
                    Text(
                      _userModelController.displayName!,
                      style: TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Stack(children: [
                      GestureDetector(
                          onTap: () {
                            _textEditingController.clear();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Container(
                                    height: 300,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Text(
                                            '변경할 활동명을 입력해주세요.',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111111)),
                                          ),
                                          SizedBox(
                                            height: 24,
                                          ),
                                          Container(
                                            height: 130,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Form(
                                                  key: _formKey,
                                                  child: TextFormField(
                                                    cursorColor:
                                                        Color(0xff377EEA),
                                                    cursorHeight: 16,
                                                    cursorWidth: 2,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    controller:
                                                        _textEditingController,
                                                    strutStyle: StrutStyle(
                                                        leading: 0.3),
                                                    decoration: InputDecoration(
                                                        errorStyle: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                        hintStyle: TextStyle(
                                                            color: Color(
                                                                0xff949494),
                                                            fontSize: 16),
                                                        hintText: '활동명 입력',
                                                        labelText: '활동명',
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 20,
                                                                bottom: 20,
                                                                left: 20,
                                                                right: 20),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFDEDEDE)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFDEDEDE)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFFF3726)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        )),
                                                    validator: (val) {
                                                      if (val!.length <= 20 &&
                                                          val.length >= 1) {
                                                        return null;
                                                      } else if (val.length ==
                                                          0) {
                                                        return '닉네임을 입력해주세요.';
                                                      } else {
                                                        return '최대 글자 수를 초과했습니다.';
                                                      }
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 6,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 19),
                                                  child: Text(
                                                    '최대 20글자까지 입력 가능합니다.',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff949494),
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
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      '취소',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                        splashFactory: InkRipple
                                                            .splashFactory,
                                                        elevation: 0,
                                                        minimumSize:
                                                            Size(100, 56),
                                                        backgroundColor:
                                                            Color(0xff555555),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0)),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        await _userModelController
                                                            .updateNickname(
                                                                _textEditingController
                                                                    .text);
                                                        Get.snackbar(
                                                            '닉네임을 변경하였습니다.', '',
                                                            snackPosition:
                                                                SnackPosition
                                                                    .BOTTOM,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 20,
                                                                    left: 20,
                                                                    bottom: 12),
                                                            backgroundColor:
                                                                Colors.black87,
                                                            colorText:
                                                                Colors.white,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    3000));
                                                        Navigator.pop(context);
                                                      } else {
                                                        Get.snackbar(
                                                            '닉네임 저장 실패',
                                                            '올바른 닉네임을 입력해주세요.',
                                                            snackPosition:
                                                                SnackPosition
                                                                    .BOTTOM,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 20,
                                                                    left: 20,
                                                                    bottom: 12),
                                                            backgroundColor:
                                                                Colors.black87,
                                                            colorText:
                                                                Colors.white,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    3000));
                                                      }
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    },
                                                    child: Text(
                                                      '변경',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                        splashFactory: InkRipple
                                                            .splashFactory,
                                                        elevation: 0,
                                                        minimumSize:
                                                            Size(100, 56),
                                                        backgroundColor:
                                                            Color(0xff2C97FB),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0)),
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
                          child: Image.asset(
                            'assets/imgs/icons/icon_edit_pencil.png',
                            height: 22,
                            width: 22,
                          )),
                    ])
                  ],
                ),
                accountEmail: Stack(
                  children: [
                    Text(
                      _userModelController.userEmail!,
                      style: TextStyle(color: Color(0xFF949494), fontSize: 13),
                    ),
                  ],
                ),
                currentAccountPicture: (_userModelController
                        .profileImageUrl!.isNotEmpty)
                    ? GestureDetector(
                        onTap: () => Get.to(() => SetProfileImage_moreTab()),
                        child: Stack(
                          children: [
                             Container(
                                  width: 64,
                                  height: 64,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.grey[100],
                                      backgroundImage: NetworkImage(
                                        _userModelController.profileImageUrl!,
                                      )),
                                ),
                            Positioned(
                                bottom: 10,
                                right: 4,
                                child: ExtendedImage.asset(
                                    'assets/imgs/icons/icon_profile_add.png',
                                    height: 22,
                                    width: 22))
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Get.to(() => SetProfileImage_moreTab()),
                        child: Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              child: CircleAvatar(
                                backgroundColor: Colors.yellow[100],
                                backgroundImage: AssetImage(
                                    'assets/imgs/profile/img_profile_default_circle.png'),
                              ),
                            ),
                            Positioned(
                                bottom: 10,
                                right: 4,
                                child: GestureDetector(
                                  child: ExtendedImage.asset(
                                      'assets/imgs/icons/icon_profile_add.png',
                                      height: 22,
                                      width: 22),
                                  onTap: () {},
                                ))
                          ],
                        ),
                      ),
                decoration: BoxDecoration(color: Colors.white),
              )),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => NoticeList());
                },
                title: Text(
                  '공지사항',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => FavoriteResort_moreTab());
                },
                title: Text(
                  '자주가는 스키장',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => ResortTab());
                },
                title: Text(
                  '리조트 모아보기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => WebPage(
                        url:
                            'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88',
                      ));
                },
                title: Text(
                  '이용약관',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => WebPage(
                        url:
                            'https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88',
                      ));
                },
                title: Text(
                  '개인정보처리방침',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => LicenseListPage());
                },
                title: Text(
                  '오픈소스라이선스',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => ContactUsPage());
                },
                title: Text(
                  'SNOWLIVE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(()=>setting_moreTab());
                },
                title: Text(
                  '설정',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 36),
            ],
          ),
        ));
  }
}
