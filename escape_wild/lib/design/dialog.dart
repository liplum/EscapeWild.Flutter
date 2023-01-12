import 'package:rettulf/rettulf.dart';

import 'package:flutter/material.dart';

extension DialogEx on BuildContext {
  /// return: whether the button was hit
  Future<bool> showTip({
    required String title,
    required String desc,
    required String ok,
    bool highlight = false,
    bool serious = false,
    bool dismissible = true,
  }) async {
    return showAnyTip(
      dismissible: dismissible,
      title: title,
      make: (_) => desc.text(style: const TextStyle()),
      ok: ok,
      highlight: false,
      serious: serious,
    );
  }

  Future<bool> showAnyTip({
    required String title,
    Widget? titleTrailing,
    required WidgetBuilder make,
    required String ok,
    bool highlight = false,
    bool serious = false,
    bool dismissible = true,
  }) async {
    final dynamic confirm = await showDialog(
      context: this,
      barrierDismissible: dismissible,
      builder: (ctx) => $Dialog(
          title: title,
          titleTrailing: titleTrailing,
          serious: serious,
          make: make,
          primary: $DialogAction(
            warning: highlight,
            text: ok,
            onPressed: () {
              ctx.navigator.pop(true);
            },
          )),
    );
    return confirm == true;
  }

  Future<bool?> showRequest({
    required String title,
    required String desc,
    required String yes,
    required String no,
    bool highlight = false,
    bool isPrimaryDefault = false,
    bool serious = false,
    bool dismissible = true,
  }) async {
    return await showAnyRequest(
      dismissible: dismissible,
      title: title,
      isPrimaryDefault: isPrimaryDefault,
      make: (_) => desc.text(style: const TextStyle()),
      yes: yes,
      no: no,
      highlight: highlight,
      serious: serious,
    );
  }

  Future<bool?> showAnyRequest({
    required String title,
    Widget? titleTrailing,
    required WidgetBuilder make,
    required String yes,
    required String no,
    bool highlight = false,
    bool isPrimaryDefault = false,
    bool serious = false,
    bool dismissible = true,
  }) async {
    return await showDialog(
      context: this,
      barrierDismissible: dismissible,
      builder: (ctx) => $Dialog(
        title: title,
        titleTrailing: titleTrailing,
        serious: serious,
        make: make,
        primary: $DialogAction(
          warning: highlight,
          isDefault: isPrimaryDefault,
          text: yes,
          onPressed: () {
            ctx.navigator.pop(true);
          },
        ),
        secondary: $DialogAction(
          text: no,
          onPressed: () {
            ctx.navigator.pop(false);
          },
        ),
      ),
    );
  }
}

class $DialogAction {
  final String text;
  final bool isDefault;
  final bool warning;
  final VoidCallback? onPressed;

  const $DialogAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.warning = false,
  });
}

class $Dialog extends StatelessWidget {
  final String? title;
  final Widget? titleTrailing;
  final $DialogAction? primary;
  final $DialogAction? secondary;

  /// Highlight the title
  final bool serious;
  final WidgetBuilder make;

  const $Dialog({
    super.key,
    this.title,
    this.titleTrailing,
    required this.make,
    this.primary,
    this.secondary,
    this.serious = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget dialog;
    final second = secondary;
    final first = primary;
    dialog = AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28.0))),
      title: title == null
          ? null
          : [
              title!.text(style: TextStyle(fontWeight: FontWeight.w600, color: serious ? Colors.redAccent : null)),
              if (titleTrailing != null) titleTrailing!,
            ].row(maa: MainAxisAlignment.spaceBetween),
      content: make(context),
      actions: [
        if (second != null)
          TextButton(
            onPressed: () {
              second.onPressed?.call();
            },
            child: second.text.text(
              style: TextStyle(
                color: second.warning ? Colors.redAccent : null,
                fontWeight: second.isDefault ? FontWeight.bold : null,
                fontSize: context.textTheme.titleMedium?.fontSize,
              ),
            ),
          ),
        if (first != null)
          TextButton(
              onPressed: () {
                first.onPressed?.call();
              },
              child: first.text.text(
                style: TextStyle(
                    color: first.warning ? Colors.redAccent : null,
                    fontWeight: first.isDefault ? FontWeight.bold : null,
                    fontSize: context.textTheme.titleMedium?.fontSize),
              ))
      ],
    );
    return dialog;
  }
}
