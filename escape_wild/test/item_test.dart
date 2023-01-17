import 'package:escape_wild/core.dart';
import 'package:flutter_test/flutter_test.dart';

String getToolType() => "axe";

void main() {
  test("test $ToolType", () {
    assert(ToolType.axe == ToolType(getToolType()));
  });
}
