import 'package:logger/logger.dart';

class TalkLogger {

  static TalkLogger _instance;

  TalkLogger._();

  factory TalkLogger()
  {
    if (_instance == null) {
      _instance = new TalkLogger._();
    }

    return _instance;
  }

  Logger _logger = Logger(printer: PrettyPrinter());
  Logger get logger => _logger;
}