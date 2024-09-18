// import 'package:com.snowlive/controller/public/vm_limitController.dart';
// import 'package:com.snowlive/screens/Ranking/v_Ranking_Crew_Screen.dart';
// import 'package:com.snowlive/screens/Ranking/v_Ranking_Indi_Screen.dart';
// import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
// import 'package:com.snowlive/view/ranking/v_rankingList_Crew.dart';
// import 'package:com.snowlive/view/ranking/v_rankingList_Indi.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../../../controller/user/vm_userModelController.dart';
// import '../../../widget/w_floatingButton_ranking.dart';
// import '../../viewmodel/vm_rankingList.dart';
// import '../../viewmodel/vm_user.dart';
//
// class RankingHomeView extends StatefulWidget {
//   RankingHomeView({Key? key}) : super(key: key);
//
//   @override
//   State<RankingHomeView> createState() => _RankingHomeViewState();
// }
//
// class _RankingHomeViewState extends State<RankingHomeView> {
//   //TODO: Dependency Injection**************************************************
//   UserModelController _userModelController = Get.find<UserModelController>();
//   limitController _seasonController = Get.find<limitController>();
//   //TODO: Dependency Injection**************************************************
//
//   final UserViewModel _userViewModel = Get.find<UserViewModel>();
//   final RankingListViewModel _rankingListViewModel = Get.find<RankingListViewModel>();
//
//   int counter = 0;
//   List<bool> isTap = [
//     true,
//     false,
//   ];
//
//   List<bool> isTapPeriod = [
//     true,
//     false,
//     false,
//   ];
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent, // 상태바 투명하게
//       statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 밝기
//     ));
//
//     Size _size = MediaQuery.of(context).size;
//
//     return Scaffold(
//         backgroundColor: Colors.white,
//         extendBodyBehindAppBar: true,
//         body: SafeArea(
//           child: Column(
//             children: [
//               Container(
//                 height: 44,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(left: 16, right: 12),
//                           child: ElevatedButton(
//                             child: Text(
//                               '개인랭킹',
//                               style: SDSTextStyle.extraBold.copyWith(
//                                   color: (_rankingListViewModel.tapName=='개인랭킹')
//                                       ? Color(0xFF111111)
//                                       : Color(0xFFDEDEDE),
//                                   fontSize: 18),
//                             ),
//                             onPressed: () async {
//                               _rankingListViewModel.changeTap('개인랭킹');
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.only(top: 0),
//                               minimumSize: Size(40, 10),
//                               backgroundColor: Color(0xFFFFFFFF),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                               elevation: 0,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(right: 12),
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               _rankingListViewModel.changeTap('크루랭킹');
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.only(top: 0),
//                               minimumSize: Size(40, 10),
//                               backgroundColor: Color(0xFFFFFFFF),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                               elevation: 0,
//                             ),
//                             child: Container(
//                               child: Text(
//                                 '크루랭킹',
//                                 style: SDSTextStyle.extraBold.copyWith(
//                                     color: (_rankingListViewModel.tapName=='크루랭킹')
//                                         ? Color(0xFF111111)
//                                         : Color(0xFFC8C8C8),
//                                     fontSize: 18),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (_rankingListViewModel.tapName=='개인랭킹')
//                 Expanded(
//                     child: RankingIndiView()),
//               if (_rankingListViewModel.tapName=='크루랭킹')
//                 Expanded(
//                   child: RankingCrewView()),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingButtonWithOptions(
//           selectedOption: _rankingListViewModel.dayOrTotal,
//           onOptionSelected: (String value) {
//             _rankingListViewModel.changeDayOrTotal(value);
//           },
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked);
//   }
// }
//
//
