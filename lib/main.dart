import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme_provider.dart';

// Screens (auth + splash)
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

// Screens (event system)
import 'screens/event_create_screen.dart';
import 'screens/events_list_screen.dart';
import 'screens/event_statistics_screen.dart';
import 'screens/entry_config_screen.dart';

// Navigation structure
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/main_nav_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Eventra',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.openSansTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F1F1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.openSansTextTheme(ThemeData.dark().textTheme),
        primaryColor: Colors.indigo[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/event-statistics') {
          final args = settings.arguments as Map<String, dynamic>;
          final eventId = args['eventId'] as String;
          return MaterialPageRoute(
            builder: (context) => EventStatisticsScreen(eventId: eventId),
          );
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          case '/create-event':
            return MaterialPageRoute(builder: (_) => const EventCreateScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const MainNavWrapper());
          case '/events':
            return MaterialPageRoute(builder: (_) => const EventsListScreen());
          case '/entry-config':
            return MaterialPageRoute(builder: (_) => const EntryConfigScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
        }

        return null;
      },
    );
  }
}
