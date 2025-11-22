class Endpoints {
  static const String baseUrl = 'http://192.168.0.4:3200';

  // user
  static const String login = '$baseUrl/user/login';
  static const String userRegistration = '$baseUrl/user/create';
  static const String getProfile = '$baseUrl/user/getProfile';
  static const String updateUser = '$baseUrl/user/update';
  static const String forgotPassword = '$baseUrl/user/recoverPassword';

  // student
  static const String registration = '$baseUrl/student/registration';
  static const String updateStudent = '$baseUrl/student/update';
  static const String deleteStudent = '$baseUrl/student/delete';
  static const String getAllStudents = '$baseUrl/student/getAll';
  static const String getStudents = '$baseUrl/student/getStudents';
  static const String getStudentsByTeamId = '$baseUrl/student/getByTeamId';
  static const String createStudent = '$baseUrl/student/create';
  static const String searchStudents = '$baseUrl/student/search';

  // trip
  static const String tripRegistration = '$baseUrl/trip/registration';
  static const String getAllTrips = '$baseUrl/trip/getAll';
  static const String updateTrip = '$baseUrl/trip/update';
  static const String deleteTrip = '$baseUrl/trip/delete';
  static const String getNextTrips = '$baseUrl/trip/next-trips';
  static const String calculateRouteEtas = '$baseUrl/trip/calculate-route-etas';

  // notifications
  static const String updateLocation = '$baseUrl/notifications/update-location';
  static const String notifyArrivalHome = '$baseUrl/notifications/notify-arrival-home';
  static const String notifyBoarding = '$baseUrl/notifications/notify-boarding';
  static const String notifyArrivalSchool = '$baseUrl/notifications/notify-arrival-school';
  static const String notifyProximity = '$baseUrl/notifications/notify-proximity';

  //team
  static const String getTeamsByTripId = '$baseUrl/trip/getBytripId';
  static const String getAllTeamsByDriver = '$baseUrl/team/getAllByDriver';
  static const String teamRegistration = '$baseUrl/team/registration';
  static const String deleteTeam = '$baseUrl/team/delete';
  static const String updateTeam = '$baseUrl/team/update';
  static const String createTeam = '$baseUrl/team/create';

  // route
  static const generateRoute = '$baseUrl/routeGenerator/generate';

  // student_team
  static const String assignStudentToTeam = '$baseUrl/studentTeam/assign';
  static const String unassignStudentFromTeam = '$baseUrl/studentTeam/unassign';

  // geocoding
  static const String autocompleteAddress = '$baseUrl/geocoding/autocomplete';
  static const String geocodingDetails = '$baseUrl/geocoding/details';
  static const String calculateEta = '$baseUrl/geocoding/calculate-eta';
 
  // Van
  static const String createVan = '$baseUrl/van/create';
  static const String getAllVans = '$baseUrl/van/getAll';
  static const String updateVan = '$baseUrl/van/update';
  static const String searchVans = '$baseUrl/van/search';
  static const String deleteVan = '$baseUrl/van/delete';

  // School
  static const String getAllSchools = '$baseUrl/school/getAll';
  static const String createSchool = '$baseUrl/school/create';
  static const String getSchool = '$baseUrl/school/get';
  static const String updateSchool = '$baseUrl/school/update';
  static const String deleteSchool = '$baseUrl/school/delete';
  static const String searchSchools = '$baseUrl/school/search';

  // presence
  static String updatePresence(int studentId) => '$baseUrl/student/$studentId/presence';
  static const String getPresenceSummary = '$baseUrl/student/presence-summary';
  static String getMonthlyPresence(int studentId, int year, int month) {
    // O backend em JS usa mês 0-11, o Dart usa 1-12.
    // Ajustamos aqui, enviando o mês no formato que o JS espera (0-11).
    final jsMonth = month - 1;

    // Note que a rota mudou para '/presences' e usa query parameters
    return '$baseUrl/student/$studentId/presences?year=$year&month=$jsMonth';
  }
  static const String getNextTripStatusBulk = '$baseUrl/user/guardian/next-trip-status-bulk';
}
