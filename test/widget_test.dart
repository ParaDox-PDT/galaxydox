import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:galaxydox/app/app.dart';
import 'package:galaxydox/core/constants/app_constants.dart';

void main() {
  testWidgets('GalaxyDox splash renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GalaxyDoxApp()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);
  });
}
