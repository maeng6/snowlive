class ShopModel{
  ShopModel({this.shopName,this.url,this.imageAsset});

  String? shopName;
  String? url;
  String? imageAsset;
}

List<ShopModel> shopList = [
  ShopModel(
    shopName: '원에잇',
    url: 'https://one8.co.kr/',
      imageAsset: 'assets/imgs/logos/shop/one8_logo.png'
  ),
  ShopModel(
      shopName: '911sports',
      url: 'http://www.911sports.co.kr/',
      imageAsset: 'assets/imgs/logos/shop/911sports_logo.png'
  ),
  ShopModel(
      shopName: '팝스노우',
      url: 'http://www.popsnowboard.co.kr/',
      imageAsset: 'assets/imgs/logos/shop/popsnow_logo.png'
  ),
  ShopModel(
      shopName: '베스트스노우',
      url: 'http://www.bestsnowboard.co.kr/',
      imageAsset: 'assets/imgs/logos/shop/bestsnow_logo.png'
  ),
  ShopModel(
      shopName: '풍류',
      url: 'http://www.poong-ryu.com/',
      imageAsset: 'assets/imgs/logos/shop/pungryu_logo.png'
  ),
  ShopModel(
      shopName: '보드코리아',
      url: 'https://m.boardkorea.com/',
      imageAsset: 'assets/imgs/logos/shop/boardkorea_logo.png'
  ),
  ShopModel(
      shopName: '자이온',
      url: 'http://www.zionsnowboard.com/',
      imageAsset: 'assets/imgs/logos/shop/zion_logo.png'
  ),
  ShopModel(
      shopName: '보드라인',
      url: 'http://www.boardline.co.kr/',
      imageAsset: 'assets/imgs/logos/shop/boardline_logo.png'
  ),
  ShopModel(
      shopName: '강남스포츠',
      url: 'http://www.gangnamsports.co.kr/',
      imageAsset: 'assets/imgs/logos/shop/gangnam_logo.png'
  ),

];

List<String?> shopNameList = [
  shopList[0].shopName,
  shopList[1].shopName,
  shopList[2].shopName,
  shopList[3].shopName,
  shopList[4].shopName,
  shopList[5].shopName,
  shopList[6].shopName,
  shopList[7].shopName,
  shopList[8].shopName,
];


List<String?> shopHomeUrlList = [
  shopList[0].url,
  shopList[1].url,
  shopList[2].url,
  shopList[3].url,
  shopList[4].url,
  shopList[5].url,
  shopList[6].url,
  shopList[7].url,
  shopList[8].url,
];
List<String?> shopImageAssetList = [
  shopList[0].imageAsset,
  shopList[1].imageAsset,
  shopList[2].imageAsset,
  shopList[3].imageAsset,
  shopList[4].imageAsset,
  shopList[5].imageAsset,
  shopList[6].imageAsset,
  shopList[7].imageAsset,
  shopList[8].imageAsset,
];


