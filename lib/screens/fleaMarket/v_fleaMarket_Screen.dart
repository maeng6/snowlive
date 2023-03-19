import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/controller/vm_webviewController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Screen.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_My_Screen.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_chatroom_List.dart';
import '../../controller/vm_userModelController.dart';
import '../../model/m_shopModel.dart';
import '../v_webPage.dart';

class FleaMarketScreen extends StatefulWidget {
  FleaMarketScreen({Key? key}) : super(key: key);

  @override
  State<FleaMarketScreen> createState() => _FleaMarketScreenState();
}

class _FleaMarketScreenState extends State<FleaMarketScreen> {
  List<String> labels = [
    '스노우마켓',
    '판매내역',
    '채팅목록',
  ];
  int counter = 0;
  List<bool> isTap = [
    true,
    false,
    false,
  ];

  bool isFlea = true;
  bool isBrand = true;
  var _stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
    // UserModelController().updateNewChatRead();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
    _stream = newStream();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('brandList')
        .orderBy('position', descending: true)
        .limit(50)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    Get.put(FleaModelController(), permanent: true);
    Get.put(FleaChatModelController(), permanent: true);
    Get.put(WebviewController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    //TODO : ****************************************************************

    Size _size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        child: Text(
                          '중고거래',
                          style: TextStyle(
                              color: (isFlea)
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF111111),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          isFlea = true;
                          print('중고거래로 전환');
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(54, 32),
                          backgroundColor:
                          (isFlea) ? Color(0xFF111111) : Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      ElevatedButton(
                        child: Text(
                          '샵',
                          style: TextStyle(
                              color: (isFlea)
                                  ? Color(0xFF111111)
                                  : Color(0xFFFFFFFF)),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          isFlea = false;
                          print('샵페이지로 전환');
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(54, 32),
                            backgroundColor: (isFlea)
                                ? Color(0xFFFFFFFF)
                                : Color(0xFF111111),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
              iconTheme: IconThemeData(size: 26, color: Colors.black87),
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '스노우마켓',
                    style: TextStyle(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  )),
              backgroundColor: Colors.white,
              elevation: 0.0,
            )
          ],
        ),
      ),
      body: (isFlea)
          ? SafeArea(
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '상품목록',
                                    style: TextStyle(
                                        color: (isTap[0])
                                            ? Color(0xFF111111)
                                            : Color(0xFFC8C8C8),
                                        fontWeight: (isTap[0])
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    print('판매목록페이지로 전환');
                                    setState(() {
                                      isTap[0] = true;
                                      isTap[1] = false;
                                      isTap[2] = false;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 3,
                              color: (isTap[0])
                                  ? Color(0xFF111111)
                                  : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '내글보기',
                                    style: TextStyle(
                                        color: (isTap[1])
                                            ? Color(0xFF111111)
                                            : Color(0xFFC8C8C8),
                                        fontWeight: (isTap[1])
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    print('판매내역 페이지로 전환');
                                    setState(() {
                                      isTap[0] = false;
                                      isTap[1] = true;
                                      isTap[2] = false;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 3,
                              color: (isTap[1])
                                  ? Color(0xFF111111)
                                  : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                  height: 40,
                                  child:
                                  FutureBuilder(
                                      future: _userModelController
                                          .getCurrentUser(
                                          _userModelController.uid),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        return Row(
                                          children: [
                                            ElevatedButton(
                                              child: Text(
                                                '채팅목록',
                                                style: TextStyle(
                                                    color: (isTap[2])
                                                        ? Color(0xFF111111)
                                                        : Color(0xFFC8C8C8),
                                                    fontWeight: (isTap[2])
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    fontSize: 16),
                                              ),
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                print('채팅목록 페이지로 전환');
                                                _userModelController
                                                    .updateNewChatRead();
                                                setState(() {
                                                  isTap[0] = false;
                                                  isTap[1] = false;
                                                  isTap[2] = true;
                                                });
                                                print(isTap);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.only(
                                                    top: 0),
                                                minimumSize: Size(50, 10),
                                                backgroundColor: Color(
                                                    0xFFFFFFFF),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(8)),
                                                elevation: 0,
                                              ),
                                            ),
                                            SizedBox(
                                                width: 5),
                                            Icon(Icons.brightness_1, size: 6.0,
                                                color:
                                                (_userModelController.newChat ==
                                                    true)
                                                    ? Color(0xFFD32F2F) : Colors
                                                    .white)
                                          ],
                                        );
                                      })
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 3,
                              color: (isTap[2])
                                  ? Color(0xFF111111)
                                  : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isTap[0] == true)
                    Expanded(child: FleaMarket_List_Screen()),
                  if (isTap[1] == true)
                    Expanded(child: FleaMarket_My_Screen()),
                  if (isTap[2] == true)
                    Expanded(child: FleaMarket_Chatroom_List()),
                ],
              ),
            ),
          ],
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 44,
                  child: Container(
                    width: _size.width,
                    height: 1,
                    color: Color(0xFFECECEC),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '의류 브랜드 16',
                                    style: TextStyle(
                                        color: (isBrand)
                                            ? Color(0xFF111111)
                                            : Color(0xFFC8C8C8),
                                        fontWeight: (isBrand)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    print('브랜드페이지로 전환');
                                    setState(() {
                                      isBrand = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 110,
                              height: 3,
                              color: (isBrand)
                                  ? Color(0xFF111111)
                                  : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '보드샵 9',
                                    style: TextStyle(
                                      color: (isBrand)
                                          ? Color(0xFFC8C8C8)
                                          : Color(0xFF111111),
                                      fontSize: 16,
                                      fontWeight: (isBrand)
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    print('샵페이지로 전환');
                                    setState(() {
                                      isBrand = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: (isBrand)
                                        ? Color(0xFFFFFFFF)
                                        : Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(6)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 72,
                              height: 3,
                              color: (isBrand)
                                  ? Colors.transparent
                                  : Color(0xFF111111),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isBrand == true)
              Expanded(child: clothWebGridView(context)),
            if (isBrand == false)
              Expanded(child: shopWebGridView(context)),
          ],
        ),
      ),
    );
  }
}

Widget clothWebGridView(BuildContext context) {
  WebviewController _webviewController = Get.find<WebviewController>();

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('brandList')
        .orderBy('position', descending: false)
        .limit(50)
        .snapshots();
  }
  var _stream = newStream();
  final Size _size = MediaQuery
      .of(context)
      .size;
  return StreamBuilder<QuerySnapshot>(
    stream: _stream,
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (!snapshot.hasData) {
        return Container(
          color: Colors.white,
        );
      } else if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      final brandDocs = snapshot.data!.docs;
      return Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: GridView.builder(
            padding: EdgeInsets.only(top: 12, bottom: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, mainAxisSpacing: 10, childAspectRatio: 5),
            itemCount: brandDocs!.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _webviewController.visitCountUpdate(
                            brandName: brandDocs[index]['brandName']);
                        Get.to(
                                () =>
                                WebPage(url: '${brandDocs[index]['url']}'));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Container(
                            width: _size.width,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFFF0F1F2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: ExtendedImage.asset(
                                            '${brandDocs[index]['imageAsset']}',
                                            width: 30,
                                            height: 30,
                                            scale: 4,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 18,
                                      ),
                                      Text(
                                        '${brandDocs[index]['brandName']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF111111)),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      (brandDocs[index]['new'] == true) ?
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(top: 1,
                                                left: 3,
                                                right: 3,
                                                bottom: 4),
                                            child: Text(
                                              'NEW',
                                              style: TextStyle(
                                                  color: Color(0xFF3D6FED),
                                                  fontSize: 10),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              border: Border.all(
                                                  color: Color(0xFF3D6FED),
                                                  width: 1),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                        ],
                                      )
                                          : SizedBox(),
                                      (brandDocs[index]['hot'] == true) ?
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(top: 1,
                                                left: 3,
                                                right: 3,
                                                bottom: 4),
                                            child: Text(
                                              'HOT',
                                              style: TextStyle(
                                                  color: Color(0xFFF9A441),
                                                  fontSize: 10),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              border: Border.all(
                                                  color: Color(0xFFF9A441),
                                                  width: 1),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                        ],
                                      )
                                          : SizedBox(),
                                      (brandDocs[index]['event'] == true) ?
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(top: 1,
                                                left: 3,
                                                right: 3,
                                                bottom: 4),
                                            child: Text(
                                              'EVENT',
                                              style: TextStyle(
                                                  color: Color(0xFF17AD4A),
                                                  fontSize: 10),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              border: Border.all(
                                                  color: Color(0xFF17AD4A),
                                                  width: 1),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                        ],
                                      )
                                          : SizedBox(),
                                    ],
                                  ),
                                  Image.asset(
                                    'assets/imgs/icons/icon_arrow_g.png',
                                    height: 24,
                                    width: 24,
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              );
            }),
      );
    },

  );
}

Widget shopWebGridView(BuildContext context) {
  final double _statusBarSize = MediaQuery
      .of(context)
      .padding
      .top;
  final Size _size = MediaQuery
      .of(context)
      .size;
  return Padding(
    padding: EdgeInsets.only(left: 16, right: 16),
    child: GridView.builder(
        padding: EdgeInsets.only(top: 12, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, mainAxisSpacing: 10, childAspectRatio: 5),
        itemCount: shopNameList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Get.to(() => WebPage(url: '${shopHomeUrlList[index]}')),
                  child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Container(
                        width: _size.width,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFF0F1F2),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(6),
                                      child: ExtendedImage.asset(
                                        '${shopImageAssetList[index]}',
                                        width: 30,
                                        height: 30,
                                        scale: 4,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 18,
                                  ),
                                  Text(
                                    '${shopNameList[index]}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF111111)),
                                  ),
                                ],
                              ),
                              Image.asset(
                                'assets/imgs/icons/icon_arrow_g.png',
                                height: 24,
                                width: 24,
                                opacity: AlwaysStoppedAnimation(.4),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ],
          );
        }),
  );
}
