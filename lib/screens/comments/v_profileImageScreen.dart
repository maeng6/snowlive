import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileImagePage extends StatefulWidget {
  ProfileImagePage({Key? key, required this.CommentProfileUrl}) : super(key: key);

  var CommentProfileUrl;

  @override
  State<ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends State<ProfileImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: GestureDetector(
            child: Icon(Icons.close,
            color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(widget.CommentProfileUrl != '')
          InteractiveViewer(
              minScale: 1,
              maxScale: 10,
              child: ExtendedImage.network(widget.CommentProfileUrl)),
          if(widget.CommentProfileUrl == '')
            ExtendedImage.asset(
              'assets/imgs/profile/img_profile_default_.png',
            ),
        ],
      ),
    );
  }
}
