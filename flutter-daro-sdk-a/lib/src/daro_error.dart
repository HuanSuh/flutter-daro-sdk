import 'package:flutter/services.dart';

class DaroError {
  final dynamic code;
  final String message;
  final dynamic details;

  const DaroError(this.code, this.message, {this.details});

  factory DaroError.fromJson(dynamic value) {
    return switch (value) {
      DaroError error => error,
      PlatformException exception => DaroError(
        exception.code,
        exception.message ?? 'Unknown error',
        details: exception.details,
      ),
      Map json => DaroError(
        json['code'] as int? ?? -1,
        json['message'] as String? ?? 'Unknown error',
        details: json['details'],
      ),
      _ => DaroError(-1, 'Unknown error', details: value),
    };
  }

  @override
  String toString() {
    return 'DaroError($code) : $message ${details ?? ''}';
  }
}
