import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../controller/vm_commentController.dart';
import '../../controller/vm_userModelController.dart';

class CommentTile_resortHome extends StatefulWidget {
  const CommentTile_resortHome({Key? key}) : super(key: key);

  @override
  State<CommentTile_resortHome> createState() => _CommentTile_resortHomeState();
}

class _CommentTile_resortHomeState extends State<CommentTile_resortHome> {


  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    Get.put(CommentModelController(), permanent: true);
    CommentModelController _commentModelController =
    Get.find<CommentModelController>();
//TODO: Dependency Injection**************************************************


    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('comment')
          .doc('resort')
          .collection('${_userModelController.instantResort.toString()}')
          .orderBy('timeStamp', descending: true)
          .limit(4)
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
        Size _size = MediaQuery.of(context).size;

        return CarouselSlider.builder(
         options: CarouselOptions(
           height: 44,
           viewportFraction: 1,
           reverse: false,
           enableInfiniteScroll: false,
           autoPlay: true,
           autoPlayInterval: Duration(seconds: 4)
         ),
          itemCount: chatDocs.length,
          itemBuilder: (context, index, pageViewIndex) {
            String _time = _commentModelController.getAgoTime(chatDocs[index].get('timeStamp'));
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
                          if(chatDocs[index]['profileImageUrl'] != "")
                           Transform.translate(
                             offset: Offset(0,6),
                             child: ExtendedImage.network(chatDocs[index]['profileImageUrl'],
                               cache: true,
                             shape: BoxShape.circle,
                               borderRadius: BorderRadius.circular(20),
                               width: 32,
                               height: 32,
                               fit: BoxFit.cover,
                             ),
                           ),
                          if(chatDocs[index]['profileImageUrl'] == "")
                            Transform.translate(
                              offset: Offset(0,6),
                              child: ExtendedImage.asset('assets/imgs/profile/img_profile_default_circle.png',
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(20),
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                          SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    chatDocs[index].get('displayName'),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF111111)),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '$_time',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF949494),
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: _size.width - 160
                                    ),
                                    child: Text(chatDocs[index].get('comment'),
                                      maxLines:1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
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
