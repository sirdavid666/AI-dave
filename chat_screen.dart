import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';

import 'ai_brain.dart';
import 'models/message.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/mic_button.dart';

class ChatScreen extends StatefulWidget {
  final bool autoStartListening;
  const ChatScreen({super.key, this.autoStartListening = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _speechAvailable = false;
  String _liveText = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _messages.add(
      ChatMessage(
        text: "Hey boss, I'm Dave — fully offline. Ask me the time, "
            "date, for a joke, or say 'open youtube'.",
        isUser: false,
      ),
    );
    if (widget.autoStartListening) {
      // Give the screen a frame to build before opening the mic.
      WidgetsBinding.instance.addPostFrameCallback((_) => _toggleListening());
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (err) => _showError("Speech error: ${err.errorMsg}"),
        onStatus: (status) {
          if (status == "done" || status == "notListening") {
            setState(() => _isListening = false);
          }
        },
      );
      setState(() {});
    } catch (e) {
      _showError("Could not initialize speech recognition: $e");
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
    } catch (e) {
      _showError("Could not initialize text-to-speech: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      _showError("Speech recognition is not available on this device.");
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_liveText.trim().isNotEmpty) {
        _handleUserMessage(_liveText.trim());
      }
      _liveText = "";
      return;
    }

    try {
      setState(() {
        _isListening = true;
        _liveText = "";
      });
      await _speech.listen(
        onResult: (result) {
          setState(() => _liveText = result.recognizedWords);
        },
      );
    } catch (e) {
      setState(() => _isListening = false);
      _showError("Could not start listening: $e");
    }
  }

  Future<void> _handleUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();

    final result = AIBrain.getAIResponse(text);

    setState(() {
      _messages.add(ChatMessage(text: result.reply, isUser: false));
    });
    _scrollToBottom();

    _speak(result.reply);

    if (result.launchedUrl != null) {
      final ok = await AIBrain.launchUrlString(result.launchedUrl!);
      if (!ok) _showError("Could not open the link.");
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      _showError("Could not speak response: $e");
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;
      final fileName = result.files.single.name;
      setState(() {
        _messages.add(
          ChatMessage(text: fileName, isUser: true, type: MessageType.file),
        );
        _messages.add(
          ChatMessage(
            text: "Got it, boss. File \"$fileName\" attached.",
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
      _speak("File attached.");
    } catch (e) {
      _showError("Could not pick file: $e");
    }
  }

  void _sendTyped() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _handleUserMessage(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          style: TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  ChatBubble(message: _messages[index]),
            ),
          ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _liveText.isEmpty ? "Listening..." : _liveText,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: kPrimaryColor),
              onPressed: _pickFile,
              tooltip: "Attach file",
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Message Dave...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendTyped(),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.send, color: kPrimaryColor),
              onPressed: _sendTyped,
              tooltip: "Send",
            ),
            MicButton(
              isListening: _isListening,
              size: 46,
              onTap: _toggleListening,
            ),
          ],
        ),
      ),
    );
  }
}
