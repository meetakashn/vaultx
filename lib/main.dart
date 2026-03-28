import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ensure these paths match your folder structure exactly
import 'firebase_options.dart';
import 'services/encryption_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation (Note: This is ignored on Web browsers but good for Mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling for Android/iOS
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: VaultXTheme.bgDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // INITIALIZE FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VaultXApp());
}

class VaultXApp extends StatelessWidget {
  const VaultXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultX',
      debugShowCheckedModeBanner: false,
      // Uses the custom theme we fixed earlier
      theme: VaultXTheme.darkTheme,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listens to the user's login state in real-time
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash while checking if user is logged in
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        // Check if user object exists
        if (snapshot.hasData && snapshot.data != null) {
          // SECURE: Re-init encryption using the unique Firebase UID
          EncryptionService.initialize(snapshot.data!.uid);
          return const HomeScreen();
        }

        // No user found? Send them to Login
        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VaultXTheme.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔐', style: TextStyle(fontSize: 80)),
            SizedBox(height: 24),
            Text(
              'VaultX',
              style: TextStyle(
                color: VaultXTheme.textPrimary,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 60),
            // Uses the accent color from your theme
            CircularProgressIndicator(
              color: VaultXTheme.accent,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}