import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GetSignalCircle {
  static String url = 'https://greenroad-gr.onrender.com/app/p1';

  static Future<dynamic> getCirclesByLocation(double? lat, double? lng) async {
    try {
      final response = await http.post(
        Uri.parse('$url/get-circle/bycoordinates'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"maxDistance": 0.9, "lat": lat, "lon": lng}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> circlesResponse = jsonDecode(response.body);
        // print(circlesResponse['circles']);
        return circlesResponse['circles'];
      } else {
        // print(response.statusCode);
        // print(response.body);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<dynamic> getSignalsByLocation(double? lat, double? lng) async {
    try {
      final response = await http.post(
        Uri.parse('$url/get-signal/bycoordinates'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"maxDistance": 0.9, "lat": lat, "lon": lng}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> circlesResponse = jsonDecode(response.body);
        // print(response);
        return circlesResponse['signals'];
      } else {
        // print(response.statusCode);
        // print(response.body);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<dynamic> getSignalsByCircle(int circleId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/get-signal/byCircle'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"circleId": circleId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> circlesResponse = jsonDecode(response.body);
        // print(response);
        return circlesResponse['signals'];
      } else {
        // print(response.statusCode);
        // print(response.body);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<dynamic> getSignalsById(int signalId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/get-signal/byId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"signalId": signalId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> circlesResponse = jsonDecode(response.body);
        // print(response);
        return circlesResponse['signal'];
      } else {
        // print(response.statusCode);
        // print(response.body);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}
