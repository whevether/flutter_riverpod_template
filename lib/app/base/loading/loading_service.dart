// 状态定义
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class LoadState {
  const LoadState();
}
//初始化状态
class InitialState extends LoadState {
  const InitialState();
}
//加载状态
class LoadingState extends LoadState {
  const LoadingState();
}
//加载错误状态
class ErrorState extends LoadState {
  final Exception exception;
  const ErrorState(this.exception);
}

/// 使用 AsyncNotifier 管理加载状态, 页面loading
class LoadAsyncNotifier extends AsyncNotifier<void> {
  bool _loading = false;

  @override
  FutureOr<void> build() {
    // 初始状态为空闲
    _loading = false;
    return null;
  }

  void loading() {
    _loading = true;
    state = const AsyncValue.loading();
  }

  void loadDone() {
    _loading = false;
    state = const AsyncValue.data(null);
  }

  void loadError(Exception exception) {
    _loading = false;
    state = AsyncValue.error(exception, StackTrace.current);
  }

  bool get isLoading => _loading;
}

/// 异步loading Provider 定义
final loadAsyncProvider =
    AsyncNotifierProvider<LoadAsyncNotifier, void>(LoadAsyncNotifier.new);

// 使用 Notifier 管理状态
class LoadSyncNotifier extends Notifier<LoadState> {
  bool _loading = false;

  @override
  LoadState build() {
    _loading = false;
    return const InitialState();
  }

  void loading() {
    _loading = true;
    state = const LoadingState();
  }

  void loadDone() {
    _loading = false;
    state = const InitialState();
  }

  void loadError(Exception exception) {
    _loading = false;
    state = ErrorState(exception);
  }

  bool get isLoading => _loading;
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