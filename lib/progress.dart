import 'dart:convert';

String dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class Progress {
  Set<String> learned = {}, saved = {};
  Map<String, int> activity = {};
  String name = 'Explorer';
  int count(int day) => learned.where((id) => id.startsWith('$day-')).length;
  int get completedDays =>
      List.generate(100, (i) => i + 1).where((d) => count(d) == 200).length;
  int get nextDay {
    for (var d = 1; d <= 100; d++) {
      if (count(d) < 200) return d;
    }
    return 100;
  }

  bool available(int day) => day <= nextDay;
  int get xp => learned.length * 5 + completedDays * 100;
  bool mark(String id, DateTime now) {
    if (!learned.add(id)) return false;
    final key = dateKey(now);
    activity[key] = (activity[key] ?? 0) + 1;
    return true;
  }

  int today(DateTime now) => activity[dateKey(now)] ?? 0;
  Set<String> get qualified =>
      activity.entries.where((e) => e.value >= 200).map((e) => e.key).toSet();
  int streak(DateTime now) {
    final days = qualified;
    var date = DateTime.utc(now.year, now.month, now.day);
    if (!days.contains(dateKey(date)))
      date = date.subtract(const Duration(days: 1));
    var result = 0;
    while (days.contains(dateKey(date))) {
      result++;
      date = date.subtract(const Duration(days: 1));
    }
    return result;
  }

  int get bestStreak {
    final dates = qualified.toList()..sort();
    int best = 0, run = 0;
    DateTime? previous;
    for (final value in dates) {
      final date = DateTime.parse('${value}T00:00:00Z');
      run = previous != null && date.difference(previous).inDays == 1
          ? run + 1
          : 1;
      if (run > best) best = run;
      previous = date;
    }
    return best;
  }

  String encode() => jsonEncode({
    'version': 1,
    'name': name,
    'learned': learned.toList(),
    'saved': saved.toList(),
    'activity': activity,
  });
  static Progress decode(String raw) {
    final data = jsonDecode(raw);
    if (data is! Map || data['version'] != 1)
      throw const FormatException('Unsupported backup');
    Set<String> ids(dynamic items) {
      if (items is! List || items.length > 20000)
        throw const FormatException('Invalid progress');
      return items.map((value) {
        if (value is! String ||
            !RegExp(r'^([1-9][0-9]?|100)-([1-9][0-9]?|1[0-9]{2}|200)$')
                .hasMatch(value))
          throw const FormatException('Invalid sentence');
        return value;
      }).toSet();
    }

    final p = Progress();
    p.learned = ids(data['learned']);
    p.saved = ids(data['saved']);
    if (data['activity'] is! Map)
      throw const FormatException('Invalid activity');
    for (final entry in (data['activity'] as Map).entries) {
      final date = DateTime.tryParse(entry.key.toString());
      if (date == null ||
          dateKey(date) != entry.key ||
          entry.value is! int ||
          entry.value < 0 ||
          entry.value > 20000)
        throw const FormatException('Invalid date');
      p.activity[entry.key] = entry.value;
    }
    if (p.activity.values.fold<int>(0, (sum, n) => sum + n) != p.learned.length)
      throw const FormatException('Inconsistent activity');
    if (data['name'] is String)
      p.name = (data['name'] as String).substring(
        0,
        (data['name'] as String).length.clamp(0, 32),
      );
    return p;
  }
}
