import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/onboarding/v_setNickname.dart';
import '../../model/m_resortModel.dart';
import '../../widget/w_fullScreenDialog.dart';

class FavoriteResort extends StatefulWidget {
  FavoriteResort({Key? key}) : super(key: key);

  @override
  State<FavoriteResort> createState() => _FavoriteResortState();
}

class _FavoriteResortState extends State<FavoriteResort> {

  //TODO: Dependency Injection********************************************
  UserModelController userModelController = Get.find<UserModelController>();
  ResortModelController resortModelController = Get.find<ResortModelController>();
  //TODO: Dependency Injection********************************************

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<bool?> _isChecked = List<bool?>.filled(14, false);
  List<bool?> _isSelected = List<bool?>.filled(14, false);
  int? favoriteResort;
  final FirebaseFirestore ref = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      '자주가는 스키장을 \n선택해주세요.',
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  '자주가는 스키장은 1개만 선택할 수 있습니다.',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildCheckboxListTile(index),
                          Divider(
                            height: 20,
                            thickness: 0.5,
                          ),
                        ],
                      );
                    }),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    CustomFullScreenDialog.showDialog();
                    await userModelController.updateFavoriteResort(favoriteResort);
                    await resortModelController.getSelectedResort(userModelController.favoriteResort!);
                    CustomFullScreenDialog.cancelDialog();
                    Get.to(SetNickname());
                  },
                  child: Text(
                    '다음',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(350, 56),
                      backgroundColor: Color(0xff2C97FB)),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }

  CheckboxListTile buildCheckboxListTile(int index) {
    return CheckboxListTile(
      title: Text('${resortNameList[index]}'),
      activeColor: Color(0xff2C97FB),
      selected: _isSelected[index]!,
      selectedTileColor: Color(0xff2C97FB),
      value: _isChecked[index],
      onChanged: (bool? value) {
        setState(() {
          _isChecked = List<bool?>.filled(14, false);
          _isSelected = List<bool?>.filled(14, false);
          _isChecked[index] = value;
          _isSelected[index] = value;
          if (value == false) {
            favoriteResort = null;
          } else {
            favoriteResort = index;
          }
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
