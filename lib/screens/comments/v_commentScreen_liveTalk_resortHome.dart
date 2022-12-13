import 'package:flutter/material.dart';
import 'package:snowlive3/screens/comments/v_commentTile_liveTalk_resortHome.dart';
import 'package:snowlive3/screens/comments/v_newComment.dart';

class CommentScreen_LiveTalk_resortHome extends StatefulWidget {
  CommentScreen_LiveTalk_resortHome({Key? key})
      : super(key: key);


  @override
  _CommentScreen_LiveTalk_resortHomeState createState() =>
      _CommentScreen_LiveTalk_resortHomeState();
}

class _CommentScreen_LiveTalk_resortHomeState
    extends State<CommentScreen_LiveTalk_resortHome> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: CommentTile_liveTalk_resortHome()),
                    NewComment(),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
