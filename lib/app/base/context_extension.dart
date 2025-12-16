import 'package:flutter/material.dart';

/// createTime: 2025/12/16 on 10:40
/// desc:
///
/// @author keep.wan
extension BuildContextEx on BuildContext {
  ///
  double get top => MediaQuery.of(this).padding.top;

  ///
  double get bottom => MediaQuery.of(this).padding.bottom;

  ///
  Size get screenSize => MediaQuery.of(this).size;

  double safeBottom([double pb = 0]) {
    return bottom > 0 ? bottom : pb;
  }
}