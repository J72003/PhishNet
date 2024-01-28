import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  stdout.write('Enter email to check: ');
  var emailToCheck = stdin.readLineSync()!.trim();

  // Replace [YOUR_API_KEY] with your actual API key
  var apiKey = '[1c79345799354f0c9dc49fe20df74c50]';

  // Make the API request
  var result = checkEmailPwned(emailToCheck, apiKey);

  if (result=='pwned') {
    print("Email '$emailToCheck' has been pwned with the following breaches:");
    print('Critical: ${result['classification']['Critical']}');
    print('High: ${result['classification']['High']}');
    print('Medium: ${result['classification']['Medium']}');
    print('Low: ${result['classification']['Low']}');
  } else {
    print("Email '$emailToCheck' has not been pwned.");
  }
}

Map<String, dynamic> classifyBreaches(List breaches) {
  var classification = {'Critical': [], 'High': [], 'Medium': [], 'Low': []};
  
  var criticalKeywords = ['Social Security Numbers', 'Credit Card Numbers'];
  var highKeywords = ['Passwords', 'Physical Addresses'];
  var mediumKeywords = ['Phone Numbers', 'Employment Information'];

  // Counters for each category
  var criticalCount = 0;
  var highCount = 0;
  var mediumCount = 0;
  var lowCount = 0;
  for (var breach in breaches) {
    if (breach['~:DataClasses'] != null) {
      var dataClasses = List<String>.from(breach['~:DataClasses']);

      if (dataClasses.any((element) => criticalKeywords.contains(element))) {
        classification['Critical']!.add(breach);
        criticalCount++;
      } else if (dataClasses.any((element) => highKeywords.contains(element))) {
        classification['High']!.add(breach);
        highCount++;
      } else if (dataClasses.any((element) => mediumKeywords.contains(element))) {
        classification['Medium']!.add(breach);
        mediumCount++;
      } else {
        classification['Low']!.add(breach);
        lowCount++;
      }
    }
  }
  // Your existing classification logic here...
   // Add counts to the result
  classification['Critical']!.insert(0, criticalCount);
  classification['High']!.insert(0, highCount);
  classification['Medium']!.insert(0, mediumCount);
  classification['Low']!.insert(0, lowCount);

  return classification;

}

// Function to check if an email has been pwned using the haveibeenpwned API
Future<Map<String, dynamic>> checkEmailPwned(String email, String apiKey) async {
  var apiUrl = 'https://haveibeenpwned.com/api/v3/breachedaccount/$email';
  var headers = {
    HttpHeaders.authorizationHeader: 'hibp-api-key: $apiKey',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  try {
    // Make the GET request using http package
    var response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      // Parse the response
      var responseData = json.decode(response.body);

      // Simulate the classification based on keywords
      var classification = classifyBreaches(responseData);

      return {'pwned': true, 'classification': classification};
    } else {
      // Handle non-200 status codes
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      return {'pwned': false, 'classification': {}};
    }
  } catch (e) {
    // Handle other errors
    print('Error: $e');
    return {'pwned': false, 'classification': {}};
  }
}
