import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/vm_timeStampController.dart';
import 'package:com.snowlive/screens/more/v_noticeDetailPage.dart';


class NoticeList extends StatefulWidget {
  const NoticeList({Key? key}) : super(key: key);

  @override
  State<NoticeList> createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {

  //TODO: Dependency Injection**************************************************
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text('공지사항',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notice')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.white,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final noticeDocs = snapshot.data!.docs;
          Size _size = MediaQuery.of(context).size;

          return ListView.builder(
            itemCount: noticeDocs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: (){
                  print(noticeDocs[index].get('noticeTitle'));
                  print(noticeDocs[index].get('noticeDetail'));
                  print(noticeDocs[index].get('noticeDetail2'));
                  Get.to(()=>NoticeDetail(
                    noticeTile: noticeDocs[index].get('noticeTitle'),
                    noticeDetail: noticeDocs[index].get('noticeDetail'),
                    noticeDetail2: noticeDocs[index].get('noticeDetail2'),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: _size.width - 180),
                        child: Text(
                          noticeDocs[index].get('noticeTitle'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111)
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Text(_timeStampController.yyyymmddFormat(noticeDocs[index].get('timeStamp')),style: TextStyle(
                        fontWeight: FontWeight.normal, color: Color(0xFF949494), fontSize: 14
                      ),),
                      SizedBox(
                        width: 12,
                      ),
                      Image.asset('assets/imgs/icons/icon_arrow_g.png',
                        height: 24,
                        width: 24,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
