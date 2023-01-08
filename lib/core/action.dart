class ActionType {
  final String name;

  const ActionType(this.name);

  @override
  String toString() => name;
  static const ActionType move = ActionType("move"),
      explore = ActionType("explore"),
      rest = ActionType("rest"),
      fire = ActionType("fire"),
      hunt = ActionType("hunt"),
      cutDownTree = ActionType("cutDownTree"),
      fish = ActionType("fish");
}
