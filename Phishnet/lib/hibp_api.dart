// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;

// Function to classify breaches into categories
Map<String, List> classifyBreaches(List breaches) {
  var classification = {'Critical': [], 'High': [], 'Medium': [], 'Low': []};
  for (var breach in breaches) {
    if (breach['dataClasses'] != null) {
      if (breach['dataClasses'].contains('Social Security Numbers') ||
          breach['dataClasses'].contains('Credit Card Numbers')) {
        classification['Critical']!.add(breach);
      } else if (breach['dataClasses'].contains('Passwords') ||
          breach['dataClasses'].contains('Physical Addresses')) {
        classification['High']!.add(breach);
      } else if (breach['dataClasses'].contains('Phone Numbers') ||
          breach['dataClasses'].contains('Employment Information')) {
        classification['Medium']!.add(breach);
      } else {
        classification['Low']!.add(breach);
      }
    }
  }
  return classification;
}

Future<Map<String, dynamic>> checkEmail(String email) async {
  var hibpApiKey = '1c79345799354f0c9dc49fe20df74c50';
  var response = await http.get(
    Uri.parse('https://haveibeenpwned.com/api/v3/breachedaccount/${Uri.encodeComponent(email)}'),
    headers: {
      'hibp-api-key': hibpApiKey,
      'User-Agent': 'Dart/2.10 (dart:io)',
    },
  );
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    var classification = classifyBreaches(data);
    return {'pwned': true, 'breaches': data, 'classification': classification};
  } else if (response.statusCode == 404) {
    return {'pwned': false, 'breaches': [], 'classification': {}};
  } else {
    throw Exception('Error checking email: ${response.reasonPhrase}');
  }
}

// Function to get Chrome version
String getChromeVersion() {
  var match = RegExp(r'Chrom(e|ium)\/([0-9]+)\.').firstMatch(window.navigator.userAgent);
  return match != null ? int.parse(match.group(2)!).toString() : 'latest';
}

// Function to store user information as a token
Future<void> setToken(Map<String, dynamic> tokenData) async {
  // Assuming using package like shared_preferences or similar for local storage
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setString('token', json.encode(tokenData));
}

Future<String> getToken() async {
  // Assuming using package like shared_preferences or similar for local storage
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // return prefs.getString('token') ?? '';
  return ''; // Add a return statement here or replace it with a default value.
}

// Function to validate email format
bool validateEmail(String email) {
  var emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return emailRegex.hasMatch(email);
}

// Function to validate date format (YYYY-MM-DD)
bool validateDateOfBirth(String dob) {
  var dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  return dateRegex.hasMatch(dob);
}

// Function to validate phone number format
bool validatePhoneNumber(String phone) {
  var phoneRegex = RegExp(r'^\d{10}$'); // Assuming a simple 10-digit phone number
  return phoneRegex.hasMatch(phone);
}

//Function to prompt user for settings and store as a token
Future<void> promptForSettings() async {
}

void main() {
  var emailToCheck = 'user@example.com';
  checkEmail(emailToCheck)
      .then((result) {
    if (result['pwned']) {
      print("Email '$emailToCheck' has been pwned with the following breaches:");
      print('Critical: ${result['classification']['Critical']}');
      print('High: ${result['classification']['High']}');
      print('Medium: ${result['classification']['Medium']}');
      print('Low: ${result['classification']['Low']}');
    } else {
      print("Email '$emailToCheck' has not been pwned.");
    }
  }).catchError((error) {
    print('Error checking email: $error');
  });
}
