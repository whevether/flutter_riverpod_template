# Copilot / AI 代码助手说明（项目专用）

目的：快速让 AI 编码助手理解本仓库的架构、关键约定和常见改动点，使其在提交补丁或生成代码时更可靠。

要点（高优先级，务必遵守）
- **项目类型**：Flutter 应用，使用 `flutter` 工具链；在 macOS 上可用 Xcode 打包 iOS。先运行 `flutter pub get`。
- **状态管理**：基于 `flutter_riverpod`（Provider/Notifier/AsyncNotifier）；查阅 `lib/` 下的 `modules/` 与 `services/` 示例（例如 `lib/services/user_service.dart`）。
- **路由**：集中化路由封装在 `lib/router/app_router.dart`，使用 `go_router` 风格；所有新页面应在路由单例中注册。
- **网络层**：在 `lib/request/` 下封装，核心文件 `lib/request/http_client.dart` 与 `lib/request/custom_interceptor.dart`。使用 `dio`，错误/状态码统一由 HttpClient 检查并抛出 `AppError`。
- **服务与初始化**：全局服务（本地存储、设置等）在 `lib/services/`，初始化在 `main()` 启动流程中完成。
- **国际化**：基于 `intl`，生成文件位于 `lib/i18n/`（例如 `messages_*.dart`）。修改 ARB 后请运行相应的生成脚本。

常见修改场景（示例与约定）
- 添加 API：在 `lib/request/api.dart` 增加端点常量，必要时在 `lib/request/common_request.dart` 添加调用封装。
- 修改认证：token 注入与刷新逻辑放在 `lib/request/custom_interceptor.dart`，保持拦截器幂等且不在拦截器中做 UI 弹窗（只记录/抛错）。
- 本地存储：使用 `LocalStorageService`（`lib/services/local_storage_service.dart`）；请通过服务接口读写，不直接使用 Hive API。
- 新页面：创建 `modules/<feature>/` 子文件夹，并在 `app_router.dart` 中注册路由；页面应尽量通过 Provider 获取数据，不使用全局单例状态。

代码风格与约定
- 单例均使用 `instance` 静态 getter（例如 `AppRouter.instance`、`HttpClient.instance`）。
- 异步状态使用 `AsyncValue`/`AsyncNotifier` 模式封装加载/成功/错误态。
- 错误处理：抛出 `AppError` 或返回 `Result` 对象；不要在底层直接调用 `SmartDialog` 展示复杂 UI。

构建 / 运行 / 调试（快速参考）
- 首次：`flutter pub get`
- 运行（Android 模拟器/真机）：`flutter run`
- 运行 iOS：在 macOS 上使用 Xcode 打开 `ios/Runner.xcworkspace` 并运行，或 `flutter run` 指定设备。
- 打包 APK：`flutter build apk`；iOS 打包请使用 Xcode 或 `flutter build ios` 后在 Xcode 完成签名。
- 测试：`flutter test`

注意的集成点与外部依赖
- 主要第三方：`dio`（网络），`flutter_riverpod`（状态），`go_router`（路由），`hive`（本地存储），`intl`（国际化）。查看 `pubspec.yaml` 获取完整版本列表。
- 原生集成：iOS/Android 的原生代码在 `ios/`、`android/` 目录；跨平台 plugin 的初始化（如 `Hive.initFlutter`、`PackageInfo`）在 `main()` 完成。

交互细节（当 AI 修改代码时的建议）
- 在改动网络层或服务时，务必增加/更新单元测试或手动说明如何手动验证（提供 `curl` 请求或本地模拟数据）。
- 对于影响全局状态的修改（如更改 `LocalStorageService` 的 key），请同时修改使用处与迁移说明。
- 修改国际化字符串时，更新对应的 ARB 并运行生成器；在 PR 描述里列出执行命令。

检查点（PR 模板建议）
- 变更范围（文件/模块）
- 如何手动验证（启动命令、模拟步骤）
- 可能的回归风险与兼容性注意点

如果本文件有遗漏或不准确的地方，请指出具体文件或场景，我会据此迭代更新。
