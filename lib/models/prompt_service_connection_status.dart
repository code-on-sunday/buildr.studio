sealed class PromptServiceConnectionStatus {
  const PromptServiceConnectionStatus._();

  const factory PromptServiceConnectionStatus.connected() = Connected;
  const factory PromptServiceConnectionStatus.disconnected() = Disconnected;
  const factory PromptServiceConnectionStatus.error(String message) = Error;
  const factory PromptServiceConnectionStatus.connecting() = Connecting;
}

class Connecting extends PromptServiceConnectionStatus {
  const Connecting() : super._();
}

class Connected extends PromptServiceConnectionStatus {
  const Connected() : super._();
}

class Disconnected extends PromptServiceConnectionStatus {
  const Disconnected() : super._();
}

class Error extends PromptServiceConnectionStatus {
  final String message;

  const Error(this.message) : super._();
}
