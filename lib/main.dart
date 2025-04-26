import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_page.dart';
import 'screens/add_property.dart';
import 'screens/property_detail.dart';
import 'screens/edit_property_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../models/property_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qjadmavgzuzrpyjmrjec.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYWRtYXZnenV6cnB5am1yamVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NjE2ODIsImV4cCI6MjA1OTIzNzY4Mn0.2xljHdHALzz5KWbf_g5z4Ut4BgrevvMsFwJbyvppn-o',
  );

  runApp(const MyApp());
}

class AuthWidgetBuilder extends StatelessWidget {
  final Widget Function(BuildContext, AuthState) builder;
  const AuthWidgetBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final state = snapshot.data;
        if (state == null) {
          return const LoginPage(); // Fallback if no auth state
        }

        return builder(context, state);
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignupPage(),
        '/home': (context) => const HomePage(), // Add explicit /home route
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/add_property': (context) => const AddPropertyPage(),
        '/property_detail': (context) {
          final propertyId = ModalRoute.of(context)!.settings.arguments as int;
          return PropertyDetailPage(propertyId: propertyId);
        },
        '/edit_property': (context) {
          final property =
              ModalRoute.of(context)!.settings.arguments as PropertyModel;
          return EditPropertyPage(property: property);
        },
      },
      builder: (context, child) {
        return AuthWidgetBuilder(
          builder: (context, state) {
            if (state.session == null) {
              return const LoginPage();
            }
            return child!;
          },
        );
      },
    );
  }
}
