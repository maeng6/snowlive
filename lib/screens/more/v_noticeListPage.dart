import 'package:com.snowlive/controller/moreTab/vm_streamController_moreTab.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/public/vm_timeStampController.dart';
import 'package:com.snowlive/screens/more/v_noticeDetailPage.dart';


class NoticeList extends StatefulWidget {
  const NoticeList({Key? key}) : super(key: key);

  @override
  State<NoticeList> createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {

  //TODO: Dependency Injection**************************************************
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  StreamController_MoreTab _streamController_MoreTab = Get.find<StreamController_MoreTab>();
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
        stream: _streamController_MoreTab.setupStreams_moreTab_notice(),
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
                  padding: EdgeInsets.only(left: 16, right: 16),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: _size.width - 80),
                                child: Text(
                                  noticeDocs[index].get('noticeTitle'),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111)
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(_timeStampController.yyyymmddFormat(noticeDocs[index].get('timeStamp')),style: TextStyle(
                                  fontWeight: FontWeight.normal, color: Color(0xFF949494), fontSize: 14
                              ),),
                            ],
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Image.asset('assets/imgs/icons/icon_arrow_g.png',
                            height: 24,
                            width: 24,
                          )
                        ],
                      ),
                      if (noticeDocs.length != index+1)
                        Divider(
                          height: 50,
                          thickness: 0.5,
                        ),
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
