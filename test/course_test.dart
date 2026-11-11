import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('course has 100 days, ten complete rounds per day and unique bilingual pairs', () {
    final days =
        jsonDecode(File('assets/course.json').readAsStringSync()) as List;
    expect(days.length, 100);
    final ids = <String>{}, hindi = <String>{}, english = <String>{};
    for (var i = 0; i < days.length; i++) {
      final d = days[i];
      expect(d['day'], i + 1);
      expect(d['level'], i ~/ 10 + 1);
      final pairs = d['pairs'] as List;
      expect(pairs.length, 200);
      for (var r = 1; r <= 10; r++) {
        expect(pairs.where((p) => p['round'] == r).length, 20);
      }
      for (final p in pairs) {
        expect(ids.add(p['id']), true);
        expect(hindi.add(p['hi']), true);
        expect(english.add(p['en']), true);
        expect(p['hi'], isNot(contains('{')));
        expect(p['en'], isNot(contains('{')));
      }
    }
    expect(ids.length, 20000);
  });
}
