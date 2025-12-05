import 'package:flutter/material.dart';

// Needs access to TowerType, TowerRarity, TowerClass, rarityColor
import 'game_screen.dart';

class ShopScreen extends StatefulWidget {
  final List<TowerType> allTowerTypes;
  final int currentMoney;

  const ShopScreen({
    super.key,
    required this.allTowerTypes,
    required this.currentMoney,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  TowerRarity? _rarityFilter;
  TowerClass? _classFilter;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAndSortedTowers();

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050816),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SHOP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.amberAccent, width: 1.4),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 18,
                  color: Colors.amberAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.currentMoney}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                // 🔹 Responsive grid so desktop cards don't become huge
                int crossAxisCount;
                if (width >= 1400) {
                  crossAxisCount = 6;
                } else if (width >= 1100) {
                  crossAxisCount = 5;
                } else if (width >= 900) {
                  crossAxisCount = 4;
                } else if (width >= 600) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    // Similar card ratio on all devices
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final t = filtered[i];
                    final affordable = widget.currentMoney >= t.cost;
                    return _TowerCard(
                      tower: t,
                      affordable: affordable,
                      onTap: () => _openTowerDetails(t, affordable),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── FILTER + SORT ─────────────────

  List<TowerType> _filteredAndSortedTowers() {
    final list = widget.allTowerTypes.where((t) {
      if (_rarityFilter != null && t.rarity != _rarityFilter) return false;
      if (_classFilter != null && t.towerClass != _classFilter) return false;
      return true;
    }).toList();

    int rarityRank(TowerRarity r) {
      switch (r) {
        case TowerRarity.epic:
          return 0;
        case TowerRarity.rare:
          return 1;
        case TowerRarity.common:
          return 2;
      }
    }

    list.sort((a, b) {
      final aAffordable = widget.currentMoney >= a.cost;
      final bAffordable = widget.currentMoney >= b.cost;

      if (aAffordable != bAffordable) {
        return aAffordable ? -1 : 1; // affordable first
      }

      final r = rarityRank(a.rarity).compareTo(rarityRank(b.rarity));
      if (r != 0) return r;

      return a.cost.compareTo(b.cost);
    });

    return list;
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF050816),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildRarityChips()),
              const SizedBox(width: 10),
              Expanded(child: _buildClassChips()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRarityChips() {
    final options = TowerRarity.values;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _rarityFilter == null,
          onSelected: (_) => setState(() => _rarityFilter = null),
          labelStyle: TextStyle(
            // 🔹 No more white-on-white
            color:
                _rarityFilter == null ? Colors.amberAccent : Colors.white70,
            fontSize: 11,
          ),
          selectedColor: const Color.fromARGB(221, 98, 98, 98),
          backgroundColor: Colors.black87,
          side: const BorderSide(color: Colors.amberAccent),
          surfaceTintColor: Colors.transparent,
        ),
        ...options.map((r) {
          final selected = _rarityFilter == r;
          final col = rarityColor(r);
          return ChoiceChip(
            label: Text(_rarityName(r)),
            selected: selected,
            onSelected: (_) => setState(() => _rarityFilter = r),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: 11,
            ),
            selectedColor: const Color.fromARGB(221, 137, 137, 137),
            backgroundColor: Colors.black87,
            side: BorderSide(color: col),
            surfaceTintColor: Colors.transparent,
          );
        }),
      ],
    );
  }

  Widget _buildClassChips() {
    final options = TowerClass.values;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _classFilter == null,
          onSelected: (_) => setState(() => _classFilter = null),
          labelStyle: TextStyle(
            color: _classFilter == null ? Colors.tealAccent : Colors.white70,
            fontSize: 11,
          ),
          selectedColor: const Color.fromARGB(221, 111, 111, 111),
          backgroundColor: Colors.black87,
          side: const BorderSide(color: Colors.tealAccent),
          surfaceTintColor: Colors.transparent,
        ),
        ...options.map((c) {
          final selected = _classFilter == c;
          final clr = _classColor(c);
          return ChoiceChip(
            label: Text(_className(c)),
            selected: selected,
            onSelected: (_) => setState(() => _classFilter = c),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: 11,
            ),
            selectedColor: const Color.fromARGB(221, 119, 119, 119),
            backgroundColor: Colors.black87,
            side: BorderSide(color: clr),
            surfaceTintColor: Colors.transparent,
          );
        }),
      ],
    );
  }

  Future<void> _openTowerDetails(TowerType t, bool affordable) async {
    final selected = await showModalBottomSheet<TowerType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _TowerDetailSheet(
          tower: t,
          affordable: affordable,
          currentMoney: widget.currentMoney,
        );
      },
    );

    if (selected != null && mounted) {
      Navigator.pop(context, selected);
    }
  }

  String _rarityName(TowerRarity r) {
    switch (r) {
      case TowerRarity.common:
        return 'Common';
      case TowerRarity.rare:
        return 'Rare';
      case TowerRarity.epic:
        return 'Epic';
    }
  }

  String _className(TowerClass c) {
    switch (c) {
      case TowerClass.dps:
        return 'DPS';
      case TowerClass.tank:
        return 'Tank';
      case TowerClass.support:
        return 'Support';
      case TowerClass.control:
        return 'Control';
      case TowerClass.hybrid:
        return 'Hybrid';
    }
  }

  Color _classColor(TowerClass c) {
    switch (c) {
      case TowerClass.dps:
        return const Color(0xFFF97316);
      case TowerClass.tank:
        return const Color(0xFF22C55E);
      case TowerClass.support:
        return const Color(0xFF0EA5E9);
      case TowerClass.control:
        return const Color(0xFFE11D48);
      case TowerClass.hybrid:
        return const Color(0xFFA855F7);
    }
  }
}

// ───────────────── TOWER CARD ─────────────────

class _TowerCard extends StatelessWidget {
  final TowerType tower;
  final bool affordable;
  final VoidCallback onTap;

  const _TowerCard({
    required this.tower,
    required this.affordable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityCol = rarityColor(tower.rarity);
    final classCol = _classColor(tower.towerClass);

    // 🔹 Full-bleed image that *fills the entire card*
    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          // IMAGE as background filling the card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(tower.portrait),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // Top gradient glow for flavor
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rarityCol.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Cost at top-right
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: affordable ? Colors.amberAccent : Colors.redAccent,
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: affordable ? Colors.amberAccent : Colors.redAccent,
                  ),
                  Text(
                    '${tower.cost}',
                    style: TextStyle(
                      color: affordable
                          ? Colors.amberAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Name bar inside the card near bottom
          Positioned(
            left: 10,
            right: 10,
            bottom: 38,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tower.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Rarity + class chips at bottom
          Positioned(
            left: 8,
            right: 8,
            bottom: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _rarityChip(tower.rarity),
                _classChip(tower.towerClass, classCol),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: affordable ? 1.0 : 0.55,
        child: ColorFiltered(
          // grayscale full card when unaffordable
          colorFilter: affordable
              ? const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.srcOver,
                )
              : const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: rarityCol.withOpacity(0.6),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: cardContent,
          ),
        ),
      ),
    );
  }

  Widget _rarityChip(TowerRarity r) {
    final col = rarityColor(r);
    String label;
    switch (r) {
      case TowerRarity.common:
        label = 'EPIC'; // lol jk, fixing below
        break;
      case TowerRarity.rare:
        label = 'RARE';
        break;
      case TowerRarity.epic:
        label = 'EPIC';
        break;
    }
    if (r == TowerRarity.common) label = 'COMMON';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [col, col.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: col, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _classChip(TowerClass c, Color col) {
    String label;
    switch (c) {
      case TowerClass.dps:
        label = 'DPS';
        break;
      case TowerClass.tank:
        label = 'TANK';
        break;
      case TowerClass.support:
        label = 'SUPPORT';
        break;
      case TowerClass.control:
        label = 'CONTROL';
        break;
      case TowerClass.hybrid:
        label = 'HYBRID';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: col.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: col, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _classColor(TowerClass c) {
    switch (c) {
      case TowerClass.dps:
        return const Color(0xFFF97316);
      case TowerClass.tank:
        return const Color(0xFF22C55E);
      case TowerClass.support:
        return const Color(0xFF0EA5E9);
      case TowerClass.control:
        return const Color(0xFFE11D48);
      case TowerClass.hybrid:
        return const Color(0xFFA855F7);
    }
  }
}

// ───────────────── DETAIL SHEET ─────────────────
// (unchanged from last version – keeping your cool profile layout)

class _TowerDetailSheet extends StatelessWidget {
  final TowerType tower;
  final bool affordable;
  final int currentMoney;

  const _TowerDetailSheet({
    required this.tower,
    required this.affordable,
    required this.currentMoney,
  });

  @override
  Widget build(BuildContext context) {
    final rarityCol = rarityColor(tower.rarity);
    final classCol = _classColor(tower.towerClass);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF020617),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              rarityCol.withOpacity(0.9),
                              Colors.black,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: rarityCol.withOpacity(0.7),
                              blurRadius: 18,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                tower.portrait,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tower.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tower.description,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _pill(
                                        label: _rarityText(tower.rarity),
                                        color: rarityCol,
                                      ),
                                      const SizedBox(width: 8),
                                      _pill(
                                        label: _classText(tower.towerClass),
                                        color: classCol,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _statsSection(),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ABILITIES',
                          style: TextStyle(
                            color: Colors.amberAccent.shade100,
                            fontSize: 13,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...tower.abilities.map((ab) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: rarityCol.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      rarityCol,
                                      rarityCol.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ab.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ab.description,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF020617),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 16,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: affordable
                            ? () {
                                Navigator.pop<TowerType>(context, tower);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              affordable ? Colors.amberAccent : Colors.grey,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              affordable
                                  ? 'Buy for ${tower.cost}'
                                  : 'Need ${tower.cost - currentMoney} more',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statsSection() {
    return Column(
      children: [
        Row(
          children: [
            _statTile(
              icon: Icons.bolt,
              label: 'DAMAGE',
              value: tower.baseDamage.toStringAsFixed(0),
            ),
            const SizedBox(width: 10),
            _statTile(
              icon: Icons.timer,
              label: 'FIRE RATE',
              value: '${tower.baseFireRate.toStringAsFixed(2)}s',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _statTile(
              icon: Icons.favorite,
              label: 'HP',
              value: tower.maxHp.toStringAsFixed(0),
            ),
            const SizedBox(width: 10),
            _statTile(
              icon: Icons.wifi_tethering,
              label: 'RANGE',
              value: tower.range.toStringAsFixed(0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.amberAccent),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _rarityText(TowerRarity r) {
    switch (r) {
      case TowerRarity.common:
        return 'COMMON';
      case TowerRarity.rare:
        return 'RARE';
      case TowerRarity.epic:
        return 'EPIC';
    }
  }

  String _classText(TowerClass c) {
    switch (c) {
      case TowerClass.dps:
        return 'DPS • DAMAGE DEALER';
      case TowerClass.tank:
        return 'TANK • FRONTLINE';
      case TowerClass.support:
        return 'SUPPORT • TEAM BUFFS';
      case TowerClass.control:
        return 'CONTROL • CROWD CONTROL';
      case TowerClass.hybrid:
        return 'HYBRID • FLEX';
    }
  }

  Color _classColor(TowerClass c) {
    switch (c) {
      case TowerClass.dps:
        return const Color(0xFFF97316);
      case TowerClass.tank:
        return const Color(0xFF22C55E);
      case TowerClass.support:
        return const Color(0xFF0EA5E9);
      case TowerClass.control:
        return const Color(0xFFE11D48);
      case TowerClass.hybrid:
        return const Color(0xFFA855F7);
    }
  }
}
