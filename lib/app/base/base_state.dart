import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/base/loading/loading_service.dart';
import 'package:flutter_riverpod_template/app/base/ui_adapter.dart';
import 'package:flutter_riverpod_template/app/base/ui_widget.dart';

///UI
abstract class BaseUIState<T extends StatefulWidget> extends State<T>
    with UIAdapter, UIWidget {}

// state
abstract class BaseState<T extends StatefulWidget> extends BaseUIState<T>
    with LoadingMixinState {
  @override
  BuildContext get buildContext => context;
}

//
///UI
abstract class BaseUIConsumerState<T extends ConsumerStatefulWidget> extends ConsumerState<T>
    with UIAdapter, UIWidget {}

// state
abstract class BaseConsumerState<T extends ConsumerStatefulWidget> extends BaseUIConsumerState<T>
    with LoadingMixinState {
  @override
  BuildContext get buildContext => context;
}