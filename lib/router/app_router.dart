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

  bool _isSplashFinished = false;

  bool get isSplashFinished => _isSplashFinished;

  // 当 Splash 播完时调用
  void finishSplash() {
    _isSplashFinished = true;
    notifyListeners(); // 关键：通知 GoRouter 重新运行 redirect
  }
}

// 1. 定义一个全局的监听器（单例或全局变量）
// 用于手动或自动通知 GoRouter 重新执行 redirect 逻辑
final routerRefreshNotifier = RouterRefreshNotifier();

class AppRouter {
  AppRouter._();
  static final AppRouter instance = AppRouter._();

  GoRouter? _router;

  // 全局 Key，方便 Dio 或其他地方在没有 context 时跳转
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  GoRouter getRouter(WidgetRef ref) {
    // --- 在路由内部监听用户状态 ---
    ref.listen(userProvider, (previous, next) {
      // 1. 如果之前加载中，现在加载完了，执行刷新
      final wasLoading = previous?.isLoading ?? true;
      final isNowLoading = next.isLoading;

      // 2. 核心对比：比较登录结果是否真的发生了变化
      final oldResult = previous?.value?.loginResult;
      final newResult = next.value?.loginResult;

      // 只有当“加载状态”改变，或者“登录数据”不一致时才通知路由
      if (wasLoading != isNowLoading || oldResult != newResult) {
        routerRefreshNotifier.update();
      }
    });
    // 如果已经初始化，直接返回
    _router ??= GoRouter(
      navigatorKey: navigatorKey,
      refreshListenable: routerRefreshNotifier,
      observers: [FlutterSmartDialog.observer],
      initialLocation: RoutePath.kSplash,
      routes: _routes, // 你的路由列表
      redirect: (context, state) {
        final isSplashFinished = routerRefreshNotifier.isSplashFinished;
        final location = state.matchedLocation;

        // 1. Splash 锁定逻辑
        if (!isSplashFinished) return RoutePath.kSplash;

        // 2. 登录态分流逻辑
        final userAsync = ref.read(userProvider);
        if (userAsync.isLoading) return null;

        final isLoggedIn = userAsync.value?.loginResult != null;

        if (!isLoggedIn) {
          // 未登录且不在登录页 -> 去登录
          return (location != RoutePath.kUserLogin)
              ? RoutePath.kUserLogin
              : null;
        } else {
          // 已登录且在登录/启动页 -> 去首页
          if (location == RoutePath.kUserLogin ||
              location == RoutePath.kSplash) {
            return RoutePath.kIndex;
          }
        }
        return null;
      },
    );

    return _router!;
  }

  List<RouteBase> get _routes {
    return [
      GoRoute(
        name: 'splash',
        path: RoutePath.kSplash,
        pageBuilder: (context, state) {
          return _fadeTransitionPage(context: context, child: SplashScreen());
        },
      ),
      GoRoute(
        name: 'login',
        path: RoutePath.kUserLogin,
        pageBuilder: (context, state) {
          return _fadeTransitionPage(context: context, child: LoginPages());
        },
        // redirect: (context, state) {
        //   var userState = context.read<UserBloc>().state;
        //   if (userState.loginResult?.token != null) {
        //     return RoutePath.kIndex;
        //   }
        //   return null;
        // },
      ),
      GoRoute(
        name: 'index',
        path: RoutePath.kIndex,
        pageBuilder: (context, state) {
          return _fadeTransitionPage(context: context, child: IndexPages());
        },
        // redirect: (context, state) {
        //   var userState = context.read<UserBloc>().state;
        //   if (userState.loginResult?.token == null) {
        //     return RoutePath.kUserLogin;
        //   }
        //   return null;
        // },
      ),
    ];
  }

  // 页面动画
  Page<void> _fadeTransitionPage({
    required BuildContext context,
    required Widget child,
  }) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
