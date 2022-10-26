class BrandModel{
  BrandModel({this.brandName,this.url, this.imageAsset, this.imageUrl});

  String? url;
  String? imageUrl;
  String? imageAsset;
  String? brandName;
}

List<BrandModel> clothBrandList = [
  BrandModel(
      brandName: 'USS2',
      url: 'http://www.uss2official.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/uss2.png',
      imageUrl: 'http://www.uss2official.co.kr/design/gemini44/pcmain_01.jpg'), //1
  BrandModel(
      brandName: 'GAFH',
      url: 'http://gafh.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/gafh.png',
      imageUrl: 'http://gafh.co.kr/lookbook/2223/look53.jpg'), //2
  BrandModel(
      brandName: 'OVYO',
      url: 'http://ovyo.net/',
      imageAsset: 'assets/imgs/logos/brand/ovyo.png',
      imageUrl: 'http://ovyo.net/web/product/big/202208/744ee4933795d94d7230be9e55bb31a9.jpg'), //3
  BrandModel(
      brandName: 'BSRABBIT',
      url: 'http://bsrabbit.com/',
      imageAsset: 'assets/imgs/logos/brand/bsrabbit.png',
      imageUrl: 'https://bsrabbit.co.kr/web/product/medium/202206/7a23fc18'
          'fb4153256763846db5d7dfb9.jpg'), //4
  BrandModel(
      brandName: 'QMILE',
      url: 'https://qmileseoul.com/',
      imageAsset: 'assets/imgs/logos/brand/qmile.png',
      imageUrl: 'https://qmileseoul.com/works/lookbook/2122/001.jpg'), //5
  BrandModel(
      brandName: 'HELLOW',
      url: 'https://helloweveryone.com/',
      imageAsset: 'assets/imgs/logos/brand/hellow.png',
      imageUrl: 'https://helloweveryone.com/web/upload/NNEditor/20210922'
          '/2122-hellow%20Lookbook(%E1%84%8B%E1%85%B0%E1%86%B8%20%E1%84%8B%E'
          '1%85%A5%E1%86%B8%E1%84%85%E1%85%A9%E1%84%83%E1%85%B3%E1%84%8B%E1'
          '%85%AD%E1%86%BC)_42_shop1_150904.jpg'), //6
  BrandModel(
      brandName: 'HOLIDAY',
      url: 'http://m.holidayouterwear.com/',
      imageAsset: 'assets/imgs/logos/brand/holiday.png',
      imageUrl: 'http://holidayouterwear.com/web/upload/NNEditor/20211'
          '028/3_shop1_124030.jpg'), //7
  BrandModel(
      brandName: 'KARETA',
      url: 'http://kareta.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/kareta.png',
      imageUrl: 'http://kareta.co.kr/web/product/big/202110/78a0cab7e5cee'
          'f703d70f85b594182a1.jpg'), //8
  BrandModel(
      brandName: 'UNBIND',
      url: 'http://unbind.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/unbind.png',
      imageUrl: 'http://unbind.co.kr/web/upload/NNEditor/20211006/1-_DSC0'
          '070-Edit_shop1_144643.jpg'), //9
  BrandModel(
      brandName: 'DIMITO',
      url: 'http://dimito.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/dimito.png',
      imageUrl: 'https://vert01.hgodo.com//img/look/thum/21ebfd.jpg'), //10
  BrandModel(
      brandName: 'BLENT',
      url: 'http://blent.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/blent.png',
      imageUrl: 'http://blent.co.kr/main/main01.jpg'), //11
  BrandModel(
      brandName: 'ROMP',
      url: 'https://romp.com/',
      imageAsset: 'assets/imgs/logos/brand/romp.png',
      imageUrl: 'https://romp.com/web/upload/131/image/company-1.jpg'), //12
  BrandModel(
      brandName: 'YOBEAT',
      url: 'https://yobeat.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/yobeat.png',
      imageUrl: 'https://yobeat.co.kr/web/product/big/202110/c209afa0f5130de2'
          'a7708f4ce0163814.jpg'), //13
  BrandModel(
      brandName: 'NNN',
      url: 'http://nnnthree.com/',
      imageAsset: 'assets/imgs/logos/brand/nnn.png',
      imageUrl: 'http://app-storage-edge-003.cafe24.com/bannermanage2/nthree/'
          '2022/01/13/4b83434134559702a38e599b1fe508a0.jpg'), //14
  BrandModel(
      brandName: 'ELNATH',
      url: 'https://elnath.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/elnathsnow.png',
      imageUrl: 'https://elnath.co.kr/web/product/medium/202109/11de8ee7fb401b6'
          'c9225b146c7eaeb45.jpg'), //15
  BrandModel(
      brandName: 'SPECIALGUEST',
      url: 'http://specialguest.co.kr/',
      imageAsset: 'assets/imgs/logos/brand/specialguest.png',
      imageUrl: 'http://www.specialguest.co.kr/web/upload/new/b2.jpg'), //16
];

List<String?> clothBrandNameList = [
  clothBrandList[0].brandName,
  clothBrandList[1].brandName,
  clothBrandList[2].brandName,
  clothBrandList[3].brandName,
  clothBrandList[4].brandName,
  clothBrandList[5].brandName,
  clothBrandList[6].brandName,
  clothBrandList[7].brandName,
  clothBrandList[8].brandName,
  clothBrandList[9].brandName,
  clothBrandList[10].brandName,
  clothBrandList[11].brandName,
  clothBrandList[12].brandName,
  clothBrandList[13].brandName,
  clothBrandList[14].brandName,
  clothBrandList[15].brandName,
];

List<String?> clothBrandImageAssetList = [
  clothBrandList[0].imageAsset,
  clothBrandList[1].imageAsset,
  clothBrandList[2].imageAsset,
  clothBrandList[3].imageAsset,
  clothBrandList[4].imageAsset,
  clothBrandList[5].imageAsset,
  clothBrandList[6].imageAsset,
  clothBrandList[7].imageAsset,
  clothBrandList[8].imageAsset,
  clothBrandList[9].imageAsset,
  clothBrandList[10].imageAsset,
  clothBrandList[11].imageAsset,
  clothBrandList[12].imageAsset,
  clothBrandList[13].imageAsset,
  clothBrandList[14].imageAsset,
  clothBrandList[15].imageAsset,
];


List<String?> clothBrandImageUrlList = [
  clothBrandList[0].imageUrl,
  clothBrandList[1].imageUrl,
  clothBrandList[2].imageUrl,
  clothBrandList[3].imageUrl,
  clothBrandList[4].imageUrl,
  clothBrandList[5].imageUrl,
  clothBrandList[6].imageUrl,
  clothBrandList[7].imageUrl,
  clothBrandList[8].imageUrl,
  clothBrandList[9].imageUrl,
  clothBrandList[10].imageUrl,
  clothBrandList[11].imageUrl,
  clothBrandList[12].imageUrl,
  clothBrandList[13].imageUrl,
  clothBrandList[14].imageUrl,
  clothBrandList[15].imageUrl,
];

List<String?> clothBrandHomeUrlList = [
  clothBrandList[0].url,
  clothBrandList[1].url,
  clothBrandList[2].url,
  clothBrandList[3].url,
  clothBrandList[4].url,
  clothBrandList[5].url,
  clothBrandList[6].url,
  clothBrandList[7].url,
  clothBrandList[8].url,
  clothBrandList[9].url,
  clothBrandList[10].url,
  clothBrandList[11].url,
  clothBrandList[12].url,
  clothBrandList[13].url,
  clothBrandList[14].url,
  clothBrandList[15].url,
];
