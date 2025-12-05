import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'shop_screen.dart';
import 'tower_upgrade_screen.dart';

const double kWorldWidth = 1280;
const double kWorldHeight = 720;


List<TowerInstance> ownedTowers = [];


final List<Offset> kPathPoints = [
  const Offset(80, kWorldHeight - 80),
  const Offset(80, 140),
  const Offset(480, 140),
  const Offset(480, 420),
  const Offset(260, 420),
  const Offset(260, 220),
  const Offset(1150, 220),
];

enum TowerRarity { common, rare, epic }

enum TowerClass { dps, tank, support, control, hybrid }


enum EnemyType { book, laptop, exam, bee, miniboss }


class TowerInstance {
  TowerType type;
  int evolutionLevel;
  double currentHp;

  TowerInstance({
    required this.type,
    required this.evolutionLevel,
    required this.currentHp,
  });
}

class TowerAbility {
  final String id;
  final String name;
  final String description;

  
  final double baseValue;
  final double perEvolution;

  const TowerAbility({
    required this.id,
    required this.name,
    required this.description,
    required this.baseValue,
    required this.perEvolution,
  });

  double valueAtLevel(int evolutionLevel) {
    final lvl = evolutionLevel.clamp(1, 3);
    return baseValue + perEvolution * (lvl - 1);
  }
}




class TowerType {
  final String id;
  final String name;
  final String description;

  final int cost;
  final double baseDamage;
  final double baseFireRate; 
  final TowerRarity rarity;
  final TowerClass towerClass;
  final double maxHp;
  final double range;

  
  final String portrait;

  
  final String weaponPath;

  
  final double weaponScale;

  
  final List<TowerAbility> abilities;

  
  int evolutionLevel;
  final int maxEvolution;

  TowerType({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.baseDamage,
    required this.baseFireRate,
    required this.rarity,
    required this.towerClass,
    required this.maxHp,
    required this.range,
    required this.portrait,
    required this.weaponPath,
    this.weaponScale = 1.0,
    required this.abilities,
    this.evolutionLevel = 1,
    this.maxEvolution = 3,
  });

  
  double get scaledDamage {
    
    final bonusFactor = 1.0 + 0.25 * (evolutionLevel - 1);
    return baseDamage * bonusFactor;
  }

  
  double get scaledFireRate {
    
    final factor = 1.0 - 0.15 * (evolutionLevel - 1);
    final clampedFactor = max(0.6, factor); 
    return baseFireRate * clampedFactor;
  }

  
  double get scaledRange {
    return range * (1.0 + 0.1 * (evolutionLevel - 1));
  }
}

class EnemyDefinition {
  final String sprite;
  final double baseHp;
  final double speed;
  final int bounty;
  final bool flying;

  const EnemyDefinition({
    required this.sprite,
    required this.baseHp,
    required this.speed,
    required this.bounty,
    this.flying = false,
  });
}
const double kEnemySpeedFactor = 1.1;   
const double kEnemyGoldFactor  = 1.9;    


const Map<EnemyType, EnemyDefinition> enemyDefs = {
  EnemyType.book: EnemyDefinition(
    sprite: 'assets/game/enemies/book.png',
    baseHp: 60,
    speed: 50,
    bounty: 10,
  ),
  EnemyType.laptop: EnemyDefinition(
    sprite: 'assets/game/enemies/essay.png',
    baseHp: 140,
    speed: 60,
    bounty: 18,
  ),
  EnemyType.exam: EnemyDefinition(
    sprite: 'assets/game/enemies/arcell.png',
    baseHp: 40,
    speed: 80,
    bounty: 15,
  ),
  EnemyType.bee: EnemyDefinition(
    sprite: 'assets/game/enemies/matel.png',
    baseHp: 200,
    speed: 60,
    bounty: 12,
    flying: true,
  ),
};


const Map<String, EnemyDefinition> minibossDefs = {
  "caballar": EnemyDefinition(
    sprite: 'assets/game/enemies/paola.png',
    baseHp: 1770,
    speed: 80,
    bounty: 1000,
  ),
  "primo": EnemyDefinition(
    sprite: 'assets/game/enemies/peren.png',
    baseHp: 2650,
    speed: 70,
    bounty: 160,
  ),
  "lontoc": EnemyDefinition(
    sprite: 'assets/game/enemies/sean.png',
    baseHp: 3900,
    speed: 40,
    bounty: 250,
  ),
};

Color rarityColor(TowerRarity rarity) {
  switch (rarity) {
    case TowerRarity.common:
      return const Color(0xFF7F8C8D); 
    case TowerRarity.rare:
      return const Color(0xFF3498DB); 
    case TowerRarity.epic:
      return const Color(0xFFE67E22); 
  }
}

List<TowerType> buildTowerTypes() {
  const basePortrait = 'assets/game/classmates/sample.png';

  return [
    
    
    
    TowerType(
      id: 'abante',
      name: 'Abante, Marjinel',
      description: 'Fierce & energetic rapid-fire DPS. Glass cannon.',
      cost: 100,
      baseDamage: 18,
      baseFireRate: 0.7,
      rarity: TowerRarity.common,
      towerClass: TowerClass.dps,
      maxHp: 90,
      range: 480,
      portrait: 'assets/game/classmates/abante.png',
      weaponPath: 'assets/game/weapons/dual_pistols.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'abante_burst',
          name: '“HoOoYy!!” Burst',
          description: 'Every few shots deals bonus damage in a small splash.',
          baseValue: 0.15,
          perEvolution: 0.05,
        ),
        TowerAbility(
          id: 'abante_hype',
          name: 'Hyper Spam',
          description: 'Attack speed increases slightly each time she hits.',
          baseValue: 0.08,
          perEvolution: 0.04,
        ),
      ],
    ),

    TowerType(
      id: 'chan',
      name: 'Chan, Rebekah',
      description: 'Creative balanced caster. Reliable single-target.',
      cost: 310,
      baseDamage: 40,
      baseFireRate: 1.0,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.hybrid,
      maxHp: 110,
      range: 460,
      portrait: 'assets/game/classmates/chan.png',
      weaponPath: 'assets/game/weapons/ink_pen.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'chan_story',
          name: 'Storyboard Focus',
          description: 'Slightly increases range and accuracy.',
          baseValue: 0.10,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'domingo',
      name: 'Domingo, Vashti',
      description: 'Organized planner. Precise lane control tower.',
      cost: 385,
      baseDamage: 36,
      baseFireRate: 1.1,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.control,
      maxHp: 100,
      range: 500,
      portrait: 'assets/game/classmates/domingo.png',
      weaponPath: 'assets/game/weapons/notebook_laser.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'domingo_clip',
          name: 'Pinned Notes',
          description:
              'Occasionally tags an enemy, making it take extra damage from all sources.',
          baseValue: 0.12,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'perez',
      name: 'Perez, Clarinze',
      description: 'Competitive prodigy. High DPS crit-style tower.',
      cost: 500,
      baseDamage: 30,
      baseFireRate: 1.3,
      rarity: TowerRarity.epic,
      towerClass: TowerClass.dps,
      maxHp: 100,
      range: 500,
      portrait: basePortrait,
      weaponPath: 'assets/game/weapons/axe.png',
      weaponScale: 1.2,
      abilities: [
        TowerAbility(
          id: 'clarinze_crit',
          name: 'Finals Clutch',
          description: 'Has a chance to deal massive critical damage.',
          baseValue: 0.18,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'clarinze_comp',
          name: 'Late Arrival',
          description:
              'Damage increases slightly each time she kills an enemy.',
          baseValue: 0.06,
          perEvolution: 0.04,
        ),
        TowerAbility(
          id: 'clarinze_range',
          name: 'Top of the Class',
          description: 'Gains bonus range at higher evolution levels.',
          baseValue: 0.12,
          perEvolution: 0.04,
        ),
      ],
    ),

    TowerType(
      id: 'peruda',
      name: 'Peruda, Zenia',
      description: 'Observant slow/control tower. Great mid-lane control.',
      cost: 230,
      baseDamage: 18,
      baseFireRate: 0.9,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.control,
      maxHp: 110,
      range: 470,
      portrait: 'assets/game/classmates/peruda.png',
      weaponPath: 'assets/game/weapons/stopwatch.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'peruda_slow',
          name: 'Hallway Watch',
          description: 'Basic attacks slow enemies for a short time.',
          baseValue: 0.20,
          perEvolution: 0.05,
        ),
        TowerAbility(
          id: 'peruda_spot',
          name: 'Observant Eyes',
          description: 'Increases slow duration slightly per evolution.',
          baseValue: 1.0,
          perEvolution: 0.2,
        ),
      ],
    ),

    TowerType(
      id: 'puro',
      name: 'Puro, Cheilou',
      description: 'Calm calculator. Reliable support/control hybrid.',
      cost: 125,
      baseDamage: 19,
      baseFireRate: 1.2,
      rarity: TowerRarity.common,
      towerClass: TowerClass.support,
      maxHp: 130,
      range: 450,
      portrait: 'assets/game/classmates/puro.png',
      weaponPath: 'assets/game/weapons/calculator.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'puro_calc',
          name: 'Sige, Try Natin',
          description:
              'Slightly buffs nearby towers’ attack speed in a small radius.',
          baseValue: 0.08,
          perEvolution: 0.04,
        ),
      ],
    ),

    TowerType(
      id: 'yahiya',
      name: 'Yahiya, Merhaya',
      description: 'Fangirl shock tower. Short-range control damage.',
      cost: 250,
      baseDamage: 24,
      baseFireRate: 1.0,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.control,
      maxHp: 105,
      range: 460,
      portrait: 'assets/game/classmates/yahiya.png',
      weaponPath: 'assets/game/weapons/mic_shock.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'yahiya_fangirl',
          name: 'Fangirl Squeal',
          description: 'Occasionally stuns nearby enemies with a squeal.',
          baseValue: 0.16,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'yahiya_chain',
          name: 'Shockwave Echo',
          description: 'Short chain lightning to nearby enemies.',
          baseValue: 0.10,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'mapanao',
      name: 'Mapanao, Issa',
      description: 'Leader aura-type support. Buff-focused hybrid.',
      cost: 450,
      baseDamage: 20,
      baseFireRate: 1.0,
      rarity: TowerRarity.epic,
      towerClass: TowerClass.support,
      maxHp: 130,
      range: 440,
      portrait: 'assets/game/classmates/mapanao.png',
      weaponPath: 'assets/game/weapons/megaphone.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'issa_leader',
          name: 'Guys, Announcement!',
          description: 'Aura that boosts nearby towers’ damage.',
          baseValue: 0.15,
          perEvolution: 0.05,
        ),
        TowerAbility(
          id: 'issa_energy',
          name: 'Energetic Call',
          description: 'Also slightly boosts attack speed.',
          baseValue: 0.08,
          perEvolution: 0.04,
        ),
        TowerAbility(
          id: 'issa_focus',
          name: 'Witty Gameplan',
          description: 'Aura radius increases per evolution.',
          baseValue: 1.0,
          perEvolution: 0.25,
        ),
      ],
    ),

    
    
    
    TowerType(
      id: 'acabo',
      name: 'Acabo, Ian',
      description: 'Burst DPS. “Pasabi” style multi-shot damage.',
      cost: 650,
      baseDamage: 28,
      baseFireRate: 1.0,
      rarity: TowerRarity.epic,
      towerClass: TowerClass.dps,
      maxHp: 95,
      range: 470,
      portrait: 'assets/game/classmates/acabo.png',
      weaponPath: 'assets/game/weapons/umbrella_cannon.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'acabo_multishot',
          name: '“Sirrr!” Multishot',
          description:
              'Occasionally fires extra projectiles at nearby enemies.',
          baseValue: 0.20,
          perEvolution: 0.07,
        ),
        TowerAbility(
          id: 'acabo_haste',
          name: 'Pasabi Malalate',
          description: 'Short burst of faster fire rate after each kill.',
          baseValue: 0.10,
          perEvolution: 0.05,
        ),
        TowerAbility(
          id: 'acabo_focus',
          name: 'Curious Focus',
          description: 'Slight crit damage bonus.',
          baseValue: 0.15,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'arias',
      name: 'Arias, Lhanz',
      description: 'Tall sniper. Very long-range lane cleaner.',
      cost: 135,
      baseDamage: 22,
      baseFireRate: 0.8,
      rarity: TowerRarity.common,
      towerClass: TowerClass.dps,
      maxHp: 100,
      range: 540,
      portrait: 'assets/game/classmates/arias.png',
      weaponPath: 'assets/game/weapons/sniper_rifle.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'arias_snipe',
          name: 'Soft-Smile Snipe',
          description: 'Deals bonus damage to the farthest enemy in range.',
          baseValue: 0.18,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'arias_focus',
          name: 'Long Stride Aim',
          description: 'Small pierce effect on bullets.',
          baseValue: 0.1,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'baquirin',
      name: 'Baquirin, Jared',
      description: 'Brave small tank. Soaks hits, steady DPS.',
      cost: 120,
      baseDamage: 18,
      baseFireRate: 1.4,
      rarity: TowerRarity.common,
      towerClass: TowerClass.tank,
      maxHp: 170,
      range: 420,
      portrait: 'assets/game/classmates/baquirin.png',
      weaponPath: 'assets/game/weapons/shield.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'jared_guard',
          name: 'Blue Shirt Guard',
          description: 'Adds bonus HP and tiny damage reflection.',
          baseValue: 0.18,
          perEvolution: 0.06,
        ),
      ],
    ),

    TowerType(
      id: 'borromeo',
      name: 'Borromeo, Frank',
      description: 'Secretive crit DPS. High burst potential.',
      cost: 580,
      baseDamage: 12,
      baseFireRate: 1.2,
      rarity: TowerRarity.common,
      towerClass: TowerClass.dps,
      maxHp: 95,
      range: 480,
      portrait: 'assets/game/classmates/borromeo.png',
      weaponPath: 'assets/game/weapons/hoodie_blade.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'frank_shadows',
          name: 'Quiet Shadows',
          description: 'High crit chance against isolated enemies.',
          baseValue: 0.22,
          perEvolution: 0.08,
        ),
        TowerAbility(
          id: 'frank_backstab',
          name: 'Sling Backstab',
          description: 'Bonus damage on already-damaged enemies.',
          baseValue: 0.16,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'frank_slip',
          name: 'Soft-Spoken Focus',
          description: 'Slightly faster fire rate each evolution.',
          baseValue: 0.06,
          perEvolution: 0.04,
        ),
      ],
    ),

    TowerType(
      id: 'casibua',
      name: 'Casibua, Joevin',
      description: 'Support buffer. Boosts nearby damage.',
      cost: 240,
      baseDamage: 16,
      baseFireRate: 1.4,
      rarity: TowerRarity.common,
      towerClass: TowerClass.support,
      maxHp: 140,
      range: 430,
      portrait: 'assets/game/classmates/casibua.png',
      weaponPath: 'assets/game/weapons/piso.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'joevin_boost',
          name: 'Big Voice Boost',
          description: 'Aura that increases damage of nearby towers.',
          baseValue: 0.14,
          perEvolution: 0.05,
        ),
        TowerAbility(
          id: 'joevin_cheer',
          name: 'Supportive Cheers',
          description: 'Slow HP regen to towers in his aura.',
          baseValue: 0.04,
          perEvolution: 0.02,
        ),
      ],
    ),

    TowerType(
      id: 'cawaling',
      name: 'Cawaling, Josh',
      description: 'Techy fast shooter. High attack speed.',
      cost: 130,
      baseDamage: 19,
      baseFireRate: 0.7,
      rarity: TowerRarity.common,
      towerClass: TowerClass.dps,
      maxHp: 100,
      range: 470,
      portrait: 'assets/game/classmates/cawaling.png',
      weaponPath: 'assets/game/weapons/laptop_turret.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'josh_code',
          name: 'Code Burst',
          description: 'Random rapid-fire bursts on one enemy.',
          baseValue: 0.16,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'josh_buffer',
          name: 'Earphone Focus',
          description: 'Slight attack speed bonus per evolution.',
          baseValue: 0.08,
          perEvolution: 0.04,
        ),
      ],
    ),

    TowerType(
      id: 'gealone',
      name: 'Gealone, Shan',
      description: 'Chill slow tower. Strong slows/control.',
      cost: 100,
      baseDamage: 12,
      baseFireRate: 1.6,
      rarity: TowerRarity.common,
      towerClass: TowerClass.control,
      maxHp: 120,
      range: 450,
      portrait: 'assets/game/classmates/gealone.png',
      weaponPath: 'assets/game/weapons/pillow_cloud.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'shan_chill',
          name: 'Low-Energy Aura',
          description: 'Strong slow effect in a small zone.',
          baseValue: 0.24,
          perEvolution: 0.06,
        ),
      ],
    ),

    TowerType(
      id: 'lavandero',
      name: 'Lavandero, Jhon',
      description: 'Strategic hybrid. Balanced stats.',
      cost: 125,
      baseDamage: 20,
      baseFireRate: 1.1,
      rarity: TowerRarity.common,
      towerClass: TowerClass.hybrid,
      maxHp: 115,
      range: 460,
      portrait: 'assets/game/classmates/lavandero.png',
      weaponPath: 'assets/game/weapons/strat_board.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'lavandero_plan',
          name: 'Crossed-Arms Plan',
          description: 'Slight global bonus to his own damage and range.',
          baseValue: 0.10,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'laudit',
      name: 'Laudit, Dan Renzo',
      description: 'Flash photographer. Control + utility.',
      cost: 345,
      baseDamage: 17,
      baseFireRate: 1.0,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.control,
      maxHp: 115,
      range: 440,
      portrait: 'assets/game/classmates/laudit.png',
      weaponPath: 'assets/game/weapons/camera_flash.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'laudit_flash',
          name: 'Flashbang Photo',
          description: 'Occasional AoE slow + tiny stun.',
          baseValue: 0.18,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'laudit_focus',
          name: 'Photographer’s Focus',
          description: 'Slight crit chance vs stunned enemies.',
          baseValue: 0.14,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'malong',
      name: 'Malong, Reinier',
      description: 'Sleepy explosive DPS. Random big hits.',
      cost: 430,
      baseDamage: 25,
      baseFireRate: 1.3,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.dps,
      maxHp: 100,
      range: 460,
      portrait: 'assets/game/classmates/malong.png',
      weaponPath: 'assets/game/weapons/pencil.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'malong_doze',
          name: 'Sleepy Charge',
          description: 'Chance to fire a huge explosive shot.',
          baseValue: 0.20,
          perEvolution: 0.07,
        ),
        TowerAbility(
          id: 'malong_yawn',
          name: 'Yawn Shockwave',
          description: 'Occasional small slow around target.',
          baseValue: 0.14,
          perEvolution: 0.05,
        ),
        TowerAbility(
          id: 'malong_lazy',
          name: 'Half-Awake Mode',
          description: 'Damage increases slightly per evolution.',
          baseValue: 0.10,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'manilla',
      name: 'Manilla, Ben',
      description: 'Muscle tank. Splash damage/tank hybrid.',
      cost: 870,
      baseDamage: 110,
      baseFireRate: 1.5,
      rarity: TowerRarity.epic,
      towerClass: TowerClass.tank,
      maxHp: 190,
      range: 410,
      portrait: 'assets/game/classmates/manilla.png',
      weaponPath: 'assets/game/weapons/gauntlet.png',
      weaponScale: 1.2,
      abilities: [
        TowerAbility(
          id: 'ben_splash',
          name: 'Muscle Slam',
          description: 'Heavy splash damage around impact.',
          baseValue: 0.22,
          perEvolution: 0.08,
        ),
        TowerAbility(
          id: 'ben_block',
          name: 'Athletic Guard',
          description: 'Chance to block part of incoming damage.',
          baseValue: 0.18,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'ben_roar',
          name: '“May lima ka?” Roar',
          description: 'Short taunt that briefly focuses enemies on him.',
          baseValue: 1.0,
          perEvolution: 0.3,
        ),
      ],
    ),

    TowerType(
      id: 'manjares',
      name: 'Manjares, Cedrick',
      description: 'Geek Control Unit. Bonus vs minibosses.',
      cost: 360,
      baseDamage: 26,
      baseFireRate: 1.1,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.control,
      maxHp: 105,
      range: 460,
      portrait: 'assets/game/classmates/manjares.png',
      weaponPath: 'assets/game/weapons/bear.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'cedrick_boss',
          name: 'Where’s the Bear?',
          description: 'Deals extra damage to miniboss enemies.',
          baseValue: 0.25,
          perEvolution: 0.08,
        ),
        TowerAbility(
          id: 'cedrick_otaku',
          name: 'Fanboy Focus',
          description:
              'Slightly higher damage the longer he stays in one spot.',
          baseValue: 0.10,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'paculanan',
      name: 'Paculanan, Louise',
      description: 'Gamer APM tower. Very high fire rate.',
      cost: 150,
      baseDamage: 16,
      baseFireRate: 0.5,
      rarity: TowerRarity.common,
      towerClass: TowerClass.dps,
      maxHp: 100,
      range: 470,
      portrait: 'assets/game/classmates/paculanan.png',
      weaponPath: 'assets/game/weapons/controller.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'louise_combo',
          name: 'GG Combo',
          description: 'Stacks attack speed while continuously firing.',
          baseValue: 0.16,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'louise_reset',
          name: 'Next Game',
          description: 'Resets cooldown on kill sometimes.',
          baseValue: 0.12,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'paras',
      name: 'Paras, Kurt Lance',
      description: 'Smart armor-piercing DPS.',
      cost: 355,
      baseDamage: 22,
      baseFireRate: 0.9,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.dps,
      maxHp: 105,
      range: 480,
      portrait: 'assets/game/classmates/paras.png',
      weaponPath: 'assets/game/weapons/arduino.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'paras_pierce',
          name: 'Focused Notes',
          description: 'High armor-piercing shots vs tough enemies.',
          baseValue: 0.22,
          perEvolution: 0.08,
        ),
        TowerAbility(
          id: 'paras_calc',
          name: 'Quiet Strategy',
          description: 'Slightly improved fire rate per evolution.',
          baseValue: 0.08,
          perEvolution: 0.04,
        ),
      ],
    ),

    TowerType(
      id: 'porcopio',
      name: 'Porcopio, Jel Cyruz',
      description: 'Bouncy projectile hybrid DPS.',
      cost: 150,
      baseDamage: 20,
      baseFireRate: 1.0,
      rarity: TowerRarity.common,
      towerClass: TowerClass.hybrid,
      maxHp: 110,
      range: 470,
      portrait: 'assets/game/classmates/porcopio.png',
      weaponPath: 'assets/game/weapons/pickleball.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'jel_quip',
          name: 'Punchline Shot',
          description: 'Projectiles can bounce to another enemy.',
          baseValue: 0.18,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'jel_sass',
          name: 'Animated Eyebrows',
          description: 'Small chance for double damage on bounce.',
          baseValue: 0.12,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'riman',
      name: 'Riman, Tyron',
      description: 'Music-based AOE/control caster.',
      cost: 490,
      baseDamage: 30,
      baseFireRate: 1.4,
      rarity: TowerRarity.epic,
      towerClass: TowerClass.control,
      maxHp: 115,
      range: 450,
      portrait: 'assets/game/classmates/riman.png',
      weaponPath: 'assets/game/weapons/headphone.png',
      weaponScale: 1.1,
      abilities: [
        TowerAbility(
          id: 'tyron_beats',
          name: 'Bass Drop',
          description: 'Big AoE damage pulse every few seconds.',
          baseValue: 0.22,
          perEvolution: 0.08,
        ),
        TowerAbility(
          id: 'tyron_rhythm',
          name: 'Rhythm Slow',
          description: 'Enemies caught in the beat are heavily slowed.',
          baseValue: 0.24,
          perEvolution: 0.06,
        ),
        TowerAbility(
          id: 'tyron_vibe',
          name: 'Quiet Vibes',
          description: 'Minor damage reduction aura for nearby towers.',
          baseValue: 0.10,
          perEvolution: 0.04,
        ),
      ],
    ),

    TowerType(
      id: 'rivero',
      name: 'Rivero, Dan Justin',
      description: 'Sarcastic high-crit DPS.',
      cost: 360,
      baseDamage: 28,
      baseFireRate: 1.3,
      rarity: TowerRarity.rare,
      towerClass: TowerClass.dps,
      maxHp: 105,
      range: 470,
      portrait: 'assets/game/classmates/rivero.png',
      weaponPath: 'assets/game/weapons/smirk_blade.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'rivero_sarcasm',
          name: 'Sarcastic Jab',
          description: 'High crit chance vs full-HP enemies.',
          baseValue: 0.20,
          perEvolution: 0.07,
        ),
        TowerAbility(
          id: 'rivero_provoke',
          name: 'Provocative Taunt',
          description: 'Light armor shred on hit.',
          baseValue: 0.14,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'tagab',
      name: 'Tagab, Mark',
      description: 'Hyper fast shooter. Insane fire rate.',
      cost: 95,
      baseDamage: 14,
      baseFireRate: 0.4,
      rarity: TowerRarity.common,
      towerClass: TowerClass.dps,
      maxHp: 95,
      range: 470,
      portrait: 'assets/game/classmates/tagab.png',
      weaponPath: 'assets/game/weapons/happi.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'tagab_hyper',
          name: 'Bouncy Walk',
          description: 'Huge attack speed potential over time.',
          baseValue: 0.18,
          perEvolution: 0.07,
        ),
        TowerAbility(
          id: 'tagab_noise',
          name: 'Noisy Energy',
          description: 'Slight chance to fire bonus shots.',
          baseValue: 0.12,
          perEvolution: 0.05,
        ),
      ],
    ),

    TowerType(
      id: 'trinidad',
      name: 'Trinidad, Jassim',
      description: 'Chaotic hybrid. Random-feeling stats.',
      cost: 150,
      baseDamage: 22,
      baseFireRate: 1.0,
      rarity: TowerRarity.common,
      towerClass: TowerClass.hybrid,
      maxHp: 110,
      range: 460,
      portrait: 'assets/game/classmates/trinidad.png',
      weaponPath: 'assets/game/weapons/cap_spinner.png',
      weaponScale: 1.0,
      abilities: [
        TowerAbility(
          id: 'jassim_rng',
          name: 'Mischief RNG',
          description:
              'Random small bonus to either damage or speed each wave.',
          baseValue: 0.16,
          perEvolution: 0.06,
        ),
      ],
    ),
  ];
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<Enemy> enemies = [];
  final List<Tower> towers = [];
  final List<Projectile> projectiles = [];

  final List<InventoryItem> inventory = [];

  
  final List<DamageText> damageTexts = [];
  final Set<int> _hoveredTowers = {};
  late List<TowerType> towerTypes;
  late Timer loop;

  int lives = 20;
  int money = 2400;

  static const double bottomBarHeight = 130;

  
  int wave = 9;
  final int maxWaves = 10;
  bool spawning = false;
  int enemiesToSpawn = 0;
  double spawnCooldown = 0;

  
  int minibossesKilled = 0;
  bool won = false;

  
  bool gameOver = false; 

  @override
  void initState() {
    super.initState();
    towerTypes = buildTowerTypes();
    loop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      updateGame(0.016);
    });
  }

  @override
  void dispose() {
    loop.cancel();
    super.dispose();
  }

  
  
  
  void updateGame(double dt) {
    if (won || gameOver) return; 

    if (!spawning && enemies.isEmpty && wave <= maxWaves) {
      startWave(wave);
    }

    if (spawning) {
      spawnCooldown -= dt;
      if (spawnCooldown <= 0 && enemiesToSpawn > 0) {
        spawnEnemy();
        enemiesToSpawn--;
        spawnCooldown = 0.8;
      }
      if (enemiesToSpawn <= 0) spawning = false;
    }

    moveEnemies(dt);

    
    if (lives <= 0 && !gameOver) {
      setState(() {
        lives = 0;
        gameOver = true;
      });
      return;
    }

    runTowers(dt);
    moveProjectiles(dt);
    _updateDamageTexts(dt);

    enemies.removeWhere((e) => e.dead || e.reachedEnd);
    projectiles.removeWhere((p) => !p.active);
    damageTexts.removeWhere((d) => d.life <= 0);


    
    if (!won && wave > maxWaves && enemies.isEmpty && !spawning) {
      setState(() {
        won = true;
      });
      return;
    }
    
    setState(() {});
  }

  void startWave(int w) {
    spawning = true;
    enemiesToSpawn = 6 + w * 2;
    if (w % 5 == 0) enemiesToSpawn = 1;
    spawnCooldown = 0.5;
  }

  void spawnEnemy() {
    final start = kPathPoints.first;

    if (wave % 5 == 0) {
      final key = minibossDefs.keys
          .toList()[Random().nextInt(minibossDefs.length)];
      final def = minibossDefs[key]!;
      enemies.add(
        Enemy(
          x: start.dx,
          y: start.dy,
          hp: def.baseHp,
          maxHp: def.baseHp,
        speed: def.speed * kEnemySpeedFactor,                     
        bounty: (def.bounty * kEnemyGoldFactor).round(),          
          type: EnemyType.miniboss,
          sprite: def.sprite,
        ),
      );
      wave++;
      return;
    }

    final type = EnemyType.values[Random().nextInt(4)];
    final def = enemyDefs[type]!;
    final totalHp = def.baseHp + wave * 6;

    enemies.add(
      Enemy(
        x: start.dx,
        y: start.dy,
        hp: totalHp,
        maxHp: totalHp,
        speed: def.speed * kEnemySpeedFactor,                     
        bounty: (def.bounty * kEnemyGoldFactor).round(),          
        type: type,
        sprite: def.sprite,
      ),
    );

    if (enemiesToSpawn == 1 && wave < maxWaves) wave++;
  }

  
  
  
  void moveEnemies(double dt) {
    for (var e in enemies) {
      if (e.dead || e.reachedEnd) continue;

      if (e.waypoint >= kPathPoints.length - 1) {
        e.reachedEnd = true;
        lives = (lives - 1).clamp(0, 999).toInt();
        continue;
      }

      final current = Offset(e.x, e.y);
      final target = kPathPoints[e.waypoint + 1];

      final dx = target.dx - current.dx;
      final dy = target.dy - current.dy;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < 1) {
        e.x = target.dx;
        e.y = target.dy;
        e.waypoint++;
        continue;
      }

      e.x += (dx / dist) * e.speed * dt;
      e.y += (dy / dist) * e.speed * dt;
    }
  }

  
  
  
  void runTowers(double dt) {
    for (var t in towers) {
      t.cooldown -= dt;

      if (t.cooldown <= 0) {
        final target = findTarget(t);
        if (target != null) {
          fireProjectile(t, target);
          t.cooldown = t.type.scaledFireRate;
        }
      }
    }
  }

  Enemy? findTarget(Tower t) {
    Enemy? best;
    double bestDist = 99999;

    for (var e in enemies) {
      if (e.dead) continue;

      final dx = e.x - t.x;
      final dy = (e.y - t.y).abs();

      if (dx.abs() < t.type.range && dy < 120) {
        if (dx < bestDist) {
          bestDist = dx;
          best = e;
        }
      }
    }
    return best;
  }

  void fireProjectile(Tower tower, Enemy target) {
    double damage = tower.type.scaledDamage;

    
    
    
    
    
    
    for (var ab in tower.type.abilities) {
      switch (ab.name) {
        case 'Ink Strike':
          if (Random().nextDouble() <
              ab.valueAtLevel(tower.type.evolutionLevel)) {
            damage *= 2;
          }
          break;

        case 'Hooy Rapidfire':
          if (Random().nextDouble() < 0.1) {
            tower.cooldown *= 0.5;
          }
          break;

        case 'Crimson Cleave':
          
          break;

        case 'Battle Focus':
          if (Random().nextDouble() <
              ab.valueAtLevel(tower.type.evolutionLevel)) {
            damage *= 2.2;
          }
          break;

        case 'Overdrive Axe':
          if (Random().nextDouble() < 0.1) {
            tower.cooldown *= 0.5;
          }
          break;

        case 'Slow Groove':
          
          break;

        case 'Bounce Shot':
          
          break;

        case 'Rhythm Chain':
          
          break;
      }
    }

    projectiles.add(
      Projectile(
        x: tower.x,
        y: tower.y,
        target: target,
        damage: damage,
        type: tower.type,
      ),
    );
  }

  
  
  
  void moveProjectiles(double dt) {
    for (var p in projectiles) {
      if (!p.active) continue;

      if (p.target.dead || p.target.reachedEnd) {
        p.active = false;
        continue;
      }

      final dx = p.target.x - p.x;
      final dy = p.target.y - p.y;
      final dist = sqrt(dx * dx + dy * dy);

      p.x += (dx / dist) * p.speed * dt;
      p.y += (dy / dist) * p.speed * dt;

      if ((p.x - p.target.x).abs() < 20 && (p.y - p.target.y).abs() < 20) {
        hitEnemy(p);
      }
    }
  }

  
  
  
  void hitEnemy(Projectile p) {
    final t = p.type;
    final enemy = p.target;

    enemy.hp -= p.damage;

    
    damageTexts.add(
      DamageText(
        x: enemy.x,
        y: enemy.y - 25,
        text: '-${p.damage.toStringAsFixed(0)}',
      ),
    );

    if (enemy.hp <= 0) {
      enemy.dead = true;
      money += enemy.bounty;
    
     if (enemy.type == EnemyType.miniboss) {
        minibossesKilled++;
      }
    }

    
    for (var ab in t.abilities) {
      switch (ab.name) {
        case 'Crimson Cleave':
          for (var e in enemies) {
            if ((e.y - enemy.y).abs() < 60 && (e.x - enemy.x).abs() < 80) {
              e.hp -= ab.valueAtLevel(t.evolutionLevel);
            }
          }
          break;

        case 'Slow Groove':
          enemy.speed *= 0.4;
          break;

        case 'Bounce Shot':
          Enemy? second = enemies.firstWhere(
            (e) => !e.dead && e != enemy,
            orElse: () => enemy,
          );
          if (second != enemy) {
            projectiles.add(
              Projectile(
                x: enemy.x,
                y: enemy.y,
                target: second,
                damage: p.damage * 0.8,
                type: p.type,
              ),
            );
          }
          break;

        case 'Rhythm Chain':
          List<Enemy> chain = enemies
              .where(
                (e) =>
                    !e.dead &&
                    sqrt(pow(e.x - enemy.x, 2) + pow(e.y - enemy.y, 2)) < 200,
              )
              .toList();
          if (chain.length > 1) {
            for (int i = 1; i < chain.length; i++) {
              chain[i].hp -= ab.valueAtLevel(t.evolutionLevel);
            }
          }
          break;
      }
    }

    p.active = false;
  }

  void _updateDamageTexts(double dt) {
    for (var d in damageTexts) {
      d.y -= 40 * dt; 
      d.life -= dt;
    }
  }

  
  void _resetGame() {
    setState(() {
      lives = 20;
      money = 160;
      wave = 1;
      spawning = false;
      enemiesToSpawn = 0;
      spawnCooldown = 0;
      minibossesKilled = 0;
      won = false;
      gameOver = false;

      enemies.clear();
      towers.clear();
      projectiles.clear();
      damageTexts.clear();
      inventory.clear();
      ownedTowers.clear();

      
      towerTypes = buildTowerTypes();
    });
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sw = constraints.maxWidth;
          final sh = constraints.maxHeight;
          final gameH = sh - bottomBarHeight;

          final scaleX = sw / kWorldWidth;
          final scaleY = gameH / kWorldHeight;

          return Stack(
            children: [
              
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: bottomBarHeight,
                child: DragTarget<InventoryItem>(
                  onWillAccept: (_) => true,
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) =>
                          _handleTowerTap(details, scaleX, scaleY),
                      child: Stack(
                        children: [
                          
                          Positioned.fill(
                            child: Image.asset(
                              'assets/maps/level1.png',
                              fit: BoxFit.cover,
                            ),
                          ),

                          
                          ...enemies.map((e) {
                            final isBoss = e.type == EnemyType.miniboss;
                            final spriteSize = isBoss ? 140.0 : 80.0;
                            final barWidth = isBoss ? 120.0 : 70.0;
                            final hpFrac = (e.hp / e.maxHp)
                                .clamp(0.0, 1.0)
                                .toDouble();

                            return Positioned(
                              left: e.x * scaleX - spriteSize / 2,
                              top: e.y * scaleY - spriteSize / 2 - 14,
                              child: Column(
                                children: [
                                  
                                  SizedBox(
                                    width: barWidth,
                                    height: 6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: hpFrac,
                                        backgroundColor: Colors.red.shade900,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              isBoss
                                                  ? Colors.amberAccent
                                                  : Colors.greenAccent,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  
                                  Image.asset(e.sprite, width: spriteSize),
                                ],
                              ),
                            );
                          }).toList(),

                          
                          ...towers.map((t) {
                            final id = t.hashCode;
                            final isHovered = _hoveredTowers.contains(id);
                            final rarityCol = rarityColor(t.type.rarity);
                            return Positioned(
                              left: t.x * scaleX - 25,
                              top: t.y * scaleY - 45,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (_) {
                                  setState(() => _hoveredTowers.add(id));
                                },
                                onExit: (_) {
                                  setState(() => _hoveredTowers.remove(id));
                                },
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _openTowerUpgrade(t),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    transform: isHovered
                                        ? (Matrix4.identity()..scale(1.06))
                                        : Matrix4.identity(),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      boxShadow: isHovered
                                          ? [
                                              BoxShadow(
                                                color: rarityCol.withOpacity(
                                                  0.85,
                                                ),
                                                blurRadius: 20,
                                                spreadRadius: 6,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: _buildTowerOnMap(t),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          
                          ...projectiles.map((p) {
                            final evo = p.type.evolutionLevel;
                            final evoWeaponScale =
                                p.type.weaponScale * (1.0 + 0.2 * (evo - 1));

                            return Positioned(
                              left: p.x * scaleX - 10,
                              top: p.y * scaleY - 10,
                              child: Image.asset(
                                p.type.weaponPath,
                                width: 20 * evoWeaponScale,
                              ),
                            );
                          }).toList(),

                          
                          ...damageTexts.map((d) {
                            final alpha = (d.life / d.maxLife)
                                .clamp(0.0, 1.0)
                                .toDouble();
                            return Positioned(
                              left: d.x * scaleX,
                              top: d.y * scaleY,
                              child: Opacity(
                                opacity: alpha,
                                child: Text(
                                  d.text,
                                  style: const TextStyle(
                                    color: Colors.yellowAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                  onAcceptWithDetails: (details) {
                    final item = details.data; 

                    
                    final box = context.findRenderObject() as RenderBox;
                    final localPos = box.globalToLocal(details.offset);

                    
                    final worldX = localPos.dx / scaleX;
                    final worldY = localPos.dy / scaleY;

                    setState(() {
                      towers.add(Tower(x: worldX, y: worldY, type: item.type));

                      
                      inventory.remove(item);
                    });
                  },
                ),
              ),

              
              _buildBottomBar(),

              
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      Text(
                        '$lives',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.attach_money, color: Colors.amber),
                      Text(
                        '$money',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              
              Positioned(
                left: 16,
                top: 16,
                child: Text(
                  'Wave $wave / $maxWaves',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              
              
              if (gameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.redAccent, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'YOU LOSE',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'All lives are gone.\nCS301 claimed another victim.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              
              if (won)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF022C22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.greenAccent, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'YOU WIN',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'All waves cleared!\nMinibosses defeated: $minibossesKilled',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Play Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

            ],
          );
        },
      ),
    );
  }

  
  Widget _buildTowerOnMap(Tower t) {
    final evo = t.type.evolutionLevel.clamp(1, 3);
    final rarityCol = rarityColor(t.type.rarity);

    double borderWidth = 2;
    Color borderColor = Colors.white24;
    List<BoxShadow> shadows = [];

    if (evo == 1) {
      borderColor = Colors.white24;
      borderWidth = 2;
    } else if (evo == 2) {
      borderColor = rarityCol.withOpacity(0.8);
      borderWidth = 3;
      shadows = [
        BoxShadow(
          color: rarityCol.withOpacity(0.4),
          blurRadius: 6,
          spreadRadius: 2,
        ),
      ];
    } else if (evo == 3) {
      borderColor = rarityCol;
      borderWidth = 4;
      shadows = [
        BoxShadow(
          color: rarityCol.withOpacity(0.8),
          blurRadius: 12,
          spreadRadius: 4,
        ),
      ];
    }

    final evoWeaponScale = t.type.weaponScale * (1.0 + 0.2 * (evo - 1));

    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: shadows,
              ),
              child: Image.asset(t.type.portrait, width: 70),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'E$evo',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Image.asset(t.type.weaponPath, width: 40 * evoWeaponScale),
      ],
    );
  }

  void _openTowerUpgrade(Tower t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TowerUpgradeScreen(
          towerType: t.type,
          money: money,
          onUpgrade: () {
            setState(() {}); 
          },
          spendMoney: (amt) {
            setState(() {
              money -= amt;
            });
          },
        ),
      ),
    );
  }

  
  
  
  void _handleTowerTap(TapUpDetails details, double sx, double sy) {
    final tapX = details.localPosition.dx / sx;
    final tapY = details.localPosition.dy / sy;

    debugPrint('tap local=${details.localPosition} -> world=($tapX,$tapY)');

    
    const hitX = 50.0;
    const hitY = 80.0;
    for (var t in towers) {
      debugPrint(
        'tower at (${t.x.toStringAsFixed(1)}, ${t.y.toStringAsFixed(1)})',
      );
      if ((t.x - tapX).abs() < hitX && (t.y - tapY).abs() < hitY) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TowerUpgradeScreen(
              towerType: t.type,
              money: money,
              onUpgrade: () => setState(() {}),
              spendMoney: (amt) {
                setState(() {
                  money -= amt;
                });
              },
            ),
          ),
        );
        return;
      }
    }
  }

  
  
  
  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: bottomBarHeight,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: inventory.map((inv) {
                    return Draggable<InventoryItem>(
                      data: inv,
                      child: _invCard(inv.type),
                      feedback: _invCard(inv.type),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _invCard(inv.type),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _openShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Shop'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openShop() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ShopScreen(allTowerTypes: towerTypes, currentMoney: money),
      ),
    );

    
    if (selected == null) return;

    
    final TowerType type = selected;

    
    if (money < type.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough ₱ to buy this tower.")),
      );
      return;
    }

    setState(() {
      money -= type.cost;

      ownedTowers.add(
        TowerInstance(type: type, evolutionLevel: 1, currentHp: type.maxHp),
      );

      
      inventory.add(InventoryItem(id: type.id, type: type));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Bought ${type.name}!"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _invCard(TowerType t) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rarityColor(t.rarity), width: 2),
      ),
      child: Column(
        children: [
          Image.asset(t.portrait, width: 40),
          const SizedBox(height: 4),
          Text(
            t.name.split(',').first,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}




class InventoryItem {
  final String id;
  final TowerType type;

  InventoryItem({required this.id, required this.type});
}

class Tower {
  double x;
  double y;
  final TowerType type;
  double cooldown = 0;

  Tower({required this.x, required this.y, required this.type});
}

class Enemy {
  double x;
  double y;
  double hp;
  double maxHp;
  double speed;
  final int bounty;
  final EnemyType type;
  final String sprite;
  bool dead = false;
  bool reachedEnd = false;
  int waypoint = 0;

  double slowDuration = 0;
  double slowStrength = 1.0; 
  double stunDuration = 0;

  Enemy({
    required this.x,
    required this.y,
    required this.hp,
    required this.maxHp,
    required this.speed,
    required this.bounty,
    required this.type,
    required this.sprite,
  });

  double get effectiveSpeed {
    if (stunDuration > 0) return 0; 
    return speed * slowStrength;
  }
}

class Projectile {
  double x;
  double y;
  final Enemy target;
  final double damage;
  final TowerType type;
  double speed = 240;
  bool active = true;

  Projectile({
    required this.x,
    required this.y,
    required this.target,
    required this.damage,
    required this.type,
  });
}

class DamageText {
  double x;
  double y;
  final String text;
  double life;
  final double maxLife;

  DamageText({
    required this.x,
    required this.y,
    required this.text,
    double lifeSeconds = 0.8,
  })  : life = lifeSeconds,
        maxLife = lifeSeconds;
}
