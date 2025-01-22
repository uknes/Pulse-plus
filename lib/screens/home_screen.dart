import 'package:flutter/material.dart';
import 'package:pulse_plus/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/avatar_provider.dart';
import 'package:pulse_plus/screens/article_screen.dart';
import 'emergency_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final avatarProvider = Provider.of<AvatarProvider>(context);
    final selectedLanguage = languageProvider.selectedLanguage;

    final translations = {
      'English': {
        'articlesText': 'Articles',
        'emergencyText': 'Emergency',
        'appBarTitle': 'Home',
      },
      'French': {
        'articlesText': 'Articles',
        'emergencyText': 'Urgence',
        'appBarTitle': 'Accueil',
      },
      'Arabic': {
        'articlesText': 'مقالات',
        'emergencyText': 'حالة طوارئ',
        'appBarTitle': 'الرئيسية',
      },
    };

    final currentTranslations = translations[selectedLanguage] ?? translations['English']!;

    return Directionality(
      textDirection: selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          title: Text(
            currentTranslations['appBarTitle']!,
            style: TextStyle(
              fontFamily: 'Nexa',
              color: Color(0xFF5EFF8B),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Color(0xFF5EFF8B),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ArticleScreen()),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Color(0xFF5EFF8B),
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset(
                                    'assets/images/article_icon.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  currentTranslations['articlesText']!,
                                  style: TextStyle(
                                    fontFamily: 'Nexa',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5EFF8B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.lerp(Color(0xFF5EFF8B), Colors.red.shade900, _animation.value)!,
                              Color.lerp(Colors.red.shade900, Color(0xFF5EFF8B), _animation.value)!
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: selectedLanguage == 'Arabic' ? Radius.circular(0) : Radius.circular(30),
                            bottomLeft: selectedLanguage == 'Arabic' ? Radius.circular(0) : Radius.circular(30),
                            topRight: selectedLanguage == 'Arabic' ? Radius.circular(30) : Radius.circular(0),
                            bottomRight: selectedLanguage == 'Arabic' ? Radius.circular(30) : Radius.circular(0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EmergencyScreen()),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/emergency_icon.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text(
                                    currentTranslations['emergencyText']!,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: selectedLanguage == 'Arabic' ? null : 20,
              right: selectedLanguage == 'Arabic' ? 20 : null,
              child: Image.asset(avatarProvider.selectedAvatar, width: 100, height: 100),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
