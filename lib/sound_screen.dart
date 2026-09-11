import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'models.dart';

// ── Sound data ────────────────────────────────────────────────────────

class SoundItem {
  final String name;
  final String emoji;
  final String audioFile;   // filename in assets/sounds/
  final String imageName;   // asset image name (optional)
  final Color color;

  const SoundItem({
    required this.name,
    required this.emoji,
    required this.audioFile,
    this.imageName = '',
    required this.color,
  });
}

class SoundDataset {
  static const List<SoundItem> items = [
    SoundItem(name: 'Cat',        emoji: '🐱', audioFile: 'cat.m4a',        color: Color(0xFFFF8C00)),
    SoundItem(name: 'Dog',        emoji: '🐶', audioFile: 'dog.m4a',        color: Color(0xFF8B4513)),
    SoundItem(name: 'Cow',        emoji: '🐄', audioFile: 'cow.m4a',        color: Color(0xFF3B6CF4)),
    SoundItem(name: 'Lion',       emoji: '🦁', audioFile: 'lion.m4a',       color: Color(0xFFD97706)),
    SoundItem(name: 'Elephant',   emoji: '🐘', audioFile: 'elephant.m4a',   color: Color(0xFF9B59B6)),
    SoundItem(name: 'Horse',      emoji: '🐴', audioFile: 'horse.m4a',      color: Color(0xFF8B4513)),
    SoundItem(name: 'Frog',       emoji: '🐸', audioFile: 'frog.m4a',       color: Color(0xFF22A740)),
    SoundItem(name: 'Duck',       emoji: '🦆', audioFile: 'duck.m4a',       color: Color(0xFFFF6B1A)),
    SoundItem(name: 'Rooster',    emoji: '🐓', audioFile: 'rooster.m4a',    color: Color(0xFFE84545)),
    SoundItem(name: 'Airplane',   emoji: '✈️', audioFile: 'airplane.m4a',   color: Color(0xFF0891B2)),
    SoundItem(name: 'Helicopter', emoji: '🚁', audioFile: 'helicopter.m4a', color: Color(0xFF7C5CDB)),
    SoundItem(name: 'Car',        emoji: '🚗', audioFile: 'car.m4a',        color: Color(0xFFE84545)),
    SoundItem(name: 'Train',      emoji: '🚂', audioFile: 'train.m4a',      color: Color(0xFF3B6CF4)),
    SoundItem(name: 'Boat',       emoji: '⛵', audioFile: 'boat.m4a',       color: Color(0xFF0891B2)),
    SoundItem(name: 'Ambulance',  emoji: '🚑', audioFile: 'ambulance.m4a',  color: Color(0xFFE84545)),
    SoundItem(name: 'Bell',       emoji: '🔔', audioFile: 'bell.m4a',       color: Color(0xFFD97706)),
    SoundItem(name: 'Thunder',    emoji: '⛈️', audioFile: 'thunder.m4a',    color: Color(0xFF3B6CF4)),
    SoundItem(name: 'Rain',       emoji: '🌧️', audioFile: 'rain.m4a',       color: Color(0xFF0891B2)),
    SoundItem(name: 'Wind',       emoji: '🌬️', audioFile: 'wind.m4a',       color: Color(0xFF22A740)),
  ];

  /// Localized name for a sound item
  static String localizedName(SoundItem item, String languageId) {
    const translations = <String, Map<String, String>>{
      'Cat':        {'hi':'बिल्ली','te':'పిల్లి','ta':'பூனை','gu':'બિલાડી','mr':'मांजर','ml':'പൂച്ച','kn':'ಬೆಕ್ಕು','ur':'بلی','es':'Gato','de':'Katze','fr':'Chat','pt':'Gato','ja':'ねこ','zh':'猫'},
      'Dog':        {'hi':'कुत्ता','te':'కుక్క','ta':'நாய்','gu':'કૂતરો','mr':'कुत्रा','ml':'പട്ടി','kn':'ನಾಯಿ','ur':'کتا','es':'Perro','de':'Hund','fr':'Chien','pt':'Cachorro','ja':'いぬ','zh':'狗'},
      'Lion':       {'hi':'शेर','te':'సింహం','ta':'சிங்கம்','gu':'સિંહ','mr':'सिंह','ml':'സിംഹം','kn':'ಸಿಂಹ','ur':'شیر','es':'León','de':'Löwe','fr':'Lion','pt':'Leão','ja':'らいおん','zh':'狮子'},
      'Elephant':   {'hi':'हाथी','te':'ఏనుగు','ta':'யானை','gu':'હાથી','mr':'हत्ती','ml':'ആന','kn':'ಆನೆ','ur':'ہاتھی','es':'Elefante','de':'Elefant','fr':'Éléphant','pt':'Elefante','ja':'ぞう','zh':'大象'},
      'Cow':        {'hi':'गाय','te':'ఆవు','ta':'பசு','gu':'ગાય','mr':'गाय','ml':'പശു','kn':'ಹಸು','ur':'گائے','es':'Vaca','de':'Kuh','fr':'Vache','pt':'Vaca','ja':'うし','zh':'牛'},
      'Horse':      {'hi':'घोड़ा','te':'గుర్రం','ta':'குதிரை','gu':'ઘોડો','mr':'घोडा','ml':'കുതിര','kn':'ಕುದುರೆ','ur':'گھوڑا','es':'Caballo','de':'Pferd','fr':'Cheval','pt':'Cavalo','ja':'うま','zh':'马'},
      'Frog':       {'hi':'मेंढक','te':'కప్ప','ta':'தவளை','gu':'દેડકો','mr':'बेडूक','ml':'തവള','kn':'ಕಪ್ಪೆ','ur':'مینڈک','es':'Rana','de':'Frosch','fr':'Grenouille','pt':'Rã','ja':'かえる','zh':'青蛙'},
      'Bird':       {'hi':'पक्षी','te':'పక్షి','ta':'பறவை','gu':'પક્ષી','mr':'पक्षी','ml':'പക്ഷി','kn':'ಹಕ್ಕಿ','ur':'پرندہ','es':'Pájaro','de':'Vogel','fr':'Oiseau','pt':'Pássaro','ja':'とり','zh':'鸟'},
      'Duck':       {'hi':'बतख','te':'బాతు','ta':'வாத்து','gu':'બતક','mr':'બદક','ml':'താറാവ്','kn':'ಬಾತುಕೋಳಿ','ur':'بطخ','es':'Pato','de':'Ente','fr':'Canard','pt':'Pato','ja':'あひる','zh':'鸭子'},
      'Sheep':      {'hi':'भेड़','te':'గొర్రె','ta':'ஆடு','gu':'ઘેટું','mr':'मेंढी','ml':'ആട്','kn':'ಕುರಿ','ur':'بھیڑ','es':'Oveja','de':'Schaf','fr':'Mouton','pt':'Ovelha','ja':'ひつじ','zh':'羊'},
      'Monkey':     {'hi':'बंदर','te':'కోతి','ta':'குரங்கு','gu':'વાંદરો','mr':'माकड','ml':'കുരങ്ങ്','kn':'ಕೋತಿ','ur':'بندر','es':'Mono','de':'Affe','fr':'Singe','pt':'Macaco','ja':'さる','zh':'猴子'},
      'Owl':        {'hi':'उल्लू','te':'గుడ్లగూబ','ta':'ஆந்தை','gu':'ઘુવડ','mr':'घुबड','ml':'മൂങ്ങ','kn':'ಗೂಬೆ','ur':'الو','es':'Búho','de':'Eule','fr':'Chouette','pt':'Coruja','ja':'ふくろう','zh':'猫头鹰'},
      'Bee':        {'hi':'मधुमक्खी','te':'తేనెటీగ','ta':'தேனீ','gu':'મધમાખી','mr':'मधमाशी','ml':'തേനീച്ച','kn':'ಜೇನುನೊಣ','ur':'شہد کی مکھی','es':'Abeja','de':'Biene','fr':'Abeille','pt':'Abelha','ja':'みつばち','zh':'蜜蜂'},
      'Snake':      {'hi':'साँप','te':'పాము','ta':'பாம்பு','gu':'સાપ','mr':'साप','ml':'പാമ്പ്','kn':'ಹಾವು','ur':'سانپ','es':'Serpiente','de':'Schlange','fr':'Serpent','pt':'Cobra','ja':'へび','zh':'蛇'},
      'Rooster':    {'hi':'मुर्गा','te':'కోడి','ta':'சேவல்','gu':'મરઘો','mr':'कोंबडा','ml':'കോഴി','kn':'ಹುಂಜ','ur':'مرغ','es':'Gallo','de':'Hahn','fr':'Coq','pt':'Galo','ja':'おんどり','zh':'公鸡'},
      'Wolf':       {'hi':'भेड़िया','te':'తోడేలు','ta':'ஓநாய்','gu':'વરુ','mr':'लांडगा','ml':'ചെന്നായ','kn':'ತೋಳ','ur':'بھیڑیا','es':'Lobo','de':'Wolf','fr':'Loup','pt':'Lobo','ja':'おおかみ','zh':'狼'},
      'Dolphin':    {'hi':'डॉल्फिन','te':'డాల్ఫిన్','ta':'டால்ஃபின்','gu':'ડોલ્ફિન','mr':'डॉल्फिन','ml':'ഡോൾഫിൻ','kn':'ಡಾಲ್ಫಿನ್','ur':'ڈولفن','es':'Delfín','de':'Delfin','fr':'Dauphin','pt':'Golfinho','ja':'いるか','zh':'海豚'},
      'Thunder':    {'hi':'गड़गड़ाहट','te':'ఉరుము','ta':'இடி','gu':'ગર્જના','mr':'गडगडाट','ml':'ഇടി','kn':'ಗುಡುಗು','ur':'گرج','es':'Trueno','de':'Donner','fr':'Tonnerre','pt':'Trovão','ja':'かみなり','zh':'雷声'},
      'Rain':       {'hi':'बारिश','te':'వర్షం','ta':'மழை','gu':'વરસાદ','mr':'पाऊस','ml':'മഴ','kn':'ಮಳೆ','ur':'بارش','es':'Lluvia','de':'Regen','fr':'Pluie','pt':'Chuva','ja':'あめ','zh':'雨'},
      'Fire':       {'hi':'आग','te':'అగ్ని','ta':'தீ','gu':'આગ','mr':'आग','ml':'തീ','kn':'ಬೆಂಕಿ','ur':'آگ','es':'Fuego','de':'Feuer','fr':'Feu','pt':'Fogo','ja':'ひ','zh':'火'},
      'Airplane':   {'hi':'हवाई जहाज','te':'విమానం','ta':'விமானம்','gu':'વિમાન','mr':'વિમાન','ml':'വിമാനം','kn':'ವಿಮಾನ','ur':'ہوائی جہاز','es':'Avión','de':'Flugzeug','fr':'Avion','pt':'Avião','ja':'ひこうき','zh':'飞机'},
      'Helicopter': {'hi':'हेलीकॉप्टर','te':'హెలికాప్టర్','ta':'ஹெலிகாப்டர்','gu':'હેલિકોપ્ટર','mr':'हेलिकॉप्टर','ml':'ഹെലികോപ്റ്റർ','kn':'ಹೆಲಿಕಾಪ್ಟರ್','ur':'ہیلی کاپٹر','es':'Helicóptero','de':'Hubschrauber','fr':'Hélicoptère','pt':'Helicóptero','ja':'ヘリコプター','zh':'直升机'},
      'Car':        {'hi':'कार','te':'కారు','ta':'கார்','gu':'કાર','mr':'कार','ml':'കാർ','kn':'ಕಾರು','ur':'کار','es':'Coche','de':'Auto','fr':'Voiture','pt':'Carro','ja':'くるま','zh':'汽车'},
      'Train':      {'hi':'ट्रेन','te':'రైలు','ta':'ரயில்','gu':'ટ્રેન','mr':'ट्रेन','ml':'ട്രെയിൻ','kn':'ರೈಲು','ur':'ٹرین','es':'Tren','de':'Zug','fr':'Train','pt':'Trem','ja':'でんしゃ','zh':'火车'},
      'Boat':       {'hi':'नाव','te':'పడవ','ta':'படகு','gu':'નાવ','mr':'नाव','ml':'ബോട്ട്','kn':'ದೋಣಿ','ur':'کشتی','es':'Barco','de':'Boot','fr':'Bateau','pt':'Barco','ja':'ボート','zh':'船'},
      'Ambulance':  {'hi':'एम्बुलेंस','te':'అంబులెన్స్','ta':'ஆம்புலன்ஸ்','gu':'એમ્બ્યુલન્સ','mr':'रुग्णवाहिका','ml':'ആംബുലൻസ്','kn':'ಆಂಬ್ಯುಲೆನ್ಸ್','ur':'ایمبولینس','es':'Ambulancia','de':'Krankenwagen','fr':'Ambulance','pt':'Ambulância','ja':'きゅうきゅうしゃ','zh':'救护车'},
      'Bell':       {'hi':'घंटी','te':'గంట','ta':'மணி','gu':'ઘંટ','mr':'घंटा','ml':'മണി','kn':'ಗಂಟೆ','ur':'گھنٹی','es':'Campana','de':'Glocke','fr':'Cloche','pt':'Sino','ja':'かね','zh':'铃'},
      'Wind':       {'hi':'हवा','te':'గాలి','ta':'காற்று','gu':'પવન','mr':'वारा','ml':'കാറ്റ്','kn':'ಗಾಳಿ','ur':'ہوا','es':'Viento','de':'Wind','fr':'Vent','pt':'Vento','ja':'かぜ','zh':'风'},
    }; // <-- Added closing brace & semicolon here

    return translations[item.name]?[languageId] ?? item.name;
  }
} // <-- Closed SoundDataset class here

// ── Sound screen ──────────────────────────────────────────────────────

class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key});

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;
  int? _bouncingIndex;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(int index) async {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final item = SoundDataset.items[index];

    // Bounce animation
    setState(() => _bouncingIndex = index);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _bouncingIndex = null);
    });

    // Speak name in current language
    final name = SoundDataset.localizedName(item, lang.id);
    context.read<TTSProvider>().speak(name, lang.speechCode);

    // Play the animal/sound MP3
    setState(() => _playingIndex = index);
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/${item.audioFile}'));
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playingIndex = null);
      });
    } catch (e) {
      // Sound file not found — just use TTS
      debugPrint('Sound file not found: ${item.audioFile}');
      if (mounted) setState(() => _playingIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LanguageProvider>().currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(Category.sounds.localizedTitle(lang.id)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F5FF), Color(0xFFEFF8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Text(
                  'Tap to hear the sound! 🔊',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: SoundDataset.items.length,
                  itemBuilder: (context, i) {
                    final item = SoundDataset.items[i];
                    final isPlaying = _playingIndex == i;
                    final isBouncing = _bouncingIndex == i;
                    final localName =
                    SoundDataset.localizedName(item, lang.id);

                    return GestureDetector(
                      onTap: () => _play(i),
                      child: AnimatedScale(
                        scale: isBouncing ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.elasticOut,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: item.color.withOpacity(
                                    isPlaying ? 0.4 : 0.15),
                                blurRadius: isPlaying ? 12 : 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: isPlaying
                                ? Border.all(
                                color: item.color, width: 2.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Emoji / image
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: item.color.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.emoji,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                  if (isPlaying)
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: item.color.withOpacity(0.6),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Name in current language
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6),
                                child: Text(
                                  localName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isPlaying
                                        ? item.color
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // English name (small, below)
                              if (lang.id != 'en')
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              // Sound wave indicator
                              SizedBox(
                                height: 18,
                                child: AnimatedOpacity(
                                  opacity: isPlaying ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                          (idx) => _SoundBar(
                                          color: item.color, delay: idx * 0.15),
                                    ),
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
          ),
        ),
      ),
    );
  }
}

// ── Animated sound bar ────────────────────────────────────────────────

class _SoundBar extends StatefulWidget {
  const _SoundBar({required this.color, required this.delay});
  final Color color;
  final double delay;

  @override
  State<_SoundBar> createState() => _SoundBarState();
}

class _SoundBarState extends State<_SoundBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 4, end: 16).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(widget.delay, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 3,
        height: _anim.value,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}