// try {
// FirebaseAnalytics.instance.logEvent(
// name: 'visit_resortHome',
// parameters: <String, Object>{
// 'user_id': _userModelController.uid!,
// 'user_name': _userModelController.displayName!,
// 'user_resort': _userModelController.favoriteResort!,
// },
// );
// } catch (e, stackTrace) {
// print('GA 업데이트 오류: $e');
// print('Stack trace: $stackTrace');
// }

// try{
// await FirebaseAnalytics.instance.logEvent(
// name: 'live_on_button_pressed_Success',
// parameters: <String, Object>{
// 'user_id': _userModelController.uid!,
// 'user_name': _userModelController.displayName!,
// 'user_resort': _userModelController.favoriteResort!
// },
// );
// }catch(e, stackTrace){
// print('GA 업데이트 오류: $e');
// print('Stack trace: $stackTrace');
// }



// onTap: () async{
// try {
// if(_friendDetailViewModel.profileImageUrl != '')
// await _friendDetailViewModel.getImageUrl();
// await _friendDetailViewModel.updateMyInfo(
// {
// "user_id": _userViewModel.user.user_id,    //필수 - 수정할 유저id
// "display_name": _friendDetailViewModel.displayNameController.text,    //선택
// "state_msg": _friendDetailViewModel.stateMsgController.text,    //선택
// "profile_image_url_user":
// (_friendDetailViewModel.profileImageUrl != '')
// ? _friendDetailViewModel.profileImageUrl
//     : _friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser,  //선택
// }
// );
// } catch (e) {
// }
// _friendDetailViewModel.toggleIsEditing();
// print('프로필 변경완료');
// },


// try {
// FirebaseAnalytics.instance.logEvent(
// name: 'visit_fleaMarket',
// parameters: <String, Object>{
// 'user_id': _userModelController.uid!,
// 'user_name': _userModelController.displayName!,
// 'user_resort': _userModelController.favoriteResort!
// },
// );
// } catch (e, stackTrace) {
// print('GA 업데이트 오류: $e');
// print('Stack trace: $stackTrace');
// }


// try{
// FirebaseAnalytics.instance.logEvent(
// name: 'visit_bulletinFree',
// parameters: <String, Object>{
// 'user_id': _userModelController.uid!,
// 'user_name': _userModelController.displayName!,
// 'user_resort': _userModelController.favoriteResort!
// },
// );
// }catch(e, stackTrace){
// print('GA 업데이트 오류: $e');
// print('Stack trace: $stackTrace');
// }


// try {
// FirebaseAnalytics.instance.logEvent(
// name: 'visit_moreTab',
// parameters: <String, Object>{
// 'user_id': _userModelController.uid!,
// 'user_name': _userModelController.displayName!,
// 'user_resort': _userModelController.favoriteResort!
// },
// );
// } catch (e, stackTrace) {
// print('GA 업데이트 오류: $e');
// print('Stack trace: $stackTrace');
// }