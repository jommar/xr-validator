import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xr_approval/screen/AutoLogin.dart';
import 'package:xr_approval/screen/index/IndexScreen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) {
          return IndexScreen();
        });
      // case '/autoLogin':
      //   return MaterialPageRoute(builder: (_) {
      //     return AutoLogin();
      //   });
      default:
        if (settings.name.contains('/autoLogin') &&
            settings.name.contains('code')) {
          return MaterialPageRoute(builder: (_) {
            return AutoLogin(
              code: settings.name,
            );
          });
        }
        return MaterialPageRoute(builder: (_) {
          return Error404Screen();
        });
    }
  }
}

class Error404Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '404 Page not found!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(
            height: 20,
          ),
          FlatButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            icon: Icon(FontAwesomeIcons.home),
            label: Text('Home'),
          )
        ],
      ),
    );
  }
}
