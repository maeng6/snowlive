import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:snowlive3/screens/discover/v_discover_Resort_Banner.dart';
import 'package:snowlive3/screens/discover/v_discover_calendar.dart';
import 'package:snowlive3/screens/discover/v_discover_info.dart';
import 'package:snowlive3/screens/discover/v_discover_tip.dart';

import '../../controller/vm_userModelController.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {

  @override
  Widget build(BuildContext context) {

    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '디스커버',
              style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: _statusBarSize+58),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(top: 10),
                  child: DiscoverScreen_ResortBanner()),
              SizedBox(height: 10),
              DiscoverScreen_Calendar(),
              SizedBox(height: 48),
              DiscoverScreen_Tip(),
              SizedBox(height: 48),
              DiscoverScreen_Info(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}