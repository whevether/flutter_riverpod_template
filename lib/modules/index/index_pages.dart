// 首页
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/app_color.dart';
import 'package:flutter_riverpod_template/app/base/base_consumer_stateful_widget.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/app/event_bus.dart';
import 'package:flutter_riverpod_template/modules/index/Find_pages.dart';
import 'package:flutter_riverpod_template/modules/index/chat_pages.dart';
import 'package:flutter_riverpod_template/modules/index/home_pages.dart';
import 'package:flutter_riverpod_template/modules/index/my_pages.dart';
import 'package:flutter_riverpod_template/services/app_setting_service.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class IndexPages extends BaseConsumerStatefulWidget {
  const IndexPages({super.key});
  @override
  ConsumerState<IndexPages> createState() => _IndexPagesState();
}

class _IndexPagesState extends BaseConsumerState<IndexPages> {
  final pageList = [HomePages(), FindPages(), ChatPages(), MyPages()];
  // 初始化
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSetting = ref.watch(appSettingProvider);
    final theme = Theme.of(context);
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: pageList[appSetting.value?.tabarIndex ?? 0],
          floatingActionButton: FloatingActionButton(
            elevation: 8,
            backgroundColor: theme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {},
            child: Center(
              child: Icon(Icons.add, color: theme.scaffoldBackgroundColor),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: appSetting.value?.themeMode == ThemeMode.light
                      ? AppColor.backgroundColorDark.withValues(alpha: 0.5)
                      : AppColor.backgroundColor.withValues(alpha: 0.5),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(0, -0.5), // 控制阴影位置（向上偏移）
                ),
              ],
            ),
            child: WaterDropNavBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              waterDropColor: theme.primaryColor,
              inactiveIconColor: theme.primaryColor,
              onItemSelected: (int index) {
                if (index == appSetting.value?.tabarIndex) {
                  EventBus.instance.emit(
                    EventBus.kBottomNavigationBarClicked,
                    index,
                  );
                }
                ref
                    .watch(appSettingProvider.notifier)
                    .onChangeTabarIndex(index);
              },
              selectedIndex: appSetting.value?.tabarIndex ?? 0,
              barItems: <BarItem>[
                BarItem(
                  filledIcon: Icons.bookmark_rounded,
                  outlinedIcon: Icons.bookmark_border_rounded,
                ),
                BarItem(
                  filledIcon: Icons.favorite_rounded,
                  outlinedIcon: Icons.favorite_border_rounded,
                ),
                BarItem(
                  filledIcon: Icons.email_rounded,
                  outlinedIcon: Icons.email_outlined,
                ),
                BarItem(
                  filledIcon: Icons.folder_rounded,
                  outlinedIcon: Icons.folder_outlined,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
