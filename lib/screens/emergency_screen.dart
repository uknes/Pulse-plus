import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String avatarMessage = "Are you sure the victim is having a cardiac arrest?";
  String yesButtonText = "Yes";
  String noButtonText = "No";
  int step = 1;
  bool isEmergencyMode = false;
  Timer? _cprTimer;

  final Map<String, Map<String, String>> translations = {
    'English': {
      'appBarTitle': 'Emergency Guide',
      'callEmergency': 'Call Emergency',
      'startCPR': 'Start CPR',
      'continue': 'Continue',
      'goBack': 'Go Back',
      'restart': 'Restart',
      'exit': 'Exit',
      'quickTips': 'Quick Tips',
      'cprRhythm': 'CPR Rhythm',
      'step': 'Step',
      'of': 'of',
    },
    'French': {
      'appBarTitle': 'Guide d\'urgence',
      'callEmergency': 'Appeler les urgences',
      'startCPR': 'Commencer la RCP',
      'continue': 'Continuer',
      'goBack': 'Retour',
      'restart': 'Recommencer',
      'exit': 'Quitter',
    },
    'Arabic': {
      'appBarTitle': 'دليل الطوارئ',
      'callEmergency': 'اتصل بالطوارئ',
      'startCPR': 'ابدأ الإنعاش القلبي الرئوي',
      'continue': 'استمر',
      'goBack': 'رجوع',
      'restart': 'إعادة',
      'exit': 'خروج',
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _cprTimer?.cancel();
    super.dispose();
  }

  Future<void> _callEmergency() async {
    const emergencyNumber = '15'; // Can be configurable per country
    final Uri url = Uri.parse('tel:$emergencyNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _startCPRHapticFeedback() {
    _cprTimer?.cancel();
    if (step == 3 || step == 4) {
      _cprTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (step != 3 && step != 4) {
          timer.cancel();
        } else {
          HapticFeedback.mediumImpact();
        }
      });
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: step > index ? Color(0xFF5EFF8B) : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCPRTimer() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool isArabic = languageProvider.selectedLanguage == 'Arabic';
    
    if (step == 3 || step == 4) {
      return Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isArabic) Icon(Icons.timer, color: Colors.white),
            if (!isArabic) SizedBox(width: 8),
            Text(
              '100-120 BPM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nexa',
              ),
            ),
            if (isArabic) SizedBox(width: 8),
            if (isArabic) Icon(Icons.timer, color: Colors.white),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildQuickTips() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool isArabic = languageProvider.selectedLanguage == 'Arabic';
    
    final tips = {
      1: isArabic 
        ? '• تأكد من سلامة المحيط\n• اطلب المساعدة إذا كانت متوفرة'
        : '• Check surroundings for safety\n• Call for help if available',
      2: isArabic
        ? '• تأكد من مجرى التنفس\n• ابحث عن حركة الصدر'
        : '• Clear airway\n• Look for chest movement',
      3: isArabic
        ? '• اضغط بقوة وسرعة\n• اسمح للصدر بالعودة إلى وضعه'
        : '• Push hard and fast\n• Allow chest to recoil',
      4: isArabic
        ? '• قلل من التوقفات\n• قم بتبديل المنقذين كل دقيقتين'
        : '• Minimize interruptions\n• Switch rescuers every 2 minutes',
      5: isArabic
        ? '• حافظ على هدوئك\n• اتبع تعليمات خدمات الطوارئ'
        : '• Stay calm\n• Follow emergency services instructions',
    };

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isArabic) Icon(Icons.tips_and_updates, color: Colors.white),
              if (!isArabic) SizedBox(width: 8),
              Text(
                translations[languageProvider.selectedLanguage]?['quickTips'] ?? 'Quick Tips:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Nexa',
                ),
              ),
              if (isArabic) SizedBox(width: 8),
              if (isArabic) Icon(Icons.tips_and_updates, color: Colors.white),
            ],
          ),
          SizedBox(height: 8),
          Text(
            tips[step] ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Nexa',
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    );
  }

  void _onButtonPressed(bool isYes) {
    setState(() {
      switch (step) {
        case 1:
          if (isYes) {
            avatarMessage = "Check for responsiveness:\n1. Tap their shoulders\n2. Ask loudly 'Are you okay?'\n3. Check for breathing";
            yesButtonText = "Responsive";
            noButtonText = "Unresponsive";
            step = 2;
            isEmergencyMode = true;
          } else {
            avatarMessage = "Monitor the person and look for these signs:\n• Chest pain\n• Difficulty breathing\n• Dizziness\n• Cold sweat";
            yesButtonText = "Check Again";
            noButtonText = "Call Help";
            isEmergencyMode = false;
          }
          break;

        case 2:
          if (isYes) {
            avatarMessage = "If responsive but showing distress:\n1. Keep them calm\n2. Call emergency services\n3. Stay with them until help arrives";
            yesButtonText = "Call Emergency";
            noButtonText = "Restart";
            step = 5;
          } else {
            avatarMessage = "IMMEDIATE ACTIONS REQUIRED:\n1. Call emergency services (or ask someone to)\n2. Start chest compressions\n3. Send someone to find an AED";
            yesButtonText = "Start CPR";
            noButtonText = "Call Emergency";
            step = 3;
          }
          break;

        case 3:
          if (isYes) {
            avatarMessage = "CPR Instructions:\n1. Place hands on center of chest\n2. Push hard and fast (100-120/min)\n3. Let chest recoil completely\n4. Minimize interruptions";
            yesButtonText = "Continue CPR";
            noButtonText = "Use AED";
            step = 4;
            _startCPRHapticFeedback();
          } else {
            _callEmergency();
            avatarMessage = "While waiting for emergency services:\n1. Clear the area\n2. Loosen tight clothing\n3. Check breathing\n4. Prepare to start CPR";
            yesButtonText = "Start CPR";
            noButtonText = "Continue Monitoring";
            step = 4;
          }
          break;

        case 4:
          if (isYes) {
            avatarMessage = "Continue CPR until:\n• Professional help arrives\n• An AED is available\n• The person shows signs of life\n• You're too exhausted to continue";
            yesButtonText = "Restart Guide";
            noButtonText = "Exit";
            step = 5;
          } else {
            if (_cprTimer != null) {
              _cprTimer?.cancel();
              _cprTimer = null;
            }
            _resetScenario();
          }
          break;

        case 5:
          if (isYes) {
            _resetScenario();
          } else {
            if (_cprTimer != null) {
              _cprTimer?.cancel();
              _cprTimer = null;
            }
            Navigator.pop(context);
          }
          break;
      }
    });
  }

  void _resetScenario() {
    setState(() {
      step = 1;
      isEmergencyMode = false;
      avatarMessage = "Are you sure the victim is having a cardiac arrest?";
      yesButtonText = "Yes";
      noButtonText = "No";
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = Provider.of<AvatarProvider>(context);
    Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentTranslations = translations[languageProvider.selectedLanguage] ?? translations['English']!;
    
    return Directionality(
      textDirection: languageProvider.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            currentTranslations['appBarTitle']!,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Nexa',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.redAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildStepIndicator(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            _buildAvatarMessageBox(),
                            _buildCPRTimer(),
                            SizedBox(height: 30),
                            Image.asset(
                              avatarProvider.selectedAvatar,
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                            _buildQuickTips(),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: _buildActionButtons(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarMessageBox() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool isArabic = languageProvider.selectedLanguage == 'Arabic';
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isEmergencyMode)
            Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 40,
            ),
          SizedBox(height: isEmergencyMode ? 10 : 0),
          Text(
            avatarMessage,
            style: TextStyle(
              fontFamily: 'Nexa',
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    Color primaryColor = Color(0xFF5EFF8B);
    
    Color getButtonColor(bool isYesButton) {
      switch (step) {
        case 1:
          return isYesButton ? Colors.red : primaryColor;
        case 2:
          return isYesButton ? primaryColor : Colors.red;
        case 3:
          return isYesButton ? Colors.red : Colors.red;
        case 4:
          return isYesButton ? Colors.red : primaryColor;
        case 5:
          return isYesButton ? primaryColor : Colors.red;
        default:
          return primaryColor;
      }
    }

    IconData getButtonIcon(Color buttonColor) {
      return buttonColor == Colors.red 
          ? Icons.warning_rounded 
          : Icons.check_circle_outline;
    }
    
    Color yesButtonColor = getButtonColor(true);
    Color noButtonColor = getButtonColor(false);
    
    return Row(
      children: [
        Expanded(
          child: _buildAnimatedButton(
            yesButtonText, 
            yesButtonColor,
            getButtonIcon(yesButtonColor),
            () => _onButtonPressed(true)
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: _buildAnimatedButton(
            noButtonText, 
            noButtonColor,
            getButtonIcon(noButtonColor),
            () => _onButtonPressed(false)
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: onPressed,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Nexa',
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
