import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 模拟后端接口
Future<List<String>> fetchData(int page, int pageSize) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return List.generate(
    pageSize,
    (i) => 'Item ${(page - 1) * pageSize + i + 1}',
  );
}

// 分页 State
class PagingState {
  final int page;
  final int pageSize;
  final bool isLoading;
  final bool hasMore;
  final List<String> items;

  PagingState({
    this.page = 1,
    this.pageSize = 10,
    this.isLoading = false,
    this.hasMore = true,
    this.items = const [],
  });

  PagingState copyWith({
    int? page,
    int? pageSize,
    bool? isLoading,
    bool? hasMore,
    List<String>? items,
  }) {
    return PagingState(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      items: items ?? this.items,
    );
  }
}

// Riverpod Notifier
class PagingNotifier extends Notifier<PagingState> {
  @override
  PagingState build() => PagingState();

  // 下一页（翻页模式）
  Future<void> nextPage() async {
    final newPage = state.page + 1;
    state = state.copyWith(isLoading: true);
    final data = await fetchData(newPage, state.pageSize);
    state = state.copyWith(
      page: newPage,
      items: data,
      hasMore: data.length == state.pageSize,
      isLoading: false,
    );
  }

  // 加载更多（追加模式）
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final newPage = state.page + 1;
    state = state.copyWith(isLoading: true);
    final data = await fetchData(newPage, state.pageSize);
    state = state.copyWith(
      page: newPage,
      items: [...state.items, ...data],
      hasMore: data.length == state.pageSize,
      isLoading: false,
    );
  }

  // 初始加载
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, page: 1);
    final data = await fetchData(1, state.pageSize);
    state = state.copyWith(
      items: data,
      hasMore: data.length == state.pageSize,
      isLoading: false,
    );
  }
}

final pagingProvider =
    NotifierProvider<PagingNotifier, PagingState>(() => PagingNotifier());

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(pagingProvider.notifier).loadInitial());
  }

  @override
  Widget build(BuildContext context) {
    final paging = ref.watch(pagingProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Riverpod 分页示例')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: paging.items.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(paging.items[index])),
              ),
            ),
            if (paging.isLoading) const LinearProgressIndicator(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed:
                      paging.isLoading ? null : () => ref.read(pagingProvider.notifier).nextPage(),
                  child: const Text('下一页（替换）'),
                ),
                ElevatedButton(
                  onPressed:
                      paging.isLoading || !paging.hasMore
                          ? null
                          : () => ref.read(pagingProvider.notifier).loadMore(),
                  child: Text(
                      paging.hasMore ? '加载更多（追加）' : '没有更多了'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
