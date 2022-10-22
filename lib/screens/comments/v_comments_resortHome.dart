import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import '../../controller/vm_commentController.dart';
import '../../controller/vm_resortModelController.dart';
import '../../controller/vm_userModelController.dart';


class Comments_resortHome extends StatefulWidget {
  const Comments_resortHome({Key? key}) : super(key: key);

  @override
  State<Comments_resortHome> createState() => _Comments_resortHomeState();
}

class _Comments_resortHomeState extends State<Comments_resortHome> {


  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    ResortModelController _resortModelController =
    Get.find<ResortModelController>();
    Get.put(CommentModelController(), permanent: true);
    CommentModelController _commentModelController =
    Get.find<CommentModelController>();
    GetDateTimeController _getDateTimeController =
    Get.find<GetDateTimeController>();
//TODO: Dependency Injection**************************************************


    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('comment')
          .doc('resort')
          .collection('${_userModelController.instantResort.toString()}')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
          );
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          reverse: false,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(chatDocs[index]['profileImageUrl'] != "")
                        CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                                chatDocs[index]['profileImageUrl'])),
                      if(chatDocs[index]['profileImageUrl'] == "")
                        CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage('assets/imgs/profile/img_profile_default_circle.png')),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                chatDocs[index].get('displayName'),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5),
                              Text(
                                '1시간전',
                                style: TextStyle(fontSize: 10),
                              ),
                              if (chatDocs[index].get('uid') == _userModelController.uid)
                                SizedBox(

                                  width: 20,
                                  height: 20,
                                  child: IconButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('comment')
                                          .doc('resort')
                                          .collection(
                                          '${_userModelController.instantResort.toString()}')
                                          .doc(_userModelController.uid)
                                          .delete();
                                    },
                                    icon: Icon(Icons.cancel,
                                      size:10 ,),
                                  ),
                                )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth: 250
                                ),
                                child: Text(chatDocs[index].get('comment'),
                                  maxLines:2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Divider(
                    color: Color(0xFFF5F5F5),
                    thickness: 1,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
