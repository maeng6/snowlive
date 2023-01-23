import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Chatroom.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_ModifyPage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class FleaMarket_List_Detail extends StatefulWidget {
  FleaMarket_List_Detail({Key? key}) : super(key: key);


  @override
  State<FleaMarket_List_Detail> createState() => _FleaMarket_List_DetailState();
}

class _FleaMarket_List_DetailState extends State<FleaMarket_List_Detail> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  FleaChatModelController _fleaChatModelController = Get.find<FleaChatModelController>();
//TODO: Dependency Injection**************************************************



  @override
  Widget build(BuildContext context) {
    String _time = _fleaModelController
        .getAgoTime(_fleaModelController.timeStamp);
    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: Column(
            children: [
              CarouselSlider.builder(
          options: CarouselOptions(
          height: 200,
              viewportFraction: 1,
              enableInfiniteScroll: false,
             ),
          itemCount: _fleaModelController.itemImagesUrls!.length,
          itemBuilder: (context, index, pageViewIndex) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: 44,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(_fleaModelController.itemImagesUrls!.isEmpty)
                            Image.asset('assets/imgs/profile/img_profile_default_.png'),
                          Container(
                            height:200,
                            child: ExtendedImage.network(
                              _fleaModelController.itemImagesUrls![index],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
              SizedBox(
                height: 20,
              ),
              Container(
                   child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(_fleaModelController.profileImageUrl!.isEmpty)
                          ExtendedImage.asset(
                              'assets/imgs/profile/img_profile_default_circle.png',
                              shape: BoxShape.circle,
                              borderRadius:
                              BorderRadius.circular(20),
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                        if(_fleaModelController.profileImageUrl!.isNotEmpty)
                          ExtendedImage.network(
                            '${_fleaModelController.profileImageUrl}',
                            shape: BoxShape.circle,
                            borderRadius:
                            BorderRadius.circular(20),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${_fleaModelController.displayName}',
                                      //chatDocs[index].get('displayName'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF111111)),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '$_time',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF949494),
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  ListTile(
                    leading: Text('카테고리'),
                    title: Text('${_fleaModelController.category}'),
                  ),
                  ListTile(
                    leading: Text('제품명'),
                    title: Text('${_fleaModelController.itemName}'),
                  ),
                  ListTile(
                    leading: Text('가격'),
                    title: Text('${_fleaModelController.price}'),
                  ),
                  ListTile(
                    leading: Text('거래지역'),
                    title: Text('${_fleaModelController.location}'),
                  ),
                  ListTile(
                    leading: Text('거래방식'),
                    title: Text('${_fleaModelController.method}'),
                  ),
                  ListTile(
                    title: Text('상세설명'),
                    subtitle: Text('${_fleaModelController.description}'),
                  )
                ]
              ),
              SizedBox(
                height: 20,
              ),

              TextButton(
                  onPressed: () async{
                    CustomFullScreenDialog.showDialog();
                    try{
                      if(_fleaModelController.uid != _userModelController.uid){
                        await _userModelController.updatefleaChatUid(_fleaModelController.uid);
                        await _userModelController.fleaChatCountUpdate(_userModelController.uid);
                        await _fleaChatModelController.createChatroom(
                            uid: _userModelController.uid,
                            otherUid: _fleaModelController.uid,
                            timeStamp: _time,
                            fleaChatCount: _userModelController.fleaChatCount,
                            otherProfileImageUrl: _fleaModelController.profileImageUrl,
                            otherResortNickname: _fleaModelController.resortNickname,
                            otherDisplayName: _fleaModelController.displayName,
                            displayName: _userModelController.displayName,
                            profileImageUrl: _userModelController.profileImageUrl,
                            resortNickname: _userModelController.resortNickname,
                            fixMyUid: _userModelController.uid
                        );
                        await _fleaChatModelController.updateChatUidSumList(_fleaModelController.uid);
                        CustomFullScreenDialog.cancelDialog();
                        return Get.to(()=>FleaChatroom());
                      }else{
                        CustomFullScreenDialog.cancelDialog();
                        return Get.to(()=>FleaMarket_ModifyPage());
                      }
                    }catch(e){
                      print('에러');
                      CustomFullScreenDialog.cancelDialog();
                    }



                  },
                  child:
                  (_fleaModelController.uid != _userModelController.uid)
                  ? Text('메시지 보내기') : Text('수정하기')

              ),



          ],
          ),
        ),
      ),
    );
  }
}

