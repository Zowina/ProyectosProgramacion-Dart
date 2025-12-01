// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Asegúrate de que 'example_app' coincida con el campo 'name' de tu pubspec.yaml
import 'package:batallas_pokemon/main.dart';

void main() {
  testWidgets('BattleScreen loads and shows initial data', (WidgetTester tester) async {
    // 1. Build the correct app widget: PokemonBattleApp.
    await tester.pumpWidget(const BatallaApp());

    // 2. Verify that the app title is present.
    expect(find.text('Batalla Pokemon'), findsOneWidget);

    // 3. Verify that the main actions (buttons) are present.
    expect(find.text('LUCHA'), findsOneWidget);
    expect(find.text('MOCHILA'), findsOneWidget);

    // 4. Verify that the Pokémon names are displayed (Flamizard and Aquarock 
    //    are defined in _BattleScreenState initState).
    expect(find.text('Flamizard'), findsOneWidget);
    expect(find.text('Aquarock'), findsOneWidget);

    // 5. Tap the 'LUCHA' button to show the attack menu
    await tester.tap(find.text('LUCHA'));
    await tester.pump(); // Rebuild the widget tree after the tap

    // 6. Verify that the attack menu title is shown.
    expect(find.text('Elige un ataque:'), findsOneWidget);

    // 7. Verify that at least one attack name is shown (e.g., 'Ascuas').
    expect(find.text('Ascuas'), findsOneWidget);
  });
}