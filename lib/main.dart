import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_audio_coach/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Ошибка виджета:\n${details.exceptionAsString()}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  runZonedGuarded(() async {
    var firebaseReady = true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        Firebase.app();
      }
    } catch (e, st) {
      debugPrint('Firebase init failed: $e\n$st');
      firebaseReady = false;
    }

    runApp(MyApp(firebaseReady: firebaseReady));
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Ошибка запуска: $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AuthGate(firebaseReady: firebaseReady),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return const FirebaseSetupRequiredScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return HomeScreen(user: snapshot.data!);
        }

        return const SignInScreen();
      },
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;
  String? _error;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.query_stats_rounded,
      title: 'SMART TRACKING',
      description:
          'Effortlessly log and monitor your business\n'
          'metrics, costs, and revenues on the go.\n'
          'Stay ahead with real-time insights.',
    ),
    _OnboardingSlide(
      icon: Icons.tips_and_updates_rounded,
      title: 'ACTIONABLE TIPS',
      description:
          'Get practical recommendations based on\n'
          'your activity and habits to improve daily\n'
          'performance and focus.',
    ),
    _OnboardingSlide(
      icon: Icons.flag_circle_rounded,
      title: 'GOAL PROGRESS',
      description:
          'Set clear goals and watch your momentum\n'
          'grow with simple milestones and progress\n'
          'visibility in one place.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await action();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _googleSignIn() async {
    await _run(() async {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
        return;
      }

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    });
  }

  bool get _supportsAppleSignIn {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> _appleSignIn() async {
    await _run(() async {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.radio_button_checked,
                      size: 62, color: Colors.black),
                  const SizedBox(height: 6),
                  Text(
                    'AVTAN',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _AuthActionButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'LOG IN WITH GOOGLE',
                    onTap: _loading ? null : _googleSignIn,
                  ),
                  const SizedBox(height: 10),
                  _AuthActionButton(
                    icon: Icons.facebook_rounded,
                    label: 'LOG IN WITH FACEBOOK',
                    onTap:
                        _loading ? null : () => _showComingSoon('Facebook login'),
                  ),
                  const SizedBox(height: 10),
                  _AuthActionButton(
                    icon: Icons.phone_android_rounded,
                    label: 'LOG IN WITH PHONE',
                    onTap: _loading ? null : () => _showComingSoon('Phone login'),
                  ),
                  if (_supportsAppleSignIn) ...[
                    const SizedBox(height: 10),
                    _AuthActionButton(
                      icon: Icons.apple,
                      label: 'LOG IN WITH APPLE',
                      onTap: _loading ? null : _appleSignIn,
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: _slides.length,
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(slide.icon, size: 88, color: Colors.black),
                            const SizedBox(height: 12),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                          child: _PagerDot(active: _currentPage == index),
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String source) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$source: Продолжение следует...'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard (Авторизован)'),
        actions: [
          TextButton(
            onPressed: () async => FirebaseAuth.instance.signOut(),
            child: const Text('Выйти'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 54),
            const SizedBox(height: 12),
            Text(
              'Вы вошли как: ${user.email ?? user.uid}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Здесь будет бизнес-логика приложения для авторизованных пользователей.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthActionButton extends StatelessWidget {
  const _AuthActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.35),
          side: const BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black, size: 30),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _PagerDot extends StatelessWidget {
  const _PagerDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.black : Colors.transparent,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class FirebaseSetupRequiredScreen extends StatelessWidget {
  const FirebaseSetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase не настроен')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Подключите Firebase к проекту через FlutterFire CLI, '
            'добавьте конфиги платформ и перезапустите приложение.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
