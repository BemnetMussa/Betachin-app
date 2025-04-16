import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Make main async to wait for Supabase initialization
Future<void> main() async {
  // Ensure Flutter is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase before the app starts
    await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
    // Run app after successful initialization
    runApp(const MyApp());
  } catch (e) {
    // If initialization fails, show error app
    runApp(const SupabaseErrorApp());
  }
}

// Error app to show when Supabase initialization fails
class SupabaseErrorApp extends StatelessWidget {
  const SupabaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize Supabase. Please check your URL and anon key.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check current session
    final session = Supabase.instance.client.auth.currentSession;
    final hasSession = session != null;

    return MaterialApp(
      title: 'Betachin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: hasSession ? '/home' : '/signup',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) =>  HomePage(),
      },
    );
  }
}
