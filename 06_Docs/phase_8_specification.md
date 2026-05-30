# Phase 8 Specification: Loopy World System

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Player returns every day.

New boss.

New loot.

New world.

Phase 8 adds local seasonal content, worlds, boss rotations, collections, and achievements.

Everything is local.

Do not build:

- Multiplayer
- Online accounts
- Global events
- Community goals
- World raids

## Seasonal Content

Add:

- Season bosses
- Event bosses
- Limited drops
- Time rewards

Seasonal content should rotate locally and make the game feel alive without requiring online accounts.

## Worlds

World examples:

- Aquarium Realm
- Chaos Zone
- Spirit Cave
- Void Water
- Ancient Toy Temple

Each world has:

- Own bosses
- Own loot
- Own visual theme

World data should define:

- `world_id`
- `world_name`
- `visual_theme`
- `boss_pool`
- `loot_pool`
- `rotation_rules`

## Boss Rotation

Need boss rotation:

- Daily bosses
- Weekly bosses
- Special spawn bosses

Rotation rules:

- Daily bosses refresh by local day.
- Weekly bosses refresh by local week.
- Special spawn bosses can appear from local event rules.
- Rotation history should prevent the experience from feeling identical every day.

## Collection System

Store:

- Bosses found
- Bosses defeated
- Rare drops
- Mythic drops
- Cat achievements

Collection should connect to worlds, events, and Hall of Fame.

## Achievements

Achievement examples:

- First Hunter
- Boss Slayer
- Portal Breaker
- Chaos Master
- Legend Cat

Achievements should be awarded locally from battle, loot, world, and evolution progress.

## Event Framework

Event examples:

- Halloween
- New Year
- Summer Event
- Loopy Olympics

Event data should define:

- `event_id`
- `event_name`
- `event_theme`
- `start_rule`
- `end_rule`
- `event_bosses`
- `limited_drops`
- `time_rewards`

Events are local in Phase 8.

## Time Rewards

Time rewards should support:

- Daily return reward
- Weekly return reward
- Event participation reward
- Special spawn reward

Rewards should save locally.

## Future Support

Prepare future support for:

- Global events
- Community goals
- World raids

Do not build these systems in Phase 8.

## Local Data

Store locally:

- Worlds unlocked
- Current world
- World boss pools
- Daily boss state
- Weekly boss state
- Special spawn state
- Event state
- Limited drops obtained
- Time rewards claimed
- Bosses found
- Bosses defeated
- Rare drops
- Mythic drops
- Cat achievements
- Rotation history

## Success Criteria

Phase 8 succeeds when:

- Worlds exist with boss pools, loot pools, and visual themes.
- Daily boss rotation works locally.
- Weekly boss rotation works locally.
- Special spawn bosses can appear from local rules.
- Seasonal/event content can define bosses, drops, and time rewards.
- Collection system stores bosses found, bosses defeated, rare drops, mythic drops, and achievements.
- Achievements can be awarded.
- Multiplayer and online accounts remain out of scope.
