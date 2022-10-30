import 'package:flutter/material.dart';
import 'package:snowlive3/screens/comments/v_commentTile_liveTalk_resortTab.dart';
import 'package:snowlive3/screens/comments/v_newComment.dart';

class CommentScreen_LiveTalk_resortTab extends StatefulWidget {
  CommentScreen_LiveTalk_resortTab({Key? key,required this.index, required this.resortName}) : super(key: key);

  int? index;
  String? resortName;

  @override
  _CommentScreen_LiveTalk_resortTabState createState() => _CommentScreen_LiveTalk_resortTabState();
}

class _CommentScreen_LiveTalk_resortTabState extends State<CommentScreen_LiveTalk_resortTab> {

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
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
              iconTheme: IconThemeData(size: 26, color: Colors.black87),
              centerTitle: true,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Text(
                  '라이브톡',
                  style: TextStyle(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF111111)),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            body: Container(
                  margin: EdgeInsets.only(top: 10),
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5, right: 6),
                              child: Text(
                                ' ${widget.resortName}',
                                style: TextStyle(
                                    letterSpacing: 0.4,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF949494)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: CommentTile_liveTalk_resortTab(index: widget.index,)),
                        NewComment(index: widget.index),
                      ],
                    )
                  ),

          ),
        ),
      ),

    );
  }
}