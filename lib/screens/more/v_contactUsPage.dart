import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: Text('우리는...'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Image.asset('assets/imgs/logos/134_logo.png',
            scale: 4.5,
            ),
            SizedBox(
              height: 50,
            ),
            Text('134 CREATIVE LAB',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
            ),
            SizedBox(
              height: 50,
            ),
            Text('E-mail : 134creativelab@gmail.com',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text('Copyright by 134CreativeLab 2022. All right reserved.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
