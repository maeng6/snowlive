import 'package:flutter/material.dart';
import 'package:snowlive3/screens/comments/v_commentTile_liveTalk_resortTab.dart';
import 'package:snowlive3/screens/comments/v_newComment.dart';

import '../../controller/vm_commentController.dart';


class CommentScreen_LiveTalk_resortTab extends StatefulWidget {
  CommentScreen_LiveTalk_resortTab({Key? key,this.index}) : super(key: key);

  int? index;

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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:   AppBar(
          iconTheme: IconThemeData(size: 26, color: Colors.black87),
          centerTitle: true,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text('라이브 톡')
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body:  Container(
              margin: EdgeInsets.only(top: 20),
                child:Column(
                  children: [
                    Expanded(child: CommentTile_liveTalk_resortTab(index: widget.index,)),
                    NewComment(),
                  ],
                )
              ),

      ),

    );
  }
}