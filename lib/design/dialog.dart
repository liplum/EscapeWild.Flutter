import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:platform_safe_func/platform_safe_func.dart';
import 'package:rettulf/rettulf.dart';

import 'package:flutter/material.dart';

bool get isCupertino => isIOS || isMacOS;

extension ColorEx on BuildContext {
  Color get $red$ => isCupertino ? CupertinoColors.destructiveRed : Colors.redAccent;
}

extension DialogEx on BuildContext {
  Future<T?> showSheet<T>(
    WidgetBuilder builder, {
    bool dismissible = true,
    bool fullScreen = true,
    bool useRootNavigator = true,
  }) async {
    if (isCupertino) {
      return await showCupertinoModalBottomSheet<T>(
        context: this,
        expand: fullScreen,
        builder: builder,
        animationCurve: Curves.fastEaseInToSlowEaseOut,
        isDismissible: dismissible,
        enableDrag: dismissible,
        useRootNavigator: useRootNavigator,
      );
    } else {
      // dismissible not working with CustomScrollView
      // see https://github.com/flutter/flutter/issues/36283
      var enableDrag = dismissible;
      var showDragHandle = enableDrag;
      return await showModalBottomSheet<T>(
        context: this,
        builder: builder,
        isDismissible: dismissible,
        isScrollControlled: fullScreen,
        useSafeArea: true,
        // It's a workaround
        showDragHandle: showDragHandle,
        enableDrag: enableDrag,
        useRootNavigator: useRootNavigator,
      );
    }
  }

  Future<T?> showDialog<T>(
    WidgetBuilder builder, {
    bool dismissible = true,
    bool useRootNavigator = false,
    Color? backgroundColor,
  }) async {
    return showAdaptiveDialog<T>(
      context: this,
      builder: builder,
      barrierColor: backgroundColor,
      barrierDismissible: dismissible,
      useRootNavigator: useRootNavigator,
    );
  }

  /// return: whether the button was hit
  Future<bool> showTip({
    String? title,
    required String desc,
    required String primary,
    bool destructive = false,
    bool primaryDestructive = false,
    bool dismissible = true,
  }) async {
    return showAnyTip(
      title: title,
      desc: (_) => desc.text(),
      primary: primary,
      destructive: destructive,
      primaryDestructive: primaryDestructive,
      dismissible: dismissible,
    );
  }

  Future<bool> showAnyTip({
    String? title,
    required WidgetBuilder desc,
    required String primary,
    bool destructive = false,
    bool primaryDestructive = false,
    bool dismissible = false,
  }) async {
    final dynamic confirm = await showAdaptiveDialog(
      barrierDismissible: dismissible,
      context: this,
      builder: (ctx) => $Dialog$(
          title: title,
          destructive: destructive,
          builder: desc,
          primary: $Action$(
            warning: primaryDestructive,
            text: primary,
            onPressed: () {
              ctx.navigator.pop(true);
            },
          )),
    );
    return confirm == true;
  }

  Future<bool?> showDialogRequest({
    String? title,
    required String desc,
    required String primary,
    required String secondary,
    bool dismissible = false,
    bool destructive = false,
    bool primaryDestructive = false,
    bool secondaryDestructive = false,
  }) async {
    return await showAnyRequest(
      title: title,
      dismissible: dismissible,
      builder: (_) => desc.text(style: const TextStyle()),
      primary: primary,
      secondary: secondary,
      destructive: destructive,
      primaryDestructive: primaryDestructive,
      secondaryDestructive: secondaryDestructive,
    );
  }

  Future<bool?> showActionRequest({
    String? title,
    required String desc,
    required String action,
    required String cancel,
    bool dismissible = true,
    bool destructive = false,
  }) async {
    if (isIOS) {
      return showCupertinoActionRequest(
        title: title,
        desc: desc,
        action: action,
        dismissible: dismissible,
        cancel: cancel,
        destructive: destructive,
      );
    } else {
      return await showAnyRequest(
        title: title ?? action,
        builder: (_) => desc.text(style: const TextStyle()),
        primary: action,
        secondary: cancel,
        dismissible: dismissible,
        primaryDestructive: destructive,
        destructive: destructive,
      );
    }
  }

  Future<bool?> showCupertinoActionRequest({
    String? title,
    required String desc,
    required String action,
    required String cancel,
    bool dismissible = true,
    bool destructive = false,
  }) async {
    return await showCupertinoModalPopup(
      context: this,
      barrierDismissible: dismissible,
      builder: (ctx) => CupertinoActionSheet(
        title: title?.text(),
        message: desc.text(),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: destructive,
            onPressed: () {
              ctx.pop(true);
            },
            child: action.text(),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            ctx.pop(false);
          },
          child: cancel.text(),
        ),
      ),
    );
  }

  Future<bool?> showAnyRequest({
    String? title,
    required WidgetBuilder builder,
    required String primary,
    required String secondary,
    bool dismissible = false,
    bool destructive = false,
    bool primaryDestructive = false,
    bool secondaryDestructive = false,
  }) async {
    return await showAdaptiveDialog(
      context: this,
      barrierDismissible: dismissible,
      builder: (ctx) => $Dialog$(
        title: title,
        destructive: destructive,
        builder: builder,
        primary: $Action$(
          warning: primaryDestructive,
          text: primary,
          onPressed: () {
            ctx.navigator.pop(true);
          },
        ),
        secondary: $Action$(
          text: secondary,
          warning: secondaryDestructive,
          onPressed: () {
            ctx.navigator.pop(false);
          },
        ),
      ),
    );
  }
}

class $Action$ {
  final String text;
  final bool isDefault;
  final bool warning;
  final VoidCallback? onPressed;

  const $Action$({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.warning = false,
  });
}

class $Dialog$ extends StatelessWidget {
  final String? title;
  final $Action$ primary;
  final $Action$? secondary;

  /// Highlight the title
  final bool destructive;
  final WidgetBuilder builder;

  const $Dialog$({
    super.key,
    this.title,
    required this.primary,
    required this.builder,
    this.secondary,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget dialog;
    final second = secondary;
    if (isCupertino) {
      dialog = CupertinoAlertDialog(
        title: title?.text(style: TextStyle(fontWeight: FontWeight.w600, color: destructive ? context.$red$ : null)),
        content: builder(context),
        actions: [
          if (second != null)
            CupertinoDialogAction(
              isDestructiveAction: second.warning,
              isDefaultAction: second.isDefault,
              onPressed: () {
                second.onPressed?.call();
              },
              child: second.text.text(),
            ),
          CupertinoDialogAction(
            isDestructiveAction: primary.warning,
            isDefaultAction: primary.isDefault,
            onPressed: () {
              primary.onPressed?.call();
            },
            child: primary.text.text(),
          )
        ],
      );
    } else {
      // For other platform
      dialog = AlertDialog(
        backgroundColor: context.theme.dialogTheme.backgroundColor,
        title: title?.text(style: TextStyle(fontWeight: FontWeight.w600, color: destructive ? context.$red$ : null)),
        content: builder(context),
        actions: [
          if (second != null)
            TextButton(
              onPressed: () {
                second.onPressed?.call();
              },
              child: second.text.text(
                style: TextStyle(
                  color: second.warning ? context.$red$ : null,
                  fontWeight: second.isDefault ? FontWeight.w600 : null,
                ),
              ),
            ),
          TextButton(
              onPressed: () {
                primary.onPressed?.call();
              },
              child: primary.text.text(
                style: TextStyle(
                  color: primary.warning ? context.$red$ : null,
                  fontWeight: primary.isDefault ? FontWeight.w600 : null,
                ),
              )),
        ],
      );
    }
    return dialog;
  }
}
