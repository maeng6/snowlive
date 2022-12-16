import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';


class NoticeDetail extends StatefulWidget {
  NoticeDetail({Key? key, this.noticeTile}) : super(key: key);

  var noticeTile;

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
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text('${widget.noticeTile}',
            style: GoogleFonts.notoSans(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w900,
                fontSize: 20),
          ),
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
                onTap: (){},
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                    constraints:
                    BoxConstraints(maxWidth: _size.width - 140),
                    child:
                    Text(
                      noticeDocs[index].get('noticeDetail'),
                      maxLines:
                      1000,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.normal,
                          fontSize: 13),
                    ),
                  ),
                )
              );
            },
          );
        },
      ),
    );
  }
}
