import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/model/m_fleaMarketModel.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class SetModifyNotice_crewDetail extends StatefulWidget {
  const SetModifyNotice_crewDetail({Key? key}) : super(key: key);

  @override
  State<SetModifyNotice_crewDetail> createState() => _SetModifyNotice_crewDetailState();
}

class _SetModifyNotice_crewDetailState extends State<SetModifyNotice_crewDetail> {
  String? _initNotice ;
  TextEditingController _crewDescribTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
    _initNotice = _liveCrewModelController.notice;
  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
    //TODO : ****************************************************************

    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              title: Text('크루 공지 변경'),
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              actions: [
                TextButton(
                    onPressed: () async{
                      final isValid = _formKey.currentState!.validate();
                      if(isValid){
                        CustomFullScreenDialog.showDialog();
                        await _liveCrewModelController.updateNotice(notice: _crewDescribTextEditingController.text, crewID: _liveCrewModelController.crewID);
                        await _liveCrewModelController.getCurrnetCrew(_liveCrewModelController.crewID);
                        CustomFullScreenDialog.cancelDialog();
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text('변경완료', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D83ED)
                      ),),
                    ))
              ],
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Form(
                      key: _formKey,
                        child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Container(
                        height: 120,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                maxLines: 10,
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor: Color(0xff377EEA),
                                cursorHeight: 16,
                                cursorWidth: 2,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                controller: _crewDescribTextEditingController..text = '$_initNotice',
                                onChanged: (notice){
                                  _initNotice = notice;
                                },
                                strutStyle: StrutStyle(leading: 0.3),
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    fontSize: 12,
                                  ),
                                  labelStyle: TextStyle(
                                      color: Color(0xff949494)
                                  ),
                                  hintStyle:
                                  TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                  hintText: '내용을 작성해 주세요. (최대 1,000자)',
                                  labelText: '크루 공지글 입력',
                                  border: InputBorder.none,
                                ),
                                validator: (val) {
                                  if (val!.length <= 1000 && val.length >= 1) {
                                    return null;
                                  } else if (val.length == 0) {
                                    return '크루 공지글을 입력해주세요.';
                                  } else {
                                    return '최대 입력 가능한 글자 수를 초과했습니다.';
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    )
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}