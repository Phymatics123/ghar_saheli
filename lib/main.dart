import 'package:flutter/material.dart';

import 'src/engine.dart';
import 'src/security/pin_service.dart';
import 'src/ui/app.dart';
import 'src/ui/app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opens SQLite and seeds categories before the first frame. Fast on a cold
  // start because nothing here touches the network — there is no network in
  // this app.
  final GharSaheliEngine engine = await GharSaheliEngine.boot();
  final PinService pin = PinService(engine.ledger);
  final AppSettings settings = await AppSettings.load(
    ledger: engine.ledger,
    pin: pin,
  );

  runApp(
    GharSaheliApp(
      engine: engine,
      pin: pin,
      settings: settings,
    ),
  );
}
