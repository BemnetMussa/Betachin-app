import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // We’ll create this
import 'signup_page.dart'; // We’ll create this
import 'home_page.dart'; // We’ll create this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:
        'https://qjadmavgzuzrpyjmrjec.supabase.coL', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYWRtYXZnenV6cnB5am1yamVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NjE2ODIsImV4cCI6MjA1OTIzNzY4Mn0.2xljHdHALzz5KWbf_g5z4Ut4BgrevvMsFwJbyvppn-o', // Replace with your anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betachin App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute:
          Supabase.instance.client.auth.currentSession != null
              ? '/home'
              : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
