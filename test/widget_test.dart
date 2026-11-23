import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_cook/presentation/input_bahan/widgets/confirm_search_dialog.dart';

void main() {
  testWidgets('ConfirmSearchDialog triggers confirm callback', (
    WidgetTester tester,
  ) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfirmSearchDialog(onConfirmSearch: () => confirmed = true),
        ),
      ),
    );

    // Verify modal text
    expect(find.text('Cari Resep Sekarang?'), findsOneWidget);
    expect(
      find.text('Ada bahan masakan yang mau\nditambahkan sebelum mencari?'),
      findsOneWidget,
    );

    // Test "Ya, Cari Resep"
    await tester.tap(find.text('Ya, Cari Resep'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('ConfirmSearchDialog triggers addMore callback', (
    WidgetTester tester,
  ) async {
    bool addMore = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfirmSearchDialog(
            onConfirmSearch: () {},
            onAddMore: () => addMore = true,
          ),
        ),
      ),
    );

    // Test "Tambah Bahan Lagi"
    await tester.tap(find.text('Tambah Bahan Lagi'));
    await tester.pumpAndSettle();
    expect(addMore, isTrue);
  });
}
