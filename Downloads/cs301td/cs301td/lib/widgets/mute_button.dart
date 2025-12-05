import 'package:flutter/material.dart';

class MuteButton extends StatelessWidget {
  final bool muted;
  final VoidCallback onPressed;

  const MuteButton({
    super.key,
    required this.muted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        muted ? Icons.volume_off : Icons.volume_up,
        size: 34,
        color: Colors.white,
      ),
    );
  }
}
