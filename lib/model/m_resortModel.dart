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
  String? resortAddress;
  String? resortUrl;
  String? webcamUrl;
  String? slopeUrl;
  String? naverUrl;
  double? latitude;
  double? longitude;
  int? nX;
  int? nY;
  String? resortNickname;
  String? resortLogo;


  ResortModel({this.index,this.resortName, this.resortAddress, this.resortUrl, this.webcamUrl,
    this.slopeUrl, this.naverUrl, this.latitude, this.longitude, this.nX, this.nY, this.resortNickname, this.resortLogo});

  ResortModel resortModelSelection(int? num) {
    ResortModel selectedResort = resortList[num!];
    return selectedResort;
  }//유저가 선택한 리조트 모델 가져오기

}

List<ResortModel> resortList = [
  ResortModel(
    index:0,
    resortName: '곤지암리조트',
    resortAddress: '광주시 도척면',
    resortUrl: 'https://konjiamresort.co.kr/',
    webcamUrl: 'https://m.konjiamresort.co.kr/ski/skiLveCam.dev',
    slopeUrl: 'https://www.konjiamresort.co.kr/ski/slopeOpenClose.dev',
    naverUrl: 'https://weather.naver.com/today/02610330?cpName=KMA',
    latitude: 37.3372414,
    longitude: 127.2953076,
    nX: 66,
    nY: 121,
    resortNickname: '곤지암',
    resortLogo: 'assets/imgs/resort/img_resort_logo_1.png'
  ),//곤지암
  ResortModel(
    index:1,
    resortName: '무주덕유산리조트',
    resortAddress: '무주군 설천면',
    resortUrl: 'https://www.mdysresort.com/',
    slopeUrl: 'https://www.mdysresort.com/convert_main_slope_191223.asp',
    webcamUrl: 'https://www.mdysresort.com/guide/webcam.asp',
    naverUrl: 'https://weather.naver.com/today/13730320?cpName=KMA',
    latitude: 35.8902945,
    longitude: 127.7375075,
    nX: 75,
    nY: 93,
    resortNickname: '무주',
      resortLogo: 'assets/imgs/resort/img_resort_logo_2.png'

  ),//무주
  ResortModel(
    index:2,
    resortName: '비발디파크',
    resortAddress: '홍천군 서면',
    resortUrl: 'https://www.sonohotelsresorts.com/daemyung.vp.skiworld.index.ds/dmparse.dm',
    webcamUrl: 'https://www.sonohotelsresorts.com/daemyung.vp.utill.09_02_02_01.ds/dmparse.dm?areaType=S',
    slopeUrl: 'https://www.sonohotelsresorts.com/daemyung.vp.skiworld.04_02_04.ds/dmparse.dm',
    naverUrl: 'https://weather.naver.com/today/01720370?cpName=KMA',
    latitude: 37.6466335,
    longitude: 127.6813286,
    nX: 72,
    nY: 129,
    resortNickname: '비발디',
      resortLogo: 'assets/imgs/resort/img_resort_logo_3.png'

  ),//비발디
  ResortModel(
    index:3,
    resortName: '알펜시아',
    resortAddress: '평창군 대관령면',
    resortUrl: 'https://www.alpensia.com/',
    webcamUrl: 'https://www.alpensia.com/guide/web-cam.do',
    slopeUrl: 'https://www.alpensia.com/ski/slope-plan.do',
    naverUrl: 'https://weather.naver.com/today/01760380?cpName=KMA',
    latitude: 37.6580936,
    longitude: 128.6713607,
    nX: 89,
    nY: 130,
    resortNickname: '알펜시아',
      resortLogo: 'assets/imgs/resort/img_resort_logo_4.png'

  ),//알펜
  ResortModel(
    index:4,
    resortName: '에덴벨리리조트',
    resortAddress: '양산시 원동면',
    resortUrl: 'http://www.edenvalley.co.kr/',
    webcamUrl: 'http://www.edenvalley.co.kr/CS/cam_pop1.asp',
    slopeUrl: '',
    naverUrl: 'https://weather.naver.com/today/03330320?cpName=KMA',
    latitude: 35.4290765,
    longitude: 128.9844681,
    nX: 95,
    nY: 80,
    resortNickname: '에덴벨리',
      resortLogo: 'assets/imgs/resort/img_resort_logo_5.png'

  ),//에덴
  ResortModel(
    index:5,
    resortName: '엘리시안강촌',
    resortAddress: '춘천시 남산면',
    resortUrl: 'https://m.elysian.co.kr/',
    webcamUrl: 'https://www.elysian.co.kr/gangchon/ski/ski_slope03.asp',
    slopeUrl: 'https://www.elysian.co.kr/gangchon/ski/ski_slope.asp',
    naverUrl: 'https://weather.naver.com/today/01110400?cpName=KMA',
    latitude: 37.8163989,
    longitude: 127.587019,
    nX: 71,
    nY: 132,
    resortNickname: '강촌',
      resortLogo: 'assets/imgs/resort/img_resort_logo_6.png'

  ),//엘리시안
  ResortModel(
    index:6,
    resortName: '오크밸리리조트',
    resortAddress: '원주시 지정면',
    resortUrl: 'http://www.oakvalley.co.kr/',
    webcamUrl: 'https://oakvalley.co.kr/ski/skiresort_realtime',
    slopeUrl: 'https://oakvalley.co.kr/ski/ski_slope',
    naverUrl: 'https://weather.naver.com/today/01130330?cpName=KMA',
    latitude: 37.4023124,
    longitude: 127.8122233,
    nX: 75,
    nY: 122,
    resortNickname: '오크밸리',
      resortLogo: 'assets/imgs/resort/img_resort_logo_7.png'

  ),//오크
  ResortModel(
    index:7,
    resortName: '오투리조트',
    resortAddress: '태백시 황지동',
    resortUrl: 'https://www.o2resort.com/',
    webcamUrl: 'https://www.o2resort.com/SKI/liftInfo.jsp',
    slopeUrl: 'https://www.o2resort.com/SKI/slopeOpen.jsp',
    naverUrl: 'https://weather.naver.com/today/01190101?cpName=KMA',
    latitude: 37.1773859,
    longitude: 128.9478083,
    nX: 95,
    nY: 119,
    resortNickname: '오투',
      resortLogo: 'assets/imgs/resort/img_resort_logo_8.png'

  ),//오투
  ResortModel(
    index:8,
    resortName: '용평리조트',
    resortAddress: '평창군 대관령면',
    resortUrl: 'https://www.yongpyong.co.kr/',
    webcamUrl: 'https://www.yongpyong.co.kr/kor/guide/realTimeNews/ypResortWebcam.do',
    slopeUrl: 'https://www.yongpyong.co.kr/kor/skiNboard/slope/openStatusBoard.do',
    naverUrl: 'https://weather.naver.com/today/01760380?cpName=KMA',
    latitude: 37.6450087,
    longitude: 128.6829718,
    nX: 89,
    nY: 130,
    resortNickname: '용평',
      resortLogo: 'assets/imgs/resort/img_resort_logo_9.png'

  ),//용평
  ResortModel(
    index:9,
    resortName: '웰리힐리파크',
    resortAddress: '횡성군 둔내면',
    resortUrl: 'https://www.wellihillipark.com/',
    webcamUrl: 'https://m.wellihillipark.com/customer/webcam',
    slopeUrl: 'https://m.wellihillipark.com/snowpark/schedule/open-slope',
    naverUrl: 'https://weather.naver.com/today/01730330?cpName=KMA',
    latitude: 37.4856398,
    longitude: 128.2474111,
    nX: 81,
    nY: 126,
    resortNickname: '웰리힐리',
      resortLogo: 'assets/imgs/resort/img_resort_logo_10.png'

  ),//웰리힐리
  ResortModel(
    index:10,
    resortName: '지산리조트',
    resortAddress: '이천시 마장면',
    resortUrl: 'https://www.jisanresort.co.kr/',
    webcamUrl: 'https://www.jisanresort.co.kr/w/ski/slopes/webcam.asp',
    slopeUrl: 'https://www.jisanresort.co.kr/w/ski/slopes/info.asp',
    naverUrl: 'https://weather.naver.com/today/02500340?cpName=KMA',
    latitude: 37.2172859,
    longitude: 127.3448223,
    nX: 66,
    nY: 120,
    resortNickname: '지산',
      resortLogo: 'assets/imgs/resort/img_resort_logo_11.png'

  ),//지산
  ResortModel(
    index:11,
    resortName: '하이원리조트',
    resortAddress: '정선군 고한읍',
    resortUrl: 'https://www.high1.com/',
    webcamUrl: 'https://www.high1.com/ski/slopeView.do?key=748&mode=p',
    slopeUrl: 'https://www.high1.com/ski/slopeView.do?key=748&mode=p',
    naverUrl: 'https://weather.naver.com/today/01770253?cpName=KMA',
    latitude: 37.2074566,
    longitude: 128.8253198,
    nX: 92,
    nY: 120,
    resortNickname: '하이원',
      resortLogo: 'assets/imgs/resort/img_resort_logo_12.png'

  ),//하이원
  ResortModel(
      index:12,
      resortName: '휘닉스평창',
      resortAddress: '평창군 봉평면',
      resortUrl: 'https://phoenixhnr.co.kr/',
      webcamUrl: 'https://phoenixhnr.co.kr/page/pyeongchang/guide/operation/sketchMovie',
      slopeUrl: 'https://phoenixhnr.co.kr/static/pyeongchang/snowpark/slope-lift',
      naverUrl: 'https://weather.naver.com/today/01760340?cpName=KMA',
      latitude: 37.613497,
      longitude: 126.838806,
      nX: 84,
      nY: 128,
      resortNickname: '휘닉스',
      resortLogo: 'assets/imgs/resort/img_resort_logo_13.png'

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

List<String?> resortAddressList = [
  resortList[0].resortAddress,
  resortList[1].resortAddress,
  resortList[2].resortAddress,
  resortList[3].resortAddress,
  resortList[4].resortAddress,
  resortList[5].resortAddress,
  resortList[6].resortAddress,
  resortList[7].resortAddress,
  resortList[8].resortAddress,
  resortList[9].resortAddress,
  resortList[10].resortAddress,
  resortList[11].resortAddress,
  resortList[12].resortAddress,
];

List<String?> naverUrlList = [
  resortList[0].naverUrl,
  resortList[1].naverUrl,
  resortList[2].naverUrl,
  resortList[3].naverUrl,
  resortList[4].naverUrl,
  resortList[5].naverUrl,
  resortList[6].naverUrl,
  resortList[7].naverUrl,
  resortList[8].naverUrl,
  resortList[9].naverUrl,
  resortList[10].naverUrl,
  resortList[11].naverUrl,
  resortList[12].naverUrl,
];

List<String?> webcamUrlList = [
  resortList[0].webcamUrl,
  resortList[1].webcamUrl,
  resortList[2].webcamUrl,
  resortList[3].webcamUrl,
  resortList[4].webcamUrl,
  resortList[5].webcamUrl,
  resortList[6].webcamUrl,
  resortList[7].webcamUrl,
  resortList[8].webcamUrl,
  resortList[9].webcamUrl,
  resortList[10].webcamUrl,
  resortList[11].webcamUrl,
  resortList[12].webcamUrl,
];

List<String?> slopeUrlList = [
  resortList[0].slopeUrl,
  resortList[1].slopeUrl,
  resortList[2].slopeUrl,
  resortList[3].slopeUrl,
  resortList[4].slopeUrl,
  resortList[5].slopeUrl,
  resortList[6].slopeUrl,
  resortList[7].slopeUrl,
  resortList[8].slopeUrl,
  resortList[9].slopeUrl,
  resortList[10].slopeUrl,
  resortList[11].slopeUrl,
  resortList[12].slopeUrl,
];

List<dynamic> nxList = [
  resortList[0].nX,
  resortList[1].nX,
  resortList[2].nX,
  resortList[3].nX,
  resortList[4].nX,
  resortList[5].nX,
  resortList[6].nX,
  resortList[7].nX,
  resortList[8].nX,
  resortList[9].nX,
  resortList[10].nX,
  resortList[11].nX,
  resortList[12].nX,
];

List<dynamic> nyList = [
  resortList[0].nY,
  resortList[1].nY,
  resortList[2].nY,
  resortList[3].nY,
  resortList[4].nY,
  resortList[5].nY,
  resortList[6].nY,
  resortList[7].nY,
  resortList[8].nY,
  resortList[9].nY,
  resortList[10].nY,
  resortList[11].nY,
  resortList[12].nY,
];


List<dynamic> nicknameList = [
  resortList[0].resortNickname,
  resortList[1].resortNickname,
  resortList[2].resortNickname,
  resortList[3].resortNickname,
  resortList[4].resortNickname,
  resortList[5].resortNickname,
  resortList[6].resortNickname,
  resortList[7].resortNickname,
  resortList[8].resortNickname,
  resortList[9].resortNickname,
  resortList[10].resortNickname,
  resortList[11].resortNickname,
  resortList[12].resortNickname,
];


List<String?> resortLogoList = [
  resortList[0].resortLogo,
  resortList[1].resortLogo,
  resortList[2].resortLogo,
  resortList[3].resortLogo,
  resortList[4].resortLogo,
  resortList[5].resortLogo,
  resortList[6].resortLogo,
  resortList[7].resortLogo,
  resortList[8].resortLogo,
  resortList[9].resortLogo,
  resortList[10].resortLogo,
  resortList[11].resortLogo,
  resortList[12].resortLogo,
];