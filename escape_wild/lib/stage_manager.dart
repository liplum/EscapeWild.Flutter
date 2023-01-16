import 'package:escape_wild/design/top.dart';
import 'package:escape_wild/design/window.dart';
import 'package:escape_wild/ui/debug/console.dart';
import 'package:flutter/widgets.dart';

class StageManager {
  StageManager._();

  static const _debugConsoleKey = ValueKey("Debug Console");

  static TopEntry showDebugConsole([BuildContext? ctx]) {
    return showWindow(
      context: ctx,
      key: _debugConsoleKey,
      title: debugConsoleTitle,
      builder: (_) => const DebugConsole(),
    );
  }

  static void closeDebugConsole([BuildContext? ctx]) {
    closeWindowByKey(_debugConsoleKey, context: ctx);
  }

  static void closeAllPageSpecificWindow([BuildContext? ctx]) {
    closeDebugConsole(ctx);
  }
}
