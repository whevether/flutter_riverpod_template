import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/modules/index/index_pages.dart';
import 'package:flutter_riverpod_template/modules/login/login_pages.dart';
import 'package:flutter_riverpod_template/modules/splash_screen.dart';
import 'package:flutter_riverpod_template/router/router_path.dart';
import 'package:flutter_riverpod_template/services/user_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

// 这里的 update() 方法允许外部触发通知
class RouterRefreshNotifier extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
// 1. 定义一个全局的监听器（单例或全局变量）
// 用于手动或自动通知 GoRouter 重新执行 redirect 逻辑
final routerRefreshNotifier = RouterRefreshNotifier();

class AppRouter {
  static final instance = AppRouter._();
  AppRouter._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  // 关键：定义一个变量来持有 router
  GoRouter? _router;

  // 提供一个获取方法，如果未初始化则报错或通过 WidgetRef 初始化
  GoRouter getRouter(WidgetRef ref) {
    _router ??= GoRouter(
      initialLocation: RoutePath.kSplash,
      navigatorKey: navigatorKey,
      observers: [FlutterSmartDialog.observer],
      // 核心：将 context 中的 userBloc 转换为 Listenable
      refreshListenable: routerRefreshNotifier,

      redirect: (context, state) {
        // 通过 context 获取 Riverpod 容器中的 userProvider 状态
        final userAsync = ProviderScope.containerOf(context).read(userProvider);

        if (userAsync.isLoading) return null;

        final user = userAsync.value;
        final bool isLoggedIn = user?.loginResult != null;
        final String location = state.matchedLocation;

        // 逻辑：如果未登录且不在登录页 -> 去登录
        if (!isLoggedIn) {
          if (location != RoutePath.kUserLogin ||
              location != RoutePath.kSplash) {
            return RoutePath.kUserLogin;
          }
        }

        // 逻辑：如果已登录且在登录页/启动页 -> 去首页
        if (isLoggedIn) {
          if (location == RoutePath.kUserLogin ||
              location == RoutePath.kSplash) {
            return RoutePath.kIndex;
          }
        }

        return null;
      },
      routes: _routes,
    );

    return _router!;
  }

  // ... 保持 _routes 和 _fadeTransitionPage 不变 ...
  List<RouteBase> get _routes => [
        GoRoute(
          name: 'splash',
          path: RoutePath.kSplash,
          pageBuilder: (context, state) => _fadeTransitionPage(
              context: context, child: const SplashScreen()),
        ),
        GoRoute(
          name: 'login',
          path: RoutePath.kUserLogin,
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context: context, child: LoginPages()),
        ),
        GoRoute(
          name: 'index',
          path: RoutePath.kIndex,
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context: context, child: IndexPages()),
        ),
      ];

  Page<void> _fadeTransitionPage(
      {required BuildContext context, required Widget child}) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
