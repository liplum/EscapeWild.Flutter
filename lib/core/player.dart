import 'package:escape_wild_flutter/core/attribute.dart';

class Player
    with AttributeManagerMixin, DefaultAttributeModelMixin
    implements AttributeManagerProtocol, AttributeModelProtocol {
  @override
  AttributeModelProtocol get model => this;
}
