import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/v_webPage.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({Key? key}) : super(key: key);

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
          child: Text('날씨',
          style: GoogleFonts.notoSans(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w900,
              fontSize: 23),
          ),
        ),
      ),
      body: resortListView(_size),
    );


  }

  ListView resortListView(Size _size) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index){
        return Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          height: _size.width * 0.2,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      '${resortNameList[index]}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${resortAddressList[index]}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        color: Colors.grey
                      ),
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                  onPressed: (){
                    Get.to(() => WebPage(
                        url:
                        '${naverUrlList[index]}',
                      ),
                    );
                  },
                  child: Text('네이버 날씨',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7)))
                ),
              )
            ],
          ),
        );
      },
      itemCount: resortList.length
  );
  }
}
