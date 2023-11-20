// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;

class GetSignalData {
  static String url = 'https://greenroad-gr.onrender.com/app/p1';
  static List<dynamic> circles = [];
  static List<dynamic> signals = [];

  static Future<void> getAllCircles() async {
    try {
      final response = await http.get(
        Uri.parse('$url/get-circle'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print(response.body);

        final Map<String, dynamic> circlesResponse = jsonDecode(response.body);
        // print(circlesResponse["circle"]);
        circles = circlesResponse['circle'] as List<dynamic>;
        // print('circles at fetch: $circles');
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> getSignalByCircle(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/get-signal/bycircle'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"circleId": id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print(response.body);

        final Map<String, dynamic> signalsResponse = jsonDecode(response.body);
        // print(signalsResponse["signals"]);
        signals = signalsResponse['signals'] as List<dynamic>;
        // print('signals at fetch: $signals');
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }
}
