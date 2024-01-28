import 'dart:convert';
import 'package:http/http.dart' as http;

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
      print('Data from API: $data'); // Print the data for inspection

      // Extract breaches for printing
      var breaches = data.map((breach) => breach['Name']).toList();

      return {'pwned': true, 'breaches': breaches};
    } else if (response.statusCode == 404) {
      return {'pwned': false, 'breaches': []};
    } else {
      throw Exception('Error checking email: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error checking email: $error');
    return {'pwned': false, 'breaches': []};
  }
}

void main() async {
  var userEmail = 'janetzulu599@gmail.com'; // Replace with the desired email
  var result = await checkEmail(userEmail);

  if (result['pwned']) {
    print("Email '$userEmail' has been pwned with the following breaches:");
    print('Breaches: ${result['breaches']}'.length);
  } else {
    print("Email '$userEmail' has not been pwned.");
  }
}
