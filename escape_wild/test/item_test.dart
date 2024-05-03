import 'package:escape_wild/core/item_comp/tool.dart';
import 'package:flutter_test/flutter_test.dart';

String getToolType() => "axe";

void main() {
  test("test $ToolType", () {
    assert(ToolType.axe == ToolType(getToolType()));
  });
}
