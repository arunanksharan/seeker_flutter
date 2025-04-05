import 'package:logger/logger.dart';

// Create a logger instance
// You can customize the printer (e.g., PrettyPrinter) and output (e.g., ConsoleOutput)
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // Number of method calls to be displayed
    errorMethodCount: 8, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat.none, // Don't print timestamps
  ),
);

// You might want different log levels for debug and release builds
// Example:
// final logger = Logger(
//   level: kReleaseMode ? Level.warning : Level.debug, // Only show warnings and above in release
//   printer: PrettyPrinter(...),
// );
// Requires importing 'package:flutter/foundation.dart'; for kReleaseMode
