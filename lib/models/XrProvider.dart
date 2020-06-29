import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:xr_approval/models/UrlModel.dart';

class XrProvider with ChangeNotifier {
  final code;
  XrProvider({this.code});
  List _forValidation = [];

  get forValidation {
    return _forValidation;
  }

  Future<void> populateForValidation() async {
    final url = apiUrl(url: 'hospital/xr', params: '&validated=0');
    final response = await http.get(url);
    final responseJson = json.decode(response.body);
    _forValidation = responseJson['radiologyInfo'];
  }

  Future<void> refreshForValidation() async {
    final url = apiUrl(url: 'hospital/xr', params: '&validated=0');
    final response = await http.get(url);
    final responseJson = json.decode(response.body);
    _forValidation = responseJson['radiologyInfo'];
    notifyListeners();
  }

  Future<Map> validateXr({Map form}) async {
    final url = apiUrl(url: 'hospital/xr');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': form['id'],
        'result': form['result'],
        'user': code,
        // 'user': '5272',
      }),
    );

    final responseJson = json.decode(response.body);
    // print(responseJson);

    // return {
    //   'error': true,
    //   'message': 'error',
    // };

    if (responseJson['error']) {
      return {
        'error': true,
        'message': responseJson['message'],
      };
    }

    _forValidation.removeWhere((element) => element['id'] == form['id']);
    notifyListeners();
    return {
      'success': true,
      'message': responseJson['message'],
    };
  }
}
