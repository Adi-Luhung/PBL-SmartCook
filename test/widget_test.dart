import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_cook/core/widgets/app_bottom_nav.dart';
import 'package:smart_cook/presentation/input_bahan/widgets/confirm_search_dialog.dart';
import 'package:smart_cook/presentation/recommendation/recommendation_page.dart';
import 'package:smart_cook/presentation/shell/main_shell.dart';

void main() {
  testWidgets('RecommendationPage renders header, chips, and recipe cards without tambah bahan',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: RecommendationPage(),
      ),
    );

    // Verify title and subtitle
    expect(find.text('Rekomendasi untukmu'), findsOneWidget);
    expect(
        find.text('Berdasarkan bahan pilihanmu'), findsOneWidget);

    // Verify ingredients count badge
    expect(find.text('4 Bahan'), findsOneWidget);

    // Verify chips
    expect(find.text('Tahu'), findsOneWidget);
    expect(find.text('Telur'), findsOneWidget);
    expect(find.text('Bawang'), findsOneWidget);
    expect(find.text('Cabai'), findsOneWidget);

    // Verify recipe cards
    expect(find.text('Tahu Telur Bumbu Kecap Pedas'), findsOneWidget);
    expect(find.text('Orak-Arik Telur Tahu Sehat'), findsOneWidget);

    // Scroll to find the 3rd card
    await tester.scrollUntilVisible(
      find.text('Sambal Goreng Tahu Telur'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Sambal Goreng Tahu Telur'), findsOneWidget);

    // Verify "Tambah Bahan Masakan" & "Punya bahan lain di rumah?" are removed
    expect(find.text('Punya bahan lain di rumah?'), findsNothing);
    expect(find.text('Tambah Bahan Masakan'), findsNothing);
  });

  testWidgets('ConfirmSearchDialog triggers confirm callback',
      (WidgetTester tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfirmSearchDialog(
            onConfirmSearch: () => confirmed = true,
          ),
        ),
      ),
    );

    // Verify modal text
    expect(find.text('Cari Resep Sekarang?'), findsOneWidget);
    expect(
      find.text(
          'Ada bahan masakan yang mau\nditambahkan sebelum mencari?'),
      findsOneWidget,
    );

    // Test "Ya, Cari Resep"
    await tester.tap(find.text('Ya, Cari Resep'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('ConfirmSearchDialog triggers addMore callback',
      (WidgetTester tester) async {
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

  testWidgets('MainShell Input tab handles search and custom navbar icon',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(),
      ),
    );

    // Verify custom InboxNavbarIcon exists in bottom nav
    expect(find.byType(InboxNavbarIcon), findsOneWidget);

    // 1. Initially on Beranda
    expect(find.text('Halo, Mau Masak Apa?'), findsOneWidget);

    // Tapping "Lihat Semua (24)" should NOT navigate away
    await tester.tap(find.text('Lihat Semua (24)'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Mau Masak Apa?'), findsOneWidget);

    // 2. Tap Eksplorasi in bottom nav
    await tester.tap(find.text('Eksplorasi'));
    await tester.pumpAndSettle();
    expect(find.text('Eksplorasi Resep'), findsOneWidget);
    expect(find.text('Paling Populer'), findsOneWidget);

    // 3. Tap Input in bottom nav
    await tester.tap(find.text('Input'));
    await tester.pumpAndSettle();
    expect(find.text('Bahan dan Masakan'), findsOneWidget);

    // Tap "Cari Resep" at the bottom
    await tester.tap(find.text('Cari Resep'));
    await tester.pumpAndSettle();

    // Confirm popup appears
    expect(find.text('Cari Resep Sekarang?'), findsOneWidget);

    // Tap "Ya, Cari Resep"
    await tester.tap(find.text('Ya, Cari Resep'));
    await tester.pumpAndSettle();

    // Now on RecommendationPage, still in Input tab!
    expect(find.text('Rekomendasi untukmu'), findsOneWidget);

    // Tap "Input" navbar button again to toggle back to InputBahanPage
    await tester.tap(find.text('Input'));
    await tester.pumpAndSettle();

    // Returns to InputBahanPage
    expect(find.text('Bahan dan Masakan'), findsOneWidget);
  });
}
