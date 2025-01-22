import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/avatar_provider.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatefulWidget {
  final Function(String) onLanguageSelected;

  SetupScreen({required this.onLanguageSelected});

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _waveController;
  String selectedLanguage = 'English';
  int selectedAvatarIndex = 0;
  bool isDarkMode = false;
  late PageController _pageController;
  bool _isLastPage = false;

  final List<Map<String, String>> languages = [
    {
      'name': 'English',
      'native': 'English',
      'flag': 'assets/flags/english_flag.png',
      'preview': 'assets/previews/english_preview.png'
    },
    {
      'name': 'French',
      'native': 'Français',
      'flag': 'assets/flags/french_flag.png',
      'preview': 'assets/previews/french_preview.png'
    },
    {
      'name': 'Arabic',
      'native': 'العربية',
      'flag': 'assets/flags/arabic_flag.png',
      'preview': 'assets/previews/arabic_preview.png'
    },
  ];

  final Map<String, Map<String, String>> translations = {
    'English': {
      'chooseTheme': 'Choose Your Theme',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'chooseGuide': 'Choose Your Guide',
      'next': 'Next',
      'back': 'Back',
      'getStarted': 'Get Started',
      'selectLanguage': 'Select Language',
      'sloganPart1': 'CPR made easy',
      'sloganPart2': 'help made instant',
    },
    'French': {
      'chooseTheme': 'Choisissez Votre Thème',
      'lightMode': 'Mode Clair',
      'darkMode': 'Mode Sombre',
      'chooseGuide': 'Choisissez Votre Guide',
      'next': 'Suivant',
      'back': 'Retour',
      'getStarted': 'Commencer',
      'selectLanguage': 'Sélectionnez la Langue',
      'sloganPart1': 'La RCP simplifiée pour tous',
      'sloganPart2': 'une aide immédiate',
    },
    'Arabic': {
      'chooseTheme': 'اختر المظهر',
      'lightMode': 'الوضع النهاري',
      'darkMode': 'الوضع الليلي',
      'chooseGuide': 'اختر دليلك',
      'next': 'التالي',
      'back': 'رجوع',
      'getStarted': 'ابدأ',
      'selectLanguage': 'اختر اللغة',
      'sloganPart1': 'تعلم الإنعاش القلبي بسهولة',
      'sloganPart2': 'مساعدة فورية للجميع',
    },
  };

  String getTranslatedText(String key) {
    return translations[selectedLanguage]?[key] ?? translations['English']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _tabController.addListener(() {
      setState(() {
        _isLastPage = _tabController.index == 2;
      });
    });

    // Initialize wave animation controller
    _waveController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Widget _buildWaveBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? Colors.black : Colors.white,
              isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                color: Color(0xFF5EFF8B).withOpacity(0.1),
                amplitude: 50,
                frequency: 1.5,
                phase: _waveController.value * 2 * 3.14159,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isActive = _tabController.index == index;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? Color(0xFF5EFF8B) : Color(0xFF5EFF8B).withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, String> language) {
    bool isSelected = selectedLanguage == language['name'];
    return GestureDetector(
      onTap: () => setState(() => selectedLanguage = language['name']!),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5EFF8B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Color(0xFF5EFF8B),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                right: 16,
                top: 16,
                child: Icon(Icons.check_circle, color: Colors.white),
              ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? Colors.white : Color(0xFF5EFF8B),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        language['flag']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language['name']!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Color(0xFF5EFF8B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          language['native']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : Color(0xFF5EFF8B).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          getTranslatedText('chooseTheme'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildThemeOption(false),
            _buildThemeOption(true),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(bool dark) {
    bool isSelected = isDarkMode == dark;
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = dark),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 150,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5EFF8B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Color(0xFF5EFF8B),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              dark ? Icons.dark_mode : Icons.light_mode,
              size: 50,
              color: isSelected ? Colors.white : Color(0xFF5EFF8B),
            ),
            SizedBox(height: 16),
            Text(
              dark ? getTranslatedText('darkMode') : getTranslatedText('lightMode'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Color(0xFF5EFF8B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSelection() {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    return Column(
      children: [
        Text(
          getTranslatedText('chooseGuide'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final avatarIndex = index + 1;
              bool isSelected = selectedAvatarIndex == avatarIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedAvatarIndex = avatarIndex);
                  avatarProvider.updateAvatar('assets/avatars/avatar$avatarIndex.png');
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Color(0xFF5EFF8B) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/avatars/avatar$avatarIndex.png',
                          fit: BoxFit.cover,
                        ),
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF5EFF8B).withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? Colors.black : Colors.white,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            _buildWaveBackground(),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                getTranslatedText('sloganPart1'),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nexa',
                                  color: Color(0xFF5EFF8B),
                                ),
                              ),
                              Text(
                                getTranslatedText('sloganPart2'),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nexa',
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildProgressIndicator(),
                  SizedBox(height: 20),
                  Expanded(
                    flex: 4,
                    child: TabBarView(
                      controller: _tabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListView.builder(
                          itemCount: languages.length,
                          itemBuilder: (context, index) => _buildLanguageCard(languages[index]),
                        ),
                        _buildThemeSelection(),
                        _buildAvatarSelection(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_tabController.index > 0)
                          TextButton(
                            onPressed: () {
                              _tabController.animateTo(_tabController.index - 1);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back, color: Color(0xFF5EFF8B)),
                                SizedBox(width: 8),
                                Text(
                                  getTranslatedText('back'),
                                  style: TextStyle(
                                    color: Color(0xFF5EFF8B),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(width: 80),
                        ElevatedButton(
                          onPressed: () {
                            if (_isLastPage) {
                              final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
                              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                              final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);

                              // Save all preferences
                              languageProvider.updateLanguage(selectedLanguage);
                              if (isDarkMode) themeProvider.toggleTheme();
                              // Make sure avatar is saved
                              avatarProvider.updateAvatar('assets/avatars/avatar$selectedAvatarIndex.png');

                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                  transitionDuration: Duration(milliseconds: 500),
                                ),
                              );
                            } else {
                              _tabController.animateTo(_tabController.index + 1);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _isLastPage ? getTranslatedText('getStarted') : getTranslatedText('next'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5EFF8B),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                _isLastPage ? Icons.check : Icons.arrow_forward,
                                color: Color(0xFF5EFF8B),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double frequency;
  final double phase;

  WavePainter({
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x < size.width; x++) {
      final y = size.height / 2 +
          amplitude * sin((x * frequency * pi / 180) + phase) +
          amplitude * cos((x * frequency * 0.5 * pi / 180) + phase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      color != oldDelegate.color ||
      amplitude != oldDelegate.amplitude ||
      frequency != oldDelegate.frequency ||
      phase != oldDelegate.phase;
}
