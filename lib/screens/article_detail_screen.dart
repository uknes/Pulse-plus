import 'package:flutter/material.dart';
import 'package:pulse_plus/models/article_model.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:math';
import '../providers/language_provider.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  final String userType;
  final String contentType;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ArticleDetailScreen({
    required this.article,
    required this.userType,
    required this.contentType,
  });

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> with SingleTickerProviderStateMixin {
  String? expandedOutcome;
  late AnimationController _lineAnimationController;
  late Animation<double> _lineAnimation;

  // Add translations map
  final Map<String, Map<String, Map<String, String>>> _translations = {
    'English': {
      'outcomes': {
        'shockable': 'Shockable\n(VF/VT)',
        'shockableDesc': 'Deliver one shock',
        'nonShockable': 'Non-Shockable\n(PEA/Asystole)',
        'nonShockableDesc': 'Continue CPR',
        'rosc': 'ROSC',
        'roscDesc': 'Stop CPR',
      },
      'shockableSteps': {
        'assessRhythm': 'Assess Rhythm',
        'assessRhythmDesc': 'Determine the type of cardiac rhythm',
        'initialAssessment': 'Initial Assessment',
        'initialAssessmentDesc': 'Check if the patient is unresponsive with absent or abnormal breathing. If confirmed, immediately call EMS/Resuscitation team.',
        'startCPR': 'Start CPR',
        'startCPRDesc': 'Begin CPR with a ratio of 30 compressions to 2 breaths (CPR 30:2).',
        'attachDefibrillator': 'Attach Defibrillator/Monitor',
        'attachDefibrillatorDesc': 'Attach a defibrillator or monitor to assess the patient\'s cardiac rhythm.',
        'deliverShock': 'Deliver Shock',
        'deliverShockDesc': 'Ensure everyone is clear',
        'resumeCPR': 'Resume CPR',
        'resumeCPRDesc': 'Immediately for 2 minutes',
        'postShockAction': 'Post-Shock Action',
        'postShockActionDesc': 'Immediately resume chest compressions for 2 minutes',
        'reassessRhythm': 'Reassess Rhythm',
        'reassessRhythmDesc': 'After 2 minutes of CPR, reassess the patient\'s rhythm',
        'continueCare': 'Continue Care',
        'continueCareDesc': 'Continue the cycle until advanced care arrives',
      },
      'nonShockableSteps': {
        'continueCPR': 'Continue CPR',
        'continueCPRDesc': 'High-quality compressions',
        'considerCauses': 'Consider Causes',
        'considerCausesDesc': 'Check H\'s and T\'s',
        'nonShockableAction': 'Non-Shockable Action',
        'nonShockableActionDesc': 'Immediately resume chest compressions for 2 minutes',
        'reassessRhythm': 'Reassess Rhythm',
        'reassessRhythmDesc': 'After 2 minutes of CPR, reassess the patient\'s rhythm',
        'continueCare': 'Continue Care',
        'continueCareDesc': 'Continue the cycle until advanced care arrives',
      },
      'roscSteps': {
        'abcdeApproach': 'ABCDE Approach',
        'abcdeApproachDesc': 'Use an ABCDE approach for post-resuscitation care',
        'optimizeOxygenation': 'Optimize Oxygenation',
        'optimizeOxygenationDesc': 'Aim for SpO₂ of 94-98% and normal PaCO₂',
        'ecgAssessment': 'ECG Assessment',
        'ecgAssessmentDesc': '12 Lead ECG monitoring',
        'identifyCause': 'Identify Cause',
        'identifyCauseDesc': 'Identify and treat underlying cause',
        'temperatureControl': 'Temperature Control',
        'temperatureControlDesc': 'Targeted temperature management',
      },
    },
    'French': {
      'outcomes': {
        'shockable': 'Choquable\n(FV/TV)',
        'shockableDesc': 'Délivrer un choc',
        'nonShockable': 'Non-Choquable\n(AEP/Asystolie)',
        'nonShockableDesc': 'Continuer la RCP',
        'rosc': 'RACS',
        'roscDesc': 'Arrêter la RCP',
      },
      'shockableSteps': {
        'assessRhythm': 'Évaluer le Rythme',
        'assessRhythmDesc': 'Déterminer le type de rythme cardiaque',
        'initialAssessment': 'Évaluation Initiale',
        'initialAssessmentDesc': 'Vérifier si le patient est inconscient avec une respiration absente ou anormale. Si confirmé, appeler immédiatement les services d\'urgence/équipe de réanimation.',
        'startCPR': 'Commencer la RCP',
        'startCPRDesc': 'Commencer la RCP avec un ratio de 30 compressions pour 2 insufflations (RCP 30:2).',
        'attachDefibrillator': 'Connecter le Défibrillateur/Moniteur',
        'attachDefibrillatorDesc': 'Connecter un défibrillateur ou un moniteur pour évaluer le rythme cardiaque du patient.',
        'deliverShock': 'Délivrer le Choc',
        'deliverShockDesc': 'S\'assurer que tout le monde est écarté',
        'resumeCPR': 'Reprendre la RCP',
        'resumeCPRDesc': 'Immédiatement pendant 2 minutes',
        'postShockAction': 'Action Post-Choc',
        'postShockActionDesc': 'Reprendre immédiatement les compressions thoraciques pendant 2 minutes',
        'reassessRhythm': 'Réévaluer le Rythme',
        'reassessRhythmDesc': 'Après 2 minutes de RCP, réévaluer le rythme du patient',
        'continueCare': 'Poursuivre les Soins',
        'continueCareDesc': 'Continuer le cycle jusqu\'à l\'arrivée des soins avancés',
      },
      'nonShockableSteps': {
        'continueCPR': 'Continuer la RCP',
        'continueCPRDesc': 'Compressions de haute qualité',
        'considerCauses': 'Considérer les Causes',
        'considerCausesDesc': 'Vérifier les H et les T',
        'nonShockableAction': 'Action Non-Choquable',
        'nonShockableActionDesc': 'Reprendre immédiatement les compressions thoraciques pendant 2 minutes',
        'reassessRhythm': 'Réévaluer le Rythme',
        'reassessRhythmDesc': 'Après 2 minutes de RCP, réévaluer le rythme du patient',
        'continueCare': 'Poursuivre les Soins',
        'continueCareDesc': 'Continuer le cycle jusqu\'à l\'arrivée des soins avancés',
      },
      'roscSteps': {
        'abcdeApproach': 'Approche ABCDE',
        'abcdeApproachDesc': 'Utiliser une approche ABCDE pour les soins post-réanimation',
        'optimizeOxygenation': 'Optimiser l\'Oxygénation',
        'optimizeOxygenationDesc': 'Viser une SpO₂ de 94-98% et une PaCO₂ normale',
        'ecgAssessment': 'Évaluation ECG',
        'ecgAssessmentDesc': 'Surveillance ECG à 12 dérivations',
        'identifyCause': 'Identifier la Cause',
        'identifyCauseDesc': 'Identifier et traiter la cause sous-jacente',
        'temperatureControl': 'Contrôle de la Température',
        'temperatureControlDesc': 'Gestion ciblée de la température',
      },
    },
    'Arabic': {
      'outcomes': {
        'shockable': 'قابل للصدمة\n(VF/VT)',
        'shockableDesc': 'تقديم صدمة كهربائية',
        'nonShockable': 'غير قابل للصدمة\n(PEA/Asystole)',
        'nonShockableDesc': 'مواصلة الإنعاش القلبي الرئوي',
        'rosc': 'عودة التدوير التلقائي',
        'roscDesc': 'توقف عن الإنعاش',
      },
      'shockableSteps': {
        'assessRhythm': 'تقييم النظم',
        'assessRhythmDesc': 'تحديد نوع النظم القلبي',
        'initialAssessment': 'التقييم الأولي',
        'initialAssessmentDesc': 'تحقق مما إذا كان المريض غير مستجيب مع تنفس غائب أو غير طبيعي. إذا تأكد ذلك، اتصل فوراً بخدمات الطوارئ/فريق الإنعاش.',
        'startCPR': 'بدء الإنعاش القلبي الرئوي',
        'startCPRDesc': 'ابدأ الإنعاش القلبي الرئوي بنسبة 30 ضغطة إلى 2 نفس (الإنعاش 30:2).',
        'attachDefibrillator': 'توصيل جهاز إزالة الرجفان/المراقبة',
        'attachDefibrillatorDesc': 'قم بتوصيل جهاز إزالة الرجفان أو المراقبة لتقييم نظم القلب للمريض.',
        'deliverShock': 'تقديم الصدمة',
        'deliverShockDesc': 'التأكد من ابتعاد الجميع',
        'resumeCPR': 'استئناف الإنعاش',
        'resumeCPRDesc': 'فوراً لمدة دقيقتين',
        'postShockAction': 'إجراء ما بعد الصدمة',
        'postShockActionDesc': 'استئناف ضغط الصدر فوراً لمدة دقيقتين',
        'reassessRhythm': 'إعادة تقييم النظم',
        'reassessRhythmDesc': 'بعد دقيقتين من الإنعاش، إعادة تقييم نظم القلب',
        'continueCare': 'مواصلة الرعاية',
        'continueCareDesc': 'الاستمرار في الدورة حتى وصول الرعاية المتقدمة',
      },
      'nonShockableSteps': {
        'continueCPR': 'مواصلة الإنعاش',
        'continueCPRDesc': 'ضغطات عالية الجودة',
        'considerCauses': 'النظر في الأسباب',
        'considerCausesDesc': 'التحقق من H\'s و T\'s',
        'nonShockableAction': 'إجراء غير قابل للصدمة',
        'nonShockableActionDesc': 'استئناف ضغط الصدر فوراً لمدة دقيقتين',
        'reassessRhythm': 'إعادة تقييم النظم',
        'reassessRhythmDesc': 'بعد دقيقتين من الإنعاش، إعادة تقييم نظم القلب',
        'continueCare': 'مواصلة الرعاية',
        'continueCareDesc': 'الاستمرار في الدورة حتى وصول الرعاية المتقدمة',
      },
      'roscSteps': {
        'abcdeApproach': 'نهج ABCDE',
        'abcdeApproachDesc': 'استخدام نهج ABCDE للرعاية بعد الإنعاش',
        'optimizeOxygenation': 'تحسين الأكسجة',
        'optimizeOxygenationDesc': 'استهداف SpO₂ 94-98% و PaCO₂ طبيعي',
        'ecgAssessment': 'تقييم تخطيط القلب',
        'ecgAssessmentDesc': 'مراقبة تخطيط القلب بـ 12 توصيلة',
        'identifyCause': 'تحديد السبب',
        'identifyCauseDesc': 'تحديد ومعالجة السبب الأساسي',
        'temperatureControl': 'التحكم في درجة الحرارة',
        'temperatureControlDesc': 'إدارة درجة الحرارة المستهدفة',
      },
    },
  };

  String _getTranslatedText(String category, String key) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.selectedLanguage;
    return _translations[currentLanguage]?[category]?[key] ?? 
           _translations['English']![category]![key]!;
  }

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers
    _lineAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _lineAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _lineAnimationController.repeat();

    // Set initial outcome after a frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final currentLanguage = languageProvider.selectedLanguage;
      setState(() {
        expandedOutcome = _translations[currentLanguage]?['outcomes']?['rosc'] ?? 'ROSC';
      });
    });
  }

  @override
  void dispose() {
    _lineAnimationController.dispose();
    super.dispose();
  }

  void _handleOutcomeSelection(String title) {
    setState(() {
      if (title != expandedOutcome) {
        expandedOutcome = title;
      }
    });
  }

  Widget _buildOutcomeBox(String outcomeKey, String descriptionKey, IconData icon, bool isDarkMode, Color accentColor) {
    return GestureDetector(
      onTap: () => _handleOutcomeSelection(_getTranslatedText('outcomes', outcomeKey)),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getTranslatedText('outcomes', outcomeKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _getTranslatedText('outcomes', descriptionKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeBoxes(bool isDarkMode) {
    final List<Map<String, dynamic>> outcomes = [
      {
        'outcomeKey': 'shockable',
        'descriptionKey': 'shockableDesc',
        'icon': Icons.flash_on,
        'color': Color(0xFFFF5E5E),
      },
      {
        'outcomeKey': 'rosc',
        'descriptionKey': 'roscDesc',
        'icon': Icons.favorite,
        'color': Color(0xFF5EFF8B),
      },
      {
        'outcomeKey': 'nonShockable',
        'descriptionKey': 'nonShockableDesc',
        'icon': Icons.do_not_disturb,
        'color': Color(0xFFFFB01D),
      },
    ];

    if (expandedOutcome != null) {
      final selectedIndex = outcomes.indexWhere((o) => 
        _getTranslatedText('outcomes', o['outcomeKey']!) == expandedOutcome);
      if (selectedIndex != -1 && selectedIndex != 1) {
        final selectedOutcome = outcomes.removeAt(selectedIndex);
        outcomes.insert(1, selectedOutcome);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: outcomes.map((outcome) => _buildOutcomeBox(
        outcome['outcomeKey']!,
        outcome['descriptionKey']!,
        outcome['icon'] as IconData,
        isDarkMode,
        outcome['color'] as Color,
      )).toList(),
    );
  }

  Widget _buildDecisionBranch(BuildContext context, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Color(0xFF5EFF8B), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF5EFF8B).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.electric_bolt,
                      color: Color(0xFF5EFF8B),
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _getTranslatedText('shockableSteps', 'assessRhythm'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getTranslatedText('shockableSteps', 'assessRhythmDesc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 40,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 40,
                    width: 2,
                    color: Color(0xFF5EFF8B).withOpacity(0.5),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 2,
                    color: Color(0xFF5EFF8B).withOpacity(0.5),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.arrow_downward, color: Color(0xFF5EFF8B)),
                    Icon(Icons.arrow_downward, color: Color(0xFF5EFF8B)),
                    Icon(Icons.arrow_downward, color: Color(0xFF5EFF8B)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildOutcomeBoxes(isDarkMode),
              SizedBox(height: 20),
              if (expandedOutcome == _getTranslatedText('outcomes', 'shockable')) ...[
                Container(
                  height: 40,
                  width: 2,
                  color: Color(0xFFFF5E5E).withOpacity(0.5),
                ),
                _buildAlgorithmStep(
                  context,
                  'deliverShock',
                  'deliverShockDesc',
                  Icons.flash_on,
                  isDarkMode,
                  color: Color(0xFFFF5E5E),
                  category: 'shockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'resumeCPR',
                  'resumeCPRDesc',
                  Icons.favorite,
                  isDarkMode,
                  color: Color(0xFFFF5E5E),
                  category: 'shockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'postShockAction',
                  'postShockActionDesc',
                  Icons.timer,
                  isDarkMode,
                  color: Color(0xFFFF5E5E),
                  category: 'shockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'reassessRhythm',
                  'reassessRhythmDesc',
                  Icons.loop,
                  isDarkMode,
                  color: Color(0xFFFF5E5E),
                  category: 'shockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'continueCare',
                  'continueCareDesc',
                  Icons.health_and_safety,
                  isDarkMode,
                  color: Color(0xFFFF5E5E),
                  category: 'shockableSteps',
                  isLast: true,
                ),
              ] else if (expandedOutcome == _getTranslatedText('outcomes', 'rosc')) ...[
                Container(
                  height: 40,
                  width: 2,
                  color: Color(0xFF5EFF8B).withOpacity(0.5),
                ),
                _buildAlgorithmStep(
                  context,
                  'abcdeApproach',
                  'abcdeApproachDesc',
                  Icons.health_and_safety,
                  isDarkMode,
                  color: Color(0xFF5EFF8B),
                  category: 'roscSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'optimizeOxygenation',
                  'optimizeOxygenationDesc',
                  Icons.monitor_heart,
                  isDarkMode,
                  color: Color(0xFF5EFF8B),
                  category: 'roscSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'ecgAssessment',
                  'ecgAssessmentDesc',
                  Icons.air,
                  isDarkMode,
                  color: Color(0xFF5EFF8B),
                  category: 'roscSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'identifyCause',
                  'identifyCauseDesc',
                  Icons.medical_services,
                  isDarkMode,
                  color: Color(0xFF5EFF8B),
                  category: 'roscSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'temperatureControl',
                  'temperatureControlDesc',
                  Icons.thermostat,
                  isDarkMode,
                  color: Color(0xFF5EFF8B),
                  category: 'roscSteps',
                  isLast: true,
                ),
              ] else if (expandedOutcome == _getTranslatedText('outcomes', 'nonShockable')) ...[
                Container(
                  height: 40,
                  width: 2,
                  color: Color(0xFFFFB01D).withOpacity(0.5),
                ),
                _buildAlgorithmStep(
                  context,
                  'continueCPR',
                  'continueCPRDesc',
                  Icons.favorite,
                  isDarkMode,
                  color: Color(0xFFFFB01D),
                  category: 'nonShockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'considerCauses',
                  'considerCausesDesc',
                  Icons.search,
                  isDarkMode,
                  color: Color(0xFFFFB01D),
                  category: 'nonShockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'nonShockableAction',
                  'nonShockableActionDesc',
                  Icons.timer,
                  isDarkMode,
                  color: Color(0xFFFFB01D),
                  category: 'nonShockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'reassessRhythm',
                  'reassessRhythmDesc',
                  Icons.loop,
                  isDarkMode,
                  color: Color(0xFFFFB01D),
                  category: 'nonShockableSteps',
                ),
                _buildAlgorithmStep(
                  context,
                  'continueCare',
                  'continueCareDesc',
                  Icons.health_and_safety,
                  isDarkMode,
                  color: Color(0xFFFFB01D),
                  category: 'nonShockableSteps',
                  isLast: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLine(Color color) {
    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        return Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: CustomPaint(
            painter: PulsatingLinePainter(
              progress: _lineAnimation.value,
              color: color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlgorithmStep(BuildContext context, String stepKey, String descriptionKey, IconData icon, bool isDarkMode, {bool isDecision = false, bool isLast = false, Color? color, String category = 'shockableSteps'}) {
    final stepColor = color ?? Color(0xFF5EFF8B);
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(isDecision ? 25 : 15),
            border: Border.all(color: stepColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stepColor.withOpacity(0.2),
                    shape: isDecision ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isDecision ? null : BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: stepColor,
                    size: 28,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _getTranslatedText(category, stepKey),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _getTranslatedText(category, descriptionKey),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) ...[
          _buildAnimatedLine(stepColor),
          Icon(
            Icons.arrow_downward,
            color: stepColor,
            size: 24,
          ),
          _buildAnimatedLine(stepColor),
        ],
      ],
    );
  }

  List<Widget> _buildAlgorithmContent(BuildContext context, bool isDarkMode) {
    final bool isAlgorithmArticle = 
      (widget.article.title.contains('Algorithm') || widget.article.title.contains('الخوارزميات')) &&
      (widget.userType == 'Regular User' || widget.userType == 'مستخدم عادي') &&
      (widget.contentType == 'Adult' || widget.contentType == 'بالغ');

    if (isAlgorithmArticle) {
      return [
        _buildAlgorithmStep(
          context,
          'initialAssessment',
          'initialAssessmentDesc',
          Icons.medical_services,
          isDarkMode,
          category: 'shockableSteps',
        ),
        _buildAlgorithmStep(
          context,
          'startCPR',
          'startCPRDesc',
          Icons.favorite,
          isDarkMode,
          category: 'shockableSteps',
        ),
        _buildAlgorithmStep(
          context,
          'attachDefibrillator',
          'attachDefibrillatorDesc',
          Icons.monitor_heart,
          isDarkMode,
          category: 'shockableSteps',
        ),
        _buildDecisionBranch(context, isDarkMode),
      ];
    }
    
    // Return default content for other articles
    return [
      Text(
        widget.article.content,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.article.title,
          style: TextStyle(
            color: Color(0xFF5EFF8B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF5EFF8B)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.article.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5EFF8B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'For: ${widget.userType} - ${widget.contentType}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ..._buildAlgorithmContent(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
}

class PulsatingLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  static const frequency = 2.0;
  static const amplitude = 3.0;

  PulsatingLinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw base line
    final basePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      basePaint,
    );

    // Create pulse effect
    final pulsePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);

    // Calculate wave points
    for (double y = 0; y < size.height; y++) {
      // Create a sine wave that moves up
      final waveProgress = (y / size.height) - progress;
      final x = size.width / 2 + sin(waveProgress * frequency * pi) * amplitude * 
                (1 - pow((y - size.height / 2) / (size.height / 2), 2)).abs();
      
      if (y == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw glow effect
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.2)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Draw main pulse line
    canvas.drawPath(path, pulsePaint);
  }

  @override
  bool shouldRepaint(PulsatingLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


