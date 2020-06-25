import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:xr_approval/models/UrlModel.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _code;

  get isLoggedIn {
    return _isLoggedIn;
  }

  get code {
    return _code;
  }

  Future<void> loginUser({String code}) async {
    final url = apiUrl(url: 'auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': code}),
    );

    final responseJson = json.decode(response.body);
    _code = responseJson['user']['username'];
    _isLoggedIn = true;
    notifyListeners();
  }
}
