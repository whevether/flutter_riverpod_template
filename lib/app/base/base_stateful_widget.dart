import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/app/base/ui_adapter.dart';

abstract class BaseStatefulWidget extends StatefulWidget with UIAdapter {
  const BaseStatefulWidget({super.key});
}