import 'package:flutter/material.dart';

class LicenseDetailPage extends StatelessWidget {
  const LicenseDetailPage({Key? key,
    required this.licenseName, required this.version, required this.license}) : super(key: key);

  final String? licenseName;
  final String? version;
  final String? license;

  String _bodyText(){
    return license!.split('\n').map((line) {
      if(line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$licenseName $version'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Container(
            child: Text(_bodyText()),
          ),
        ),
      )
    );
  }
}
