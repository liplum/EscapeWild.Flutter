import 'package:escape_wild/core/item.dart';
import 'package:flutter_test/flutter_test.dart';

String getToolType() => "axe";

void main() {
  test("test tool Type", () {
    assert(ToolType.axe == ToolType(getToolType()));
  });
}
