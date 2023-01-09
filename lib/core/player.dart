import 'package:escape_wild_flutter/core/attribute.dart';

class Player with AttributeManagerMixin, DefaultAttributeModelMixin {
  @override
  AttributeModelProtocol get model => this;
}
