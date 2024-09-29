import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

class LicenseDetailPage extends StatelessWidget {
  const LicenseDetailPage({Key? key,
    required this.licenseName, required this.version, required this.license, required this.repository,}) : super(key: key);

  final String? licenseName;
  final String? version;
  final String? license;
  final String? repository;

  String _bodyText(){
    return license!.split('\n').map((line) {
      if(line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
        toolbarHeight: 44,
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
        title: Text('$licenseName $version',
          style: SDSTextStyle.extraBold.copyWith(
              color: SDSColor.gray900,
              fontSize: 18),),
        centerTitle: false,
        backgroundColor: SDSColor.snowliveWhite,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$repository',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 15,
                  color: SDSColor.gray900
                ),),
                SizedBox(
                  height: 40,
                ),
                Text(_bodyText(),
                  style: SDSTextStyle.regular.copyWith(
                      fontSize: 15,
                      color: SDSColor.gray900
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
