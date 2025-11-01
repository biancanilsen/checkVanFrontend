class Endpoints {
  static const String baseUrl = 'http://192.168.0.183:3200';

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


  // trip
  static const String tripRegistration = '$baseUrl/trip/registration';
  static const String getAllTrips = '$baseUrl/trip/getAll';
  static const String updateTrip = '$baseUrl/trip/update';
  static const String deleteTrip = '$baseUrl/trip/delete';

  //team
  static const String getTeamsByTripId = '$baseUrl/trip/getBytripId';
  static const String getAllTeamsByDriver = '$baseUrl/team/getAllByDriver';
  static const String teamRegistration = '$baseUrl/team/registration';
  static const String deleteTeam = '$baseUrl/team/delete';
  static const String updateTeam = '$baseUrl/team/update';

  // route
  static const generateRoute = '$baseUrl/routeGenerator/generate';

  // student_team
  static const String assignStudentToTeam = '$baseUrl/studentTeam/assign';
  static const String unassignStudentFromTeam = '$baseUrl/studentTeam/unassign';

  // geocoding
  static const String autocompleteAddress = '$baseUrl/geocoding/autocomplete';
  static const String geocodingDetails = '$baseUrl/geocoding/details';
 
  // Van
  static const String createVan = '$baseUrl/van/create';

  // School
  static const String getAllSchools = '$baseUrl/school/getAll';
  static const String createSchool = '$baseUrl/school/create';

  // presence
  static String updatePresence(int studentId) => '$baseUrl/student/$studentId/presence';
  static const String getPresenceSummary = '$baseUrl/student/presence-summary';
}
