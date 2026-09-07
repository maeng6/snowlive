import 'package:cloud_firestore/cloud_firestore.dart';

class SplashModel {

  SplashModel();

  String _url='';
  DocumentReference? reference;

  SplashModel.fromJson(dynamic json, this.reference){
    _url = json['url'];
  }

  SplashModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);

  Future<SplashModel> getSplashImage() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    await FirebaseFirestore.instance.collection('splash').doc('image');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    SplashModel splashmodel = SplashModel.fromSnapShot(documentSnapshot);
    return splashmodel;
  }

  String get modelUrl => _url;

}