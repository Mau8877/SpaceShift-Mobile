import 'package:flutter_test/flutter_test.dart';
import 'package:spaceshift_mobile/main.dart';

void main() {
  testWidgets('SpaceShift App load test', (WidgetTester tester) async {
    // Carga nuestra app real
    await tester.pumpWidget(const SpaceShiftApp());

    // Verifica que el texto principal aparezca en pantalla
    expect(find.text('SpaceShift'), findsOneWidget);
  });
}
