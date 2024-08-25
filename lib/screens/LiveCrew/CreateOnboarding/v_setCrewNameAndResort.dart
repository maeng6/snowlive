import 'package:com.snowlive/screens/LiveCrew/CreateOnboarding/v_setCrewImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import '../../../model_2/m_resortModel.dart';
import '../../snowliveDesignStyle.dart';

class SetCrewNameAndResort extends StatefulWidget {
  SetCrewNameAndResort({Key? key}) : super(key: key);

  @override
  State<SetCrewNameAndResort> createState() => _SetCrewNameAndResortState();
}

class _SetCrewNameAndResortState extends State<SetCrewNameAndResort> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _crewName;
  bool isLoading = false;

  List<bool?> _isSelected = List<bool?>.filled(14, false);
  List<bool?> _isChecked = List<bool?>.filled(14, false);

  int baseResort = 0;

  @override
  void initState() {
    super.initState();
    UserModelController _userModelController = Get.find<UserModelController>();
    _isSelected[0] = true; // 초기값을 선택된 상태로 설정
    _isChecked[0] = true;
  }

  void _showResortSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: resortNameList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.only(left: 16, right: 16),
                    title: Text('${resortNameList[index]}', style: TextStyle(fontSize: 16),),
                    selected: _isSelected[index]!,
                    trailing: _isChecked[index]!
                        ? Image.asset(
                      'assets/imgs/icons/icon_check_filled.png',
                      width: 24,
                      height: 24,
                    )
                        : Image.asset(
                      'assets/imgs/icons/icon_check_unfilled.png',
                      width: 24,
                      height: 24,
                    ),
                    onTap: () {
                      setState(() {
                        _isChecked = List<bool?>.filled(14, false);
                        _isSelected = List<bool?>.filled(14, false);
                        _isChecked[index] = true;
                        _isSelected[index] = true;
                        baseResort = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(58),
              child: AppBar(
                leading: GestureDetector(
                  child: Icon(Icons.arrow_back),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                centerTitle: false,
                titleSpacing: 0,
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: _statusBarSize + 58, left: 16, right: 16, bottom: _statusBarSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '라이브크루 정보를 입력해 주세요.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '라이브크루 생성을 위해 아래 정보를 입력해 주세요.',
                    style: TextStyle(color: Color(0xff949494), fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '크루명',
                    style: TextStyle(color: Color(0xff111111), fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣]")),
                      ],
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: '이름을 입력해 주세요(최대 10자 이내)',
                        filled: true,
                        fillColor: Color(0xFFEFEFEF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '크루명을 입력해주세요.';
                        } else if (val.length > 10) {
                          return '최대 입력 가능한 글자 수를 초과했습니다.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '크루명은 최초 설정 후 수정 불가합니다.',
                    style: TextStyle(color: Color(0xff949494), fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '베이스 스키장',
                    style: TextStyle(color: Color(0xff111111), fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showResortSelectionModal(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            resortNameList[baseResort]!,
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '베이스 스키장은 최초 설정 후 수정 불가합니다.',
                    style: TextStyle(color: Color(0xff949494), fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            right: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _crewName = _textEditingController.text;
                      Get.to(() => SetCrewImage(crewName: _crewName, baseResort: baseResort));
                    }
                  },
                  child: (isLoading)
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    '다음',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.snowliveBlue,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
