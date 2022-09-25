import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_bottomNavigationBar.dart';
import 'package:snowlive3/controller/vm_loginController.dart';

class MainHome extends StatelessWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection************************************************
    Get.put(BottomNavigationBarController(), permanent: true);
    BottomNavigationBarController _bottomNavigationBarController =
        Get.find<BottomNavigationBarController>();
    //TODO: Dependency Injection************************************************

    return SafeArea(
        child: Scaffold(
            bottomNavigationBar: Obx(
                  () => BottomNavigationBar(
                backgroundColor: Colors.white,
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
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/imgs/icons/icon_brand_off.png',
                      scale: 4,
                    ),
                    activeIcon: Image.asset(
                        'assets/imgs/icons/icon_brand_on.png',
                        scale: 4),
                    label: 'Brand',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/imgs/icons/icon_weather_off.png',
                      scale: 4,
                    ),
                    activeIcon: Image.asset(
                        'assets/imgs/icons/icon_weather_on.png',
                        scale: 4),
                    label: 'Weather',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/imgs/icons/icon_more_off.png',
                      scale: 4,
                    ),
                    activeIcon: Image.asset(
                        'assets/imgs/icons/icon_more_on.png',
                        scale: 4),
                    label: 'More',
                  ),
                ],
                showUnselectedLabels: false,
                showSelectedLabels: false,
              ),
            ),
            body: Obx(() => _bottomNavigationBarController.currentPage)));
  }
}
