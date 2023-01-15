import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:collection';

// Thanks to [Overlay Support](https://github.com/boyan01/overlay_support)
final GlobalKey<TopState> _topK = GlobalKey(debugLabel: 'Top');
bool _debugInitialized = false;

typedef TopBuilder = Widget Function(BuildContext context, TopEntry entry);

/// To show overlay widget.
///
/// - [builder] see [TopBuilder].
/// - [key] To identify a TopEntry.
///
/// For example:
/// ```dart
/// final builder = (ctx) => Placeholder();
/// final builder2 = (ctx) => Text("TEST");
/// final key = ValueKey('MyTop');
/// // Now placeholder is shown on the screen immediately.
/// showTop(builder, key: key);
/// // If you reuse the same key, the former one will be replaced.
/// showTop(builder2, key: key);
///
///
TopEntry showTop(
  TopBuilder builder, {
  Key? key,
  BuildContext? context,
}) {
  assert(key is! GlobalKey);

  final top = findTopState(context);
  final overlay = top?.overlayState;
  if (top == null || overlay == null) {
    assert(() {
      debugPrint('[OverlayState] is not found, failed to show top with $key.');
      return true;
    }());
    return TopEntry.empty();
  }

  final overlayKey = key ?? UniqueKey();

  final oldTopEntry = top.getEntry(key: overlayKey);

  oldTopEntry?.closeWindow();
  late final TopEntry topEntry;
  final entry = OverlayEntry(builder: (context) {
    // Capture local variable [topEntry]
    return KeyedTop(key: overlayKey, child: builder(context, topEntry));
  });
  topEntry = TopEntry._internal(entry, overlayKey, top);
  top.addEntry(topEntry, key: overlayKey);
  overlay.insert(entry);
  return topEntry;
}

TopEntry? getTopEntry({
  required Key key,
  BuildContext? context,
}) {
  final top = findTopState(context);
  return top?.getEntry(key: key);
}

abstract class CloseableProtocol {
  void closeWindow();

  Future<bool> get isClosed;
}

abstract class TopEntry extends CloseableProtocol {
  factory TopEntry._internal(
    OverlayEntry entry,
    Key key,
    TopState top,
  ) {
    return _TopEntryImpl._(entry, key, top);
  }

  factory TopEntry.empty() {
    return _EmptyTopEntry();
  }

  /// Find [TopEntry] by [context].
  ///
  /// The [context] should be the BuildContext which build a element in Notification.
  ///
  static TopEntry? of(BuildContext context) {
    return TopEntry.empty();
  }
}

/// [TopEntry] represent a overlay popup by [showTop].
///
class _TopEntryImpl implements TopEntry {
  final OverlayEntry _entry;
  final Key _overlayKey;
  final TopState _top;

  _TopEntryImpl._(
    this._entry,
    this._overlayKey,
    this._top,
  );

  // To known when notification has been dismissed.
  final Completer<bool> _$dismissed = Completer<bool>();

  @override
  Future<bool> get isClosed => _$dismissed.future;

  /// Whether [OverlayEntry] has been removed from [Overlay].
  ///
  /// It's to avoid calling [Completer.complete] on [_$dismissed] twice.
  bool _dismissed = false;

  @override
  void closeWindow() {
    if (_dismissed) return;
    // Remove this entry from TopState.
    _top.removeEntry(key: _overlayKey);
    _dismissed = true;
    _entry.remove();
    _$dismissed.complete(true);
  }
}

class _EmptyTopEntry implements TopEntry {
  @override
  void closeWindow() {}

  @override
  Future<bool> get isClosed => Future.value(true);
}

/// A widget that builds its child.
/// The same as [KeyedSubtree].
class KeyedTop extends StatelessWidget {
  final Widget child;

  const KeyedTop({required Key key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

TopState? findTopState([BuildContext? context]) {
  if (context == null) {
    assert(
      _debugInitialized,
      'Global Top Not Initialized ! \n'
      'ensure your app wrapped widget Top.global',
    );
    final state = _topK.currentState;
    assert(() {
      if (state == null) {
        throw FlutterError('''[TopState] is not found.
        You should wrap your app with `Top.global`, like this:
         Top.global(child: MaterialApp(title: 'My App', home: HomePage()))
      ''');
      }
      return true;
    }());
    return state;
  }
  return context.findAncestorStateOfType<TopState>();
}

class Top extends StatelessWidget {
  final Widget child;

  final bool global;

  const Top({
    Key? key,
    required this.child,
    this.global = true,
  }) : super(key: key);

  const Top.global({
    super.key,
    required this.child,
  }) : global = true;

  const Top.local({
    super.key,
    required this.child,
  }) : global = false;

  TopState? of(BuildContext context) {
    return context.findAncestorStateOfType<TopState>();
  }

  @override
  Widget build(BuildContext context) {
    return global ? _GlobalTop(child: child) : _LocalTop(child: child);
  }
}

abstract class TopState<T extends StatefulWidget> extends State<T> {
  final Map<Key, TopEntry> _entries = HashMap();

  OverlayState? get overlayState;

  TopEntry? getEntry({required Key key}) {
    return _entries[key];
  }

  void addEntry(TopEntry entry, {required Key key}) {
    _entries[key] = entry;
  }

  void removeEntry({required Key key}) {
    _entries.remove(key);
  }
}

class _GlobalTop extends StatefulWidget {
  final Widget child;

  _GlobalTop({required this.child}) : super(key: _topK);

  @override
  StatefulElement createElement() {
    _debugInitialized = true;
    return super.createElement();
  }

  @override
  _GlobalTopState createState() => _GlobalTopState();
}

class _GlobalTopState extends TopState<_GlobalTop> {
  @override
  Widget build(BuildContext context) {
    assert(() {
      if (context.findAncestorWidgetOfExactType<_GlobalTop>() != null) {
        throw FlutterError('There is already an Top.global in the Widget tree.');
      }
      return true;
    }());
    return widget.child;
  }

  @override
  OverlayState? get overlayState {
    NavigatorState? navigator;
    void visitor(Element element) {
      if (navigator != null) return;

      if (element.widget is Navigator) {
        navigator = (element as StatefulElement).state as NavigatorState?;
      } else {
        element.visitChildElements(visitor);
      }
    }

    context.visitChildElements(visitor);

    assert(navigator != null, '''[Navigator] is not found.
         You should wrap your app with `Top`, like this:
         Top.global(child: MaterialApp(title: 'My App', home: HomePage()))
      ''');
    return navigator?.overlay;
  }
}

class _LocalTop extends StatefulWidget {
  final Widget child;

  const _LocalTop({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _LocalTopState createState() => _LocalTopState();
}

class _LocalTopState extends TopState<_LocalTop> {
  final GlobalKey<OverlayState> _overlayStateKey = GlobalKey();

  @override
  OverlayState? get overlayState => _overlayStateKey.currentState;

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayStateKey,
      initialEntries: [OverlayEntry(builder: (context) => widget.child)],
    );
  }
}
