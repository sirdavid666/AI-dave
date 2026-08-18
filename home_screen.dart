import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat_screen.dart';
import 'widgets/mic_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestStartupPermissions();
  }

  Future<void> _requestStartupPermissions() async {
    try {
      await [
        Permission.microphone,
        Permission.storage,
      ].request();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission error: $e")),
      );
    }
  }

  void _openChat({bool startListening = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(autoStartListening: startListening),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          "Dave AI",
          style: TextStyle(
            color: Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF00D4FF)),
            onPressed: () => _openChat(),
            tooltip: "Open chat",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tap the mic and talk to Dave",
              style: TextStyle(color: Colors.white54, fontSize: 15),
            ),
            const SizedBox(height: 40),
            MicButton(
              isListening: false,
              size: 140,
              onTap: () => _openChat(startListening: true),
            ),
            const SizedBox(height: 40),
            const Text(
              "100% Offline · No internet needed",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
