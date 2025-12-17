import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadState {
  final Exception? exception;
  final bool? loading;
  LoadState({this.loading,this.exception});
  //加载状态
  LoadState copyWith({Exception? exception,bool? loading}){
    return LoadState(
      loading: loading ?? this.loading,
      exception: exception ?? this.exception
    );
  }
}
// 使用 Notifier 管理状态
class LoadSyncNotifier extends Notifier<LoadState> {
  @override
  LoadState build() {
    return LoadState(loading: false,exception: null);
  }

  void loading() {
    state =  state.copyWith(loading: true);
  }

  void loadDone() {
     state =  state.copyWith(loading: false);
  }

  void loadError(Exception exception) {
    state =  state.copyWith(loading: false,exception: exception);
  }
}
/// 同步 loading Provider 定义
final loadSyncProvider =
    NotifierProvider<LoadSyncNotifier, void>(LoadSyncNotifier.new);


///
/// loading mixin
///

mixin LoadingMixinState {
  ///获取[BuildContext]
  BuildContext get buildContext;
}