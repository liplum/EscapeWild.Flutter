import 'package:event_bus/event_bus.dart';

final eventBus = EventBus();

enum GameOverState {
  win,
  failure,
  tie;
}

class GameOverEvent {
  final GameOverState state;

  const GameOverEvent(this.state);
}
