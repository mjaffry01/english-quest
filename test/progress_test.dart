import 'package:flutter_test/flutter_test.dart';
import 'package:english_quest/progress.dart';

void main() {
  test('replays do not inflate XP or calendar activity', () {
    final p = Progress(), now = DateTime(2026, 11, 11);
    expect(p.mark('1-1', now), true);
    expect(p.mark('1-1', now.add(const Duration(days: 1))), false);
    expect(p.xp, 5);
    expect(p.today(now), 1);
    expect(p.today(now.add(const Duration(days: 1))), 0);
  });
  test(
    'only 200 new sentences qualify a calendar date; a gap resets streak',
    () {
      final p = Progress(), first = DateTime(2026, 11, 11);
      for (var i = 1; i <= 199; i++) {
        p.mark('1-$i', first);
      }
      expect(p.streak(first), 0);
      expect(p.available(2), false);
      p.mark('1-200', first);
      expect(p.streak(first), 1);
      expect(p.available(2), true);
      expect(p.xp, 1100);
      for (var i = 1; i <= 200; i++) {
        p.mark('2-$i', first.add(const Duration(days: 1)));
      }
      expect(p.streak(first.add(const Duration(days: 1))), 2);
      expect(p.streak(first.add(const Duration(days: 2))), 2);
      expect(p.streak(first.add(const Duration(days: 3))), 0);
      expect(p.bestStreak, 2);
    },
  );
  test('two lessons on one date still earn only one streak day', () {
    final p = Progress(), now = DateTime(2026, 12, 31);
    for (var d = 1; d <= 2; d++) {
      for (var i = 1; i <= 200; i++) {
        p.mark('$d-$i', now);
      }
    }
    expect(p.streak(DateTime(2027, 1, 1)), 1);
    expect(p.completedDays, 2);
  });
  test('backup round trip and invalid data rejection', () {
    final p = Progress()..name = 'Ali';
    p.mark('1-1', DateTime(2026, 11, 11));
    p.saved.add('100-200');
    final restored = Progress.decode(p.encode());
    expect(restored.learned, p.learned);
    expect(restored.saved, p.saved);
    expect(restored.name, 'Ali');
    expect(() => Progress.decode('{"version":2}'), throwsFormatException);
    expect(
      () => Progress.decode(
        '{"version":1,"learned":["101-1"],"saved":[],"activity":{}}',
      ),
      throwsFormatException,
    );
    expect(
      () => Progress.decode(
        '{"version":1,"learned":[],"saved":[],"activity":{"2026-11-11":200}}',
      ),
      throwsFormatException,
    );
  });
}
