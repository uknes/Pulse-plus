import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse_plus/screens/article_detail_screen.dart';
import 'package:pulse_plus/models/article_model.dart'; // Import the Article model
import '../models/image_selection_dialog.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/volume_provider.dart';
import '../widgets/video_category_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:async';

class ArticleScreen extends StatefulWidget {
  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0; // Start with the first article
  bool isUpArrowClicked = false;
  bool isDownArrowClicked = false;
  int? expandedCategoryIndex;
  List<ExpansionTileController> categoryControllers = [];
  
  // Add new state variables for welcome voice
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isWelcomePlaying = false;
  String? _selectedAvatar;
  final List<double> _barHeights = List.generate(12, (index) => 0.5);
  StreamSubscription? _audioStreamSubscription;
  Map<int, bool> _tabVisited = {0: false, 1: false, 2: false};

  // Define translations for the dialogs
  final Map<String, Map<String, String>> _dialogTranslations = {
    'English': {
      'whoAreYou': 'Who are you?',
      'doctor': 'Doctor',
      'regularUser': 'Regular User',
      'chooseContentType': 'Choose Content Type',
      'adult': 'Adult',
      'children': 'Children',
      'selectBoth': 'Please select both user type and content type.',
    },
    'French': {
      'whoAreYou': 'Qui êtes-vous?',
      'doctor': 'Médecin',
      'regularUser': 'Utilisateur Régulier',
      'chooseContentType': 'Choisir le Type de Contenu',
      'adult': 'Adulte',
      'children': 'Enfant',
      'selectBoth': 'Veuillez sélectionner le type d\'utilisateur et le type de contenu.',
    },
    'Arabic': {
      'whoAreYou': 'من أنت؟',
      'doctor': 'طبيب',
      'regularUser': 'مستخدم عادي',
      'chooseContentType': 'اختر نوع المحتوى',
      'adult': 'بالغ',
      'children': 'طفل',
      'selectBoth': 'الرجاء تحديد نوع المستخدم ونوع المحتوى.',
    },
  };

  String _getDialogTranslation(String key) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.selectedLanguage;
    return _dialogTranslations[currentLanguage]?[key] ?? _dialogTranslations['English']![key]!;
  }

  void _updateBarHeights() {
    setState(() {
      for (int i = 0; i < _barHeights.length; i++) {
        // Smaller amplitude for quiet parts (0.1 to 0.3)
        double targetHeight = 0.1 + math.Random().nextDouble() * 0.2;
        
        // Occasionally create higher amplitudes to simulate voice (0.2 to 0.8)
        if (math.Random().nextDouble() > 0.7) {
          targetHeight = 0.2 + math.Random().nextDouble() * 0.6;
        }
        
        double currentHeight = _barHeights[i];
        _barHeights[i] = currentHeight + (targetHeight - currentHeight) * 0.3;
      }
    });
  }

  Future<void> _playWelcomeVoice(String language, String avatarNumber, String section) async {
    final prefs = await SharedPreferences.getInstance();
    final lastLanguage = prefs.getString('${section}LastLanguage');
    
    if (lastLanguage != language) {
      setState(() {
        _isWelcomePlaying = true;
        _selectedAvatar = avatarNumber;
      });

      final voiceType = (avatarNumber == '1' || avatarNumber == '2') ? 'man' : 'woman';
      final audioFile = 'voices - articles section/$language - $voiceType - $section.mp3';
      
      try {
        Timer.periodic(Duration(milliseconds: 50), (timer) {
          if (!_isWelcomePlaying) {
            timer.cancel();
          } else {
            _updateBarHeights();
          }
        });

        // Set volume from VolumeProvider
        final volumeProvider = Provider.of<VolumeProvider>(context, listen: false);
        await _audioPlayer.setVolume(volumeProvider.volume);
        await _audioPlayer.play(AssetSource(audioFile));
        
        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() {
            _isWelcomePlaying = false;
            _selectedAvatar = null;
          });
        });

        await prefs.setString('${section}LastLanguage', language);
      } catch (e) {
        print('Error playing welcome audio: $e');
        setState(() {
          _isWelcomePlaying = false;
          _selectedAvatar = null;
        });
      }
    }
  }

  Future<void> _showDoctorOrRegularDialog(BuildContext context, Article article) {
    final options = [
      ImageOption(
        label: _getDialogTranslation('doctor'),
        imagePath: 'assets/images/doctor.png'
      ),
      ImageOption(
        label: _getDialogTranslation('regularUser'),
        imagePath: 'assets/images/regular_user.png'
      ),
    ];

    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: ImageSelectionDialog(
              title: _getDialogTranslation('whoAreYou'),
              options: options,
              onPressed: (userType) {
                Future.delayed(Duration(milliseconds: 100), () {
                  _showAdultOrChildrenDialog(context, article, userType);
                });
              },
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
    );
  }

  Future<void> _showAdultOrChildrenDialog(BuildContext context, Article article, String userType) {
    final options = [
      ImageOption(
        label: _getDialogTranslation('adult'),
        imagePath: 'assets/images/adult.png'
      ),
      ImageOption(
        label: _getDialogTranslation('children'),
        imagePath: 'assets/images/children.png'
      ),
    ];

    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: ImageSelectionDialog(
              title: _getDialogTranslation('chooseContentType'),
              options: options,
              onPressed: (contentType) {
                Future.delayed(Duration(milliseconds: 100), () {
                  _navigateToArticleDetail(context, article, userType, contentType);
                });
              },
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
    );
  }

  void _navigateToArticleDetail(BuildContext context, Article article, String userType, String contentType) {
    if (userType.isEmpty || contentType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getDialogTranslation('selectBoth'))),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          article: article,
          userType: userType,
          contentType: contentType,
        ),
      ),
    );
  }

  void changeArrowColor(bool isUpArrow) {
    setState(() {
      if (isUpArrow) {
        isUpArrowClicked = true;
      } else {
        isDownArrowClicked = true;
      }
    });

    // Reset the color after a short delay
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        if (isUpArrow) {
          isUpArrowClicked = false;
        } else {
          isDownArrowClicked = false;
        }
      });
    });
  }

  // Define translations for the articles
  final Map<String, Map<String, String>> _translations = {
    'English': {
      'articlesTitle': 'Articles',
      'articlesDescription': 'Learn how to stay healthy with these simple tips',
      'algorithmsTitle': 'Algorithms',
      'algorithmsDescription': 'How to prepare for emergencies effectively',
      'infoUtilsTitle': 'Info Utils',
      'infoUtilsDescription': 'Basic first aid techniques everyone should know',
      'videosTitle': 'Videos',
      'videosDescription': 'Informative videos on health and safety tips',
      'testsTitle': 'Tests',
      'testsDescription': 'Evaluate your knowledge with these tests',
      'recommendationsTitle': 'Recommendations',
      'plusInfoTitle': "Plus d'information",
      // Add video categories translations
      'basicLifeSupport': 'Basic Life Support',
      'advancedCardiacLifeSupport': 'Advanced Cardiac Life Support',
      'pediatricLifeSupport': 'Pediatric Advanced Life Support',
      // Add video titles translations
      'blsGuidelinesTitle': 'Basic Life Support - ERC Guidelines 2021',
      'blsGuidelinesDesc': 'Learn the latest guidelines for basic life support',
      'handsOnlyCPRTitle': 'Learn Hands-Only CPR',
      'handsOnlyCPRDesc': 'Essential guide to hands-only CPR techniques',
      'performCPRTitle': 'How to Perform Hands-Only CPR',
      'performCPRDesc': 'Step-by-step guide to hands-only CPR',
      'cprActionTitle': 'CPR in Action: 3D Look Inside the Body',
      'cprActionDesc': 'Visualize how CPR affects the body internally',
      'aedActionTitle': 'AED in Action: 3D Look Inside the Body',
      'aedActionDesc': 'Understanding how AED works inside the body',
      'cprAEDTitle': 'Hands-Only CPR plus AED Extended',
      'cprAEDDesc': 'Comprehensive guide to CPR and AED usage',
      'cardiacArrestTitle': 'Recognizing Cardiac Arrest',
      'cardiacArrestDesc': 'Learn to identify signs of cardiac arrest',
      'xiphoidTitle': 'Locating the Xiphoid Process',
      'xiphoidDesc': 'Important anatomical guidance for pediatric CPR',
    },
    'French': {
      'articlesTitle': 'Articles',
      'articlesDescription': 'Apprenez à rester en bonne santé avec ces conseils simples',
      'algorithmsTitle': 'Algorithmes',
      'algorithmsDescription': 'Comment se préparer efficacement aux urgences',
      'infoUtilsTitle': 'Info Utils',
      'infoUtilsDescription': 'Techniques de premiers secours de base que tout le monde devrait connaître',
      'videosTitle': 'Vidéos',
      'videosDescription': 'Vidéos informatives sur la santé et la sécurité',
      'testsTitle': 'Tests',
      'testsDescription': 'Évaluez vos connaissances avec ces tests',
      'recommendationsTitle': 'Recommandations',
      'plusInfoTitle': "Plus d'information",
      // Add video categories translations
      'basicLifeSupport': 'Support Vital de Base',
      'advancedCardiacLifeSupport': 'Support Cardiaque Avancé',
      'pediatricLifeSupport': 'Support Vital Avancé Pédiatrique',
      // Add video titles translations
      'blsGuidelinesTitle': 'Support Vital de Base - Directives ERC 2021',
      'blsGuidelinesDesc': 'Découvrez les dernières directives pour le support vital de base',
      'handsOnlyCPRTitle': 'Apprendre la RCP Mains Seules',
      'handsOnlyCPRDesc': 'Guide essentiel des techniques de RCP mains seules',
      'performCPRTitle': 'Comment Effectuer la RCP Mains Seules',
      'performCPRDesc': 'Guide étape par étape de la RCP mains seules',
      'cprActionTitle': 'RCP en Action: Vue 3D à l\'intérieur du Corps',
      'cprActionDesc': 'Visualisez comment la RCP affecte le corps en interne',
      'aedActionTitle': 'DEA en Action: Vue 3D à l\'intérieur du Corps',
      'aedActionDesc': 'Comprendre comment fonctionne le DEA dans le corps',
      'cprAEDTitle': 'RCP Mains Seules plus DEA Étendu',
      'cprAEDDesc': 'Guide complet de l\'utilisation de la RCP et du DEA',
      'cardiacArrestTitle': 'Reconnaître l\'Arrêt Cardiaque',
      'cardiacArrestDesc': 'Apprenez à identifier les signes d\'un arrêt cardiaque',
      'xiphoidTitle': 'Localisation du Processus Xiphoïde',
      'xiphoidDesc': 'Guide anatomique important pour la RCP pédiatrique',
    },
    'Arabic': {
      'articlesTitle': 'المقالات',
      'articlesDescription': 'تعلم كيفية البقاء بصحة جيدة مع هذه النصائح البسيطة',
      'algorithmsTitle': 'الخوارزميات',
      'algorithmsDescription': 'كيفية التحضير للطوارئ بشكل فعال',
      'infoUtilsTitle': 'معلومات مفيدة',
      'infoUtilsDescription': 'أساسيات الإسعافات الأولية التي يجب على الجميع معرفتها',
      'videosTitle': 'الفيديوهات',
      'videosDescription': 'فيديوهات معلوماتية حول الصحة والسلامة',
      'testsTitle': 'الاختبارات',
      'testsDescription': 'قم بتقييم معرفتك من خلال هذه الاختبارات',
      'recommendationsTitle': 'توصيات',
      'plusInfoTitle': 'المزيد من المعلومات',
      // Add video categories translations
      'basicLifeSupport': 'دعم الحياة الأساسي',
      'advancedCardiacLifeSupport': 'دعم القلب المتقدم',
      'pediatricLifeSupport': 'دعم الحياة المتقدم للأطفال',
      // Add video titles translations
      'blsGuidelinesTitle': 'دعم الحياة الأساسي - إرشادات ERC 2021',
      'blsGuidelinesDesc': 'تعلم أحدث الإرشادات لدعم الحياة الأساسي',
      'handsOnlyCPRTitle': 'تعلم الإنعاش القلبي الرئوي باليدين فقط',
      'handsOnlyCPRDesc': 'دليل أساسي لتقنيات الإنعاش القلبي الرئوي باليدين',
      'performCPRTitle': 'كيفية إجراء الإنعاش القلبي الرئوي باليدين',
      'performCPRDesc': 'دليل خطوة بخطوة للإنعاش القلبي الرئوي باليدين',
      'cprActionTitle': 'الإنعاش القلبي الرئوي في العمل: نظرة ثلاثية الأبعاد داخل الجسم',
      'cprActionDesc': 'تصور كيف يؤثر الإنعاش القلبي الرئوي على الجسم داخليًا',
      'aedActionTitle': 'جهاز AED في العمل: نظرة ثلاثية الأبعاد داخل الجسم',
      'aedActionDesc': 'فهم كيف يعمل جهاز AED داخل الجسم',
      'cprAEDTitle': 'الإنعاش القلبي الرئوي باليدين مع AED الموسع',
      'cprAEDDesc': 'دليل شامل لاستخدام الإنعاش القلبي الرئوي وAED',
      'cardiacArrestTitle': 'التعرف على توقف القلب',
      'cardiacArrestDesc': 'تعلم كيفية تحديد علامات توقف القلب',
      'xiphoidTitle': 'تحديد موقع النتوء الرهابي',
      'xiphoidDesc': 'إرشادات تشريحية مهمة للإنعاش القلبي الرئوي للأطفال',
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
      _handleTabChange();
    });
    
    categoryControllers = List.generate(
      getVideoCategories().length,
      (_) => ExpansionTileController(),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
      final currentLanguage = languageProvider.selectedLanguage.toLowerCase();
      final avatarPath = avatarProvider.selectedAvatar;
      final avatarNumber = avatarPath.split('avatar').last.split('.').first;
      _playWelcomeVoice(currentLanguage, avatarNumber, 'articles');
      _tabVisited[0] = true;
    });
  }

  void _handleTabChange() async {
    if (_tabController.indexIsChanging || !_tabController.indexIsChanging && !_tabVisited[_tabController.index]!) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
      final currentLanguage = languageProvider.selectedLanguage.toLowerCase();
      final avatarPath = avatarProvider.selectedAvatar;
      final avatarNumber = avatarPath.split('avatar').last.split('.').first;
      
      String section;
      switch (_tabController.index) {
        case 0:
          section = 'articles';
          break;
        case 1:
          section = 'videos';
          break;
        case 2:
          section = 'quiz';
          break;
        default:
          section = 'articles';
      }
      
      _tabVisited[_tabController.index] = true;
      await _playWelcomeVoice(currentLanguage, avatarNumber, section);
    }
  }

  @override
  void dispose() {
    _audioStreamSubscription?.cancel();
    _audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getVideoCategories() {
    return [
      {
        'title': 'basicLifeSupport',
        'videos': [
          VideoItem(
            path: 'assets/videos/Basic_Life_Support_ERC_Guidelines_2021.mp4',
            title: 'blsGuidelinesTitle',
            description: 'blsGuidelinesDesc',
            thumbnailPath: 'assets/thumbnails/bls_erc.png',
          ),
          VideoItem(
            path: 'assets/videos/Learn_Hands_Only_CPR_480P.mp4',
            title: 'handsOnlyCPRTitle',
            description: 'handsOnlyCPRDesc',
            thumbnailPath: 'assets/thumbnails/learn_hands_only.png',
          ),
          VideoItem(
            path: 'assets/videos/How_to_Perform_Hands_Only_CPR.mp4',
            title: 'performCPRTitle',
            description: 'performCPRDesc',
            thumbnailPath: 'assets/thumbnails/perform_hands_only.png',
          ),
          VideoItem(
            path: 'assets/videos/CPR_in_Action_3D_look_inside_the_body.mp4',
            title: 'cprActionTitle',
            description: 'cprActionDesc',
            thumbnailPath: 'assets/thumbnails/cpr_3d_action.png',
          ),
        ],
      },
      {
        'title': 'advancedCardiacLifeSupport',
        'videos': [
          VideoItem(
            path: 'assets/videos/AED_in_Action_3D_Look_Inside_the_Body.mp4',
            title: 'aedActionTitle',
            description: 'aedActionDesc',
            thumbnailPath: 'assets/thumbnails/aed_3d_action.jpg',
          ),
          VideoItem(
            path: 'assets/videos/Hands_Only_CPR_plus_AED_Extended.mp4',
            title: 'cprAEDTitle',
            description: 'cprAEDDesc',
            thumbnailPath: 'assets/thumbnails/cpr_aed_extended.png',
          ),
          VideoItem(
            path: 'assets/videos/Recognising_Cardiac_Arrest_animation.mp4',
            title: 'cardiacArrestTitle',
            description: 'cardiacArrestDesc',
            thumbnailPath: 'assets/thumbnails/cardiac_arrest.png',
          ),
        ],
      },
      {
        'title': 'pediatricLifeSupport',
        'videos': [
          VideoItem(
            path: 'assets/videos/Locating_the_Xiphoid_Process_CPR_Steps.mp4',
            title: 'xiphoidTitle',
            description: 'xiphoidDesc',
            thumbnailPath: 'assets/thumbnails/xiphoid_process.png',
          ),
        ],
      },
    ];
  }

  void _closeAllExcept(int index) {
    for (int i = 0; i < categoryControllers.length; i++) {
      if (i != index) {
        categoryControllers[i].collapse();
      }
    }
  }

  Widget _buildSoundWave() {
    return Container(
      height: 50,
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          12,
          (index) {
            final barHeight = 5 + (35 * _barHeights[index]); // Reduced base height and max height
            return AnimatedContainer(
              duration: Duration(milliseconds: 50),
              width: 3,
              height: barHeight,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentTranslations = _translations[languageProvider.selectedLanguage] ?? _translations['English']!;

    final List<Article> articles = [
      Article(
        title: currentTranslations['recommendationsTitle'] ?? 'Recommendations',
        description: currentTranslations['articlesDescription'] ?? 'Learn how to stay healthy with these simple tips.',
        content: 'Full content of Articles...',
      ),
      Article(
        title: currentTranslations['algorithmsTitle'] ?? 'Algorithms',
        description: currentTranslations['algorithmsDescription'] ?? 'Step-by-step guide for emergency response',
        content: 'Adult CPR Algorithm\n\n' +
                'Initial Assessment:\n' +
                '- Check if patient is unresponsive with absent/abnormal breathing\n' +
                '- Call EMS/Resuscitation team immediately if confirmed\n\n' +
                'Start CPR:\n' +
                '- Begin CPR with ratio of 30:2 (compressions:breaths)\n\n' +
                'Attach Defibrillator/Monitor:\n' +
                '- Assess cardiac rhythm\n\n' +
                'Assess Rhythm:\n' +
                '- Check if shockable (VF/VT) or non-shockable (PEA/Asystole)\n' +
                '- If shockable: deliver 1 shock\n' +
                '- If non-shockable: no shock\n\n' +
                'Post-Shock Action:\n' +
                '- Resume chest compressions for 2 minutes\n\n' +
                'Reassess Rhythm:\n' +
                '- Check rhythm after each 2-minute CPR cycle\n' +
                '- Continue loop based on rhythm type\n\n' +
                'ROSC Check:\n' +
                '- If ROSC achieved: stop CPR and manage patient\n' +
                '- If no ROSC: continue CPR loop',
      ),
      Article(
        title: currentTranslations['plusInfoTitle'] ?? "Plus d'information",
        description: currentTranslations['infoUtilsDescription'] ?? 'Basic first aid techniques everyone should know.',
        content: 'Full content of Info Utils...',
      ),
    ];

    final videoCategories = getVideoCategories().map((category) {
      return {
        'title': currentTranslations[category['title']]!,
        'originalTitle': category['title'],  // Keep original title for icon mapping
        'videos': (category['videos'] as List<VideoItem>).map((video) => VideoItem(
          path: video.path,
          title: currentTranslations[video.title]!,
          description: currentTranslations[video.description]!,
          thumbnailPath: video.thumbnailPath,
        )).toList(),
      };
    }).toList();

    return Stack(
      children: [
        Directionality(
          textDirection: languageProvider.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(30),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          child: TabBar(
                            dividerColor: Colors.transparent,
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            splashFactory: NoSplash.splashFactory,
                            controller: _tabController,
                            indicator: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF5EFF8B), Colors.greenAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black87,
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            tabs: [
                              Tab(
                                child: TabContent(
                                  icon: Icons.article,
                                  label: currentTranslations['articlesTitle'] ?? 'Articles',
                                  currentIndex: 0,
                                  selectedIndex: _tabController.index,
                                ),
                              ),
                              Tab(
                                child: TabContent(
                                  icon: Icons.video_library,
                                  label: currentTranslations['videosTitle'] ?? 'Videos',
                                  currentIndex: 1,
                                  selectedIndex: _tabController.index,
                                ),
                              ),
                              Tab(
                                child: TabContent(
                                  icon: Icons.assignment,
                                  label: currentTranslations['testsTitle'] ?? 'Tests',
                                  currentIndex: 2,
                                  selectedIndex: _tabController.index,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Container(
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // Articles Tab
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            textDirection: languageProvider.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                            children: [
                              // Arrow for Previous Article (Up Arrow)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_upward,
                                  size: 30,
                                  color: isUpArrowClicked
                                      ? Colors.greenAccent
                                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentIndex = (currentIndex - 1 + articles.length) % articles.length;
                                  });
                                  changeArrowColor(true);
                                },
                                splashRadius: null,
                                splashColor: Colors.transparent,
                                iconSize: 36,
                                padding: EdgeInsets.all(16),
                              ),

                              // Display the current article with vertical swipe gestures
                              Expanded(
                                child: GestureDetector(
                                  onVerticalDragEnd: (details) {
                                    if (details.primaryVelocity! < 0) {
                                      // Swipe Up (Next Article)
                                      setState(() {
                                        currentIndex = (currentIndex + 1) % articles.length;
                                      });
                                    } else if (details.primaryVelocity! > 0) {
                                      // Swipe Down (Previous Article)
                                      setState(() {
                                        currentIndex = (currentIndex - 1 + articles.length) % articles.length;
                                      });
                                    }
                                  },
                                  onTap: () {
                                    _showDoctorOrRegularDialog(context, articles[currentIndex]);
                                  },
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 400),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                    child: Directionality(  // Apply Directionality here
                                      textDirection: languageProvider.selectedLanguage == 'Arabic'
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      child: Container(
                                        key: ValueKey<int>(currentIndex),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/article_bg_$currentIndex.jpg'),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withOpacity(0.5),
                                              BlendMode.darken,
                                            ),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 16,
                                              left: 16,
                                              right: 16,
                                              child: Column(
                                                crossAxisAlignment: languageProvider.selectedLanguage == 'Arabic'
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    articles[currentIndex].title,
                                                    style: TextStyle(
                                                      fontFamily: 'Nexa',
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    articles[currentIndex].description,
                                                    style: TextStyle(
                                                      fontFamily: 'Nexa',
                                                      fontSize: 16,
                                                      color: Colors.white.withOpacity(0.8),
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Arrow for Next Article (Down Arrow)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_downward,
                                  size: 30,
                                  color: isDownArrowClicked
                                      ? Colors.greenAccent
                                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentIndex = (currentIndex + 1) % articles.length;
                                  });
                                  changeArrowColor(false);
                                },
                                splashRadius: 28,
                                splashColor: Colors.greenAccent,
                                iconSize: 36,
                                padding: EdgeInsets.all(16),
                              ),
                            ],
                          ),
                        ),
                        // Videos Tab
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: videoCategories.length,
                            itemBuilder: (context, index) {
                              final category = videoCategories[index];
                              return VideoCategory(
                                title: category['title'] as String,
                                videos: (category['videos'] as List<dynamic>).cast<VideoItem>(),
                                isExpanded: expandedCategoryIndex == index,
                                controller: categoryControllers[index],
                                onExpansionChanged: (isExpanded) {
                                  setState(() {
                                    if (isExpanded) {
                                      for (var i = 0; i < categoryControllers.length; i++) {
                                        if (i != index) {
                                          categoryControllers[i].collapse();
                                        }
                                      }
                                      expandedCategoryIndex = index;
                                    } else {
                                      expandedCategoryIndex = null;
                                    }
                                  });
                                },
                                originalTitle: category['originalTitle'] as String,  // Pass original title for icon
                              );
                            },
                          ),
                        ),
                        // Tests Tab
                        Center(
                          child: Text(
                            'Tests Section Coming Soon',
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontSize: 18,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isWelcomePlaying)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedAvatar != null)
                      Consumer<AvatarProvider>(
                        builder: (context, avatarProvider, child) => Image.asset(
                          avatarProvider.selectedAvatar,
                          height: 150,
                          width: 150,
                        ),
                      ),
                    SizedBox(height: 20),
                    _buildSoundWave(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

}

class TabContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final int currentIndex; // Add currentIndex as a parameter
  final int selectedIndex; // Add selectedIndex to compare

  const TabContent({
    Key? key,
    required this.icon,
    required this.label,
    required this.currentIndex, // Add required currentIndex
    required this.selectedIndex, // Add required selectedIndex
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: selectedIndex == currentIndex // Check for current index
              ? Colors.white
              : Color(0xFF5EFF8B),
        ),
        if (selectedIndex == currentIndex) // Show label only if selected
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

