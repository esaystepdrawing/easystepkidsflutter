/// Words the activities need that are not in the app's content data:
/// the name of each picture and a short "well done" phrase, per language.
/// Numbers and color names come from the app's own data (see kids_language.dart).
///
/// REVIEW NEEDED: drafted, not checked by native speakers.
/// Sanskrit ('sa') and Odia ('or') are the least certain.
class CbnStrings {
  static const subjects = [
    'apple', 'banana', 'grapes', 'strawberry', 'carrot', 'corn', 'pumpkin', 'tomato', 'butterfly', 'elephant', 'fish', 'turtle', 'boat', 'car', 'rocket', 'train', 'barn', 'chicken', 'cow', 'tractor',
  ];

  static const Map<String, List<String>> titles = {
    'en': ['Apple', 'Banana', 'Grapes', 'Strawberry', 'Carrot', 'Corn', 'Pumpkin', 'Tomato', 'Butterfly', 'Elephant', 'Fish', 'Turtle', 'Boat', 'Car', 'Rocket', 'Train', 'Barn', 'Chicken', 'Cow', 'Tractor'],
    'hi': ['सेब', 'केला', 'अंगूर', 'स्ट्रॉबेरी', 'गाजर', 'मक्का', 'कद्दू', 'टमाटर', 'तितली', 'हाथी', 'मछली', 'कछुआ', 'नाव', 'कार', 'रॉकेट', 'रेलगाड़ी', 'खलिहान', 'मुर्गी', 'गाय', 'ट्रैक्टर'],
    'te': ['ఆపిల్', 'అరటిపండు', 'ద్రాక్ష', 'స్ట్రాబెర్రీ', 'క్యారెట్', 'మొక్కజొన్న', 'గుమ్మడికాయ', 'టమాటా', 'సీతాకోకచిలుక', 'ఏనుగు', 'చేప', 'తాబేలు', 'పడవ', 'కారు', 'రాకెట్', 'రైలు', 'కొట్టం', 'కోడి', 'ఆవు', 'ట్రాక్టర్'],
    'ta': ['ஆப்பிள்', 'வாழைப்பழம்', 'திராட்சை', 'ஸ்ட்ராபெர்ரி', 'கேரட்', 'சோளம்', 'பூசணிக்காய்', 'தக்காளி', 'பட்டாம்பூச்சி', 'யானை', 'மீன்', 'ஆமை', 'படகு', 'கார்', 'ராக்கெட்', 'ரயில்', 'களஞ்சியம்', 'கோழி', 'பசு', 'டிராக்டர்'],
    'gu': ['સફરજન', 'કેળું', 'દ્રાક્ષ', 'સ્ટ્રોબેરી', 'ગાજર', 'મકાઈ', 'કોળું', 'ટામેટું', 'પતંગિયું', 'હાથી', 'માછલી', 'કાચબો', 'હોડી', 'કાર', 'રોકેટ', 'ટ્રેન', 'કોઠાર', 'મરઘી', 'ગાય', 'ટ્રેક્ટર'],
    'mr': ['सफरचंद', 'केळे', 'द्राक्षे', 'स्ट्रॉबेरी', 'गाजर', 'मका', 'भोपळा', 'टोमॅटो', 'फुलपाखरू', 'हत्ती', 'मासा', 'कासव', 'होडी', 'कार', 'रॉकेट', 'रेल्वे', 'कोठार', 'कोंबडी', 'गाय', 'ट्रॅक्टर'],
    'ml': ['ആപ്പിൾ', 'വാഴപ്പഴം', 'മുന്തിരി', 'സ്ട്രോബെറി', 'കാരറ്റ്', 'ചോളം', 'മത്തങ്ങ', 'തക്കാളി', 'ചിത്രശലഭം', 'ആന', 'മീൻ', 'ആമ', 'വള്ളം', 'കാർ', 'റോക്കറ്റ്', 'തീവണ്ടി', 'കളപ്പുര', 'കോഴി', 'പശു', 'ട്രാക്ടർ'],
    'kn': ['ಸೇಬು', 'ಬಾಳೆಹಣ್ಣು', 'ದ್ರಾಕ್ಷಿ', 'ಸ್ಟ್ರಾಬೆರಿ', 'ಕ್ಯಾರೆಟ್', 'ಜೋಳ', 'ಕುಂಬಳಕಾಯಿ', 'ಟೊಮೆಟೊ', 'ಚಿಟ್ಟೆ', 'ಆನೆ', 'ಮೀನು', 'ಆಮೆ', 'ದೋಣಿ', 'ಕಾರು', 'ರಾಕೆಟ್', 'ರೈಲು', 'ಕೊಟ್ಟಿಗೆ', 'ಕೋಳಿ', 'ಹಸು', 'ಟ್ರ್ಯಾಕ್ಟರ್'],
    'es': ['Manzana', 'Plátano', 'Uvas', 'Fresa', 'Zanahoria', 'Maíz', 'Calabaza', 'Tomate', 'Mariposa', 'Elefante', 'Pez', 'Tortuga', 'Barco', 'Coche', 'Cohete', 'Tren', 'Granero', 'Gallina', 'Vaca', 'Tractor'],
    'de': ['Apfel', 'Banane', 'Trauben', 'Erdbeere', 'Karotte', 'Mais', 'Kürbis', 'Tomate', 'Schmetterling', 'Elefant', 'Fisch', 'Schildkröte', 'Boot', 'Auto', 'Rakete', 'Zug', 'Scheune', 'Huhn', 'Kuh', 'Traktor'],
    'ur': ['سیب', 'کیلا', 'انگور', 'اسٹرابیری', 'گاجر', 'مکئی', 'کدو', 'ٹماٹر', 'تتلی', 'ہاتھی', 'مچھلی', 'کچھوا', 'کشتی', 'کار', 'راکٹ', 'ریل گاڑی', 'گودام', 'مرغی', 'گائے', 'ٹریکٹر'],
    'pt': ['Maçã', 'Banana', 'Uvas', 'Morango', 'Cenoura', 'Milho', 'Abóbora', 'Tomate', 'Borboleta', 'Elefante', 'Peixe', 'Tartaruga', 'Barco', 'Carro', 'Foguete', 'Trem', 'Celeiro', 'Galinha', 'Vaca', 'Trator'],
    'fr': ['Pomme', 'Banane', 'Raisin', 'Fraise', 'Carotte', 'Maïs', 'Citrouille', 'Tomate', 'Papillon', 'Éléphant', 'Poisson', 'Tortue', 'Bateau', 'Voiture', 'Fusée', 'Train', 'Grange', 'Poule', 'Vache', 'Tracteur'],
    'ja': ['りんご', 'バナナ', 'ぶどう', 'いちご', 'にんじん', 'とうもろこし', 'かぼちゃ', 'トマト', 'ちょうちょ', 'ぞう', 'さかな', 'かめ', 'ふね', 'くるま', 'ロケット', 'でんしゃ', 'なや', 'にわとり', 'うし', 'トラクター'],
    'zh': ['苹果', '香蕉', '葡萄', '草莓', '胡萝卜', '玉米', '南瓜', '番茄', '蝴蝶', '大象', '鱼', '乌龟', '船', '汽车', '火箭', '火车', '谷仓', '鸡', '牛', '拖拉机'],
    'sa': ['सेवम्', 'कदलीफलम्', 'द्राक्षा', 'तृणबदरम्', 'गृञ्जनम्', 'यवनालः', 'कूष्माण्डः', 'रक्तफलम्', 'चित्रपतङ्गः', 'गजः', 'मत्स्यः', 'कूर्मः', 'नौका', 'कारयानम्', 'अग्निबाणः', 'रेलयानम्', 'धान्यागारम्', 'कुक्कुटः', 'धेनुः', 'कर्षणयानम्'],
    'bn': ['আপেল', 'কলা', 'আঙুর', 'স্ট্রবেরি', 'গাজর', 'ভুট্টা', 'কুমড়া', 'টমেটো', 'প্রজাপতি', 'হাতি', 'মাছ', 'কচ্ছপ', 'নৌকা', 'গাড়ি', 'রকেট', 'ট্রেন', 'গোলাঘর', 'মুরগি', 'গরু', 'ট্রাক্টর'],
    'or': ['ସେଓ', 'କଦଳୀ', 'ଅଙ୍ଗୁର', 'ଷ୍ଟ୍ରବେରୀ', 'ଗାଜର', 'ମକା', 'କଖାରୁ', 'ଟମାଟୋ', 'ପ୍ରଜାପତି', 'ହାତୀ', 'ମାଛ', 'କଇଁଛ', 'ଡଙ୍ଗା', 'କାର', 'ରକେଟ', 'ରେଳଗାଡ଼ି', 'ଅମାର', 'କୁକୁଡ଼ା', 'ଗାଈ', 'ଟ୍ରାକ୍ଟର'],
    'ne': ['स्याउ', 'केरा', 'अंगुर', 'स्ट्रबेरी', 'गाजर', 'मकै', 'फर्सी', 'गोलभेँडा', 'पुतली', 'हात्ती', 'माछा', 'कछुवा', 'डुङ्गा', 'कार', 'रकेट', 'रेल', 'भकारी', 'कुखुरा', 'गाई', 'ट्र्याक्टर'],
    'ar': ['تفاحة', 'موزة', 'عنب', 'فراولة', 'جزرة', 'ذرة', 'يقطين', 'طماطم', 'فراشة', 'فيل', 'سمكة', 'سلحفاة', 'قارب', 'سيارة', 'صاروخ', 'قطار', 'حظيرة', 'دجاجة', 'بقرة', 'جرار'],
  };

  static const Map<String, String> praise = {
    'en': 'Great job!',
    'hi': 'शाबाश!',
    'te': 'శభాష్!',
    'ta': 'அருமை!',
    'gu': 'શાબાશ!',
    'mr': 'शाब्बास!',
    'ml': 'കൊള്ളാം!',
    'kn': 'ಶಭಾಷ್!',
    'es': '¡Muy bien!',
    'de': 'Super gemacht!',
    'ur': 'شاباش!',
    'pt': 'Muito bem!',
    'fr': 'Bravo !',
    'ja': 'よくできました!',
    'zh': '真棒!',
    'sa': 'साधु!',
    'bn': 'সাবাশ!',
    'or': 'ସାବାସ!',
    'ne': 'स्याबास!',
    'ar': 'أحسنت!',
  };

  /// Picture name in the given language, or null if there is none.
  static String? title(String subject, String languageId) {
    final index = subjects.indexOf(subject);
    final list = titles[languageId];
    if (index < 0 || list == null || index >= list.length) return null;
    return list[index];
  }

  static String praiseFor(String languageId) => praise[languageId] ?? '';
}
