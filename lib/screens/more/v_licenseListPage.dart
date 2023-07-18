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
        title: Text('오픈소스라이선스',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 20),
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
                licenseName: licenseNameList[index],
                repository: repositoryList[index],
              ));
            },
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 18),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Flexible(
                      child: Text(
                        '${licenseNameList[index]} ${versionList[index]}',
                        style: TextStyle(
                            fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Image.asset('assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                    width: 24,
                  )
                ],
              ),
            ),
          );
        },
        itemCount: licenseList.length
    );
  }
}
