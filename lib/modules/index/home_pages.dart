import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/app/base/base_stateful_widget.dart';
import 'package:flutter_riverpod_template/app/base/list/list_service.dart';
import 'package:flutter_riverpod_template/widget/common_refresh_widget.dart';

class HomePages extends BaseStatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends BaseState<HomePages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Home Page'),
            Expanded(
              child: CommonRefreshWidget(
                child: (_, list,scrollController) {
                  return ListView.builder(
                    itemCount: list.length,
                    padding: all(16),
                    controller: scrollController,
                    itemBuilder: (_, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            list[index]["accountName"] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              list[index]["id"] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                listArgs: ListArgs(url: '/api/asf/comic/GetComicList',pageSize: 20,params: {'categoryId': '716552973116985344','OngoingStatus': 0}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
