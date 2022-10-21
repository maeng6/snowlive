import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/comments/v_comments_liveTalk.dart';
import 'package:snowlive3/screens/comments/v_comments_resortMain.dart';
import 'package:snowlive3/screens/comments/v_new_comments.dart';

import '../../controller/vm_commentController.dart';


class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {

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
                    Expanded(child: Comments_liveTalk()),
                    NewComments(),
                  ],
                )
              ),

      ),

    );
  }
}