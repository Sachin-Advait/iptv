import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oman_tv/common/widgets/tv_notification_overlay.dart';
import 'package:oman_tv/services/tv_notification_controller.dart';

void main() {
  testWidgets('pops up, then zooms away after its duration', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => TvNotificationOverlay(child: child!),
        home: const Scaffold(body: Text('Live TV')),
      ),
    );
    TvNotificationController.instance.handleEvent({
      'action': 'SHOW',
      'id': 1,
      'title': 'Fire drill',
      'message': 'Gather at the assembly point',
      'category': 'EMERGENCY',
      'durationSeconds': 5,
      'playSound': false,
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Fire drill'), findsOneWidget);
    expect(find.text('EMERGENCY'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Fire drill'), findsNothing);
    expect(find.text('Live TV'), findsOneWidget);
  });

  testWidgets('cancel removes it early', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => TvNotificationOverlay(child: child!),
        home: const Scaffold(body: Text('Live TV')),
      ),
    );
    final c = TvNotificationController.instance;
    c.handleEvent({
      'action': 'SHOW',
      'id': 2,
      'title': 'Hello',
      'category': 'INFO',
      'durationSeconds': 30,
      'playSound': false,
    });
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Hello'), findsOneWidget);
    c.handleEvent({'action': 'CANCEL', 'id': 2});
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
  });
}
