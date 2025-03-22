import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<void> writeToCsv(List<List<dynamic>> rows, String filePath) async {
  String csvData = const ListToCsvConverter().convert(rows);
  final file = File(filePath);
  await file.writeAsString(csvData);
  print("Data saved in the $filePath");
}

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

Future<List<String>> getMxRecords(String domain) async {
  final googleMX = "https://dns.google/resolve?name=$domain&type=MX";
  final url = Uri.parse(googleMX);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['Answer'] != null) {
      return data['Answer']
          .map<String>((answer) => answer['data'] as String)
          .toList();
    }
  }
  return [];
}

Future<void> checkMailInfo(List<List<dynamic>> rows) async {
  print("Email:");
  String? email = stdin.readLineSync();
  if (email != null && email != "") {
    bool isEmailValid = isValidEmailFormat(email);
    bool isDomainValidFlag = await isDomainValid(email);
    List<String> mxRecords = await getMxRecords(email.split('@').last);
    String status;

    if (isEmailValid && isDomainValidFlag) {
      status = "Email and Domain are valid";
    } else if (isEmailValid) {
      status = "Domain is not valid";
    } else if (isDomainValidFlag) {
      status = "Email is not valid";
    } else {
      status = "Email and Domain are not valid";
    }

    rows.add([email, status, mxRecords.join('; ')]);
    print("\n$email\t\t\t# $status");

    if (mxRecords.isNotEmpty) {
      print("\nMX results:");
      mxRecords.forEach(print);
    } else {
      print("\nMX results not found.");
    }

    print("\nCheck another mail? (y/n)");
    String? check = stdin.readLineSync();
    if (check?.toLowerCase() == "y") {
      await checkMailInfo(rows);
    } else {
      final dateTime = DateTime.now();
      final formattedDateTime = DateFormat('yyyyMMdd_HHmm').format(dateTime);
      final fileName = 'email_validation_results_$formattedDateTime.csv';
      await writeToCsv(rows, fileName);
    }
  } else {
    print("Enter your email");
    print("\nRestarting...");
    await checkMailInfo(rows);
  }
}

//--------------------MAIN-----------------------//
void main() async {
  List<List<dynamic>> rows = [
    ['Email', "Status", "MX Records"]
  ];
  await checkMailInfo(rows);
}
