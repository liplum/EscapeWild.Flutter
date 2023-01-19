import 'package:escape_wild/design/theme.dart';

import 'top.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

TopEntry showWindow({
  Key? key,
  required String title,
  required WidgetBuilder builder,
  BuildContext? context,
}) {
  return showTop(
    context: context,
    key: key,
    (context, entry) => Window(
      title: title,
      builder: builder,
      closeable: entry,
    ),
  );
}

void closeWindowByKey(Key key, {BuildContext? context}) {
  final entry = getTopEntry(key: key, context: context);
  entry?.closeWindow();
}

const double kWidthFactorPortrait = 0.8;
const double kHeightFactorPortrait = 0.6;
const double kWidthFactorLandscape = 0.6;
const double kHeightFactorLandscape = 0.75;

class Window extends StatefulWidget {
  final String title;

  /// Default is 40.
  final double? titleHeight;

  /// The window size.
  ///
  /// Default is [MediaQueryData.size]
  final Size? windowSize;

  /// The width factor of [windowSize].
  /// - When [MediaQueryData.orientation] is [Orientation.portrait], the default is [kWidthFactorPortrait].
  /// - Otherwise, the default is [kWidthFactorLandscape].
  final double? widthFactor;

  /// The height factor of [windowSize].
  ///
  /// - When [MediaQueryData.orientation] is [Orientation.portrait], the default is [kHeightFactorPortrait].
  /// - Otherwise, the default is [kHeightFactorLandscape].
  final double? heightFactor;
  final CloseableProtocol? closeable;
  final WidgetBuilder builder;
  final Duration fadeDuration;

  const Window({
    super.key,
    required this.title,
    this.closeable,
    required this.builder,
    this.windowSize,
    this.widthFactor,
    this.heightFactor,
    this.fadeDuration = const Duration(milliseconds: 200),
    this.titleHeight,
  });

  @override
  State<Window> createState() => _WindowState();
}

class _WindowState extends State<Window> {
  var _x = 0.0;
  var _y = 0.0;
  final _mainBodyKey = GlobalKey();

  // Hide the first frame to avoid position flash
  var opacity = 0.0;
  Orientation? lastOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ctx = _mainBodyKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject();
        if (box is RenderBox) {
          final childSize = box.size;
          final selfSize = context.mediaQuery.size;
          setState(() {
            _x = (selfSize.width - childSize.width) / 2;
            _y = (selfSize.height - childSize.height) / 2;
            opacity = 1.0;
          });
        }
      }
    });
  }

  Size calcuWindowSize(BuildContext ctx) {
    final size = widget.windowSize;
    if (size != null) return size;
    final full = ctx.mediaQuery.size;
    if (ctx.isPortrait) {
      return Size(
        full.width * (widget.widthFactor ?? kWidthFactorPortrait),
        full.height * (widget.heightFactor ?? kHeightFactorPortrait),
      );
    } else {
      return Size(
        full.width * (widget.widthFactor ?? kWidthFactorLandscape),
        full.height * (widget.heightFactor ?? kHeightFactorLandscape),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.fadeDuration,
      child: [
        Positioned(
          key: _mainBodyKey,
          left: _x,
          top: _y,
          child: buildWindowContent(context),
        ),
      ].stack().safeArea(),
    );
  }

  Future<void> onCloseWindow() async {
    setState(() {
      opacity = 0.0;
    });
    await Future.delayed(widget.fadeDuration);
    widget.closeable?.closeWindow();
  }

  void onWindowMove(PointerMoveEvent e) {
    setState(() {
      _x += e.delta.dx;
      _y += e.delta.dy;
    });
  }

  Widget buildWindowContent(BuildContext ctx) {
    final windowSize = calcuWindowSize(ctx);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onCloseWindow,
        ),
        title: widget.title.text(),
        centerTitle: true,
      ).listener(onPointerMove: onWindowMove).preferredSize(Size.fromHeight(widget.titleHeight ?? 40)),
      body: widget.builder(ctx),
    ).sizedIn(windowSize).clipRRect(borderRadius: ctx.cardBorderRadius);
  }
}
