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
                appBar: AppBar(
                  iconTheme: IconThemeData(size: 30, color: Colors.black),
                  actions: [
                    GestureDetector(
                      child: Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      onTap: () {
                        LoginController().signOut();
                      },
                    )
                  ],
                  centerTitle: true,
                  title: Text(
                    'SNOWLIVE',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                ),
                bottomNavigationBar: Obx(()=>BottomNavigationBar(

                  currentIndex: _bottomNavigationBarController.currentIndex.value,
                  onTap: _bottomNavigationBarController.changePage,
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined), label: 'Home'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.snowboarding_outlined), label: 'Brand'),
                  ],
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                )),
                body: Obx(()=>_bottomNavigationBarController.currentPage)
            ));

  }
}





