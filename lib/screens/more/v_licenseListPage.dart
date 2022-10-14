import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/model/m_licenseModel.dart';
import 'package:snowlive3/screens/more/v_licenseDetailPage.dart';

class LicenseListPage extends StatelessWidget {
  const LicenseListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text('오픈소스라이선스',
            style: GoogleFonts.notoSans(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w900,
                fontSize: 20),
          ),
        ),
      ),
      body: licenseListView(_size),
    );
  }

  ListView licenseListView(Size _size) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: (){
              Get.to(()=>LicenseDetailPage(
                license: licenseList[index],
                version: versionList[index],
                licenseName: licenseNameList[index],));
            },
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: _size.width * 0.2,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      '${licenseNameList[index]} ${versionList[index]}',
                      style: TextStyle(
                          fontSize: 17,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios)
                ],
              ),
            ),
          );
        },
        itemCount: licenseList.length
    );
  }
}
