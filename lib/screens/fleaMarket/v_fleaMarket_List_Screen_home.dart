import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_List_Screen_Home extends StatefulWidget {
  const FleaMarket_List_Screen_Home({Key? key}) : super(key: key);

  @override
  State<FleaMarket_List_Screen_Home> createState() => _FleaMarket_List_ScreenState_Home();
}

class _FleaMarket_List_ScreenState_Home extends State<FleaMarket_List_Screen_Home> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;
  var f = NumberFormat('###,###,###,###');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('fleaMarket')
        .orderBy('timeStamp', descending: true)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
     stream: _stream,
     builder: (context, snapshot) {
       if (!snapshot.hasData) {
         return Container(
           color: Colors.white,
         );
       } else if (snapshot.connectionState ==
           ConnectionState.waiting) {
         return  Center(
           child: CircularProgressIndicator(),
         );
       }
       final chatDocs = snapshot.data!.docs;
       return Column(
         children: [
           if(chatDocs.length.isGreaterThan(0))
           CarouselSlider.builder(
               itemCount: chatDocs.length,
               itemBuilder: (context, index, pageViewIndex) {
                 String _time = _fleaModelController
                     .getAgoTime(chatDocs[index].get('timeStamp'));
                 return GestureDetector(
                   onTap: () async {
                     if (_userModelController.repoUidList!
                         .contains(chatDocs[index].get('uid'))) {
                       return;
                     }

                     CustomFullScreenDialog.showDialog();
                     await _fleaModelController.getCurrentFleaItem(
                         uid: chatDocs[index].get('uid'),
                         fleaCount: chatDocs[index].get('fleaCount'));
                     CustomFullScreenDialog.cancelDialog();
                     print(_fleaModelController.itemImagesUrls);
                     Get.to(() => FleaMarket_List_Detail());
                   },
                   child: Obx(() => Column(
                     children: [
                       Container(
                         color: Colors.white,
                         child: Column(
                           crossAxisAlignment:
                           CrossAxisAlignment.start,
                           children: [
                             (_userModelController.repoUidList!
                                 .contains(
                                 chatDocs[index].get('uid')))
                                 ? Center(
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                                 child: Text(
                                   '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                   style: TextStyle(
                                       fontWeight:
                                       FontWeight.normal,
                                       fontSize: 12,
                                       color:
                                       Color(0xffc8c8c8)),
                                 ),
                               ),
                             )
                                 : Row(
                               crossAxisAlignment:
                               CrossAxisAlignment.start,
                               children: [
                                 if (List.from(chatDocs[index]
                                 ['itemImagesUrls'])
                                     .isNotEmpty)
                                   Padding(
                                     padding: EdgeInsets.only(top: 8, bottom: 8),
                                     child:
                                     ExtendedImage.network(
                                       chatDocs[index][
                                       'itemImagesUrls'][0],
                                       cache: true,
                                       shape:
                                       BoxShape.rectangle,
                                       borderRadius:
                                       BorderRadius
                                           .circular(8),
                                       border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                       width: 40,
                                       height: 40,
                                       fit: BoxFit.cover,
                                     ),
                                   ),
                                 if (List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                   Padding(
                                     padding: EdgeInsets.only(top: 8, bottom: 8),
                                     child:
                                     ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                       shape:
                                       BoxShape.rectangle,
                                       borderRadius:
                                       BorderRadius
                                           .circular(8),
                                       width: 40,
                                       height: 40,
                                       fit: BoxFit.cover,
                                     ),
                                   ),
                                 SizedBox(width: 12),
                                 Padding(
                                   padding: const EdgeInsets.symmetric(vertical: 6),
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         children: [
                                           Container(
                                             constraints:
                                             BoxConstraints(
                                                 maxWidth: _size.width - 150),
                                             child: Text(
                                               chatDocs[index]
                                                   .get('title'),
                                               maxLines: 1,
                                               overflow: TextOverflow.ellipsis,
                                               style: TextStyle(
                                                   fontWeight:
                                                   FontWeight.normal,
                                                   fontSize: 14,
                                                   color: Color(
                                                       0xFF555555)),
                                             ),
                                           ),                                                          ],
                                       ),
                                       Container(
                                         constraints:
                                         BoxConstraints(
                                             maxWidth:
                                             _size.width -
                                                 106),
                                         child: Text(
                                           f.format(chatDocs[index].get('price'))+' 원',
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                           style: TextStyle(
                                               color: Color(0xFF111111),
                                               fontWeight:
                                               FontWeight.bold,
                                               fontSize: 14),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                       SizedBox(
                         height: 12,
                       )
                     ],
                   )),
                 );

               },
               options: CarouselOptions(
                   height: 68,
                   initialPage: 0,
                   scrollPhysics: NeverScrollableScrollPhysics(),
                   viewportFraction: 1,
                   enableInfiniteScroll: false,
                   autoPlayInterval: Duration(seconds: 4)),
           ),
           if(chatDocs.length.isGreaterThan(1))
           CarouselSlider.builder(
             itemCount: chatDocs.length,
             itemBuilder: (context, index, pageViewIndex) {
               String _time = _fleaModelController
                   .getAgoTime(chatDocs[index].get('timeStamp'));
               return GestureDetector(
                 onTap: () async {
                   if (_userModelController.repoUidList!
                       .contains(chatDocs[index].get('uid'))) {
                     return;
                   }

                   CustomFullScreenDialog.showDialog();
                   await _fleaModelController.getCurrentFleaItem(
                       uid: chatDocs[index].get('uid'),
                       fleaCount: chatDocs[index].get('fleaCount'));
                   CustomFullScreenDialog.cancelDialog();
                   print(_fleaModelController.itemImagesUrls);
                   Get.to(() => FleaMarket_List_Detail());
                 },
                 child: Obx(() => Column(
                   children: [
                     Container(
                       color: Colors.white,
                       child: Column(
                         crossAxisAlignment:
                         CrossAxisAlignment.start,
                         children: [
                           (_userModelController.repoUidList!
                               .contains(
                               chatDocs[index].get('uid')))
                               ? Center(
                             child: Padding(
                               padding: const EdgeInsets.symmetric(vertical: 24),
                               child: Text(
                                 '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                 style: TextStyle(
                                     fontWeight:
                                     FontWeight.normal,
                                     fontSize: 12,
                                     color:
                                     Color(0xffc8c8c8)),
                               ),
                             ),
                           )
                               : Row(
                             crossAxisAlignment:
                             CrossAxisAlignment.start,
                             children: [
                               if (List.from(chatDocs[index]
                               ['itemImagesUrls'])
                                   .isNotEmpty)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8, bottom: 8),
                                   child:
                                   ExtendedImage.network(
                                     chatDocs[index][
                                     'itemImagesUrls'][0],
                                     cache: true,
                                     shape:
                                     BoxShape.rectangle,
                                     borderRadius:
                                     BorderRadius
                                         .circular(8),
                                     border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                     width: 40,
                                     height: 40,
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               if (List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8, bottom: 8),
                                   child:
                                   ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                     shape:
                                     BoxShape.rectangle,
                                     borderRadius:
                                     BorderRadius
                                         .circular(8),
                                     width: 40,
                                     height: 40,
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               SizedBox(width: 12),
                               Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 6),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Container(
                                           constraints:
                                           BoxConstraints(
                                               maxWidth: _size.width - 150),
                                           child: Text(
                                             chatDocs[index]
                                                 .get('title'),
                                             maxLines: 2,
                                             overflow: TextOverflow.ellipsis,
                                             style: TextStyle(
                                                 fontWeight:
                                                 FontWeight.normal,
                                                 fontSize: 14,
                                                 color: Color(
                                                     0xFF555555)),
                                           ),
                                         ),                                                          ],
                                     ),
                                     Container(
                                       constraints:
                                       BoxConstraints(
                                           maxWidth:
                                           _size.width -
                                               106),
                                       child: Text(
                                         f.format(chatDocs[index].get('price'))+' 원',                                         maxLines: 1,
                                         overflow: TextOverflow.ellipsis,
                                         style: TextStyle(
                                             color: Color(0xFF111111),
                                             fontWeight:
                                             FontWeight.bold,
                                             fontSize: 14),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                     SizedBox(
                       height: 12,
                     )
                   ],
                 )),
               );
             },
             options: CarouselOptions(
                 height: 68,
                 scrollPhysics: NeverScrollableScrollPhysics(),
                 initialPage: 1,
                 viewportFraction: 1,
                 enableInfiniteScroll: false,
                 autoPlayInterval: Duration(seconds: 4)),
           ),
           if(chatDocs.length.isGreaterThan(2))
           CarouselSlider.builder(
             itemCount: chatDocs.length,
             itemBuilder: (context, index, pageViewIndex) {
               String _time = _fleaModelController
                   .getAgoTime(chatDocs[index].get('timeStamp'));
               return GestureDetector(
                 onTap: () async {
                   if (_userModelController.repoUidList!
                       .contains(chatDocs[index].get('uid'))) {
                     return;
                   }

                   CustomFullScreenDialog.showDialog();
                   await _fleaModelController.getCurrentFleaItem(
                       uid: chatDocs[index].get('uid'),
                       fleaCount: chatDocs[index].get('fleaCount'));
                   CustomFullScreenDialog.cancelDialog();
                   print(_fleaModelController.itemImagesUrls);
                   Get.to(() => FleaMarket_List_Detail());
                 },
                 child: Obx(() => Column(
                   children: [
                     Container(
                       color: Colors.white,
                       child: Column(
                         crossAxisAlignment:
                         CrossAxisAlignment.start,
                         children: [
                           (_userModelController.repoUidList!
                               .contains(
                               chatDocs[index].get('uid')))
                               ? Center(
                             child: Padding(
                               padding: const EdgeInsets.symmetric(vertical: 24),
                               child: Text(
                                 '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                 style: TextStyle(
                                     fontWeight:
                                     FontWeight.normal,
                                     fontSize: 12,
                                     color:
                                     Color(0xffc8c8c8)),
                               ),
                             ),
                           )
                               : Row(
                             crossAxisAlignment:
                             CrossAxisAlignment.start,
                             children: [
                               if (List.from(chatDocs[index]
                               ['itemImagesUrls'])
                                   .isNotEmpty)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8, bottom: 8),
                                   child:
                                   ExtendedImage.network(
                                     chatDocs[index][
                                     'itemImagesUrls'][0],
                                     cache: true,
                                     shape:
                                     BoxShape.rectangle,
                                     borderRadius:
                                     BorderRadius
                                         .circular(8),
                                     border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                     width: 40,
                                     height: 40,
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               if (List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8, bottom: 8),
                                   child:
                                   ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                     shape:
                                     BoxShape.rectangle,
                                     borderRadius:
                                     BorderRadius
                                         .circular(8),
                                     width: 40,
                                     height: 40,
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               SizedBox(width: 12),
                               Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 6),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Container(
                                           constraints:
                                           BoxConstraints(
                                               maxWidth: _size.width - 150),
                                           child: Text(
                                             chatDocs[index]
                                                 .get('title'),
                                             maxLines: 2,
                                             overflow: TextOverflow.ellipsis,
                                             style: TextStyle(
                                                 fontWeight:
                                                 FontWeight.normal,
                                                 fontSize: 14,
                                                 color: Color(
                                                     0xFF555555)),
                                           ),
                                         ),                                                          ],
                                     ),
                                     Container(
                                       constraints:
                                       BoxConstraints(
                                           maxWidth:
                                           _size.width -
                                               106),
                                       child: Text(
                                         f.format(chatDocs[index].get('price'))+' 원',                                         maxLines: 1,
                                         overflow: TextOverflow.ellipsis,
                                         style: TextStyle(
                                             color: Color(0xFF111111),
                                             fontWeight:
                                             FontWeight.bold,
                                             fontSize: 14),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                     SizedBox(
                       height: 12,
                     )
                   ],
                 )),
               );

             },
             options: CarouselOptions(
                 height: 68,
                 scrollPhysics: NeverScrollableScrollPhysics(),
                 initialPage: 2,
                 viewportFraction: 1,
                 enableInfiniteScroll: false,
                 autoPlayInterval: Duration(seconds: 4)),
           ),
           if(chatDocs.length.isGreaterThan(3))
           CarouselSlider.builder(
             itemCount: chatDocs.length,
             itemBuilder: (context, index, pageViewIndex) {
               String _time = _fleaModelController
                   .getAgoTime(chatDocs[index].get('timeStamp'));
               return GestureDetector(
                 onTap: () async {
                   if (_userModelController.repoUidList!
                       .contains(chatDocs[index].get('uid'))) {
                     return;
                   }

                   CustomFullScreenDialog.showDialog();
                   await _fleaModelController.getCurrentFleaItem(
                       uid: chatDocs[index].get('uid'),
                       fleaCount: chatDocs[index].get('fleaCount'));
                   CustomFullScreenDialog.cancelDialog();
                   print(_fleaModelController.itemImagesUrls);
                   Get.to(() => FleaMarket_List_Detail());
                 },
                 child: Obx(() => Column(
                   children: [
                     Container(
                       color: Colors.white,
                       child: Column(
                         crossAxisAlignment:
                         CrossAxisAlignment.start,
                         children: [
                           (_userModelController.repoUidList!
                               .contains(
                               chatDocs[index].get('uid')))
                               ? Center(
                             child: Padding(
                               padding: const EdgeInsets.symmetric(vertical: 24),
                               child: Text(
                                 '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                 style: TextStyle(
                                     fontWeight:
                                     FontWeight.normal,
                                     fontSize: 12,
                                     color:
                                     Color(0xffc8c8c8)),
                               ),
                             ),
                           )
                               : Row(
                             crossAxisAlignment:
                             CrossAxisAlignment.start,
                             children: [
                               if (List.from(chatDocs[index]
                               ['itemImagesUrls'])
                                   .isNotEmpty)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8, bottom: 8),
                                   child:
                                   ExtendedImage.network(
                                     chatDocs[index][
                                     'itemImagesUrls'][0],
                                     cache: true,
                                     shape:
                                     BoxShape.rectangle,
                                     borderRadius:
                                     BorderRadius
                                         .circular(8),
                                     border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                     width: 40,
                                     height: 40,
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               if (List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8, bottom: 8),
                                   child:
                                   ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                     shape:
                                     BoxShape.rectangle,
                                     borderRadius:
                                     BorderRadius
                                         .circular(8),
                                     width: 40,
                                     height: 40,
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               SizedBox(width: 12),
                               Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 6),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Container(
                                           constraints:
                                           BoxConstraints(
                                               maxWidth: _size.width - 150),
                                           child: Text(
                                             chatDocs[index]
                                                 .get('title'),
                                             maxLines: 2,
                                             overflow: TextOverflow.ellipsis,
                                             style: TextStyle(
                                                 fontWeight:
                                                 FontWeight.normal,
                                                 fontSize: 14,
                                                 color: Color(
                                                     0xFF555555)),
                                           ),
                                         ),                                                          ],
                                     ),
                                     Container(
                                       constraints:
                                       BoxConstraints(
                                           maxWidth:
                                           _size.width -
                                               106),
                                       child: Text(
                                         f.format(chatDocs[index].get('price'))+' 원',                                         maxLines: 1,
                                         overflow: TextOverflow.ellipsis,
                                         style: TextStyle(
                                             color: Color(0xFF111111),
                                             fontWeight:
                                             FontWeight.bold,
                                             fontSize: 14),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                     SizedBox(
                       height: 12,
                     )
                   ],
                 )),
               );
             },
             options: CarouselOptions(
                 height: 68,
                 scrollPhysics: NeverScrollableScrollPhysics(),
                 initialPage: 3,
                 viewportFraction: 1,
                 enableInfiniteScroll: false,
                 autoPlayInterval: Duration(seconds: 4)),
           ),
           if(chatDocs.length.isGreaterThan(4))
           CarouselSlider.builder(
               itemCount: chatDocs.length,
               itemBuilder: (context, index, pageViewIndex) {
                 String _time = _fleaModelController
                     .getAgoTime(chatDocs[index].get('timeStamp'));
                 return GestureDetector(
                   onTap: () async {
                     if (_userModelController.repoUidList!
                         .contains(chatDocs[index].get('uid'))) {
                       return;
                     }

                     CustomFullScreenDialog.showDialog();
                     await _fleaModelController.getCurrentFleaItem(
                         uid: chatDocs[index].get('uid'),
                         fleaCount: chatDocs[index].get('fleaCount'));
                     CustomFullScreenDialog.cancelDialog();
                     print(_fleaModelController.itemImagesUrls);
                     Get.to(() => FleaMarket_List_Detail());
                   },
                   child: Obx(() => Column(
                     children: [
                       Container(
                         color: Colors.white,
                         child: Column(
                           crossAxisAlignment:
                           CrossAxisAlignment.start,
                           children: [
                             (_userModelController.repoUidList!
                                 .contains(
                                 chatDocs[index].get('uid')))
                                 ? Center(
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 24),
                                 child: Text(
                                   '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                   style: TextStyle(
                                       fontWeight:
                                       FontWeight.normal,
                                       fontSize: 12,
                                       color:
                                       Color(0xffc8c8c8)),
                                 ),
                               ),
                             )
                                 : Row(
                               crossAxisAlignment:
                               CrossAxisAlignment.start,
                               children: [
                                 if (List.from(chatDocs[index]
                                 ['itemImagesUrls'])
                                     .isNotEmpty)
                                   Padding(
                                     padding: EdgeInsets.only(top: 8, bottom: 8),
                                     child:
                                     ExtendedImage.network(
                                       chatDocs[index][
                                       'itemImagesUrls'][0],
                                       cache: true,
                                       shape:
                                       BoxShape.rectangle,
                                       borderRadius:
                                       BorderRadius
                                           .circular(8),
                                       border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                       width: 40,
                                       height: 40,
                                       fit: BoxFit.cover,
                                     ),
                                   ),
                                 if (List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                   Padding(
                                     padding: EdgeInsets.only(top: 8, bottom: 8),
                                     child:
                                     ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                       shape:
                                       BoxShape.rectangle,
                                       borderRadius:
                                       BorderRadius
                                           .circular(8),
                                       width: 40,
                                       height: 40,
                                       fit: BoxFit.cover,
                                     ),
                                   ),
                                 SizedBox(width: 16),
                                 Padding(
                                   padding: const EdgeInsets.symmetric(vertical: 6),
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         children: [
                                           Container(
                                             constraints:
                                             BoxConstraints(
                                                 maxWidth: _size.width - 150),
                                             child: Text(
                                               chatDocs[index]
                                                   .get('title'),
                                               maxLines: 2,
                                               overflow: TextOverflow.ellipsis,
                                               style: TextStyle(
                                                   fontWeight:
                                                   FontWeight.normal,
                                                   fontSize: 14,
                                                   color: Color(
                                                       0xFF555555)),
                                             ),
                                           ),                                                          ],
                                       ),
                                       Row(
                                         children: [
                                           Container(
                                             constraints:
                                             BoxConstraints(
                                                 maxWidth:
                                                 _size.width -
                                                     106),
                                             child: Text(
                                               f.format(chatDocs[index].get('price'))+' 원',                                               maxLines: 1,
                                               overflow: TextOverflow.ellipsis,
                                               style: TextStyle(
                                                   color: Color(0xFF111111),
                                                   fontWeight:
                                                   FontWeight.bold,
                                                   fontSize: 14),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                       SizedBox(
                         height: 12,
                       )
                     ],
                   )),
                 );
               },
               options: CarouselOptions(
                   height: 68,
                   scrollPhysics: NeverScrollableScrollPhysics(),
                   initialPage: 4,
                   viewportFraction: 1,
                   enableInfiniteScroll: false,
                   autoPlayInterval: Duration(seconds: 4)),
             ),
         ],
       );
     },
    );
  }
}
