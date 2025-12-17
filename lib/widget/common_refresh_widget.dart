import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/base/base_consumer_stateful_widget.dart';
import 'package:flutter_riverpod_template/app/base/base_state.dart';
import 'package:flutter_riverpod_template/app/base/list/list_service.dart';
import 'package:flutter_riverpod_template/widget/status/app_empty_widget.dart';

typedef RefreshChild =
    Widget Function(BuildContext context, List<dynamic> list);

class CommonRefreshWidget extends BaseConsumerStatefulWidget {
  final RefreshChild child;
  final Widget? emptyWidget;
  final bool wantKeepAlive;
  final ListArgs listArgs;
  const CommonRefreshWidget({
    required this.child,
    required this.listArgs,
    this.emptyWidget,
    this.wantKeepAlive = false,
    super.key,
  });

  @override
  ConsumerState<CommonRefreshWidget> createState() =>
      _CommonRefreshWidgetState();
}

class _CommonRefreshWidgetState<T>
    extends BaseConsumerState<CommonRefreshWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    //api/asf/comic/GetComicList/?pageNo=1&pageSize=30&categoryId=716552973116985344&OngoingStatus=0
    final provider = listProvider(widget.listArgs);
    final listAsync = ref.read(provider.notifier);
    final listAsyncState = ref.watch(provider);
    return EasyRefresh(
      triggerAxis: Axis.vertical,

      // clipBehavior: Clip.none,
      header: const ClassicHeader(
        // safeArea: false,
        mainAxisAlignment: MainAxisAlignment.center,
        dragText: '拉动以刷新',
        armedText: '准备就绪',
        readyText: '刷新中...',
        processingText: '刷新中...',
        processedText: '成功',
        noMoreText: '没有更多了',
        failedText: '失败',
        messageText: '最后更新时间 %T',
      ),
      // header: const MaterialHeader(),
      footer: const ClassicFooter(
        infiniteOffset: 70,
        triggerOffset: 70,
        mainAxisAlignment: MainAxisAlignment.center,
        dragText: '拉动以刷新',
        armedText: '准备就绪',
        readyText: '加载中...',
        processingText: '加载中...',
        processedText: '成功',
        noMoreText: '没有更多了',
        failedText: '失败',
        messageText: '最后更新时间 %T',
      ),
      onRefresh: () => listAsync.refresh(),
      onLoad: () => listAsync.loadMore(),
      controller: listAsync.controller,
      child: listAsyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
        data: (data) => data.isEmpty
            ? Center(
                child:
                    widget.emptyWidget ??
                    AppEmptyWidget(onRefresh: listAsync.refresh),
              )
            : widget.child.call(context, data),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}
