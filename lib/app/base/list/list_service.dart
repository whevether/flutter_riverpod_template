import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/app_constant.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_riverpod_template/request/http_client.dart';

//获取列表传参数
class ListArgs {
  final String url; // 必传
  final int pageSize; // 可选，默认值
  final int startPageNum; // 可选，默认值
  final Map<String, dynamic>? params;
  final Map<String, dynamic>? data;
  final String method;

  ListArgs({
    required this.url, // 必传
    this.pageSize = 10,
    this.startPageNum = 1,
    this.params,
    this.data,
    this.method = 'GET',
  });
}

class ListAsyncNotifier<T> extends AsyncNotifier<List<T>> {
  //页码
  late int _page;
  //每页大小
  late int _pageSize;
  //传递query参数 get请求
  late Map<String, dynamic> _params;
  //传递data参数 post请求
  late Map<String, dynamic> _data;
  //请求方式
  late String _method;
  //是否加载更多
  bool _hasMore = true;
  //请求地址
  late String _url;

  ///EasyRefresh控制器
  final EasyRefreshController controller = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  //滚动控制器
  final ScrollController scrollController = ScrollController();

  /// 初始化传递参数
  /// [args] 列表参数
  ListAsyncNotifier(ListArgs args) {
    _url = args.url;
    _pageSize = args.pageSize;
    _page = args.startPageNum;
    _params = args.params ?? {};
    _data = args.data ?? {};
    _method = args.method;
  }

  @override
  Future<List<T>> build() async {
    // 初始加载第一页
    return await fetchList();
  }

  //获取数据
  Future<List<T>> fetchList() async {
    _changeParams();
    Map<String, dynamic>? bean;
    // 请求返回数据
    if (_method == 'GET') {
      bean = await HttpClient.instance.getJson(
        _url,
        queryParameters: _params,
        checkCode: true,
      ) as Map<String, dynamic>?;
    } else if (_method == 'POST') {
      bean = await HttpClient.instance.postJson(
        _url,
        queryParameters: _params,
        data: _data,
        checkCode: true,
      ) as Map<String, dynamic>?;
    }
    // 检查状态码是否正确
    if (bean == null) {
      return <T>[];
    }
    // 如果返回的数据不存在则返回一个空列表
    List<T> list = <T>[];
    var result = bean[AppConstant.resultKey];
    for (var item in result) {
      list.add(item as T);
    }
     // 如果当前页数等于总页数，表示没有更多数据
    if (list == bean[AppConstant.totalCountKey]) {
      return <T>[];
    }
    return list;
  }

  // 修改参数
  void _changeParams() {
    if (_method == 'GET') {
      _params['pageNo'] = _page;
      _params['pageSize'] = _pageSize;
    } else if (_method == 'POST') {
      _data['pageNo'] = _page;
      _data['pageSize'] = _pageSize;
    }
  }

  // 滚动到顶并刷新
  void scrollToTopOrRefresh() {
    if (scrollController.offset > 0) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    } else {
      controller.callRefresh();
    }
  }

  //刷新加载
  Future<void> refresh() async {
    //分页
    _page = 1;
    _hasMore = true;
    state = AsyncValue.loading();
    try {
      final items = await fetchList();
      state = AsyncValue.data(items);
      if (items.isEmpty) {
        // 数据为空 → 刷新结束 + 底部提示无更多
        controller.finishRefresh();
        controller.finishLoad(IndicatorResult.noMore);
      } else {
        // 有数据 → 刷新结束 + 重置底部
        controller.finishRefresh();
        controller.resetFooter();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      controller.finishLoad(IndicatorResult.fail);
    }
  }

  //加载更多
  Future<void> loadMore() async {
    if (!_hasMore) {
      return;
    }
    // state = AsyncValue.loading();
    try {
      _page++;
      final items = await fetchList();
      if (items.isEmpty) {
        _hasMore = false;
        controller.finishLoad(IndicatorResult.noMore);
        return;
      }
      state = AsyncValue.data([...?state.value, ...items]);
      controller.finishLoad(IndicatorResult.success);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      controller.finishLoad(IndicatorResult.fail);
    }
  }
}

final listProvider = AsyncNotifierProvider.autoDispose
    .family<ListAsyncNotifier, List<dynamic>, ListArgs>(ListAsyncNotifier.new);
