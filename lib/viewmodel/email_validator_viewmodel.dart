import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EmailValidatorViewModel extends ChangeNotifier {
  Future<void> writeToCsv(List<List<dynamic>> rows, String filePath) async {
    String csvData = const ListToCsvConverter().convert(rows);
    final file = File(filePath);
    await file.writeAsString(csvData);
    log("Data saved in the $filePath");
  }

  bool isValidEmailFormat(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> isDomainValid(String email) async {
    try {
      final domain = email.split('@').last;
      final List<String> mxRecords = await getMxRecords(domain);
      return mxRecords.isNotEmpty;
    } catch (e) {
      log('Error validating domain: $e');
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

  Future<String> checkMailInfo(
      List<List<dynamic>> rows, String getEmail) async {
    log("Email: $getEmail");
    String email = getEmail;
    if (email != "") {
      bool isEmailValid = isValidEmailFormat(email);
      bool isDomainValidFlag = await isDomainValid(email);
      List<String> mxRecords = await getMxRecords(email.split('@').last);
      String status;

      if (isEmailValid && isDomainValidFlag) {
        status = "$email - ${email.split('@').last}";
      } else if (isEmailValid) {
        status = "$email - Domain is not valid";
      } else if (isDomainValidFlag) {
        status = "$email - Email is not valid";
      } else {
        status = "$email - Email and Domain are not valid";
      }

      rows.add([email, status, mxRecords.join('; ')]);
      log("\n$email\t\t\t# $status");

      if (mxRecords.isNotEmpty) {
        log("\nMX results:");
        mxRecords.forEach(log);
      } else {
        log("\nMX results not found.");
      }

      log("\nSaving..");
      //String? check = stdin.readLineSync();
      //final dateTime = DateTime.now();
      //final formattedDateTime = DateFormat('yyyyMMdd_HHmm').format(dateTime);
      //final fileName = 'email_validation_results_$formattedDateTime.csv';
      //await writeToCsv(rows, fileName);
      log("Saved");
      return status;
    }
    return "Email is empty";
  }
}

//--------------------MAIN-----------------------//
void main() async {
/*  List<List<dynamic>> rows = [
    ['Email', "Status", "MX Records"]
  ];
  await checkMailInfo(rows);*/
}
