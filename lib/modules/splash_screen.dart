import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/base/base_consumer_stateful_widget.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/app/log.dart';
import 'package:flutter_riverpod_template/router/router_path.dart';
import 'package:flutter_riverpod_template/services/user_service.dart';
// import 'package:flutter_riverpod_template/services/user_service.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends BaseConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseConsumerState<SplashScreen> {
  late final ProviderSubscription _sub;
  @override
  void initState() {
    super.initState();
    //
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _sub = ref.listenManual<AsyncValue<UserState>>(userProvider, (
          previous,
          next,
        ) {
          if (next.hasValue) {
            final user = next.value!;
            if (user.loginResult?.token != null) {
              Log.d("User logged in: ${user.loginResult?.token}");
              super.context.go(RoutePath.kIndex);
            } else {
              Log.d("User logged out");
              super.context.go(RoutePath.kUserLogin);
            }
          }
        });
        // if (userServiceState.value?.loginResult == null) {
        //   Log.d("User logged out");
        //   super.context.go(RoutePath.kUserLogin);
        // } else if (userServiceState.value?.loginResult?.token != null) {
        //   Log.d(
        //     "User logged in: ${userServiceState.value?.loginResult?.token}",
        //   );
        //   super.context.go(RoutePath.kIndex);
        // }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sub.close();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/splashbackground.png',
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: LottieBuilder.asset(
              'assets/lotties/splash_v3.json',
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              repeat: true,
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_bg.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'demo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
