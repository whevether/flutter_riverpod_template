import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/base/base_consumer_stateful_widget.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/services/user_service.dart';

class LoginPages extends BaseConsumerStatefulWidget {
  const LoginPages({super.key});

  @override
  ConsumerState<LoginPages> createState() => _LoginPageState();
}

//登录页面状态
class _LoginPageState extends BaseConsumerState<LoginPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: ListView(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(userProvider.notifier).login({
                  'loginType': 'account',
                  'username': 'test',
                  'password': 'test',
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
