import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF00D4FF);

class MicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;
  final double size;

  const MicButton({
    super.key,
    required this.isListening,
    required this.onTap,
    this.size = 110,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          final glowStrength = widget.isListening ? _glow.value : 0.45;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111111),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(glowStrength * 0.7),
                  blurRadius: widget.isListening ? 40 : 20,
                  spreadRadius: widget.isListening ? 8 : 2,
                ),
              ],
              border: Border.all(
                color: kPrimaryColor.withOpacity(0.8),
                width: 2,
              ),
            ),
            child: Icon(
              widget.isListening ? Icons.mic : Icons.mic_none,
              color: kPrimaryColor,
              size: widget.size * 0.4,
            ),
          );
        },
      ),
    );
  }
}
