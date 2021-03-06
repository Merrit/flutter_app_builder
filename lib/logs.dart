import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

/// Print log messages.
void initializeLogger() {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    final String time = DateFormat('h:mm:ss a').format(record.time);

    var msg = 'flutter_app_builder: ${record.level.name}: $time: '
        '${record.loggerName}: ${record.message}';

    if (record.error != null) msg += '\nError: ${record.error}';

    print(msg);
  });
}
