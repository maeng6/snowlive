import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_commentController.dart';

import '../../controller/vm_resortModelController.dart';
import '../../controller/vm_userModelController.dart';

class NewComment extends StatefulWidget {
  const NewComment({Key? key}) : super(key: key);

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends State<NewComment> {
  final _controller = TextEditingController();
  var _newComment = '';

  @override
  Widget build(BuildContext context) {

//TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    ResortModelController _resortModelController =
        Get.find<ResortModelController>();
    CommentModelController _commentModelController =
        Get.find<CommentModelController>();
//TODO: Dependency Injection**************************************************

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(labelText: '댓글 남기기...'),
              onChanged: (value) {
                setState(() {
                  _newComment = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: () async{
              _newComment.trim().isEmpty
                  ? null
                  : FocusScope.of(context).unfocus();
              await _commentModelController.sendMessage(
                  displayName: _userModelController.displayName,
                  uid: _userModelController.uid,
                  profileImageUrl: _userModelController.profileImageUrl,
                  instantResort: _userModelController.instantResort,
                  comment: _newComment);
              _controller.clear();
            },
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
