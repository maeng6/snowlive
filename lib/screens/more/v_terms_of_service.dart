import 'package:flutter/material.dart';

class TermsOfService extends StatefulWidget {
  const TermsOfService({Key? key}) : super(key: key);

  @override
  State<TermsOfService> createState() => _TermsOfServiceState();
}

class _TermsOfServiceState extends State<TermsOfService> {
  int index = 0;

  Widget _topMenu() {
    return Wrap(
      children: [
        _menuOne(
          menu: '이용약관',
          isActive: index == 0,
          onTap: () {
            index = 0;
            update();
          },
        ),
        _menuOne(
            menu: '개인정보 처리방침',
            isActive: index == 1,
            onTap: () {
              index = 1;
              update();
            }),
      ],
    );
  }

  void update() => setState(() {});

  Widget _menuOne(
      {required String menu,
        required bool isActive,
        required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 12,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
              width: 1,
              color:
              isActive ? const Color(0xffe53154) : const Color(0xffcccccc)),
          color: const Color(0xfffafafa),
        ),
        child: Center(
          child: Text(
            menu,
            style: TextStyle(
              color: isActive ? const Color(0xffe53154) : Colors.black,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomContentView() {
    return IndexedStack(
      index: index,
      children: [
        Container(
          child: Text('이용 약관 내용 입력'),
        ),
        Container(
          child: Text('개인정보처리방침 내용 입력'),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('서비스 약관'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(10), child: _topMenu()),
            Padding(
                padding: const EdgeInsets.all(10), child: _bottomContentView()),
          ],
        ),
      ),
    );
  }
}