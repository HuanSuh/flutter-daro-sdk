class DaroError {
  final int code;
  final String message;
  final dynamic details;

  const DaroError(this.code, this.message, {this.details});

  factory DaroError.fromJson(dynamic value) {
    if (value is DaroError) {
      return value;
    }
    if (value case final Map json) {
      final code = json['code'] as int? ?? -1;
      final message = json['message'] as String? ?? 'Unknown error';
      return DaroError(code, message, details: json['details']);
    }
    return DaroError(-1, 'Unknown error', details: value);
  }

  @override
  String toString() {
    return 'DaroError($code) : $message ${details ?? ''}';
  }
}
