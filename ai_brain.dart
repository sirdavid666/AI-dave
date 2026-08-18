import 'dart:math';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result of an AI brain call. [reply] is what gets shown/spoken.
/// [launchedUrl] is set when a URL should be opened by the caller
/// (kept separate so this function has no BuildContext dependency).
class AIResult {
  final String reply;
  final String? launchedUrl;
  AIResult(this.reply, {this.launchedUrl});
}

class AIBrain {
  static final List<String> _jokes = [
    "Why did the AI go to therapy? Too many bytes.",
    "I told my computer I needed a break, now it won't stop sending me KitKats.",
    "What do you call a robot that does laundry? A washine.",
  ];

  /// 100% offline rule-based response engine. No network calls.
  static AIResult getAIResponse(String rawInput) {
    final input = rawInput.toLowerCase().trim();

    if (input.isEmpty) {
      return AIResult("I didn't catch that, boss. Try again?");
    }

    if (input.contains("hello") || input.contains("hi")) {
      return AIResult("Hello boss, how can I help you?");
    }

    if (input.contains("time")) {
      final now = DateTime.now();
      final formatted = DateFormat('h:mm a').format(now);
      return AIResult("The time is $formatted");
    }

    if (input.contains("date")) {
      final now = DateTime.now();
      final formatted = DateFormat('EEEE, MMMM d, y').format(now);
      return AIResult("Today is $formatted");
    }

    if (input.contains("joke")) {
      final joke = _jokes[Random().nextInt(_jokes.length)];
      return AIResult(joke);
    }

    if (input.contains("open youtube")) {
      return AIResult(
        "Opening YouTube for you, boss.",
        launchedUrl: "https://youtube.com",
      );
    }

    return AIResult(
      "I'm offline boss. I can do time, date, jokes, and open apps.",
    );
  }

  /// Actually performs the URL launch. Called by the UI layer so
  /// errors can be shown via SnackBar there.
  static Future<bool> launchUrlString(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
