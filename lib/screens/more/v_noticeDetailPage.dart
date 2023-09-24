import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';


class NoticeDetail extends StatefulWidget {
  NoticeDetail({Key? key,required this.noticeTile,required this.noticeDetail,required this.noticeDetail2}) : super(key: key);

  var noticeTile;
  var noticeDetail;
  var noticeDetail2;

  @override
  State<NoticeDetail> createState() => _NoticeDetailState();
}

class _NoticeDetailState extends State<NoticeDetail> {


  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    setState(fn);
  }

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.noticeTile}',
                  style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  '${widget.noticeDetail}',
                  maxLines:
                  1000,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  '${widget.noticeDetail2}',
                  maxLines:
                  1000,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
