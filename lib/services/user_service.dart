import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/model/login_result_model.dart';
import 'package:flutter_riverpod_template/model/user_model.dart';
import 'package:flutter_riverpod_template/request/common_request.dart';
import 'package:flutter_riverpod_template/services/local_storage_service.dart';

class UserState {
  final UserModel? user;
  final LoginResultModel? loginResult;
  UserState({this.user, this.loginResult});
  UserState copyWith({UserModel? user, LoginResultModel? loginResult}) {
    return UserState(
      user: user ?? this.user,
      loginResult: loginResult ?? this.loginResult,
    );
  }
}

class UserNotifier extends AsyncNotifier<UserState> {
  final CommonRequest request = CommonRequest();
  //初始化服务
  @override
  Future<UserState> build() async {
    return _init();
  }
  // 初始化登录与用户信息状态
  Future<UserState> _init() async {
    //从缓存获取登录结果
    var loginResult = LocalStorageService.instance.getValue(
      LocalStorageService.kToken,
      '',
    );
    if (loginResult.isNotEmpty) {
      var result = await request.getUserInfo();
      if (result == null) {
        return UserState(
          user: null,
          loginResult: LoginResultModel.fromJson(json.decode(loginResult)),
        );
      }
      return UserState(
        user: result,
        loginResult: LoginResultModel.fromJson(json.decode(loginResult)),
      );
    }
    return UserState(user: null, loginResult: null);
  }
}
/// Provider
final userProvider =
    AsyncNotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);
