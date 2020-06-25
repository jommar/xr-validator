import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xr_approval/components/UermWidgets.dart';
import 'package:xr_approval/models/AuthProvider.dart';
import 'package:xr_approval/models/UrlModel.dart';

class AutoLogin extends StatelessWidget {
  final code;
  AutoLogin({this.code});
  Future<void> _loginUser({BuildContext context, String code}) async {
    await Provider.of<AuthProvider>(context, listen: false)
        .loginUser(code: code);
  }

  @override
  Widget build(BuildContext context) {
    String str = code;
    String params = str.split('?')[1];
    List vals = params.split('&');
    Map parsedParameters = {};
    vals.forEach((param) {
      List splitParams = param.split('=');
      parsedParameters[splitParams[0]] = splitParams[1];
    });

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: _loginUser(context: context, code: parsedParameters['code']),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.waiting:
              case ConnectionState.none:
                return LoadingWidget();
              default:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOGGED IN as: ${parsedParameters['code']}',
                      textAlign: TextAlign.center,
                    ),
                    FlatButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', ModalRoute.withName('/'));
                        // Navigator.of(context).pop();
                        // Navigator.of(context).pushReplacementNamed('/');
                      },
                      icon: Icon(FontAwesomeIcons.home),
                      label: Text('Continue'),
                    )
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
