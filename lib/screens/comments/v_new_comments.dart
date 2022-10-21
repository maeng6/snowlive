import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_commentController.dart';

import '../../controller/vm_resortModelController.dart';
import '../../controller/vm_userModelController.dart';

class NewComments extends StatefulWidget {
  const NewComments({Key? key}) : super(key: key);

  @override
  _NewCommentsState createState() => _NewCommentsState();
}

class _NewCommentsState extends State<NewComments> {
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
            onPressed: () {
              _newComment.trim().isEmpty
                  ? null
                  : FocusScope.of(context).unfocus();
              _commentModelController.sendMessage(
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
