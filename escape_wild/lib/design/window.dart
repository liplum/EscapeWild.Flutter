import 'top.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

const _kWindowAspectRatio = 4 / 3;

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

class Window extends StatefulWidget {
  final String title;

  /// If you know width:
  ///   height = width * [aspectRatio]
  ///
  /// If you know height:
  ///   width = height / [aspectRatio]
  final double aspectRatio;
  final CloseableProtocol? closeable;
  final WidgetBuilder builder;
  final Duration fadeDuration;

  const Window({
    super.key,
    required this.title,
    this.closeable,
    required this.builder,
    this.aspectRatio = _kWindowAspectRatio,
    this.fadeDuration = const Duration(milliseconds: 200),
  });

  @override
  State<Window> createState() => _WindowState();
}

class _WindowState extends State<Window> {
  var _x = 0.0;
  var _y = 0.0;
  final _mainBodyKey = GlobalKey();
  static var scaleDelta = 0.0;
  static const scaleRange = 150;

  static double get scaleDeltaProgress => clampDouble(scaleDelta / scaleRange, 0.0, 1.0);

  static set scaleDeltaProgress(double newV) => scaleDelta = newV * scaleRange;
  var isResizing = false;

  // Hide the first frame to avoid position flash
  var opacity = 0.0;

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

  Size calcuBestSize(BuildContext ctx) {
    final full = ctx.mediaQuery.size;
    if (ctx.isPortrait) {
      // on Portrait mode, the preview window is based on width.
      final width = full.width * 0.8;
      final height = width / widget.aspectRatio + scaleDelta;
      return Size(width, height);
    } else {
      // on Landscape mode, the preview window is based on height.
      final height = full.height * 0.8 + scaleDelta;
      final width = height * widget.aspectRatio;
      return Size(width, height);
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

  Widget buildWindowContent(BuildContext ctx) {
    final windowSize = calcuBestSize(ctx);
    Widget content = [
      Listener(
        child: buildWindowHead(ctx),
        onPointerMove: (d) {
          if (!isResizing) {
            setState(() {
              _x += d.delta.dx;
              _y += d.delta.dy;
            });
          }
        },
      ).sized(w: windowSize.width),
      widget.builder(ctx).sizedIn(windowSize),
    ].column();
    content = content.inCard();
    return content;
  }

  Widget buildTitle(BuildContext ctx) {
    final Widget res;
    if (isResizing) {
      res = Slider(
        value: scaleDeltaProgress,
        onChanged: (newV) {
          setState(() {
            scaleDeltaProgress = newV;
          });
        },
      );
    } else {
      final style = ctx.textTheme.titleMedium;
      res = [
        widget.title
            .text(style: style, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1)
            .padSymmetric(h: 10, v: 10)
            .align(at: Alignment.center),
      ].stack().inCard(elevation: 2);
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
      child: res,
    );
  }

  Widget buildWindowHead(BuildContext ctx) {
    final closeable = widget.closeable;
    return [
      IconButton(
        onPressed: () {
          setState(() {
            isResizing = !isResizing;
          });
        },
        icon: const Icon(Icons.open_in_full_rounded),
      ),
      buildTitle(ctx).expanded(),
      if (closeable != null)
        IconButton(
            onPressed: () async {
              setState(() {
                opacity = 0.0;
              });
              await Future.delayed(widget.fadeDuration);
              closeable.closeWindow();
            },
            icon: const Icon(Icons.close)),
    ].row();
  }
}
