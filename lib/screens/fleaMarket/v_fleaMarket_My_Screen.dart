import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Upload.dart';
import 'package:snowlive3/screens/fleaMarket/v_phone_Auth_Screen.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_My_Screen extends StatefulWidget {
  const FleaMarket_My_Screen({Key? key}) : super(key: key);

  @override
  State<FleaMarket_My_Screen> createState() =>
      _FleaMarket_My_ScreenState();
}

class _FleaMarket_My_ScreenState
    extends State<FleaMarket_My_Screen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController =
  Get.find<FleaModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;
  var f = NumberFormat('###,###,###,###');


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
    print(_stream);
  }


  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('fleaMarket')
        .where("uid", isEqualTo: "${_userModelController.uid}")
        .orderBy('timeStamp', descending: true)
        .limit(500)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF3D6FED),
            onPressed: () async{
              await _userModelController.getCurrentUser(_userModelController.uid);
              if(_userModelController.phoneAuth == true){
                Get.to(() => FleaMarket_Upload());
              }else if(_userModelController.phoneAuth == false){
                Get.to(()=>PhoneAuthScreen());
              }else{

              }
            },
            child: Icon(Icons.add),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _stream,
                    builder: (context, snapshot) {
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
                      final chatDocs = snapshot.data!.docs;
                      return Scrollbar(
                        child: ListView.builder(
                          itemCount: chatDocs.length,
                          itemBuilder: (context, index) {
                            String _time = _fleaModelController
                                .getAgoTime(chatDocs[index].get('timeStamp'));
                            return GestureDetector(
                              onTap: () async{
                                CustomFullScreenDialog.showDialog();
                                await _fleaModelController.getCurrentFleaItem(
                                    uid: chatDocs[index].get('uid'),
                                    fleaCount: chatDocs[index].get('fleaCount'));
                                CustomFullScreenDialog.cancelDialog();
                                Get.to(()=>FleaMarket_List_Detail());
                              },
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if(List.from(chatDocs[index]['itemImagesUrls']).isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: ExtendedImage.network(
                                                  chatDocs[index]['itemImagesUrls'][0],
                                                  cache: true,
                                                  shape:
                                                  BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            if(List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: ExtendedImage.asset(
                                                  'assets/imgs/profile/img_profile_default_.png',
                                                  shape:
                                                  BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  width: 100,
                                                  height: 100,
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
                                                  Container(
                                                    constraints:
                                                    BoxConstraints(
                                                        maxWidth: _size.width - 150),
                                                    child: Text(
                                                      chatDocs[index].get('title'),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF555555)),
                                                    ),
                                                  ),
                                                  Text(
                                                    '$_time',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Color(0xFF949494),
                                                        fontWeight: FontWeight.normal),
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth:
                                                            _size.width - 106),
                                                        child: Text(
                                                          f.format(chatDocs[index].get('price')) + ' 원',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(3),
                                                          color: Color(0xFFD7F4FF),
                                                        ),
                                                        padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                        child: Text(
                                                          chatDocs[index].get('category'),
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12,
                                                              color: Color(0xFF458BF5)),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 6,
                                                      ),
                                                      Container(decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        color: Color(0xFFD5F7E0),
                                                      ),
                                                        padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                        child: Text(
                                                          chatDocs[index].get(
                                                              'location'),
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12,
                                                              color: Color(0xFF17AD4A)),
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
                                  Divider(
                                    color: Color(0xFFDEDEDE),
                                    height: 32,
                                    thickness: 0.5,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
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
