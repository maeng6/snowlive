import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class ProfileImageView extends StatefulWidget {
  ProfileImageView({Key? key, required this.userProfileUrl}) : super(key: key);

  final String userProfileUrl;

  @override
  State<ProfileImageView> createState() => _ProfileImageViewState();
}

class _ProfileImageViewState extends State<ProfileImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: GestureDetector(
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
        ),
      ),
      body: PhotoView(
        imageProvider: widget.userProfileUrl.isNotEmpty
            ? ExtendedNetworkImageProvider(
            widget.userProfileUrl,
            cache: true
        )
            : AssetImage('assets/imgs/profile/img_profile_default_.png') as ImageProvider,
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 7,
      ),
    );
  }
}
