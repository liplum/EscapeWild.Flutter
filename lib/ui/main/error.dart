import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rettulf/primitive/string.dart';

class ErrorPage extends ConsumerStatefulWidget {
  final String? message;

  const ErrorPage({super.key, this.message});

  @override
  ConsumerState createState() => _ErrorPageState();
}

class _ErrorPageState extends ConsumerState<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: "Error".text()),
      body: (widget.message ?? "").text(),
    );
  }
}
