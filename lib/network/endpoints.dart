class Endpoints {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String login = '$baseUrl/user/login';
  static const String userRegistration = '$baseUrl/user/registration';
  static const String getProfile = '$baseUrl/user/getProfile';
  static const String updateUser = '$baseUrl/user/update';
  static const String forgotPassword = '$baseUrl/user/recoverPassword';
}
