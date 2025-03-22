import 'package:http/http.dart' as http;

bool isValidEmail(String email) {
  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

Future<bool> checkDomain(String domain) async {
  final response = await http.get(Uri.parse(
      'https://api.apilayer.com/email_verification/check?email=$domain'));
  return response.statusCode == 200;
}
