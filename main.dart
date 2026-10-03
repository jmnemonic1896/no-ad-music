import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.deinname.noadmusic.channel.audio',
    androidNotificationChannelName: 'No Ad Music',
    androidNotificationOngoing: true,
  );
  runApp(const NoAdMusicApp());
}

const _locales = ['de', 'en', 'fr', 'es', 'pt', 'zh', 'da', 'sv', 'fi', 'nl', 'hu', 'cs', 'sr', 'el', 'it'];

// Reihenfolge: simple, advanced, error, volume, title
const Map<String, List<String>> _t = {
  'de': ['Einfach', 'Erweitert', 'Stream nicht erreichbar', 'Lautstärke', 'No Ad Music'],
  'en': ['Simple', 'Advanced', 'Stream unavailable', 'Volume', 'No Ad Music'],
  'fr': ['Simple', 'Avancé', 'Flux indisponible', 'Volume', 'Musique Sans Pub'],
  'es': ['Simple', 'Avanzado', 'Transmisión no disponible', 'Volumen', 'Música Sin Anuncios'],
  'pt': ['Simples', 'Avançado', 'Transmissão indisponível', 'Volume', 'Música Sem Anúncios'],
  'zh': ['简单', '高级', '无法连接到电台', '音量', '无广告音乐'],
  'da': ['Enkel', 'Avanceret', 'Stream ikke tilgængelig', 'Lydstyrke', 'Musik Uden Reklamer'],
  'sv': ['Enkel', 'Avancerad', 'Strömmen är inte tillgänglig', 'Volym', 'Musik Utan Reklam'],
  'fi': ['Yksinkertainen', 'Edistynyt', 'Lähetys ei ole saatavilla', 'Äänenvoimakkuus', 'Mainokseton Musiikki'],
  'nl': ['Eenvoudig', 'Geavanceerd', 'Stream niet beschikbaar', 'Volume', 'Muziek Zonder Reclame'],
  'hu': ['Egyszerű', 'Haladó', 'A adás nem érhető el', 'Hangerő', 'Reklámmentes Zene'],
  'cs': ['Jednoduchý', 'Pokročilý', 'Stream není dostupný', 'Hlasitost', 'Hudba Bez Reklam'],
  'sr': ['Једноставно', 'Напредно', 'Стрим није доступан', 'Јачина звука', 'Музика Без Реклама'],
  'el': ['Απλό', 'Προχωρημένο', 'Η ροή δεν είναι διαθέσιμη', 'Ένταση', 'Μουσική Χωρίς Διαφημίσεις'],
  'it': ['Semplice', 'Avanzato', 'Stream non disponibile', 'Volume', 'Musica Senza Pubblicità'],
};

String tr(String lang, int i) => (_t[lang] ?? _t['en']!)[i];

class NoAdMusicApp extends StatelessWidget {
  const NoAdMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Ad Music',
      debugShowCheckedModeBanner: false,
      supportedLocales: _locales.map((c) => Locale(c)).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        for (final s in supported) {
          if (s.languageCode == locale?.languageCode) return s;
        }
        return const Locale('en');
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainRadioScreen(),
    );
  }
}

class RadioStation {
  final String name;
  final String country;
  final String genre;
  final String url;
  const RadioStation(this.name, this.country, this.genre, this.url);
}

// Alle Streams sind kostenlose, werbefreie bzw. offizielle Internetradio-Streams.
// Vor Veröffentlichung bitte die Nutzungsbedingungen der Sender prüfen.
const List<RadioStation> stations = [
  RadioStation('SomaFM Groove Salad', 'USA', 'Ambient / Chill', 'https://ice.somafm.com/groovesalad'),
  RadioStation('SomaFM PopTron', 'USA', 'Pop / Electropop', 'https://ice.somafm.com/poptron'),
  RadioStation('Radio Paradise', 'USA', 'Eclectic / Rock / Pop', 'https://stream.radioparadise.com/aac-128'),
  RadioStation('SomaFM Heavyweight Reggae', 'USA', 'Reggae', 'https://ice.somafm.com/reggae'),
  RadioStation('BeatGo', 'Germany', 'Afrobeats / R&B', 'https://stream.laut.fm/beatgo'),
  RadioStation('SomaFM Left Coast 70s', 'USA', 'Rock / 70s', 'https://ice.somafm.com/seventies'),
];

class MainRadioScreen extends StatefulWidget {
  const MainRadioScreen({super.key});

  @override
  State<MainRadioScreen> createState() => _MainRadioScreenState();
}

class _MainRadioScreenState extends State<MainRadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool isAdvancedMode = false;
  RadioStation selected = stations.first;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(RadioStation station, String lang) async {
    try {
      if (station == selected && _player.audioSource != null) {
        _player.playing ? await _player.pause() : _player.play();
        return;
      }
      setState(() => selected = station);
      await _player.setAudioSource(AudioSource.uri(
        Uri.parse(station.url),
        tag: MediaItem(
          id: station.url,
          title: station.name,
          album: '${station.country} • ${station.genre}',
        ),
      ));
      _player.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr(lang, 2))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(lang, 4)),
        actions: [
          Text(isAdvancedMode ? tr(lang, 1) : tr(lang, 0),
              style: const TextStyle(fontSize: 12)),
          Switch(
            value: isAdvancedMode,
            onChanged: (v) => setState(() => isAdvancedMode = v),
          ),
        ],
      ),
      body: StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snap) {
          final state = snap.data;
          final playing = state?.playing ?? false;
          final loading = state?.processingState == ProcessingState.loading ||
              state?.processingState == ProcessingState.buffering;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: stations.length,
                  itemBuilder: (context, i) {
                    final s = stations[i];
                    final current = s == selected;
                    return ListTile(
                      leading: Icon(Icons.radio,
                          color: current ? Colors.deepPurpleAccent : Colors.grey),
                      title: Text(s.name,
                          style: TextStyle(
                              fontWeight:
                                  current ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text('${s.country} • ${s.genre}'),
                      trailing: IconButton(
                        iconSize: 32,
                        color: Colors.deepPurpleAccent,
                        icon: Icon(current && playing
                            ? Icons.pause_circle
                            : Icons.play_circle),
                        onPressed: () => _toggle(s, lang),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selected.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (loading)
                        const SizedBox(
                            height: 64,
                            child: Center(child: CircularProgressIndicator()))
                      else
                        IconButton(
                          iconSize: 64,
                          icon: Icon(
                              playing ? Icons.pause_circle : Icons.play_circle),
                          onPressed: () => _toggle(selected, lang),
                        ),
                      if (isAdvancedMode)
                        StreamBuilder<double>(
                          stream: _player.volumeStream,
                          builder: (context, v) => Row(
                            children: [
                              const Icon(Icons.volume_down),
                              Expanded(
                                child: Slider(
                                  value: v.data ?? 1.0,
                                  onChanged: _player.setVolume,
                                ),
                              ),
                              const Icon(Icons.volume_up),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
