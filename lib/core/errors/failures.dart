abstract class Failure {
  final String message;
  final dynamic cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message ${cause != null ? "($cause)" : ""}';
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.cause]);
}

class NativeBridgeFailure extends Failure {
  const NativeBridgeFailure(super.message, [super.cause]);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.cause]);
}

class SessionFailure extends Failure {
  const SessionFailure(super.message, [super.cause]);
}
