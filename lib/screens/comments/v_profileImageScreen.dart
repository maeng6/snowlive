import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snowlive3/screens/comments/v_liveTalk_Screen.dart';

class ProfileImagePage extends StatefulWidget {
  ProfileImagePage({Key? key, required this.CommentProfileUrl}) : super(key: key);

  var CommentProfileUrl;

  @override
  State<ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends State<ProfileImagePage> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.down,
      key: UniqueKey(),
      onDismissed: (_)=>Navigator.pop(context),
      child: Scaffold(
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
        body: InteractiveViewer(
          maxScale: 7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if(widget.CommentProfileUrl != '')
              ExtendedImage.network(widget.CommentProfileUrl),
              if(widget.CommentProfileUrl == '')
                ExtendedImage.asset(
                  'assets/imgs/profile/img_profile_default_.png',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
