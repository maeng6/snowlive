import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_licenseModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/view/moreTab/v_licenseDetailPage.dart';

class LicenseListPage extends StatelessWidget {
  const LicenseListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
        title: Text('오픈소스 라이선스',
          style: SDSTextStyle.extraBold.copyWith(
              color: SDSColor.gray900,
              fontSize: 18),
        ),
      ),
      body: licenseListView(_size),
    );
  }

  ListView licenseListView(Size _size) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              Get.to(()=>LicenseDetailPage(
                license: licenseList[index],
                version: versionList[index],
                licenseName: licenseNameList[index],
                repository: repositoryList[index],
              ));
            },
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
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
