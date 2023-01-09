import 'package:escape_wild_flutter/core/item.dart';
import 'package:flutter_test/flutter_test.dart';

String getToolType() => "oxe";

void main() {
  test("test tool Type", () {
    assert(ToolType.oxe == ToolType(getToolType()));
  });
}
