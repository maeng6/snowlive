
import 'package:flutter/material.dart';

class NoticeList extends StatelessWidget {
  const NoticeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

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
      body:  ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (){
              //공지사항 디테일로 보내는 처리
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
                              'noticeTitle',
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
                          Text('yyyymmddFormat',style: TextStyle(
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
                  // if (noticeDocs.length != index+1)
                    Divider(
                      height: 50,
                      thickness: 0.5,
                    ),
                ],
              ),
            ),
          );
        },
      )
    );
  }
}
