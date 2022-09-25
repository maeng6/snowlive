import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_bottomNavigationBar.dart';
import 'package:snowlive3/controller/vm_loginController.dart';

class MainHome extends StatelessWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection************************************************
    Get.put(BottomNavigationBarController(),permanent: true);
    BottomNavigationBarController _bottomNavigationBarController = Get.find<BottomNavigationBarController>();
    //TODO: Dependency Injection************************************************

    return SafeArea(
          child: Scaffold(
              backgroundColor: Color(0xFFF2F4F6),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(58),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppBar(
                      iconTheme: IconThemeData(size: 26, color: Colors.black87),
                      actions: [
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 13),
                            child: Image.asset(
                              'assets/imgs/icons/icon_snowLive_menu.png',
                              width: 26,
                              height: 26,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            LoginController().signOut();
                          },
                        )
                      ],
                      centerTitle: false,
                      titleSpacing: 0,
                      title: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Image.asset(
                          'assets/imgs/logos/snowliveLogo_black.png',
                          width: 112,
                          height: 38,
                        ),
                      ),
                      backgroundColor: Color(0xFFF2F4F6),
                      elevation: 0.0,
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Obx(()=>BottomNavigationBar(
                elevation: 10,
                type: BottomNavigationBarType.fixed,
                currentIndex: _bottomNavigationBarController.currentIndex.value,
                onTap: _bottomNavigationBarController.changePage,
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/imgs/icons/icon_home_off.png',
                      scale: 4,
                    ),
                    activeIcon: Image.asset(
                      'assets/imgs/icons/icon_home_on.png',
                      scale: 4,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/imgs/icons/icon_brand_off.png',
                      scale: 4,
                    ),
                    activeIcon: Image.asset(
                        'assets/imgs/icons/icon_brand_on.png',
                        scale: 4),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/imgs/icons/icon_weather_off.png',
                      scale: 4,
                    ),
                    activeIcon: Image.asset(
                        'assets/imgs/icons/icon_weather_on.png',
                        scale: 4),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/imgs/icons/icon_more_off.png',
                      scale: 4,
                    ),
                    activeIcon: Image.asset(
                        'assets/imgs/icons/icon_more_on.png',
                        scale: 4),
                    label: '',
                  ),
                ],
                showUnselectedLabels: false,
                showSelectedLabels: false,
              )),
              body: Obx(()=>_bottomNavigationBarController.currentPage))
      );
  }
}





