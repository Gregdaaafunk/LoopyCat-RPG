# Phase 9 Specification: Local Social Layer

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Player wants to show:

"My cat defeated this boss."

Phase 9 adds local social content, share screens, exports, profile stats, and collection pages.

Everything is local.

Do not build online mode.

## Local Social Content

Create:

- Cat showcase
- Victory cards
- Battle screenshots
- Reward posters

These are generated locally from battle, Cat Hero, loot, and progression data.

## Share Screens

After victory, show:

- Cat Hero
- Boss defeated
- Loot
- Title
- Level
- Rare item

The share screen should make the victory feel worth saving.

## Templates

Need templates:

- `VS_CARD`
- `KO_CARD`
- `LOOT_CARD`
- `LEGEND_CARD`

Template purpose:

- `VS_CARD`: Cat Hero vs boss matchup.
- `KO_CARD`: Boss defeated result.
- `LOOT_CARD`: Item obtained result.
- `LEGEND_CARD`: Cat Hero milestone, title, or Hall of Fame moment.

## Photo Export

Save locally:

- Image
- Short animation
- Victory frame

Exports should be created without requiring online accounts.

## Profile Stats

Show:

- Cat name
- Title
- Level
- Bosses defeated
- Rare drops
- Achievements

Profile stats should be reusable in cards, posters, and showcase screens.

## Collection Pages

Need collection pages:

- Boss gallery
- Loot gallery
- Cat history

Collection pages should pull from local collection, Hall of Fame, inventory, and battle history data.

## Future Support

Prepare future support for:

- QR share
- Friend battles
- Cat exchange cards
- Community events

Do not build these systems in Phase 9.

## Local Data

Store locally:

- Saved showcase cards
- Victory card exports
- Battle screenshots
- Reward posters
- Short animation exports
- Victory frame exports
- Profile stat snapshots
- Template metadata
- Collection page data

## Out Of Scope

Do not build in Phase 9:

- Online mode
- Online accounts
- Social feed
- Friend graph
- Multiplayer battles
- Community events

## Success Criteria

Phase 9 succeeds when:

- Victory can generate a local share screen.
- Share screen includes Cat Hero, boss defeated, loot, title, level, and rare item.
- User can save image, short animation, and victory frame locally.
- VS, KO, Loot, and Legend card templates exist.
- Profile stats show cat name, title, level, bosses defeated, rare drops, and achievements.
- Boss gallery, loot gallery, and cat history pages exist.
- Online mode remains out of scope.
