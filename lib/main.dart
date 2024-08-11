import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'displays/cleaning_page.dart';
import 'displays/kitchen_page.dart';
import 'displays/payment%20_page.dart';
import 'displays/waiter_page.dart';
import 'displays/host_page.dart';
import 'firebase_options.dart';
import 'displays/login_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Maasai Food Restaurante",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/host': (context) => const HostPage(),
        '/clean': (context) => const CleaningPage(),
        '/waiter': (context) => const WaiterPage(),
        '/kitchen': (context) => const KitchenPage(),
        '/payment': (context) => const PaymentPage(),
      },
    );
  }
}
