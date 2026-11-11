import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'install.dart';
import 'progress.dart';

const forest = Color(0xFF176B59),
    ink = Color(0xFF173E35),
    paper = Color(0xFFF7F8F2),
    gold = Color(0xFFFFC857);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnglishQuest());
}

class EnglishQuest extends StatelessWidget {
  const EnglishQuest({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'English Quest',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamilyFallback: const ['Hindi'],
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyLarge: TextStyle(fontSize: 17, height: 1.6, color: ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    home: const QuestHome(),
  );
}

Widget box(Widget child, {Color color = Colors.white}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: color == Colors.white ? const Color(0xFFE3E9E0) : color,
    ),
  ),
  child: child,
);

class QuestHome extends StatefulWidget {
  const QuestHome({super.key});
  @override
  State<QuestHome> createState() => _QuestHomeState();
}

class _QuestHomeState extends State<QuestHome> {
  List<dynamic> course = [];
  Progress progress = Progress();
  SharedPreferences? prefs;
  String? error;
  int page = 0;
  Future<void> saveQueue = Future.value();
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      course =
          jsonDecode(await rootBundle.loadString('assets/course.json')) as List;
      prefs = await SharedPreferences.getInstance();
      final raw = prefs!.getString('englishQuestV1');
      if (raw != null) {
        try {
          progress = Progress.decode(raw);
        } catch (_) {
          error = 'Saved progress could not be read. Your original data has been kept. Restore a backup from Settings before continuing.';
        }
      }
    } catch (_) {
      error = 'The course could not load. Please refresh or try again when connected.';
    }
    if (mounted) setState(() {});
  }

  Future<void> persist() {
    if (error != null) return Future.value();
    final snapshot = progress.encode();
    saveQueue = saveQueue.then((_) async {
      try {
        if (!(await prefs?.setString('englishQuestV1', snapshot) ?? false))
          throw StateError('Save failed');
      } catch (_) {
        if (mounted)
          message(
            'Progress could not be saved. Copy a backup from Settings before closing.',
          );
      }
    });
    return saveQueue;
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> openDay(int day) async {
    if (error != null) {
      message(error!);
      return;
    }
    if (!progress.available(day)) {
      message('Finish Day ${progress.nextDay} to unlock this adventure.');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          day: course[day - 1],
          progress: progress,
          onSave: persist,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (course.isEmpty)
      return Scaffold(
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Text(error!),
        ),
      );
    final wide = MediaQuery.sizeOf(context).width >= 880;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'English Quest',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (canOfferInstall()) ...[
            wide
                ? FilledButton.icon(
                    onPressed: openInstall,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.install_mobile, size: 18),
                    label: const Text('Install app'),
                  )
                : IconButton.filled(
                    tooltip: 'Install app',
                    onPressed: openInstall,
                    icon: const Icon(Icons.install_mobile, size: 20),
                  ),
            const SizedBox(width: 8),
          ],
          Chip(label: Text('🔥 ${progress.streak(DateTime.now())}')),
          const SizedBox(width: 8),
          Chip(label: Text('✦ ${progress.xp}')),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide)
            NavigationRail(
              extended: true,
              backgroundColor: paper,
              selectedIndex: page,
              onDestinationSelected: (i) => setState(() => page = i),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  label: Text('My adventure'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.route_outlined),
                  label: Text('100-day trail'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border),
                  label: Text('Practice vault'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  label: Text('Rewards'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: Text('Settings'),
                ),
              ],
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 32 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null)
                        box(Text(error!), color: const Color(0xFFFFE7D0)),
                      switch (page) {
                        0 => dashboard(),
                        1 => trail(),
                        2 => vault(),
                        3 => rewards(),
                        _ => settings(),
                      },
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: page,
              onDestinationSelected: (i) => setState(() => page = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.route_outlined),
                  label: 'Trail',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border),
                  label: 'Practice',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  label: 'Rewards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }

  Widget dashboard() {
    final day = progress.nextDay, done = progress.count(progress.nextDay);
    final data = course[day - 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LET’S GROW, ONE SENTENCE AT A TIME',
          style: TextStyle(
            letterSpacing: 2,
            color: forest,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hello, ${progress.name}! 👋',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Small rounds. Big confidence. Your English adventure awaits.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 28),
        box(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR NEXT ADVENTURE',
                style: TextStyle(
                  letterSpacing: 2,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${data['emoji']}  Day $day · ${data['title']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${data['hindi']}  •  Level ${data['level']}: ${data['levelName']}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 22),
              LinearProgressIndicator(
                value: done / 200,
                minHeight: 9,
                color: gold,
                backgroundColor: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 10),
              Text(
                '$done / 200 sentences mastered · 10 rounds of 20',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: ink,
                ),
                onPressed: () => openDay(day),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  done > 0 ? 'Continue adventure' : 'Start today’s adventure',
                ),
              ),
            ],
          ),
          color: forest,
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, size) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              stat(
                '🔥',
                '${progress.streak(DateTime.now())} days',
                'Current streak',
                size.maxWidth,
              ),
              stat(
                '🌱',
                '${progress.completedDays} / 100',
                'Adventures completed',
                size.maxWidth,
              ),
              stat(
                '💎',
                '${progress.learned.length}',
                'Sentences mastered',
                size.maxWidth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Make today count', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        box(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${progress.today(DateTime.now())} / 200 new sentences today',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (progress.today(DateTime.now()) / 200).clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
              const Text(
                'Complete 200 new sentences today to earn a streak day. Take a break after each round. Replays help you practise, but earn no extra XP.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        box(
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🦉', style: TextStyle(fontSize: 40)),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Read the Hindi, try the English, then check and say it aloud. Mistakes go into your Practice Vault. There’s no timer and no lost hearts.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ],
          ),
          color: const Color(0xFFFFF0CC),
        ),
      ],
    );
  }

  Widget stat(String emoji, String value, String label, double width) =>
      SizedBox(
        width: width < 600 ? width : (width - 24) / 3,
        child: box(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              Text(label),
            ],
          ),
        ),
      );
  Widget trail() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your 100-day trail',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 8),
      const Text(
        '20,000 sentence pairs · 10 growing levels · one adventure at a time',
      ),
      const SizedBox(height: 20),
      for (var level = 0; level < 10; level++)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEVEL ${level + 1} · ${course[level * 10]['levelName']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 8),
                Text(course[level * 10]['tip']),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(10, (i) {
                    final day = level * 10 + i + 1;
                    final complete = progress.count(day) == 200;
                    return SizedBox(
                      width: 74,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: complete
                              ? const Color(0xFFDAEFE5)
                              : Colors.white,
                        ),
                        onPressed: () => openDay(day),
                        child: Column(
                          children: [
                            Text(
                              complete
                                  ? '✓'
                                  : progress.available(day)
                                  ? course[day - 1]['emoji']
                                  : '🔒',
                            ),
                            Text('$day'),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
    ],
  );
  Widget vault() {
    final pairs = course
        .expand((d) => d['pairs'] as List)
        .where((p) => progress.saved.contains(p['id']))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Practice vault',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        const Text('Reveal, practise aloud, then remove when confident.'),
        const SizedBox(height: 20),
        if (pairs.isEmpty)
          box(
            const Text(
              '✨ All clear! Bookmark a sentence or try a quiz to build your personal revision list.',
            ),
          ),
        for (final pair in pairs)
          Card(
            child: ExpansionTile(
              title: Text(pair['hi']),
              subtitle: Text(
                'Day ${(pair['id'] as String).split('-').first} · tap to reveal',
              ),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                Text(pair['en'], style: Theme.of(context).textTheme.bodyLarge),
                TextButton.icon(
                  onPressed: () {
                    setState(() => progress.saved.remove(pair['id']));
                    persist();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('I’m confident now'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget rewards() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your trophy shelf',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 8),
      Text(
        'Best streak: ${progress.bestStreak} days · ${progress.xp} XP earned',
      ),
      const SizedBox(height: 20),
      for (final item in [
        (1, '🌱', 'First spark'),
        (3, '🔥', 'On a roll'),
        (7, '🌟', 'Weekly wonder'),
        (14, '🚀', 'Taking flight'),
        (30, '💎', 'Diamond dedication'),
        (60, '🏆', 'Trail legend'),
        (100, '👑', 'Century champion'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: box(
            Row(
              children: [
                Text(item.$2, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${item.$1}-day streak · ${progress.bestStreak >= item.$1 ? 'Unlocked forever' : 'Keep growing'}',
                      ),
                    ],
                  ),
                ),
                Icon(
                  progress.bestStreak >= item.$1
                      ? Icons.verified
                      : Icons.lock_outline,
                  color: forest,
                ),
              ],
            ),
          ),
        ),
      if (progress.completedDays == 100)
        box(
          Text(
            '🎓 Course complete! ${progress.name} has completed 100 adventures and 20,000 sentence pairs.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          color: const Color(0xFFFFF0CC),
        ),
      const SizedBox(height: 12),
      const Text(
        'A missed day resets your current streak, never your XP, lessons, best streak, or earned badges. Come back whenever you’re ready.',
      ),
    ],
  );
  Widget settings() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your learning space',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 20),
      if (canOfferInstall()) ...[
        box(
          Row(
            children: [
              const Icon(Icons.install_mobile, color: forest, size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Install English Quest on your phone. It gets its own home-screen icon and works offline.',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: openInstall,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: const Text('Install'),
              ),
            ],
          ),
          color: const Color(0xFFE9F3E8),
        ),
        const SizedBox(height: 20),
      ],
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: progress.name,
              enabled: error == null,
              maxLength: 32,
              decoration: const InputDecoration(labelText: 'Explorer nickname'),
              onChanged: (value) {
                progress.name = value.trim().isEmpty
                    ? 'Explorer'
                    : value.trim();
                persist();
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Progress stays on this browser or device. Clearing browser data removes it. Keep a backup to move devices. No account, advertising, or analytics.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await Clipboard.setData(
                        ClipboardData(text: progress.encode()),
                      );
                      if (mounted)
                        message('Backup copied. Save it in a text file.');
                    } catch (_) {
                      if (mounted)
                        message(
                          'Clipboard unavailable. Please try another browser.',
                        );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy progress backup'),
                ),
                OutlinedButton.icon(
                  onPressed: restore,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore backup'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      box(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About this course',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 12),
            Text(
              '100 days × 200 Hindi–English sentence pairs. Each day has 10 rounds of 20. Structured variations combine 200 activities and 100 sentence patterns; familiar themes return with harder grammar. This is translation practice, not a guarantee of fluency.\n\nMost Hindi examples use हम (we). English uses Indian/British spelling. Other natural translations may also be correct. Written practice uses self-assessment, not AI grading.\n\nListening uses the device’s available voices. Streaks use the local calendar and require 200 newly mastered sentences per date. You can finish more than one course day in a calendar day, but earn only one streak day.\n\nFor parents: spread 200 sentences across short sessions and practise real conversations. Supervise cooking, travel and experiments where appropriate.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
  Future<void> restore() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore a progress backup'),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText:
                  'Paste backup JSON. This replaces progress on this device.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    try {
      final restored = Progress.decode(result);
      setState(() {
        progress = restored;
        error = null;
      });
      await persist();
      if (mounted) message('Progress restored.');
    } catch (_) {
      if (mounted) message('Invalid backup. Current progress has not changed.');
    }
  }
}

class LessonScreen extends StatefulWidget {
  final dynamic day;
  final Progress progress;
  final Future<void> Function() onSave;
  const LessonScreen({
    super.key,
    required this.day,
    required this.progress,
    required this.onSave,
  });
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final tts = FlutterTts(), answer = TextEditingController();
  final scroll = ScrollController();
  int index = 0;
  bool reveal = false,
      quiz = true,
      submitted = false,
      correct = false,
      busy = false;
  String? selected;
  List<String> choices = [];
  List get pairs => widget.day['pairs'] as List;
  dynamic get pair => pairs[index];
  @override
  void initState() {
    super.initState();
    final first = pairs.indexWhere(
      (p) => !widget.progress.learned.contains(p['id']),
    );
    index = first < 0 ? 0 : first;
    prepare();
  }

  void prepare() {
    answer.clear();
    reveal = false;
    submitted = false;
    correct = false;
    selected = null;
    final random = Random(widget.day['day'] * 1000 + index),
        round = index ~/ 20;
    final others =
        pairs
            .sublist(round * 20, round * 20 + 20)
            .where((p) => p['id'] != pair['id'])
            .map<String>((p) => p['en'] as String)
            .toList()
          ..shuffle(random);
    choices = [pair['en'] as String, ...others.take(3)]..shuffle(random);
  }

  @override
  void dispose() {
    tts.stop();
    answer.dispose();
    scroll.dispose();
    super.dispose();
  }

  /// Show a new sentence from the top of the page.
  void toTop() {
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void notice(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> listen() async {
    try {
      await tts.setLanguage('en-IN');
      await tts.setSpeechRate(.42);
      final result = await tts.speak(pair['en']);
      if (result != 1 && mounted)
        notice('An English voice is unavailable on this device.');
    } catch (_) {
      if (mounted)
        notice(
          'Listening is unavailable on this device. You can still read and practise.',
        );
    }
  }

  void check() {
    setState(() {
      submitted = true;
      reveal = true;
      correct = selected == pair['en'];
    });
    if (!correct) {
      widget.progress.saved.add(pair['id']);
      widget.onSave();
    }
  }

  Future<void> finish({required bool mastered}) async {
    if (busy) return;
    setState(() => busy = true);
    final wasComplete = widget.progress.count(widget.day['day']) == 200;
    if (mastered) {
      widget.progress.mark(pair['id'], DateTime.now());
    } else {
      widget.progress.saved.add(pair['id']);
    }
    await widget.onSave();
    if (!mounted) return;
    final total = widget.progress.count(widget.day['day']);
    if (index % 20 == 19 || total == 200 && !wasComplete) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            total == 200 && !wasComplete
                ? '🏆 Day complete! +100 XP'
                : '🌟 Round finished!',
          ),
          content: Text(
            '$total / 200 sentences mastered.\n\nTake a short break. Stretch, drink some water, then return when ready.${total < 200 ? '\nUnmastered sentences stay available for another try.' : ''}',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep exploring'),
            ),
          ],
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      if (index < 199) {
        index++;
      } else {
        final first = pairs.indexWhere(
          (p) => !widget.progress.learned.contains(p['id']),
        );
        index = first < 0 ? 0 : first;
      }
      prepare();
      busy = false;
    });
    toTop();
  }

  @override
  Widget build(BuildContext context) {
    final saved = widget.progress.saved.contains(pair['id']),
        count = widget.progress.count(widget.day['day']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${widget.day['day']} · ${widget.day['title']}'),
        actions: [
          IconButton(
            tooltip: saved ? 'Remove bookmark' : 'Save for revision',
            onPressed: () {
              setState(() {
                saved
                    ? widget.progress.saved.remove(pair['id'])
                    : widget.progress.saved.add(pair['id']);
              });
              widget.onSave();
            },
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      // The sentence and choices scroll; the answer/next buttons stay pinned
      // at the bottom (and above the keyboard) so they are always reachable.
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ROUND ${index ~/ 20 + 1} / 10   •   SENTENCE ${index + 1} / 200',
                        style: const TextStyle(
                          letterSpacing: 1.4,
                          color: forest,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: count / 200,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      Text('$count mastered · +5 XP for each new sentence'),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ChoiceChip(
                            label: const Text('Choose the translation'),
                            selected: quiz,
                            onSelected: busy
                                ? null
                                : (_) => setState(() {
                                    quiz = true;
                                    prepare();
                                  }),
                          ),
                          ChoiceChip(
                            label: const Text('Write & compare'),
                            selected: !quiz,
                            onSelected: busy
                                ? null
                                : (_) => setState(() {
                                    quiz = false;
                                    prepare();
                                  }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      box(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HOW WOULD YOU SAY THIS IN ENGLISH?',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: forest,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SelectableText(
                              pair['hi'],
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.6,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.day['tip'],
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (quiz)
                        ...choices.map(
                          (choice) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(20),
                                  foregroundColor: ink,
                                  disabledForegroundColor: ink,
                                  backgroundColor: submitted && choice == pair['en']
                                      ? const Color(0xFFDAEFE5)
                                      : selected == choice
                                      ? const Color(0xFFE8E9FF)
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: submitted || busy
                                    ? null
                                    : () => setState(() => selected = choice),
                                child: Text(
                                  choice,
                                  style: const TextStyle(fontSize: 17, height: 1.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!quiz)
                        TextField(
                          controller: answer,
                          enabled: !reveal,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Try your English translation',
                            hintText: 'It’s okay to make mistakes.',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      if (reveal) ...[
                        const SizedBox(height: 16),
                        box(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz
                                    ? correct
                                          ? '✨ You got it!'
                                          : '🌱 A chance to learn'
                                    : 'Compare with the model answer',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SelectableText(
                                pair['en'],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Other natural translations may also be correct. Say it aloud once.',
                              ),
                              TextButton.icon(
                                onPressed: listen,
                                icon: const Icon(Icons.volume_up_outlined),
                                label: const Text('Listen in English'),
                              ),
                            ],
                          ),
                          color: const Color(0xFFE9F3E8),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: busy || index == 0
                                ? null
                                : () {
                                    setState(() {
                                      index--;
                                      prepare();
                                    });
                                    toTop();
                                  },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                          const Spacer(),
                          DropdownButton<int>(
                            value: index ~/ 20,
                            items: List.generate(
                              10,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text('Round ${i + 1}'),
                              ),
                            ),
                            onChanged: busy
                                ? null
                                : (value) {
                                    setState(() {
                                      index = value! * 20;
                                      prepare();
                                    });
                                    toTop();
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: paper,
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!reveal)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed:
                                  (quiz ? selected == null : answer.text.trim().isEmpty)
                                  ? null
                                  : () {
                                      if (quiz) {
                                        check();
                                      } else {
                                        setState(() => reveal = true);
                                      }
                                    },
                              child: Text(quiz ? 'Check answer' : 'Show model answer'),
                            ),
                          ),
                        if (reveal && quiz && correct)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: busy ? null : () => finish(mastered: true),
                              child: const Text('Got it · Next sentence →'),
                            ),
                          ),
                        if (reveal && quiz && !correct)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              FilledButton(
                                onPressed: busy
                                    ? null
                                    : () => setState(() => prepare()),
                                child: const Text('Try this sentence again'),
                              ),
                              TextButton(
                                onPressed: busy ? null : () => finish(mastered: false),
                                child: const Text('Save for practice & continue'),
                              ),
                            ],
                          ),
                        if (reveal && !quiz)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              FilledButton(
                                onPressed: busy ? null : () => finish(mastered: true),
                                child: const Text('My meaning matched ✓'),
                              ),
                              OutlinedButton(
                                onPressed: busy ? null : () => finish(mastered: false),
                                child: const Text('I need more practice'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
