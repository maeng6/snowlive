import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';

import '../../controller/vm_commentController.dart';
import '../../controller/vm_resortModelController.dart';
import '../../controller/vm_userModelController.dart';

class Comments extends StatefulWidget {
  const Comments({Key? key}) : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    ResortModelController _resortModelController =
        Get.find<ResortModelController>();
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          reverse: false,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      spreadRadius: 1.0),
                ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          ( chatDocs[index]['profileImageUrl'] == null)
                              ? Container(
                            width: 64,
                            height: 64,
                            child: CircleAvatar(
                              backgroundColor: Colors.yellow[100],
                              backgroundImage: AssetImage(
                                  'assets/imgs/profile/img_profile_default_circle.png'),
                            ),
                          )
                              : CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(
                                  chatDocs[index]['profileImageUrl'])),
                          SizedBox(width: 5),
                          Text(
                            chatDocs[index].get('displayName'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if(chatDocs[index].get('uid') == _userModelController.uid)
                          IconButton(
                            onPressed: () async{
                             await FirebaseFirestore.instance
                                  .collection('comment')
                                  .doc('resort')
                                  .collection('${_userModelController.instantResort.toString()}')
                                 .doc(_userModelController.uid)
                                 .delete();
                            },
                            icon: Icon(Icons.cancel),)
                        ],
                      ),
                    ),
                    Container(
                      child: Text(
                        '1시간전',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Text(chatDocs[index].get('comment')),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
