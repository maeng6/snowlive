import 'package:flutter/material.dart';

import '../snowliveDesignStyle.dart';

class CrewTodayPage extends StatefulWidget {
  @override
  State<CrewTodayPage> createState() => _CrewTodayPageState();
}

class _CrewTodayPageState extends State<CrewTodayPage> {
  bool isCurrentSeason = true; // true: 24-25시즌, false: 23-24시즌
  int? expandedCardIndex; // 확장된 카드의 인덱스를 저장하는 변수
  bool isTodayCardExpanded = true; // 오늘 현황 카드의 확장 상태

  @override
  void initState() {
    super.initState();
    // 초기화 시점에 현재 시점의 월과 일 카드가 열리도록 설정
    expandedCardIndex = DateTime.now().day - 1; // 현재 일에 맞춰 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.gray50,
      appBar: AppBar(
        backgroundColor: SDSColor.gray50,
        elevation: 0.0,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          '오늘의 현황',
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCurrentSeason = true;
                    expandedCardIndex = DateTime.now().day - 1; // 현재 일에 맞춰 설정
                    isTodayCardExpanded = true;
                  });
                },
                child: Chip(
                  label: Text('24-25시즌'),
                  backgroundColor: isCurrentSeason ? Colors.black : Colors.grey[300],
                  labelStyle: TextStyle(color: isCurrentSeason ? Colors.white : Colors.black),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCurrentSeason = false;
                    expandedCardIndex = DateTime.now().day - 1; // 현재 일에 맞춰 설정
                    isTodayCardExpanded = true;
                  });
                },
                child: Chip(
                  label: Text('23-24시즌'),
                  backgroundColor: isCurrentSeason ? Colors.grey[300] : Colors.black,
                  labelStyle: TextStyle(color: isCurrentSeason ? Colors.black : Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            isCurrentSeason ? '2025년 1월' : '2024년 12월',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          buildTodayCard(isCurrentSeason),
          ...List.generate(10, (index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                key: Key(index.toString()), // 키를 사용하여 고유하게 만듭니다.
                initiallyExpanded: expandedCardIndex == index,
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (expanded) {
                      expandedCardIndex = index;
                    } else {
                      if (expandedCardIndex == index) {
                        expandedCardIndex = null;
                      }
                    }
                  });
                },
                title: Text('${14 - index}일(${['일', '월', '화', '수', '목', '금', '토'][index % 7]})'),
                children: <Widget>[
                  ListTile(title: Text('세부사항')),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildTodayCard(bool isCurrentSeason) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        key: Key('today'), // 고유 키 설정
        initiallyExpanded: isTodayCardExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            isTodayCardExpanded = expanded;
          });
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '15일(토)',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Chip(
              label: Text('오늘'),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildStatusColumn(isCurrentSeason ? '951' : '800', '오늘의 점수'),
                    buildStatusColumn(isCurrentSeason ? '7' : '6', '오늘 탄 멤버'),
                    buildStatusColumn(isCurrentSeason ? '5' : '4', '라이브온'),
                  ],
                ),
                SizedBox(height: 16),
                Divider(thickness: 1),
                SizedBox(height: 16),
                Text(
                  '시간대별 라이딩 횟수',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(8, (index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: isCurrentSeason ? (index + 1) * 20.0 : (8 - index) * 15.0,
                            width: 20,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 4),
                          Text('${index * 2}-${index * 2 + 2}'),
                        ],
                      );
                    }),
                  ),
                ),
                SizedBox(height: 16),
                Divider(thickness: 1),
                SizedBox(height: 16),
                Text(
                  '오늘의 라이딩 멤버 6명',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                ...List.generate(6, (index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('https://example.com/profile.jpg'),
                    ),
                    title: Text('멤버 $index'),
                    trailing: Text('${(index + 1) * (isCurrentSeason ? 30 : 25)}점'),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column buildStatusColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}