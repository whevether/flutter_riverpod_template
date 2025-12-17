import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/base/base_consumer_stateful_widget.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/router/router_path.dart';
import 'package:flutter_riverpod_template/services/user_service.dart';
import 'package:go_router/go_router.dart';

class LoginPages extends BaseConsumerStatefulWidget {
  const LoginPages({super.key});

  @override
  ConsumerState<LoginPages> createState() => _LoginPageState();
}

//登录页面状态
class _LoginPageState extends BaseConsumerState<LoginPages> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    //监听登录状态改变来处理跳转到首页
    ref.listen<AsyncValue<UserState>>(userProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user.loginResult != null) {
            context.go(RoutePath.kIndex);
          }
        },
      );
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: ListView(
        children: [
          userAsync.when(
            data: (_) => const SizedBox.shrink(), // UI 不负责跳转
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('错误: $err'),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(userProvider.notifier).login({
                  'loginType': 'account',
                  'username': 'admin',
                  'password': 'admin',
                  'tenancyId': '1',
                });
              },
              child: const Text('登录'),
            ),
          ),
        ],
      ),
    );
  }
}
