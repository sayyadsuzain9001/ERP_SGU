import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/shared/firebase_startup_screen.dart';
import 'screens/shared/firebase_sign_in_screen.dart';
import 'theme/app_theme.dart';
import 'navigation/app_shell.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SGUStudentCampusApp());
}

class SGUStudentCampusApp extends StatelessWidget {
  const SGUStudentCampusApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SGU Student Campus',
    theme: AppTheme.theme,
    home: const _FirebaseGate(),
    onGenerateRoute: AppRoutes.onGenerateRoute,
    onUnknownRoute: (settings) => AppRoutes.onGenerateRoute(settings),
  );
}

class _FirebaseGate extends StatefulWidget {
  const _FirebaseGate();

  @override
  State<_FirebaseGate> createState() => _FirebaseGateState();
}

class _FirebaseGateState extends State<_FirebaseGate> {
  Object? _firebaseError;
  bool _firebaseReady = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    setState(() {
      _firebaseReady = false;
      _firebaseError = null;
    });
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      if (mounted) setState(() => _firebaseReady = true);
    } catch (error) {
      if (mounted) setState(() => _firebaseError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_firebaseReady) return const _FirebaseAuthGate();
    if (_firebaseError != null) {
      return FirebaseStartupScreen(
        error: _firebaseError!,
        onRetry: _initializeFirebase,
      );
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}


class _FirebaseAuthGate extends StatelessWidget {
  const _FirebaseAuthGate();

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.data == null) return const FirebaseSignInScreen();
      return const AppShell();
    },
  );
}
