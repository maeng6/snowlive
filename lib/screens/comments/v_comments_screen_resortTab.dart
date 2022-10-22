import 'package:flutter/material.dart';
import 'package:snowlive3/screens/comments/v_comments_resortTab.dart';
import 'package:snowlive3/screens/comments/v_new_comments.dart';

import '../../controller/vm_commentController.dart';


class CommentsScreen_resortTab extends StatefulWidget {
  CommentsScreen_resortTab({Key? key,this.index}) : super(key: key);

  int? index;

  @override
  _CommentsScreen_resortTabState createState() => _CommentsScreen_resortTabState();
}

class _CommentsScreen_resortTabState extends State<CommentsScreen_resortTab> {

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
                    Expanded(child: Comments_resortTab(index: widget.index,)),
                    NewComments(),
                  ],
                )
              ),

      ),

    );
  }
}