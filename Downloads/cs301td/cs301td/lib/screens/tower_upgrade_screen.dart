import 'package:flutter/material.dart';
import 'game_screen.dart'; // TowerType, TowerAbility, TowerRarity, rarityColor

class TowerUpgradeScreen extends StatefulWidget {
  final TowerType towerType;
  final int money;
  final VoidCallback onUpgrade;
  final void Function(int) spendMoney;

  const TowerUpgradeScreen({
    super.key,
    required this.towerType,
    required this.money,
    required this.onUpgrade,
    required this.spendMoney,
  });

  @override
  State<TowerUpgradeScreen> createState() => _TowerUpgradeScreenState();
}

class _TowerUpgradeScreenState extends State<TowerUpgradeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController glowController;

  TowerType get t => widget.towerType;

  @override
  void initState() {
    super.initState();
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.4,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  int _evolutionCost(TowerType t) {
    final level = t.evolutionLevel.clamp(1, 3);
    final factor = 0.4 + 0.2 * level; // 0.6, 0.8, 1.0
    return (t.cost * factor).round();
  }

  double _scaledDamage(TowerType t) {
    final bonus = 1.0 + 0.25 * (t.evolutionLevel - 1);
    return t.baseDamage * bonus;
  }

  double _scaledFireRate(TowerType t) {
    final bonus = 1.0 - 0.1 * (t.evolutionLevel - 1);
    return (t.baseFireRate * bonus).clamp(0.2, 99.0);
  }

  double _scaledHp(TowerType t) {
    final bonus = 1.0 + 0.15 * (t.evolutionLevel - 1);
    return t.maxHp * bonus;
  }

  double _scaledWeaponScale(TowerType t) {
    return t.weaponScale * (1.0 + 0.15 * (t.evolutionLevel - 1));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: const BackButton(color: Colors.white),
            title: Text(t.name, style: const TextStyle(color: Colors.white)),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020617), Color(0xFF020617)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isWide ? _buildWideContent() : _buildMobileContent(),
            ),
          ),
        );
      },
    );
  }

  // ───────────────── MOBILE: stacked layout ─────────────────
  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heroCard(isWide: false),
        const SizedBox(height: 16),
        _evolutionPanel(),
        const SizedBox(height: 16),
        _abilitiesCard(),
      ],
    );
  }

  // ───────────────── WEB / DESKTOP: hero left, abilities right ─────────────────
  Widget _buildWideContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: hero + evolve
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _heroCard(isWide: true),
              const SizedBox(height: 16),
              _evolutionPanel(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // RIGHT: ability list
        Expanded(flex: 3, child: _abilitiesCard()),
      ],
    );
  }

  // ───────────────── HERO CARD (Clash Royale-style) ─────────────────
  Widget _heroCard({required bool isWide}) {
    final rarityCol = rarityColor(t.rarity);
    final evo = t.evolutionLevel;
    final rarityText = switch (t.rarity) {
      TowerRarity.common => "Common",
      TowerRarity.rare => "Rare",
      TowerRarity.epic => "Epic",
    };

    final heroWidth = isWide ? 320.0 : 260.0;
    final heroHeight = isWide ? 220.0 : 200.0;

    final dmg = _scaledDamage(t).toStringAsFixed(0);
    final fr = _scaledFireRate(t).toStringAsFixed(2);
    final hp = _scaledHp(t).toStringAsFixed(0);
    final range = t.range.toStringAsFixed(0);

    return AnimatedBuilder(
      animation: glowController,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueGrey.shade900.withOpacity(0.98),
                Colors.blueGrey.shade800.withOpacity(0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: rarityCol.withOpacity(glowController.value),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: rarityCol.withOpacity(glowController.value * 0.75),
                blurRadius: 24,
                spreadRadius: 3,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top: rarity + class chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pill(
                    label: rarityText,
                    icon: Icons.auto_awesome,
                    color: rarityCol,
                  ),
                  const SizedBox(width: 8),
                  _pill(
                    label: t.towerClass.name.toUpperCase(),
                    icon: Icons.category,
                    color: Colors.tealAccent,
                  ),
                  const SizedBox(width: 8),
                  _pill(
                    label: 'EVO $evo / 3',
                    icon: Icons.upgrade,
                    color: Colors.amberAccent,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Big portrait in the center with name overlay
              Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: heroWidth,
                      height: heroHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(t.portrait, fit: BoxFit.cover),
                      ),
                    ),
                    // Name bar
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: heroWidth,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Text(
                          t.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWide ? 24 : 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stat chips under the picture
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statChip(icon: Icons.whatshot, label: 'DMG', value: dmg),
                  _statChip(
                    icon: Icons.bolt,
                    label: 'FIRE RATE',
                    value: '${fr}s',
                  ),
                  _statChip(icon: Icons.favorite, label: 'HP', value: hp),
                  _statChip(
                    icon: Icons.radio_button_checked,
                    label: 'RANGE',
                    value: range,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              if (t.description.isNotEmpty)
                Text(
                  t.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _pill({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.7),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF020617)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amberAccent, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── ABILITIES PANEL WRAPPER ─────────────────
  Widget _abilitiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: _abilitiesPanel(),
    );
  }

  // ───────────────── ABILITIES PANEL CONTENT (Clash Royale-like) ─────────────────
  Widget _abilitiesPanel() {
    final accent = rarityColor(t.rarity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Abilities",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (t.abilities.isEmpty)
          const Text(
            "No active abilities.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          )
        else
          ...t.abilities.asMap().entries.map((entry) {
            final int index = entry.key;
            final TowerAbility ab = entry.value;
            final valueNow = ab.valueAtLevel(t.evolutionLevel);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: accent.withOpacity(0.85),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF020617)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row: icon + name
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [accent, accent.withOpacity(0.4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              // small “badge” with ability number
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ab.name,
                            style: const TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Description
                    Text(
                      ab.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Bottom power strip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF111827), Color(0xFF020617)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Power",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Evo ${t.evolutionLevel}: ${valueNow.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ───────────────── EVOLUTION PANEL — big bottom button ─────────────────
  Widget _evolutionPanel() {
    final canEvolve = t.evolutionLevel < 3;
    final cost = canEvolve ? _evolutionCost(t) : 0;
    final canAfford = widget.money >= cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            canEvolve
                ? "Evolution ${t.evolutionLevel} → ${t.evolutionLevel + 1}"
                : "Max Evolution",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Big EVOLVE button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (canEvolve && canAfford)
                  ? () {
                      widget.spendMoney(cost);
                      setState(() {
                        t.evolutionLevel = (t.evolutionLevel + 1).clamp(1, 3);
                      });
                      widget.onUpgrade();
                    }
                  : null, // null = grayed-out button
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford
                    ? Colors.amber
                    : Colors.grey.shade800, // base color when enabled
                disabledBackgroundColor: Colors.grey.shade900,
                foregroundColor: Colors.black,
                disabledForegroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    canEvolve
                        ? (canAfford ? "EVOLVE  •  ₱$cost" : "Need ₱$cost")
                        : "MAX EVOLUTION",
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          if (canEvolve)
            Text(
              "Your coins: ₱${widget.money}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
