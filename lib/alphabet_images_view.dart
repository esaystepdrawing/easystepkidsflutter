import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

/// Maps each English letter to its available image asset names.
/// Images live in assets/images/A/Apple.png, assets/images/B/Ball.png etc.
class AlphabetImageRegistry {
  static const Map<String, List<String>> images = {
    'A': ['Apple','Airplane','Alligator','Ant','Ambulance','Anchor','Angel','Apron','Astronaut','Avocado','Acron','Allium'],
    'B': ['Banana','Bear','Bird','Boat','Book','Bus','Butterfly','Bag','Basket','Bell','Ballon'],
    'C': ['Car','Cake','Carrot','Clock','Cloud','Cookie','Corn','Cow','Cup','Cactus','Cap','Clay-pot'],
    'D': ['Duck','Dolphin','Drum','Door','Dates','Diamond','Dice','Donut'],
    'E': ['Eagle','Egg','Elephant','Envelope','Earth','Ear','Eggplant','Emu','Eraser','Elm-tree','Ear-of-Corn'],
    'F': ['Fish','Flower','Fan','Feather','Flamingo','Fries','Fruit','Fruits'],
    'G': ['Giraffe','Gate','Gift','Girl','Glasses','Goldfish','Gorilla','Grass','Guava'],
    'H': ['Horse','House','Hat','Heart','Hen','Helicopter','Hamburger','Hand','Hippopotamus','Honey','Hot-Air-Balloon','Hut'],
    'I': ['Igloo','Ice-cream','Idea','Inch','India','Ink','Insect','Invite','Iron','Island'],
    'J': ['Jellyfish','Juice','Jacket','Jackfruit','Jaguar','Jam','Jeep','Jelly','Judge','Jump'],
    'K': ['Kangaroo','Knowledge','Koala','Kaleidoscope','Knight','Karate','Kettle','Keyboard','King','Kitchen','Kiwi','Knot'],
    'L': ['Lion','Leaf','Lamp','Lemon','Ladybug','Lighthouse','Lollipop','Ladder','Landscape','Learn','Letter','Lovebird','Lunchbox'],
    'M': ['Monkey','Moon','Mouse','Mango','Mirror','Mountain','Mug','Mushroom','Mailbox','Marigold','Mat','Motorcycle','Mother'],
    'N': ['Nature','Nest','Nurse','Needle-Thread','Newspaper','Night','Nine','Noodles','Nose','Notebook','Nuts','Nelumbo','Newborn'],
    'O': ['Octopus','Orange','Owl','Ocean-paint','Oil','Olive','Omelette','Onion','Open-Box','Ostrich','Oven','Ox'],
    'P': ['Panda','Peacock','Pencil-case','Pear','Pizza','Pig','Puppy','Picture','Plant','Pot','Pouch','Present'],
    'Q': ['Queen','Quill','Quail','Quarter','Question','Quick','Quiet','Quilt','Quinoa','Quokka'],
    'R': ['Rabbit','Rainbow','Rose','Radio','Railway','Rat','Red-Apple','Refrigerator','Reward','Road','Rope','Rug'],
    'S': ['Star','Sunflower','Snake','Sheep','Ship','Shoes','Soap','Socks','Soup','Squirrel','Strawberry','School-Bus','Shell','Scarf'],
    'T': ['Tiger','Tree','Turtle','Train','Tea','Teddy-Bear','Telephone','Television','Tent','Tiger','Time','Tissue','Tomato','Tractor'],
    'U': ['Umbrella','Unicorn-Bag','Ukulele','Uncle','Uniform','Universe','Urchin','Urn','Utensils','Uva-Grapes','Umbrella-Pink'],
    'V': ['Violin','Volcano','Van','Vase','Vegetables-Basket','Vessel','Vest','Veterinarian','View','Vine','Vulture'],
    'W': ['Wolf','Whale','Watch','Watermelon','Wagon','Wad-of-Cash','Water','Windmill','Window','Winter','Witch','Wool','World','Woven-Basket'],
    'X': ['Xylophone','X-ray','X-mas-Tree','X-ray-Vision','Xerus','Ximenia','Xiphias-Swordfish','Xylo-Toy'],
    'Y': ['Yak','Yarn','Yo-yo','Yacht','Yam','Yogurt','Yew-Tree','You-Did-It','Yam-Dish', 'Yours'],
    'Z': ['Zoo','Zipper','Zero','Zest','Zigzag-Pattern','Zipper-Bag','Zither','Zone','Zookeeper','Zucchini','Zzz'],
  };

  static List<String> randomImages(String letter, {int count = 4}) {
    final key = letter.toUpperCase();
    final available = List<String>.from(images[key] ?? []);
    available.shuffle();
    return available.take(count).toList();
  }

  // Multilingual labels for each image
  static const Map<String, Map<String, String>> labels = {
    'Apple':    {'en':'Apple',   'hi':'सेब',     'te':'ఆపిల్',  'ta':'ஆப்பிள்', 'gu':'સફરજન', 'mr':'सफरचंद','ml':'ആപ്പിൾ', 'kn':'ಸೇಬು',  'es':'Manzana','de':'Apfel', 'fr':'Pomme', 'pt':'Maçã',   'ja':'りんご','zh':'苹果'},
    'Airplane': {'en':'Airplane','hi':'हवाई जहाज','te':'విమానం', 'ta':'விமானம்', 'gu':'વિમાન',  'mr':'विमान', 'ml':'വിമാനം','kn':'ವಿಮಾನ', 'es':'Avión',  'de':'Flugzeug','fr':'Avion','pt':'Avião', 'ja':'ひこうき','zh':'飞机'},
    'Ant':      {'en':'Ant',     'hi':'चींटी',   'te':'చీమ',    'ta':'எறும்பு', 'gu':'કીડી',   'mr':'मुंगी', 'ml':'ഉറുമ്പ്','kn':'ಇರುವೆ', 'es':'Hormiga','de':'Ameise','fr':'Fourmi','pt':'Formiga','ja':'あり', 'zh':'蚂蚁'},
    'Ball':     {'en':'Ball',    'hi':'गेंद',    'te':'బంతి',   'ta':'பந்து',   'gu':'દડો',    'mr':'चेंडू', 'ml':'പന്ത്', 'kn':'ಚೆಂಡು', 'es':'Pelota', 'de':'Ball',  'fr':'Balle', 'pt':'Bola',   'ja':'ボール','zh':'球'},
    'Banana':   {'en':'Banana',  'hi':'केला',    'te':'అరటి',   'ta':'வாழை',    'gu':'કેળું',  'mr':'केळ',   'ml':'വാഴ',  'kn':'ಬಾಳೆ',  'es':'Plátano','de':'Banane','fr':'Banane','pt':'Banana', 'ja':'バナナ','zh':'香蕉'},
    'Bear':     {'en':'Bear',    'hi':'भालू',    'te':'ఎలుగు',  'ta':'கரடி',    'gu':'રીંછ',   'mr':'अस्वल','ml':'കരടി', 'kn':'ಕರಡಿ',  'es':'Oso',    'de':'Bär',   'fr':'Ours',  'pt':'Urso',   'ja':'くま', 'zh':'熊'},
    'Bird':     {'en':'Bird',    'hi':'पक्षी',   'te':'పక్షి',  'ta':'பறவை',    'gu':'પક્ષી',  'mr':'पक्षी', 'ml':'പക്ഷി','kn':'ಹಕ್ಕಿ',  'es':'Pájaro', 'de':'Vogel', 'fr':'Oiseau','pt':'Pássaro','ja':'とり', 'zh':'鸟'},
    'Cat':      {'en':'Cat',     'hi':'बिल्ली',  'te':'పిల్లి', 'ta':'பூனை',    'gu':'બિલાડી', 'mr':'मांजर','ml':'പൂച്ച', 'kn':'ಬೆಕ್ಕು', 'es':'Gato',   'de':'Katze', 'fr':'Chat',  'pt':'Gato',   'ja':'ねこ', 'zh':'猫'},
    'Dog':      {'en':'Dog',     'hi':'कुत्ता',  'te':'కుక్క',  'ta':'நாய்',    'gu':'કૂતરો',  'mr':'कुत्रा','ml':'പട്ടി', 'kn':'ನಾಯಿ',  'es':'Perro',  'de':'Hund',  'fr':'Chien', 'pt':'Cachorro','ja':'いぬ','zh':'狗'},
    'Fish':     {'en':'Fish',    'hi':'मछली',    'te':'చేప',    'ta':'மீன்',    'gu':'માછলી',  'mr':'मासा',  'ml':'മീൻ',  'kn':'ಮೀನು',  'es':'Pez',    'de':'Fisch', 'fr':'Poisson','pt':'Peixe', 'ja':'さかな','zh':'鱼'},
    'House':    {'en':'House',   'hi':'घर',      'te':'ఇల్లు',  'ta':'வீடு',    'gu':'ઘર',     'mr':'घर',    'ml':'വീട്', 'kn':'ಮನೆ',   'es':'Casa',   'de':'Haus',  'fr':'Maison','pt':'Casa',   'ja':'いえ', 'zh':'房子'},
    'Moon':     {'en':'Moon',    'hi':'चाँद',    'te':'చంద్రుడు','ta':'நிலவு',  'gu':'ચંદ્ર',   'mr':'चंद्र', 'ml':'ചന്ദ്രൻ','kn':'ಚಂದ್ರ','es':'Luna',   'de':'Mond',  'fr':'Lune',  'pt':'Lua',    'ja':'つき', 'zh':'月亮'},
    'Sun':      {'en':'Sun',     'hi':'सूरज',    'te':'సూర్యుడు','ta':'சூரியன்','gu':'સૂર્ય',  'mr':'सूर्य', 'ml':'സൂര്യൻ','kn':'ಸೂರ್ಯ','es':'Sol',    'de':'Sonne', 'fr':'Soleil','pt':'Sol',    'ja':'たいよう','zh':'太阳'},
    'Tree':     {'en':'Tree',    'hi':'पेड़',    'te':'చెట్టు', 'ta':'மரம்',    'gu':'ઝાડ',    'mr':'झाड',   'ml':'മരം',  'kn':'ಮರ',    'es':'Árbol',  'de':'Baum',  'fr':'Arbre', 'pt':'Árvore', 'ja':'き',   'zh':'树'},
    'Star':     {'en':'Star',    'hi':'तारा',    'te':'నక్షత్రం','ta':'நட்சத்திரம்','gu':'તારો','mr':'तारा','ml':'നക്ഷത്രം','kn':'ನಕ್ಷತ್ರ','es':'Estrella','de':'Stern','fr':'Étoile','pt':'Estrela','ja':'ほし','zh':'星星'},
    'Lion':     {'en':'Lion',    'hi':'शेर',     'te':'సింహం',  'ta':'சிங்கம்', 'gu':'સિંહ',   'mr':'सिंह',  'ml':'സിംഹം','kn':'ಸಿಂಹ',  'es':'León',   'de':'Löwe',  'fr':'Lion',  'pt':'Leão',   'ja':'らいおん','zh':'狮子'},
    'Elephant': {'en':'Elephant','hi':'हाथी',    'te':'ఏనుగు',  'ta':'யானை',    'gu':'હાથી',   'mr':'हत्ती', 'ml':'ആന',   'kn':'ಆನೆ',   'es':'Elefante','de':'Elefant','fr':'Éléphant','pt':'Elefante','ja':'ぞう','zh':'大象'},
    'Umbrella': {'en':'Umbrella','hi':'छाता',    'te':'గొడుగు', 'ta':'குடை',    'gu':'છત્રી',  'mr':'छत्री', 'ml':'കുട',  'kn':'ಛತ್ರಿ', 'es':'Paraguas','de':'Regenschirm','fr':'Parapluie','pt':'Guarda-chuva','ja':'かさ','zh':'伞'},
    'Zebra':    {'en':'Zebra',   'hi':'ज़ेबरा',  'te':'జీబ్రా', 'ta':'வரிக்குதிரை','gu':'ઝીબ્રા','mr':'झेब्रा','ml':'സീബ്ര','kn':'ಝೀಬ್ರಾ','es':'Cebra', 'de':'Zebra', 'fr':'Zèbre', 'pt':'Zebra',  'ja':'しまうま','zh':'斑马'},
  };

  static String labelFor(String imageName, String languageId) {
    return labels[imageName]?[languageId]
        ?? labels[imageName]?['en']
        ?? imageName.replaceAll('-', ' ');
  }
}

// ── Main widget ──────────────────────────────────────────────────────

class AlphabetImagesView extends StatefulWidget {
  const AlphabetImagesView({
    required this.letter,
    required this.language,
    super.key,
  });

  final String letter;
  final AppLanguage language;

  @override
  State<AlphabetImagesView> createState() => _AlphabetImagesViewState();
}

class _AlphabetImagesViewState extends State<AlphabetImagesView>
    with SingleTickerProviderStateMixin {
  List<String> _imageNames = [];
  int? _bouncedSlot;
  bool _celebrating = false;
  late AnimationController _shuffleController;

  final _random = Random();
  final _burstParticles = <_Particle>[];
  bool _showParticles = false;

  static const _burstColors = [
    Colors.red, Colors.orange, Colors.yellow,
    Colors.green, Colors.blue, Colors.purple, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadImages();
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    super.dispose();
  }

  void _loadImages() {
    setState(() {
      _imageNames = AlphabetImageRegistry.randomImages(widget.letter);
    });
  }

  void _onShuffleTap(BuildContext context) {
    _loadImages();
    _shuffleController.forward(from: 0);
    setState(() => _celebrating = true);
    _triggerBurst(context);
    context.read<TTSProvider>().speak(
        widget.letter.toLowerCase(), widget.language.speechCode);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _celebrating = false);
    });
  }

  void _onTileTap(String name, int slot) {
    setState(() => _bouncedSlot = slot);
    final label = AlphabetImageRegistry.labelFor(name, widget.language.id);
    context.read<TTSProvider>().speak(label, widget.language.speechCode);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _bouncedSlot = null);
    });
  }

  void _triggerBurst(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = 80.0;
    _burstParticles.clear();
    for (int i = 0; i < 24; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 60 + _random.nextDouble() * 120;
      _burstParticles.add(_Particle(
        x: cx, y: cy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: _burstColors[_random.nextInt(_burstColors.length)],
        size: 6 + _random.nextDouble() * 10,
      ));
    }
    setState(() => _showParticles = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showParticles = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tint = Category.alphabets.tint;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _tile(_imageNames.isNotEmpty ? _imageNames[0] : '', 0, tint)),
                  const SizedBox(width: 10),
                  _shuffleButton(context, tint),
                  const SizedBox(width: 10),
                  Expanded(child: _tile(_imageNames.length > 1 ? _imageNames[1] : '', 1, tint)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _tile(_imageNames.length > 2 ? _imageNames[2] : '', 2, tint)),
                  const SizedBox(width: 54 + 20), // spacer matching shuffle button
                  Expanded(child: _tile(_imageNames.length > 3 ? _imageNames[3] : '', 3, tint)),
                ],
              ),
            ],
          ),
        ),
        if (_showParticles)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(_burstParticles),
              ),
            ),
          ),
      ],
    );
  }

  Widget _shuffleButton(BuildContext context, Color tint) {
    return GestureDetector(
      onTap: () => _onShuffleTap(context),
      child: AnimatedScale(
        scale: _celebrating ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: RotationTransition(
          turns: _shuffleController,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [tint, tint.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: tint.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.shuffle, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _tile(String name, int slot, Color tint) {
    if (name.isEmpty) return const SizedBox();
    final bounced = _bouncedSlot == slot;
    final label = AlphabetImageRegistry.labelFor(name, widget.language.id);

    return GestureDetector(
      onTap: () => _onTileTap(name, slot),
      child: AnimatedScale(
        scale: bounced ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: tint.withOpacity(bounced ? 0.7 : 0.2),
                  width: bounced ? 2.5 : 1,
                ),
              ),
              child: Image.asset(
                'assets/images/${widget.letter.toUpperCase()}/$name.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  color: tint.withOpacity(0.4),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Particle helpers ─────────────────────────────────────────────────

class _Particle {
  double x, y, vx, vy, size;
  Color color;
  _Particle({required this.x, required this.y, required this.vx,
    required this.vy, required this.color, required this.size});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x + p.vx * 0.5, p.y + p.vy * 0.5),
        p.size / 2,
        Paint()..color = p.color.withOpacity(0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}