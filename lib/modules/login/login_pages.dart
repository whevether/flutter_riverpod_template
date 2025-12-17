import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/base/base_consumer_stateful_widget.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/router/router_path.dart';
import 'package:go_router/go_router.dart';

class LoginPages extends BaseConsumerStatefulWidget{
  const LoginPages({super.key});
  
  @override
  ConsumerState<LoginPages> createState() => _LoginPageState();
}
//登录页面状态
class _LoginPageState extends BaseConsumerState<LoginPages>{
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(onPressed: (){
          // 触发登录事件
          context.go(RoutePath.kIndex);
        }, child: const Text('登录'),),
      ),
    );
  }
}