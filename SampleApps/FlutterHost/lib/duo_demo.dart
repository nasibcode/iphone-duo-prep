// Phase A5 — FlutterHost adapter demo (intentional R6 hits).
// Adapter smoke — calls iPhoneDuoPrepFlutter size/hinge APIs.
import '../../../Adapters/iPhoneDuoPrepFlutter/lib/iphone_duo_prep.dart';

Future<void> demoDuoHelpers() async {
  final insets = await IPhoneDuoPrep.safeAreaInsets();
  final compact = await IPhoneDuoPrep.isCompactWidth(400);
  final hinge = await IPhoneDuoPrep.hingeFraction();
  final reserved = await IPhoneDuoPrep.reservedInsets();
  IPhoneDuoPrep.observeHinge().listen((_) {});
  assert(insets.top >= 0);
  assert(compact == true || compact == false);
  assert(hinge >= 0);
  assert(reserved.left >= 0);
}
