import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

// Custom log filter to control logging in different environments
class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Don't log in release mode
    if (kReleaseMode) {
      return event.level.index >= Level.error.index;
    }
    return true;
  }
}

final logger = Logger(
  filter: CustomLogFilter(),
  printer: PrettyPrinter(
    methodCount: 2, // Number of method calls to be displayed
    errorMethodCount: 8, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat:
        DateTimeFormat.onlyTimeAndSinceStart, // Fixed deprecated printTime
  ),
  output: ConsoleOutput(), // Output to console
);

// Helper methods for convenient access
void logDebug(String message) => logger.d(message);
void logInfo(String message) => logger.i(message);
void logWarning(String message) => logger.w(message);
void logError(String message, [dynamic error, StackTrace? stackTrace]) =>
    logger.e(message, error: error, stackTrace: stackTrace);
