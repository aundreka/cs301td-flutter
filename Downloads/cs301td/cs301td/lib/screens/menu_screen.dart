import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import '../widgets/mute_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  bool isMuted = false;

  late AnimationController _animController;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleOffset;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleOffset;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);

    // Autoplay for mobile/desktop only
    if (!kIsWeb) {
      _initMusic();
    }

    // Simple intro animation for title & subtitle
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _titleOpacity = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _titleOffset = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _subtitleOffset = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  Future<void> _initMusic() async {
    try {
      if (kIsWeb) {
        await _player.play(
          UrlSource("assets/music/bg.mp3"),
        );
      } else {
        await _player.play(
          AssetSource("music/bg.mp3"),
        );
      }
      await _player.setVolume(1.0);
    } catch (e) {
      debugPrint("Error loading bg music: $e");
    }
  }

  void toggleMute() {
    setState(() => isMuted = !isMuted);
    _player.setVolume(isMuted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          // Web autoplay fix — starts music only after first click
          if (kIsWeb && _player.state != PlayerState.playing) {
            await _initMusic();
          }

          // Navigate to game
          if (mounted) {
            Navigator.pushNamed(context, "/game");
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Image.asset(
              "assets/menu/menu_bg.png",
              fit: BoxFit.cover,
            ),

            // Title with animation
            FadeTransition(
              opacity: _titleOpacity,
              child: SlideTransition(
                position: _titleOffset,
                child: Image.asset(
                  "assets/menu/menu_title.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Subtitle with animation
            FadeTransition(
              opacity: _subtitleOpacity,
              child: SlideTransition(
                position: _subtitleOffset,
                child: Image.asset(
                  "assets/menu/menu_subtitle.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Center caption
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Click anywhere to start",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Mute button
            Positioned(
              top: 20,
              right: 20,
              child: MuteButton(
                muted: isMuted,
                onPressed: toggleMute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
