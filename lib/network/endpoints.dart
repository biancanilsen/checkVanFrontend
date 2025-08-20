class Endpoints {
  static const String baseUrl = 'http://192.168.0.114:3200';

  // user
  static const String login = '$baseUrl/user/login';
  static const String userRegistration = '$baseUrl/user/registration';
  static const String getProfile = '$baseUrl/user/getProfile';
  static const String updateUser = '$baseUrl/user/update';
  static const String forgotPassword = '$baseUrl/user/recoverPassword';
  static const String createStudent = '$baseUrl/user/recoverPassword';
  static const String getStudents = '$baseUrl/user/getStudents';

  // student
  static const String registration = '$baseUrl/student/registration';
  static const String updateStudent = '$baseUrl/student/update';
  static const String deleteStudent = '$baseUrl/student/delete';
  static const String getAllStudents = '$baseUrl/student/getAllStudents';
  static const String getStudentsByTeamId = '$baseUrl/student/getByTeamId';

  // trip
  static const String tripRegistration = '$baseUrl/trip/registration';
  static const String getAllTrips = '$baseUrl/trip/getAll';
  static const String updateTrip = '$baseUrl/trip/update';
  static const String deleteTrip = '$baseUrl/trip/delete';

  //team
  static const String getTeamsByTripId = '$baseUrl/trip/getBytripId';

  //schoool
  static const String listSchools = '$baseUrl/school/list';
}
