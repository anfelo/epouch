import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/services.dart';
import 'screens/screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Finances>.value(
            value: Global.financesRef.documentStream),
        StreamProvider<List<Organization>>.value(
            value: Global.orgsRef.streamData()),
        StreamProvider<FirebaseUser>.value(value: AuthService().user),
        FutureProvider<List<CashflowCategory>>.value(
            value: Global.cashflowCatRef.getData())
      ],
      child: MaterialApp(
        // Firebase Analytics
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: Global.analytics)
        ],
        // Named Routes
        routes: {
          '/': (context) => LoginScreen(),
          '/accounts': (context) => AccountsScreen(),
          '/organizations': (context) => OrganizationsScreen(),
          '/profile': (context) => ProfileScreen(),
          '/about': (context) => AboutScreen(),
        },
        title: Global.title,
        theme: ThemeData(
          fontFamily: 'Nunito',
          bottomAppBarTheme: BottomAppBarTheme(
            color: Colors.black87,
          ),
          brightness: Brightness.dark,
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 18),
            body2: TextStyle(fontSize: 16),
            button: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
            headline: TextStyle(fontWeight: FontWeight.bold),
            subhead: TextStyle(color: Colors.grey),
          ),
          buttonTheme: ButtonThemeData(),
          primaryColor: Color.fromRGBO(17, 153, 142, 1),
          cardColor: Color.fromRGBO(53, 222, 117, 1),
        ),
      ),
    );
  }
}
