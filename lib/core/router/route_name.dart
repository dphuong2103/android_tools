// ignore_for_file: constant_identifier_names

sealed class RouteName {
  const RouteName._();

  /// Put your named routes here
  static const String INITIAL_ROUTE = RouteName.LANDING;
  static const String LANDING = '/landing';
  static const String WELCOME = '/welcome';
  static const String REGISTRATION = '/registration';
  static const String REGISTRATION_PASSWORD = '/registrationPassword';
  static const String REGISTRATION_OTP = '/registrationOtp';
  static const String LOGIN = '/login';
  static const String HOME = '/home';

  static const String HOME_CHANGE_INFO ="/change_info";
  static const String HOME_BACKUP ="/backup";
  static const String HOME_INSTALL_APK ="/install_apk";
  static const String HOME_CONTROL ="/control";

  static const String BACK_UP = "/backup";
}
