import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/volume_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  final Map<String, Map<String, String>> _translations = {
    'English': {
      'appBarTitle': 'Settings',
      'appearance': 'Appearance',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'copyright': '© 2024 Uknes Studio. All rights reserved.',
      'profile': 'Profile',
      'changeAvatar': 'Change Avatar',
      'disclaimer': 'Pulse + is not responsible or liable for any mishaps, reliability issues, or accuracy issues from using this app.\n\nPlease familiarize and verify this app before using in an actual chest compression-only CPR situation.',
      'volume': 'Volume',
    },
    'French': {
      'appBarTitle': 'Paramètres',
      'appearance': 'Apparence',
      'darkMode': 'Mode Sombre',
      'language': 'Langue',
      'selectLanguage': 'Sélectionner la langue',
      'copyright': '© 2024 Uknes Studio. Tous droits réservés.',
      'profile': 'Profil',
      'changeAvatar': 'Changer l\'avatar',
      'disclaimer': 'Pulse + n\'est pas responsable des accidents, des problèmes de fiabilité ou des problèmes de précision liés à l\'utilisation de cette application.\n\nVeuillez vous familiariser et vérifier cette application avant de l\'utiliser dans une situation réelle de RCP par compression thoracique uniquement.',
      'volume': 'Volume',
    },
    'Arabic': {
      'appBarTitle': 'الإعدادات',
      'appearance': 'المظهر',
      'darkMode': 'الوضع الداكن',
      'language': 'اللغة',
      'selectLanguage': 'اختر اللغة',
      'copyright': '© 2024 Uknes Studio. جميع الحقوق محفوظة.',
      'profile': 'الملف الشخصي',
      'changeAvatar': 'تغيير الصورة الرمزية',
      'disclaimer': 'Pulse + غير مسؤول عن أي حوادث أو مشاكل في الموثوقية أو مشاكل في الدقة من استخدام هذا التطبيق.\n\nيرجى التعرف على هذا التطبيق والتحقق منه قبل استخدامه في حالة الإنعاش القلبي الرئوي بالضغط على الصدر فقط.',
      'volume': 'مستوى الصوت',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language_code') ?? 'English';
    });
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  void _showAvatarSelectionDialog(BuildContext context, AvatarProvider avatarProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Avatar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5EFF8B),
                  ),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 1; i <= 4; i++)
                      GestureDetector(
                        onTap: () {
                          avatarProvider.updateAvatar('assets/avatars/avatar$i.png');
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: avatarProvider.selectedAvatar == 'assets/avatars/avatar$i.png'
                                  ? Color(0xFF5EFF8B)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            'assets/avatars/avatar$i.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final avatarProvider = Provider.of<AvatarProvider>(context);
    final volumeProvider = Provider.of<VolumeProvider>(context);

    Color backgroundColor = themeProvider.isDarkMode ? Colors.black : Colors.white;
    Color textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    Color cardColor = themeProvider.isDarkMode ? Colors.grey[850]! : Colors.white;

    final currentTranslations = _translations[_selectedLanguage] ?? _translations['English']!;

    return Directionality(
      textDirection: _selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            currentTranslations['appBarTitle']!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF5EFF8B)),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF5EFF8B)),
        ),
        body: Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF5EFF8B).withOpacity(0.3)),
                ),
                child: Text(
                  currentTranslations['disclaimer']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Text(
                currentTranslations['profile']!,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Image.asset(
                    avatarProvider.selectedAvatar,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(
                    currentTranslations['changeAvatar']!,
                    style: TextStyle(fontSize: 20, color: Color(0xFF5EFF8B)),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF5EFF8B)),
                  onTap: () => _showAvatarSelectionDialog(context, avatarProvider),
                ),
              ),
              SizedBox(height: 20),
              Text(
                currentTranslations['appearance']!,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  title: Text(
                    currentTranslations['darkMode']!,
                    style: TextStyle(fontSize: 20, color: Color(0xFF5EFF8B)),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  secondary: Icon(
                    Icons.dark_mode,
                    color: Color(0xFF5EFF8B),
                  ),
                  activeColor: Color(0xFF5EFF8B),
                  inactiveTrackColor: Colors.white,
                  inactiveThumbColor: Color(0xFF5EFF8B),
                ),
              ),
              SizedBox(height: 20),
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.volume_up,
                            color: Color(0xFF5EFF8B),
                          ),
                          SizedBox(width: 16),
                          Text(
                            currentTranslations['volume']!,
                            style: TextStyle(fontSize: 20, color: Color(0xFF5EFF8B)),
                          ),
                        ],
                      ),
                      Slider(
                        value: volumeProvider.volume,
                        onChanged: (newValue) {
                          volumeProvider.updateVolume(newValue);
                        },
                        activeColor: Color(0xFF5EFF8B),
                        inactiveColor: Color(0xFF5EFF8B).withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                currentTranslations['language']!,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField<String>(
                  value: languageProvider.selectedLanguage,
                  items: <String>['English', 'French', 'Arabic']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Color(0xFF5EFF8B)),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      languageProvider.updateLanguage(newValue);
                      _saveLanguagePreference(newValue);
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                    }
                  },
                  hint: Text(
                    currentTranslations['selectLanguage']!,
                    style: TextStyle(fontFamily: 'Nexa', color: textColor),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: cardColor,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF5EFF8B)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF5EFF8B)),
                    ),
                  ),
                  iconEnabledColor: Color(0xFF5EFF8B),
                ),
              ),
              Spacer(),
              Center(
                child: Text(
                  currentTranslations['copyright']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
