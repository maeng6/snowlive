import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/comments/comments.dart';
import 'package:snowlive3/screens/comments/new_comments.dart';

import '../../controller/vm_commentController.dart';


class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {

  @override
  Widget build(BuildContext context) {

//TODO: Dependency Injection**************************************************
    Get.put(CommentModelController(), permanent: true);
//TODO: Dependency Injection**************************************************

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: Container(
                    child: Comments()),
              ),
              NewComments(),
            ],
          ),
        ),
      ),
    );
  }
}