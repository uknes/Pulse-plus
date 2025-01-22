import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/volume_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/avatar_provider.dart';
import 'screens/article_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedTheme = await ThemeProvider.getInitialTheme();
  runApp(MyApp(initialTheme: savedTheme));
}

class MyApp extends StatelessWidget {
  final bool initialTheme;

  const MyApp({Key? key, required this.initialTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(initialTheme)),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AvatarProvider()),
        ChangeNotifierProvider(create: (context) => VolumeProvider()),
      ],
      child: PulseApp(),
    );
  }
}

class PulseApp extends StatefulWidget {
  @override
  _PulseAppState createState() => _PulseAppState();
}

class _PulseAppState extends State<PulseApp> {
  Locale? _locale;
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedLanguage = prefs.getString('language_code');
      bool? savedTheme = prefs.getBool('dark_mode');
      
      if (savedLanguage != null && savedTheme != null) {
        Provider.of<LanguageProvider>(context, listen: false).updateLanguage(savedLanguage);
        if (savedTheme) {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        }
        setState(() {
          _locale = _getLocaleFromLanguage(savedLanguage);
          _isFirstLaunch = false;
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'French':
        return Locale('fr');
      case 'Arabic':
        return Locale('ar');
      default:
        return Locale('en');
    }
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return MaterialApp(
        navigatorKey: ArticleDetailScreen.navigatorKey,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5EFF8B)),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: ArticleDetailScreen.navigatorKey,
      locale: _locale ?? Locale('en'),
      supportedLocales: [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: themeProvider.isDarkMode 
        ? ThemeData.dark().copyWith(
            primaryColor: Color(0xFF5EFF8B),
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF5EFF8B),
              secondary: Color(0xFF5EFF8B),
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Color(0xFF5EFF8B),
            colorScheme: ColorScheme.light(
              primary: Color(0xFF5EFF8B),
              secondary: Color(0xFF5EFF8B),
            ),
          ),
      home: _isFirstLaunch
        ? SetupScreen(
            onLanguageSelected: (language) {
              _setLocale(_getLocaleFromLanguage(language));
            },
          )
        : HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
