import 'dart:io';

void main() {
  stdout.write('Enter email to check: ');
  var emailToCheck = stdin.readLineSync()!.trim();

  // Simulated test function using the same categorization methods
  var result = checkEmailTest(emailToCheck);

  if (result['pwned']) {
    print("Email '$emailToCheck' has been pwned with the following breaches:");
    print('Critical: ${result['classification']['Critical']}');
    print('High: ${result['classification']['High']}');
    print('Medium: ${result['classification']['Medium']}');
    print('Low: ${result['classification']['Low']}');
  } else {
    print("Email '$emailToCheck' has not been pwned.");
  }
}

Map<String, List> classifyBreaches(List breaches) {
  var classification = {'Critical': [], 'High': [], 'Medium': [], 'Low': []};

  // Keywords for each category
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

  // Add counts to the result
  classification['Critical']!.insert(0, criticalCount);
  classification['High']!.insert(0, highCount);
  classification['Medium']!.insert(0, mediumCount);
  classification['Low']!.insert(0, lowCount);

  return classification;
}

String _getHighestPriorityCategory(List<String> breachDataClasses) {
  var highestPriorityCategory = 'Low';
  var priorityCategories = ['Critical', 'High', 'Medium', 'Low'];

  for (var category in priorityCategories) {
    if (breachDataClasses.any((word) => _isKeywordForCategory(word, category))) {
      highestPriorityCategory = category;
      break;
    }
  }
  return highestPriorityCategory;
}

bool _isKeywordForCategory(String word, String category) {
  // Define keywords for each category
  var categoryKeywords = {
    'Critical': ['social security numbers', 'credit card numbers'],
    'High': ['passwords', 'physical addresses'],
    'Medium': ['phone numbers', 'employment information'],
  };

  return categoryKeywords[category]!.any((keyword) => word.toLowerCase().contains(keyword));
}

bool _containsKeyword(String text, List<String> keywords) {
  return keywords.any((keyword) => text.contains(keyword));
}

// Simulated test function using the same categorization methods
Map<String, dynamic> checkEmailTest(String email) {
  // Simulated data to represent the result of the API call
  var testData = [
    {
      '~:DataClasses': ['Social Security Numbers', 'Credit Card Numbers'],
      '~:Description': 'Breach 1'
    },
    {
      '~:DataClasses': ['Passwords', 'Physical Addresses'],
      '~:Description': 'Breach 2'
    },
    {
      '~:DataClasses': ['Phone Numbers', 'Employment Information'],
      '~:Description': 'Breach 3'
    },
    {
      '~:DataClasses': ['Other Data', 'Miscellaneous'],
      '~:Description': 'Breach 4'
    },
  ];

  // Simulating the classification based on keywords
  var classification = classifyBreaches(testData);

  return {'pwned': true, 'classification': classification};
}
