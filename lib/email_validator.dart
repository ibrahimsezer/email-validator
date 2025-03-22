import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

bool isValidEmailFormat(String email) {
  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

Future<bool> isDomainValid(String email) async {
  try {
    final domain = email.split('@').last;
    final response = await http.get(Uri.parse('http://$domain'));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<void> checkMxRecords(String email) async {
  final domain = email.split('@').last;
  final googleMX = "https://dns.google/resolve?name=$domain&type=MX";
  final url = Uri.parse(googleMX);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['Answer'] != null) {
      print("\nMX results:");
      for (var answer in data['Answer']) {
        print(answer['data']);
      }
    } else {
      print("\nMX results not found.");
    }
  } else {
    print("Error: ${response.statusCode}");
  }
}

Future<void> checkMailInfo() async {
  print("Email:");
  String? email = stdin.readLineSync();
  if (email != null) {
    if (isValidEmailFormat(email) && await isDomainValid(email)) {
      print("\n$email\t\t\t# Email and Domain is valid ");
    } else if (isValidEmailFormat(email) == true &&
        await isDomainValid(email) != true) {
      print("\n$email\t\t\t# Domain is not valid");
    } else if (isValidEmailFormat(email) != true &&
        await isDomainValid(email) == true) {
      print("\n$email\t\t\t# Email is not valid");
    } else {
      print("\n$email\t\t\t# Email and Domain is not valid");
    }
    await checkMxRecords(email);
    print("\nCheck another mail ? y or n");
    String? check = stdin.readLineSync();
    if (check == "y") {
      checkMailInfo();
    }
  } else {
    print("Enter your email");
    print("\nRestarting...");
    checkMailInfo();
  }
}

//--------------------MAIN-----------------------//
void main() async {
  checkMailInfo();
}
