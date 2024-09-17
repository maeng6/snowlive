import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/m_resortModel.dart';
import '../screens/snowliveDesignStyle.dart';



class SelectResortWidget extends StatefulWidget {

  @override
  _SelectResortWidgetState createState() => _SelectResortWidgetState();
}

class _SelectResortWidgetState extends State<SelectResortWidget> {
  List<bool?> _isSelected = List<bool?>.filled(13, false);
  int? selectResort;

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: SDSColor.snowliveWhite,
      ),
      padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              height: 4,
              width: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: SDSColor.gray200,
              ),
            ),
          ),
          Text(
            '자주가는 스키장을 선택해 주세요.',
            style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
          ),
          SizedBox(height: 8),
          Text(
            '자주가는 스키장은 1개만 선택할 수 있습니다.',
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 13,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      trailing: _isSelected[index]!
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
                      title: Text(
                        '${resortNameList[index]}',
                        style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                      ),
                      selected: _isSelected[index]!,
                      onTap: () {
                        setState(() {
                          _isSelected = List<bool?>.filled(13, false);
                          _isSelected[index] = true;
                          selectResort = index;
                        });
                      },
                    ),
                    if (index != 12) Divider(height: 4, thickness: 0.5, color: SDSColor.snowliveWhite),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              width: _size.width,
              padding: EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectResort!+1);
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  '선택 완료',
                  style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                  elevation: 0,
                  splashFactory: InkRipple.splashFactory,
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: SDSColor.snowliveBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

