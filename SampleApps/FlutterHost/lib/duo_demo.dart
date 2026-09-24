// Phase A5 — FlutterHost adapter demo (intentional R6 hits).
// Adapter smoke — calls DuoHarnessFlutter size/hinge APIs.
import '../../../Adapters/DuoHarnessFlutter/lib/duo_harness.dart';

Future<void> demoDuoHelpers() async {
  final insets = await DuoHarness.safeAreaInsets();
  final compact = await DuoHarness.isCompactWidth(400);
  final hinge = await DuoHarness.hingeFraction();
  final reserved = await DuoHarness.reservedInsets();
  DuoHarness.observeHinge().listen((_) {});
  assert(insets.top >= 0);
  assert(compact == true || compact == false);
  assert(hinge >= 0);
  assert(reserved.left >= 0);
}
