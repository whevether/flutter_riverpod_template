import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/app_constant.dart';
import 'package:flutter_riverpod_template/app/dialog_utils.dart';
import 'package:flutter_riverpod_template/app/log.dart';
import 'package:flutter_riverpod_template/services/local_storage_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:local_auth/local_auth.dart';

/// 状态类
class AppSettingState {
  final ThemeMode? themeMode;
  final Locale? locale;
  final bool? firstRun;
  final bool? localAuth;
  final LocalAuthentication auth;
  final int? tabarIndex;

  AppSettingState({
    this.themeMode,
    this.locale,
    this.firstRun,
    this.localAuth,
    LocalAuthentication? auth,
    this.tabarIndex
  }) : auth = auth ?? LocalAuthentication();

  AppSettingState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? firstRun,
    bool? localAuth,
    LocalAuthentication? auth,
    int? tabarIndex
  }) {
    return AppSettingState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      firstRun: firstRun ?? this.firstRun,
      localAuth: localAuth ?? this.localAuth,
      auth: auth ?? this.auth,
      tabarIndex: tabarIndex ?? this.tabarIndex
    );
  }
}

/// Riverpod Notifier
class AppSettingNotifier extends Notifier<AppSettingState> {
  @override
  AppSettingState build()  {
    return _init();
  }

  AppSettingState _init()  {
    final themeMode = ThemeMode.values[
      LocalStorageService.instance.getValue(LocalStorageService.kThemeMode, 1)
    ];
    final locale = AppConstant.mapLocale[
      LocalStorageService.instance.getValue(LocalStorageService.kLanguage, 2)
    ]!;
    final firstRun = LocalStorageService.instance.getValue(
      LocalStorageService.kFirstRun,
      true,
    );
    final localAuth = LocalStorageService.instance.getValue(
      LocalStorageService.kLocalAuth,
      false,
    );

    return  AppSettingState(
      themeMode: themeMode,
      locale: locale,
      firstRun: firstRun,
      localAuth: localAuth,
      tabarIndex: 0
    );
  }

  /// 设置主题
  Future<void> setTheme(ThemeMode themeMode) async {
    final current = state;
    if (current.themeMode == themeMode) return;
    await LocalStorageService.instance.setValue(
      LocalStorageService.kThemeMode,
      themeMode.index,
    );
    state = current.copyWith(themeMode: themeMode);
  }

  /// 设置语言
  Future<void> setLocale(int locale) async {
    final current = state;
    if (current.locale == AppConstant.mapLocale[locale]) return;
    await LocalStorageService.instance.setValue(
      LocalStorageService.kLanguage,
      locale,
    );
    state = current.copyWith(locale: AppConstant.mapLocale[locale]);
  }

  /// 普通验证
  Future<bool> _authenticate() async {
    try {
      return await state.auth.authenticate(
        localizedReason: '请验证以支付',
      );
    } on LocalAuthException catch (e) {
      Log.d('认证失败: ${e.code}');
      return false;
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      return await state.auth.authenticate(
        localizedReason: '请验证以支付',
      );
    } on LocalAuthException catch (e) {
      Log.d('认证失败: ${e.code}');
      return false;
    }
  }

  Future<bool> _authenticateWithoutDialogs() async {
    try {
      return await state.auth.authenticate(
        localizedReason: '请验证以支付',
      );
    } on LocalAuthException catch (e) {
      Log.d('认证失败: ${e.code}');
      return false;
    }
  }

  Future<bool> _authenticateWithErrorHandling() async {
    try {
      return await state.auth.authenticate(
        localizedReason: '请验证以支付',
      );
    } on LocalAuthException catch (e) {
      Log.d('认证失败: ${e.code}');
      return false;
    }
  }

  Future<bool> _checkSupport() async {
    final auth = state.auth;
    final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> _onOpenLocalAuth() async {
    final isSupport = await _checkSupport();
    if (isSupport) {
      final isSuccess = await _authenticate();
      if (!isSuccess) {
        SmartDialog.showToast('认证失败');
        return false;
      }
      return true;
    } else {
      SmartDialog.showToast('不支持的设备');
      return false;
    }
  }

  /// 开启/关闭生物验证
  Future<void> onOpenFaceId(bool e, {int? authType = 0}) async {
    final current = state;
    if (current.localAuth == e) return;

    final mapAuth = {
      0: _onOpenLocalAuth(),
      1: _authenticateWithBiometrics(),
      2: _authenticateWithoutDialogs(),
      3: _authenticateWithErrorHandling(),
    };

    if (e) {
      final result = await DialogUtils.showAlertDialog(
        '为了你的账号安全，我们需要进行生物特征安全设置',
        title: '安全设置',
      );
      if (!result) return;
      final isSuccess = await mapAuth[authType]!;
      if (!isSuccess) return;
    } else {
      final isSuccess = await mapAuth[authType]!;
      if (!isSuccess) return;
    }

    await LocalStorageService.instance.setValue(
      LocalStorageService.kLocalAuth,
      e,
    );
    state = current.copyWith(localAuth: e);
  }

  /// 首次运行
  Future<void> showFirstRun() async {
    final current = state;
    if (current.firstRun == true) {
      await LocalStorageService.instance.setValue<bool>(
        LocalStorageService.kFirstRun,
        false,
      );
      state = current.copyWith(firstRun: false);
      DialogUtils.checkUpdate();
    } else {
      await LocalStorageService.instance.setValue<bool>(
        LocalStorageService.kFirstRun,
        true,
      );
      state = current.copyWith(firstRun: true);
      DialogUtils.checkUpdate();
    }
  }
  //修改导航索引
  void onChangeTabarIndex(int? i){
    final current = state;
    state = current.copyWith(tabarIndex: i);
  }
}

/// Provider
final appSettingProvider =
    NotifierProvider<AppSettingNotifier, AppSettingState>(
  AppSettingNotifier.new,
);
