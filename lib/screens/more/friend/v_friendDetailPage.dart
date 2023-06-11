import 'package:flutter/material.dart';

class FriendDetailPage extends StatefulWidget {
  const FriendDetailPage({Key? key,required uid}) : super(key: key);

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(165.0),
        child: AppBar(
          backgroundColor: Color(0xFF3D83ED),
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
          titleSpacing: 0,
          centerTitle: true,
        ),
      ),
    );
  }
}
