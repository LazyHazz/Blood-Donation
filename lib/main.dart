import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/donor_home.dart';
import 'screens/admin_home.dart';
import 'screens/user_home.dart';
import 'screens/splash_screen.dart';
import 'screens/blood_request_screen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: appRoutes,
      onGenerateRoute: generateRoute,
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Failed to initialize Firebase. Please try again later.'),
        ),
      ),
    );
  }
}

final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(), // Reference LoginScreen class
  '/register': (context) => RegisterScreen(),
  '/home': (context) => const UserHomeScreen(),
  '/donorHome': (context) => DonorHomeScreen(),
  '/adminHome': (context) => AdminHomeScreen(),
};

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/newRequest':
      final bloodGroup = settings.arguments as String?;
      if (bloodGroup == null) {
        return MaterialPageRoute(
          builder: (context) => const ErrorScreen(message: 'Invalid arguments for /newRequest'),
        );
      }
      return MaterialPageRoute(
        builder: (context) => BloodRequestScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}