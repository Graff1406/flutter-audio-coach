import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_audio_coach/firebase_options.dart';
import 'package:flutter_audio_coach/revenuecat_config.dart';
import 'package:flutter_audio_coach/subscription_service.dart';

enum AppLanguage { en, ru }

class LanguageController extends ChangeNotifier {
  static const _storageKey = 'app_language';

  AppLanguage _language = AppLanguage.en;

  AppLanguage get language => _language;

  AppStrings get strings => AppStrings(_language);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    _language = code == AppLanguage.ru.name ? AppLanguage.ru : AppLanguage.en;
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) {
      return;
    }

    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, language.name);
  }
}

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get _ru => language == AppLanguage.ru;

  String get appTitle => 'Flutter Audio Coach';
  String get googleLogin => _ru
      ? '\u0412\u041e\u0419\u0422\u0418 \u0427\u0415\u0420\u0415\u0417 GOOGLE'
      : 'LOG IN WITH GOOGLE';
  String get appleLogin => _ru
      ? '\u0412\u041e\u0419\u0422\u0418 \u0427\u0415\u0420\u0415\u0417 APPLE'
      : 'LOG IN WITH APPLE';
  String get phoneLogin => _ru
      ? '\u0412\u041e\u0419\u0422\u0418 \u041f\u041e \u0422\u0415\u041b\u0415\u0424\u041e\u041d\u0423'
      : 'LOG IN WITH PHONE';
  String get facebookLogin => _ru
      ? '\u0412\u041e\u0419\u0422\u0418 \u0427\u0415\u0420\u0415\u0417 FACEBOOK'
      : 'LOG IN WITH FACEBOOK';
  String get twitterLogin => _ru
      ? '\u0412\u041e\u0419\u0422\u0418 \u0427\u0415\u0420\u0415\u0417 TWITTER'
      : 'LOG IN WITH TWITTER';
  String get otherSignInOptions => _ru
      ? '\u0414\u0420\u0423\u0413\u0418\u0415 \u0421\u041f\u041e\u0421\u041e\u0411\u042b \u0412\u0425\u041e\u0414\u0410'
      : 'OTHER SIGN-IN OPTIONS';
  String get comingSoon => _ru
      ? '\u0421\u043a\u043e\u0440\u043e \u0431\u0443\u0434\u0435\u0442 \u0434\u043e\u0441\u0442\u0443\u043f\u043d\u043e'
      : 'Coming soon';
  String get dashboardTitle => _ru
      ? '\u041f\u0430\u043d\u0435\u043b\u044c \u0443\u043f\u0440\u0430\u0432\u043b\u0435\u043d\u0438\u044f'
      : 'Dashboard';
  String get premiumTitle => _ru ? 'Premium' : 'Premium';
  String get premiumActive => _ru
      ? '\u041f\u043e\u0434\u043f\u0438\u0441\u043a\u0430 \u0430\u043a\u0442\u0438\u0432\u043d\u0430'
      : 'Subscription active';
  String get premiumInactive => _ru
      ? '\u041f\u043e\u0434\u043f\u0438\u0441\u043a\u0430 \u043d\u0435 \u0430\u043a\u0442\u0438\u0432\u043d\u0430'
      : 'Subscription inactive';
  String get openPremium => _ru
      ? '\u041e\u0442\u043a\u0440\u044b\u0442\u044c Premium'
      : 'Open Premium';
  String get restorePurchases => _ru
      ? '\u0412\u043e\u0441\u0441\u0442\u0430\u043d\u043e\u0432\u0438\u0442\u044c \u043f\u043e\u043a\u0443\u043f\u043a\u0438'
      : 'Restore purchases';
  String get revenueCatUnavailable => _ru
      ? 'RevenueCat \u0434\u043e\u0441\u0442\u0443\u043f\u0435\u043d \u043d\u0430 Android/iOS'
      : 'RevenueCat is available on Android/iOS';
  String get signOut => _ru ? '\u0412\u044b\u0439\u0442\u0438' : 'Sign out';
  String signedInAs(String identity) => _ru
      ? '\u0412\u044b \u0432\u043e\u0448\u043b\u0438 \u043a\u0430\u043a: $identity'
      : 'Signed in as: $identity';
  String get dashboardPlaceholder => _ru
      ? '\u0417\u0434\u0435\u0441\u044c \u0431\u0443\u0434\u0435\u0442 \u043e\u0441\u043d\u043e\u0432\u043d\u0430\u044f \u043b\u043e\u0433\u0438\u043a\u0430 \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u044f \u0434\u043b\u044f \u0430\u0432\u0442\u043e\u0440\u0438\u0437\u043e\u0432\u0430\u043d\u043d\u044b\u0445 \u043f\u043e\u043b\u044c\u0437\u043e\u0432\u0430\u0442\u0435\u043b\u0435\u0439.'
      : 'The main app experience for signed-in users will be here.';
  String get firebaseSetupTitle => _ru
      ? 'Firebase \u043d\u0435 \u043d\u0430\u0441\u0442\u0440\u043e\u0435\u043d'
      : 'Firebase is not configured';
  String get firebaseSetupMessage => _ru
      ? '\u041f\u043e\u0434\u043a\u043b\u044e\u0447\u0438\u0442\u0435 Firebase \u043a \u043f\u0440\u043e\u0435\u043a\u0442\u0443 \u0447\u0435\u0440\u0435\u0437 FlutterFire CLI, \u0434\u043e\u0431\u0430\u0432\u044c\u0442\u0435 \u043a\u043e\u043d\u0444\u0438\u0433\u0438 \u043f\u043b\u0430\u0442\u0444\u043e\u0440\u043c \u0438 \u043f\u0435\u0440\u0435\u0437\u0430\u043f\u0443\u0441\u0442\u0438\u0442\u0435 \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u0435.'
      : 'Connect Firebase with FlutterFire CLI, add platform configuration files, and restart the app.';
  String get widgetError => _ru
      ? '\u041e\u0448\u0438\u0431\u043a\u0430 \u0432\u0438\u0434\u0436\u0435\u0442\u0430'
      : 'Widget error';
  String get startupError => _ru
      ? '\u041e\u0448\u0438\u0431\u043a\u0430 \u0437\u0430\u043f\u0443\u0441\u043a\u0430'
      : 'Startup error';

  String get smartTrackingTitle => _ru
      ? '\u0423\u041c\u041d\u041e\u0415 \u041e\u0422\u0421\u041b\u0415\u0416\u0418\u0412\u0410\u041d\u0418\u0415'
      : 'SMART TRACKING';
  String get smartTrackingDescription => _ru
      ? '\u041b\u0435\u0433\u043a\u043e \u0444\u0438\u043a\u0441\u0438\u0440\u0443\u0439\u0442\u0435 \u0438 \u043e\u0442\u0441\u043b\u0435\u0436\u0438\u0432\u0430\u0439\u0442\u0435\n\u043c\u0435\u0442\u0440\u0438\u043a\u0438, \u0440\u0430\u0441\u0445\u043e\u0434\u044b \u0438 \u0434\u043e\u0445\u043e\u0434\u044b.\n\u0414\u0435\u0440\u0436\u0438\u0442\u0435 \u0444\u043e\u043a\u0443\u0441 \u043d\u0430 \u0433\u043b\u0430\u0432\u043d\u043e\u043c.'
      : 'Effortlessly log and monitor your business\nmetrics, costs, and revenues on the go.\nStay ahead with real-time insights.';
  String get actionableTipsTitle => _ru
      ? '\u041f\u0420\u0410\u041a\u0422\u0418\u0427\u041d\u042b\u0415 \u0421\u041e\u0412\u0415\u0422\u042b'
      : 'ACTIONABLE TIPS';
  String get actionableTipsDescription => _ru
      ? '\u041f\u043e\u043b\u0443\u0447\u0430\u0439\u0442\u0435 \u043f\u043e\u043b\u0435\u0437\u043d\u044b\u0435 \u0440\u0435\u043a\u043e\u043c\u0435\u043d\u0434\u0430\u0446\u0438\u0438\n\u043f\u043e \u0430\u043a\u0442\u0438\u0432\u043d\u043e\u0441\u0442\u0438 \u0438 \u043f\u0440\u0438\u0432\u044b\u0447\u043a\u0430\u043c,\n\u0447\u0442\u043e\u0431\u044b \u0440\u0430\u0431\u043e\u0442\u0430\u0442\u044c \u0441\u0442\u0430\u0431\u0438\u043b\u044c\u043d\u0435\u0435.'
      : 'Get practical recommendations based on\nyour activity and habits to improve daily\nperformance and focus.';
  String get goalProgressTitle => _ru
      ? '\u041f\u0420\u041e\u0413\u0420\u0415\u0421\u0421 \u0426\u0415\u041b\u0415\u0419'
      : 'GOAL PROGRESS';
  String get goalProgressDescription => _ru
      ? '\u0421\u0442\u0430\u0432\u044c\u0442\u0435 \u043f\u043e\u043d\u044f\u0442\u043d\u044b\u0435 \u0446\u0435\u043b\u0438 \u0438 \u0441\u043b\u0435\u0434\u0438\u0442\u0435,\n\u043a\u0430\u043a \u0440\u0430\u0441\u0442\u0435\u0442 \u0432\u0430\u0448 \u043f\u0440\u043e\u0433\u0440\u0435\u0441\u0441\n\u0447\u0435\u0440\u0435\u0437 \u043f\u0440\u043e\u0441\u0442\u044b\u0435 \u044d\u0442\u0430\u043f\u044b.'
      : 'Set clear goals and watch your momentum\ngrow with simple milestones and progress\nvisibility in one place.';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageController = LanguageController();
  final subscriptionService = SubscriptionService();
  await languageController.load();
  await subscriptionService.configure();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${languageController.strings.widgetError}:\n'
            '${details.exceptionAsString()}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  runZonedGuarded(
    () async {
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

      runApp(
        MyApp(
          firebaseReady: firebaseReady,
          languageController: languageController,
          subscriptionService: subscriptionService,
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught zone error: $error\n$stack');
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${languageController.strings.startupError}: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.firebaseReady,
    required this.languageController,
    required this.subscriptionService,
  });

  final bool firebaseReady;
  final LanguageController languageController;
  final SubscriptionService subscriptionService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: languageController,
      builder: (context, _) {
        return MaterialApp(
          title: languageController.strings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: AuthGate(
            firebaseReady: firebaseReady,
            languageController: languageController,
            subscriptionService: subscriptionService,
          ),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.firebaseReady,
    required this.languageController,
    required this.subscriptionService,
  });

  final bool firebaseReady;
  final LanguageController languageController;
  final SubscriptionService subscriptionService;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return FirebaseSetupRequiredScreen(
        languageController: languageController,
      );
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
          unawaited(subscriptionService.identify(snapshot.data!.uid));
          return HomeScreen(
            user: snapshot.data!,
            languageController: languageController,
            subscriptionService: subscriptionService,
          );
        }

        return SignInScreen(languageController: languageController);
      },
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher({required this.controller});

  final LanguageController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<AppLanguage>(
        value: controller.language,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(12),
        dropdownColor: const Color(0xFFE6E6E6),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
        selectedItemBuilder: (context) {
          return const [
            Align(alignment: Alignment.centerRight, child: Text('EN')),
            Align(alignment: Alignment.centerRight, child: Text('RU')),
          ];
        },
        items: const [
          DropdownMenuItem(value: AppLanguage.en, child: Text('English')),
          DropdownMenuItem(value: AppLanguage.ru, child: Text('Russian')),
        ],
        onChanged: (language) {
          if (language != null) {
            controller.setLanguage(language);
          }
        },
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.languageController});

  final LanguageController languageController;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;
  bool _showOtherSignInMethods = false;
  String? _error;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingSlide> _slides(AppStrings strings) {
    return [
      _OnboardingSlide(
        icon: Icons.query_stats_rounded,
        title: strings.smartTrackingTitle,
        description: strings.smartTrackingDescription,
      ),
      _OnboardingSlide(
        icon: Icons.tips_and_updates_rounded,
        title: strings.actionableTipsTitle,
        description: strings.actionableTipsDescription,
      ),
      _OnboardingSlide(
        icon: Icons.flag_circle_rounded,
        title: strings.goalProgressTitle,
        description: strings.goalProgressDescription,
      ),
    ];
  }

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

  bool get _isAppleDevice {
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
    final strings = widget.languageController.strings;
    final slides = _slides(strings);
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 16,
              child: _LanguageSwitcher(controller: widget.languageController),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 54,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.radio_button_checked,
                        size: 62,
                        color: Colors.black,
                      ),
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
                      ..._buildAuthActions(strings),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemCount: slides.length,
                          itemBuilder: (context, index) {
                            final slide = slides[index];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(slide.icon, size: 88, color: Colors.black),
                                const SizedBox(height: 12),
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
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
                          slides.length,
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
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String source) {
    final strings = widget.languageController.strings;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$source: ${strings.comingSoon}')));
  }

  List<Widget> _buildAuthActions(AppStrings strings) {
    final primaryActions = _isAppleDevice
        ? <_SignInAction>[
            _SignInAction(
              icon: Icons.apple,
              label: strings.appleLogin,
              onTap: _appleSignIn,
            ),
            _phoneAction(strings),
          ]
        : <_SignInAction>[
            _SignInAction(
              icon: Icons.g_mobiledata_rounded,
              label: strings.googleLogin,
              onTap: _googleSignIn,
            ),
            _phoneAction(strings),
          ];

    final otherActions = _isAppleDevice
        ? <_SignInAction>[
            _SignInAction(
              icon: Icons.g_mobiledata_rounded,
              label: strings.googleLogin,
              onTap: _googleSignIn,
            ),
            _facebookAction(strings),
            _twitterAction(strings),
          ]
        : <_SignInAction>[
            _appleAction(strings),
            _facebookAction(strings),
            _twitterAction(strings),
          ];

    return [
      for (final action in primaryActions) ...[
        _AuthActionButton(
          icon: action.icon,
          label: action.label,
          onTap: _loading ? null : action.onTap,
        ),
        const SizedBox(height: 10),
      ],
      _OtherSignInMethods(
        label: strings.otherSignInOptions,
        expanded: _showOtherSignInMethods,
        onToggle: _loading
            ? null
            : () {
                setState(() {
                  _showOtherSignInMethods = !_showOtherSignInMethods;
                });
              },
        actions: otherActions
            .map(
              (action) => _AuthActionButton(
                icon: action.icon,
                label: action.label,
                onTap: _loading ? null : action.onTap,
              ),
            )
            .toList(),
      ),
    ];
  }

  _SignInAction _phoneAction(AppStrings strings) {
    return _SignInAction(
      icon: Icons.phone_android_rounded,
      label: strings.phoneLogin,
      onTap: () => _showComingSoon(strings.phoneLogin),
    );
  }

  _SignInAction _appleAction(AppStrings strings) {
    return _SignInAction(
      icon: Icons.apple,
      label: strings.appleLogin,
      onTap: _supportsAppleSignIn
          ? _appleSignIn
          : () => _showComingSoon(strings.appleLogin),
    );
  }

  _SignInAction _facebookAction(AppStrings strings) {
    return _SignInAction(
      icon: Icons.facebook_rounded,
      label: strings.facebookLogin,
      onTap: () => _showComingSoon(strings.facebookLogin),
    );
  }

  _SignInAction _twitterAction(AppStrings strings) {
    return _SignInAction(
      icon: Icons.alternate_email_rounded,
      label: strings.twitterLogin,
      onTap: () => _showComingSoon(strings.twitterLogin),
    );
  }
}

class _SignInAction {
  const _SignInAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _OtherSignInMethods extends StatelessWidget {
  const _OtherSignInMethods({
    required this.label,
    required this.expanded,
    required this.onToggle,
    required this.actions,
  });

  final String label;
  final bool expanded;
  final VoidCallback? onToggle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final color = onToggle == null ? Colors.black38 : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onToggle,
          icon: Icon(
            expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 26,
          ),
          label: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 2),
              for (final action in actions) ...[
                action,
                const SizedBox(height: 10),
              ],
            ],
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeOut,
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.languageController,
    required this.subscriptionService,
  });

  final User user;
  final LanguageController languageController;
  final SubscriptionService subscriptionService;

  @override
  Widget build(BuildContext context) {
    final strings = languageController.strings;
    final identity = user.email ?? user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.dashboardTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _LanguageSwitcher(controller: languageController),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              await subscriptionService.reset();
              await FirebaseAuth.instance.signOut();
            },
            child: Text(strings.signOut),
          ),
        ],
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: subscriptionService,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    subscriptionService.premium
                        ? Icons.workspace_premium_rounded
                        : Icons.verified_user,
                    size: 54,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.signedInAs(identity),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.dashboardPlaceholder,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _PremiumPanel(
                    strings: strings,
                    subscriptionService: subscriptionService,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumPanel extends StatelessWidget {
  const _PremiumPanel({
    required this.strings,
    required this.subscriptionService,
  });

  final AppStrings strings;
  final SubscriptionService subscriptionService;

  @override
  Widget build(BuildContext context) {
    final canUseRevenueCat = subscriptionService.configured;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.premiumTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subscriptionService.premium
                    ? strings.premiumActive
                    : strings.premiumInactive,
              ),
              if (subscriptionService.lastError != null) ...[
                const SizedBox(height: 8),
                Text(
                  subscriptionService.lastError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: canUseRevenueCat
                    ? () async {
                        await RevenueCatUI.presentPaywallIfNeeded(
                          RevenueCatConfig.entitlementId,
                        );
                        await subscriptionService.refresh();
                      }
                    : null,
                child: Text(
                  canUseRevenueCat
                      ? strings.openPremium
                      : strings.revenueCatUnavailable,
                ),
              ),
              TextButton(
                onPressed: canUseRevenueCat
                    ? () async {
                        await subscriptionService.restorePurchases();
                      }
                    : null,
                child: Text(strings.restorePurchases),
              ),
            ],
          ),
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
  const FirebaseSetupRequiredScreen({
    super.key,
    required this.languageController,
  });

  final LanguageController languageController;

  @override
  Widget build(BuildContext context) {
    final strings = languageController.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.firebaseSetupTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _LanguageSwitcher(controller: languageController),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            strings.firebaseSetupMessage,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
