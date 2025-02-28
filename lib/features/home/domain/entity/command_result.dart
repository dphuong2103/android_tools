class CommandResult {
  final String? ip;
  final bool success;
  final String message;
  final String? error;

  CommandResult({
    required this.success,
    required this.message,
    this.error,
    this.ip,
  });
}