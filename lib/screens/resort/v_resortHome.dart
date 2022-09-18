import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';

class ResortHome extends StatelessWidget {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController =
      Get.find<ResortModelController>();
  GetDateTimeController _getDateTimeController =
      Get.find<GetDateTimeController>();
  //TODO: Dependency Injection**************************************************
 bool isWaiting = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _userModelController.getLocalSave(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          _resortModelController
              .getSelectedResort(_userModelController.favoriteSaved!);
          return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Color(0xff54B2EB),
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 28,
                            ),
                            GestureDetector(
                              child: Obx(
                                () => Text(
                                  '${_resortModelController.resortName}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20),
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                          child: ListView.builder(
                                              itemCount: 14,
                                              itemBuilder: (ctx, index) {
                                                return ListTile(
                                                    title: Text(
                                                        '${resortNameList[index]}'),
                                                    onTap: () async {
                                                      await _resortModelController
                                                          .getSelectedResort(
                                                              index);
                                                      Navigator.pop(ctx);
                                                    });
                                              }));
                                    });
                              },
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              '${_getDateTimeController.date}',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                            SizedBox(
                              height: 35,
                            ),
                            TextButton(
                              child: Obx(
                                () =>  Text(
                                  '${_resortModelController.resortTemp!.substring(0,2)}\u2103',//u00B0
                                  style: TextStyle(
                                      fontSize: 80, color: Colors.white),
                                ),
                              ),
                              onPressed: () {
                                Get.to(Obx(
                                  () => WebPage(
                                    url: '${_resortModelController.naverUrl}',
                                  ),
                                ));
                              },
                            ),
                            SizedBox(
                              height: 19,
                            ), //실시간 날씨
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '강수',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Obx(
                                      () => Text(
                                        '${_resortModelController.resortRain}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '풍속',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Obx(
                                      () => Text(
                                        '${_resortModelController.resortWind}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '습도',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Obx(() =>
                                      Text(
                                        '${_resortModelController.resortWet}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '최저/최고',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Obx(() =>
                                        Text(
                                          '${_resortModelController.resortMinTemp}/${_resortModelController.resortMaxTemp}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 37,
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 28,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('리조트 정보'),
                              SizedBox(
                                height: 10,
                              ),
                              ListTile(
                                leading: Icon(Icons.emergency_recording),
                                title: Text('실시간 웹캠'),
                                trailing: Text('더보기'),
                                onTap: () {
                                  Get.to(Obx(
                                    () => WebPage(
                                      url: '${_resortModelController.webcamUrl}',
                                    ),
                                  ));
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.monitor),
                                title: Text('리조트 홈페이지'),
                                trailing: Text('더보기'),
                                onTap: () {
                                  Get.to(Obx(
                                    () => WebPage(
                                      url: '${_resortModelController.resortUrl}',
                                    ),
                                  ));
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
        });
  }
}
