import 'package:cloud_firestore/cloud_firestore.dart';

class ResortData{
void getResortData() async {
  await FirebaseFirestore.instance.collection('resort').orderBy('resortName').snapshots().listen((data) {
    resortList[0].resortName = data.docs[0]['resortName'];
  });

  }
}
//TODO : 리조트데이터 파베에서 관리할 때 사용. 아직 사용안함

class ResortModel {

  int? index;
  String? resortName;
  String? resortUrl;
  String? webcamUrl;
  String? naverUrl;
  double? latitude;
  double? longitude;
  int? nX;
  int? nY;

  ResortModel({this.index,this.resortName, this.resortUrl, this.webcamUrl,
    this.naverUrl, this.latitude, this.longitude, this.nX, this.nY});

  ResortModel resortModelSelection(int num) {
    ResortModel selectedResort = resortList[num];
    return selectedResort;
  } //유저가 선택한 리조트 모델 가져오기
}

List<ResortModel> resortList = [
  ResortModel(
    index:0,
    resortName: '곤지암리조트',
    resortUrl: 'https://konjiamresort.co.kr/',
    webcamUrl: '',
    naverUrl: 'https://weather.naver.com/today/02610330?cpName=KMA',
    latitude: 37.3372414,
    longitude: 127.2953076,
    nX: 66,
    nY: 121,
  ),//곤지암
  ResortModel(
    index:1,
    resortName: '무주덕유산리조트',
    resortUrl: 'https://www.mdysresort.com/',
    webcamUrl: 'https://www.mdysresort.com/guide/webcam.asp',
    naverUrl: 'https://weather.naver.com/today/13730320?cpName=KMA',
    latitude: 35.8902945,
    longitude: 127.7375075,
    nX: 75,
    nY: 93,
  ),//무주
  ResortModel(
    index:2,
    resortName: '비발디파크',
    resortUrl: 'https://www.sonohotelsresorts.com/daemyung.vp.skiworld.index.ds/',
    webcamUrl: 'https://www.sonohotelsresorts.com/daemyung.vp.utill.09_02_02_01.ds/dmparse.dm?areaType=S',
    naverUrl: 'https://weather.naver.com/today/01720370?cpName=KMA',
    latitude: 37.6466335,
    longitude: 127.6813286,
    nX: 72,
    nY: 129,
  ),//비발디
  ResortModel(
    index:3,
    resortName: '알펜시아',
    resortUrl: 'https://www.alpensia.com/',
    webcamUrl: 'https://www.alpensia.com/guide/web-cam.do',
    naverUrl: 'https://weather.naver.com/today/01760380?cpName=KMA',
    latitude: 37.6580936,
    longitude: 128.6713607,
    nX: 89,
    nY: 130,
  ),//알펜
  ResortModel(
    index:4,
    resortName: '에덴벨리리조트',
    resortUrl: 'http://www.edenvalley.co.kr/',
    webcamUrl: '',
    naverUrl: 'https://weather.naver.com/today/03330320?cpName=KMA',
    latitude: 35.4290765,
    longitude: 128.9844681,
    nX: 95,
    nY: 80,
  ),//에덴
  ResortModel(
    index:5,
    resortName: '엘리시안강촌',
    resortUrl: 'https://elysian.co.kr/',
    webcamUrl: 'https://www.elysian.co.kr/gangchon/ski/ski_slope03.asp',
    naverUrl: 'https://weather.naver.com/today/01110400?cpName=KMA',
    latitude: 37.8163989,
    longitude: 127.587019,
    nX: 71,
    nY: 132,
  ),//엘리시안
  ResortModel(
    index:6,
    resortName: '오크밸리리조트',
    resortUrl: 'http://www.oakvalley.co.kr/',
    webcamUrl: 'http://www.oakvalley.co.kr/oak_new/new_ski04.asp',
    naverUrl: 'https://weather.naver.com/today/01130330?cpName=KMA',
    latitude: 37.4023124,
    longitude: 127.8122233,
    nX: 75,
    nY: 122,
  ),//오크
  ResortModel(
    index:7,
    resortName: '오투리조트',
    resortUrl: 'https://www.o2resort.com/',
    webcamUrl: '',
    naverUrl: 'https://weather.naver.com/today/01190101?cpName=KMA',
    latitude: 37.1773859,
    longitude: 128.9478083,
    nX: 95,
    nY: 119,
  ),//오투
  ResortModel(
    index:8,
    resortName: '용평리조트',
    resortUrl: 'https://www.yongpyong.co.kr/',
    webcamUrl: 'https://www.yongpyong.co.kr/kor/guide/realTimeNews/ypResortWebcam.do',
    naverUrl: 'https://weather.naver.com/today/01760380?cpName=KMA',
    latitude: 37.6450087,
    longitude: 128.6829718,
    nX: 89,
    nY: 130,
  ),//용평
  ResortModel(
    index:9,
    resortName: '웰리힐리파크',
    resortUrl: 'https://www.wellihillipark.com/',
    webcamUrl: '',
    naverUrl: 'https://weather.naver.com/today/01730330?cpName=KMA',
    latitude: 37.4856398,
    longitude: 128.2474111,
    nX: 81,
    nY: 126,
  ),//웰리힐리
  ResortModel(
    index:10,
    resortName: '지산리조트',
    resortUrl: 'https://www.jisanresort.co.kr/',
    webcamUrl: '',
    naverUrl: 'https://weather.naver.com/today/02500340?cpName=KMA',
    latitude: 37.2172859,
    longitude: 127.3448223,
    nX: 66,
    nY: 120,
  ),//지산
  ResortModel(
    index:11,
    resortName: '하이원리조트',
    resortUrl: 'https://www.high1.com/',
    webcamUrl: 'https://www.high1.com/ski/slopeView.do?key=748&mode=p',
    naverUrl: 'https://weather.naver.com/today/01770253?cpName=KMA',
    latitude: 37.2074566,
    longitude: 128.8253198,
    nX: 92,
    nY: 120,
  ),//하이원
  ResortModel(
    index:12,
    resortName: '휘닉스평창',
    resortUrl: 'https://phoenixhnr.co.kr/',
    webcamUrl: 'https://phoenixhnr.co.kr/page/pyeongchang/guide/operation/sketchMovie',
    naverUrl: 'https://weather.naver.com/today/01760340?cpName=KMA',
    latitude: 37.5817875,
    longitude: 128.3208284,
    nX: 84,
    nY: 128,
  ),//휘닉스
];

List<String?> resortNameList = [
  resortList[0].resortName,
  resortList[1].resortName,
  resortList[2].resortName,
  resortList[3].resortName,
  resortList[4].resortName,
  resortList[5].resortName,
  resortList[6].resortName,
  resortList[7].resortName,
  resortList[8].resortName,
  resortList[9].resortName,
  resortList[10].resortName,
  resortList[11].resortName,
  resortList[12].resortName,
];































































