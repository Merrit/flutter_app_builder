import 'package:logger/logger.dart';

/// Globally available instance available for easy logging.
late final Logger log;

/// Manages logging for the app.
class LoggingManager {
  /// Singleton instance for easy access.
  static late final LoggingManager instance;

  LoggingManager._() {
    instance = this;
  }

  static Future<LoggingManager> initialize({required bool verbose}) async {
    final List<LogOutput> outputs = [
      ConsoleOutput(),
    ];

    log = Logger(
      filter: ProductionFilter(),
      level: (verbose) ? Level.verbose : Level.warning,
      output: MultiOutput(outputs),
      // Colors false because it outputs ugly escape characters to log file.
      printer: PrefixPrinter(PrettyPrinter(colors: false)),
    );

    log.v('Logger initialized.');

    return LoggingManager._();
  }

  /// Close the logger and release resources.
  void close() => log.close();
}
