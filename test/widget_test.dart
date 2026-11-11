import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_quest/main.dart';
import 'package:english_quest/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
  });
  testWidgets(
    'mobile dashboard loads and opens first lesson without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnglishQuest());
        await rootBundle.loadString('assets/course.json');
        await SharedPreferences.getInstance();
      });
      await tester.pumpAndSettle();
      expect(find.text('Hello, Explorer! 👋'), findsOneWidget);
      await tester.tap(find.text('Start today’s adventure'));
      await tester.pumpAndSettle();
      expect(find.text('हम कमरा साफ़ करना चाहते हैं।'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('correct quiz awards once, wrong answer is saved without XP', (
    tester,
  ) async {
    final day = (jsonDecode(
      File('assets/course.json').readAsStringSync(),
    ) as List)
        .first;
    final progress = Progress();
    await tester.pumpWidget(
      MaterialApp(
        home: LessonScreen(day: day, progress: progress, onSave: () async {}),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('We want to clean the room.'));
    await tester.tap(find.text('We want to clean the room.'));
    await tester.pump();
    await tester.ensureVisible(find.text('Check answer'));
    await tester.tap(find.text('Check answer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Got it · Next sentence →'));
    await tester.tap(find.text('Got it · Next sentence →'));
    await tester.pumpAndSettle();
    expect(progress.learned, {'1-1'});
    expect(progress.xp, 5);
    final options = find
        .byType(OutlinedButton)
        .evaluate()
        .map((e) => e.widget as OutlinedButton)
        .where((w) => w.child is Text)
        .toList();
    final wrong = (options
            .firstWhere(
              (w) => (w.child as Text).data != 'We want to make the bed.',
            )
            .child as Text)
        .data!;
    await tester.ensureVisible(find.text(wrong));
    await tester.tap(find.text(wrong));
    await tester.pump();
    await tester.ensureVisible(find.text('Check answer'));
    await tester.tap(find.text('Check answer'));
    await tester.pumpAndSettle();
    expect(progress.saved, contains('1-2'));
    expect(progress.xp, 5);
    expect(tester.takeException(), isNull);
  });
}
