import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/base/ui_adapter.dart';

abstract class BaseConsumerStatefulWidget extends ConsumerStatefulWidget with UIAdapter {
  const BaseConsumerStatefulWidget({super.key});
}