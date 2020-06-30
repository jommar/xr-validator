import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xr_approval/RouteGenerator.dart';
import 'package:xr_approval/models/AuthProvider.dart';
import 'package:xr_approval/models/ValidatorProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ValidatorProvider>(
          create: (context) => ValidatorProvider(),
          update: (_, auth, prev) => ValidatorProvider(code: auth.code),
        ),
      ],
      child: MaterialApp(
        title: 'Result Validator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.blue[50],
          appBarTheme: AppBarTheme(
            color: Colors.blue[700],
          ),
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.blue, textTheme: ButtonTextTheme.primary),
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        // onGenerateRoute: (settings) {
        //   // String url = settings.name;
        //   // url.split("asd");
        //   // print(Uri.base.queryParameters['code']);
        //   return MaterialPageRoute(builder: (context) {
        //     return AutoLogin();
        //   });
        // },
        // routes: {
        //   '/': (_) => Router(screen: IndexScreen()),
        //   '/autoLogin': (_) => AutoLogin(),
        // },
      ),
    );
  }
}

// class Router extends StatelessWidget {
//   final Widget screen;
//   Router({this.screen});

//   @override
//   Widget build(BuildContext context) {
//     Provider.of<AuthProvider>(context).loginUser(code: '5272');
//     return screen;
//   }
// }
