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

  //登录,登录之后获取用户信息,保证用户信息每次登录都是新的，而不是存在缓存中的
  Future<void> login(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      var result = await request.login(data);
      if (result == null) {
        state = AsyncValue.error("登录失败", StackTrace.fromString("登录数据是空的"));
        return;
      }
      LocalStorageService.instance.setValue(
        LocalStorageService.kToken,
        result.toString(),
      );
      var userResult = await request.getUserInfo();
      if (userResult == null) {
        state = AsyncValue.error("获取信息失败", StackTrace.fromString("获取用户信息失败"));
        return;
      }
      final currentState = state.value;
      if(currentState != null){
        state = AsyncValue.data(currentState.copyWith(loginResult: result,user: userResult,));
      }else{
        state = AsyncData(UserState(loginResult: result,user: userResult));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return;
    }
  }
  //单独获取用户信息,使用场景当修改了用户信息之后在获取新的用户信息
  Future<void> getUserInfo()async{
     state = const AsyncValue.loading();
    try{
      final currentState = state.value;
      if(currentState?.loginResult == null){
        state = AsyncValue.error("获取信息失败", StackTrace.fromString("登录状态是空的"));
        return;
      }
      var userResult = await request.getUserInfo();
      if (userResult == null) {
        state = AsyncValue.error("获取信息失败", StackTrace.fromString("获取用户信息失败"));
        return;
      }
      state = AsyncValue.data(currentState!.copyWith(user: userResult));
    }catch(e,st){
      state = AsyncValue.error(e, st);
      return;
    }
  }
}

/// Provider
final userProvider = AsyncNotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);
