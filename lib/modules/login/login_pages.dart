import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/app/base/base_stateful_widget.dart';

class LoginPages extends BaseStatefulWidget{
  const LoginPages({super.key});
  
  @override
  State<LoginPages> createState() => _LoginPageState();
}
//登录页面状态
class _LoginPageState extends BaseState<LoginPages>{
  @override
  Widget build(BuildContext context) {
    return Text('adsada');
  }
}