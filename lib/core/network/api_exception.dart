sealed class ApiException implements Exception {
  const ApiException(this.message, {this.code});

  final String message;
  final String? code;

  factory ApiException.fromPostgrest(Object error) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('23P01') || msg.contains('exclusion_violation')) {
        return const DoubleBookingException();
      }
      if (msg.contains('P0001') || msg.contains('not available')) {
        return const VehicleUnavailableException();
      }
      return UnknownApiException(msg);
    }
    return UnknownApiException(error.toString());
  }
}

final class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);

  @override
  String toString() => message;
}

final class DoubleBookingException extends ApiException {
  const DoubleBookingException()
      : super('Seçilen tarihler için araç müsait değil.');
}

final class VehicleUnavailableException extends ApiException {
  const VehicleUnavailableException()
      : super('Araç bu tarihler için kiralanamaz.');
}

final class NetworkException extends ApiException {
  const NetworkException() : super('Sunucuya bağlanılamadı.');
}
