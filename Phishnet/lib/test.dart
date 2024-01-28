import 'dart:convert';
import 'package:http/http.dart' as http;

Map<String, List<String>> classifyBreaches(List<dynamic> breaches) {
  var classification = {'Critical': [], 'High': [], 'Medium': [], 'Low': []};

  for (var breach in breaches) {
    if (breach['dataClasses'] != null && breach['dataClasses'] is List) {
      var dataClasses = List<String>.from(breach['dataClasses']);
      for (var dataClass in dataClasses) {
        var category = _getHighestPriorityCategory(dataClass);
        classification[category]!.add(breach['description'].toString());
      }
    }
  }

  return classification.map((key, value) => MapEntry(key, List<String>.from(value)));
}

String _getHighestPriorityCategory(String breach) {
  var priorityCategories = ['Critical', 'High', 'Medium', 'Low'];

  for (var category in priorityCategories) {
    if (_isKeywordForCategory(breach, category)) {
      return category;
    }
  }

  return 'Low'; // Default to 'Low' if no match is found
}

bool _isKeywordForCategory(String breach, String category) {
  var categoryKeywords = {
    'Critical': ['social security numbers', 'credit card numbers'],
    'High': ['passwords', 'physical addresses'],
    'Medium': ['phone numbers', 'employment information'],
  };

  return categoryKeywords[category]!.any((keyword) => breach.contains(keyword));
}

Future<Map<String, dynamic>> checkEmail(String email) async {
  const apiKey = '1c79345799354f0c9dc49fe20df74c50';

  try {
    var response = await http.get(
      Uri.parse('https://haveibeenpwned.com/api/v3/breachedaccount/${Uri.encodeComponent(email)}'),
      headers: {
        'hibp-api-key': apiKey,
        'User-Agent': 'Dart/2.10 (dart:io)',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var classification = classifyBreaches(data);
      return {'pwned': true, 'classification': classification};
    } else if (response.statusCode == 404) {
      return {'pwned': false, 'classification': {}};
    } else {
      throw Exception('Error checking email: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error checking email: $error');
    return {'pwned': false, 'classification': {}};
  }
}

void main() async {
  var userEmail = 'nzulu11@gmail.com'; // Replace with the desired email
  var result = await checkEmail(userEmail);

  if (result['pwned']) {
    print("Email '$userEmail' has been pwned with the following breaches:");
    print('Critical: ${result['classification']['Critical'].length} ${result['classification']['Critical']}');
    print('High: ${result['classification']['High'].length} ${result['classification']['High']}');
    print('Medium: ${result['classification']['Medium'].length} ${result['classification']['Medium']}');
    print('Low: ${result['classification']['Low'].length} ${result['classification']['Low']}');
  } else {
    print("Email '$userEmail' has not been pwned.");
  }
}
