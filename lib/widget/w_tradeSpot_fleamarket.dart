import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TradeSpotFleamarketWidget extends StatefulWidget {

  @override
  _TradeSpotFleamarketWidgetState createState() => _TradeSpotFleamarketWidgetState();
}

class _TradeSpotFleamarketWidgetState extends State<TradeSpotFleamarketWidget> {
  List<bool?> _isSelected = List<bool?>.filled(13, false);
  String? tradeSpot;

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
            '희망 거래 장소를 선택해 주세요.',
            style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
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
                        '${spot_list[index]}',
                        style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                      ),
                      selected: _isSelected[index]!,
                      onTap: () {
                        setState(() {
                          _isSelected = List<bool?>.filled(13, false);
                          _isSelected[index] = true;
                          tradeSpot = spot_list[index];
                        });
                      },
                    ),
                    if (index != 12) Divider(height: 4, thickness: 0.5, color: SDSColor.snowliveWhite),
                    if (index == 12) Container(height: 12),
                  ],
                );
              },
            ),
          ),
          Container(
            width: _size.width,
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, tradeSpot);
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
        ],
      ),
    );
  }
}

List<String?> spot_list = [
  '곤지암리조트',
  '무주덕유산리조트',
  '비발디파크',
  '알펜시아',
  '엘리시안강촌',
  '오크밸리리조트',
  '오투리조트',
  '용평리조트',
  '웰리힐리파크',
  '지산리조트',
  '하이원리조트',
  '휘닉스파크',
  '기타'
];