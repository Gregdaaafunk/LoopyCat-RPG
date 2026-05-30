# Core Game Loop Specification

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

User records a complete Loopy RPG battle clip:

Cat Hero VS Boss
-> camera fight
-> portal spawn
-> hits
-> KO
-> loot drop

## Canonical Battle Flow

1. User opens app.
2. User creates Cat Hero.
3. User taps `FIGHT`.
4. App randomly selects boss.
5. Show VS screen before camera battle.
6. After VS intro, open camera battle mode.
7. Camera searches for physical toy marker.
8. Marker detected.
9. App confirms `TARGET LOCKED`.
10. Portal opens from marker anchor.
11. Boss emerges from portal.
12. Fight starts.
13. Cat attacks physical toy.
14. Hit detection triggers combat feedback.
15. Boss defeated.
16. Finisher sequence plays.
17. Loot reward screen appears.
18. Save result.

## Cat Hero Creation

User creates Cat Hero with:

- Upload or capture cat photo
- Enter cat name
- Enter custom title

Example:

```text
SHOIGU
DESTROYER
```

## VS Screen

VS screen must appear before camera battle.

Left:

- Cat Hero card

Right:

- Boss card

Center:

- VS animation

Style:

- Street Fighter
- Arcade fighting game

## Camera Battle Mode

After VS intro:

1. Open camera battle mode.
2. Show live camera feed.
3. Search for physical toy marker.
4. Keep the toy visible during battle.

Battle must happen through live camera.

The toy must remain visible in camera battle mode.

## Marker And Portal Flow

1. Camera searches for physical toy marker.
2. Marker detected.
3. App confirms `TARGET LOCKED`.
4. Portal opens from marker anchor.
5. Boss emerges from portal.
6. Fight starts.

Portal and boss must remain attached to the marker anchor.

## Tracking Engine V2

Marker is only required for initial acquisition.

After `TARGET LOCKED`:

- Boss stays attached to last known anchor.
- Brief marker loss must not remove the boss.
- Brief marker loss must not reset the fight.
- Brief marker loss must not hide HP.
- Tracking Engine V2 uses last known position, size, rotation, velocity, and decay.

Loss grace periods:

- 0-1.5 seconds: show `LOCK STABLE`; boss fully visible.
- 1.5-5 seconds: show `SIGNAL UNSTABLE`; boss visible with slight glitch effect.
- 5+ seconds: show `SHOW MARKER AGAIN`; boss pauses but does not instantly disappear.

When marker returns:

- Smoothly restore anchor.
- Show `TARGET RESTORED`.
- Do not reset HP.
- Do not restart boss.
- Ignore hit detection for 400ms.

Never calculate hits from a re-lock jump.

## Hit Flow

Cat attacks physical toy.

Hit detection triggers:

- Damage
- HP drop
- Hit effects
- Boss reaction
- Combo
- Critical roll
- Floating damage
- Boss emotion change
- Phase change

Combat feel:

- Basic hit reaction
- Combo text
- Critical impact
- Boss emotion
- Impact effects
- KO sequence
- Floating damage

## Defeat And Finisher

After boss defeat:

1. Dynamic victory arena loads.
2. Cat Hero avatar appears.
3. Cat Hero performs final attack animation.
4. Boss gets KO.
5. Freeze frame plays.
6. Portal becomes unstable.
7. Boss collapses.
8. Loot explosion plays.

Do not play fixed video.

Finisher uses live animation scene.

## Reward And Save Flow

After finisher:

1. Loot energy appears inside boss.
2. Item launches upward.
3. Item reveal starts.
4. Camera focuses on item.
5. Item name, rarity, and set name appear.
6. Cat Hero reacts.
7. Item collects into inventory.
8. Loot reward screen appears.
9. Save item to inventory.
10. Save XP to cat.
11. Save battle history.

Required saved result:

- Item to inventory
- XP to cat
- Battle history

## Recording Modes

Required modes:

- `REC`
- `PHOTO`

## REC Mode

REC must not save raw camera only.

REC output must include:

- Live camera feed
- Boss
- Portal
- HP
- Damage numbers
- Hit effects
- Combo banners
- KO animation
- Loot animation
- Item reveal
- Rarity effects
- Cat Hero reward reaction
- Inventory collect pulse
- All UI overlays intended for video

Saved video must look exactly like what user sees on screen.

If native camera recording cannot capture overlays, build composed recording pipeline.

Raw camera-only video is not acceptable.

## PHOTO Mode

PHOTO mode must capture:

- Camera frame
- Boss
- Effects
- UI overlays

PHOTO output must match the visible screen composition.

## Local Output

Save video/photo locally to Photos.

Outputs:

- Composed battle video
- Composed battle photo
- Victory frame where applicable

## Composed Recording Pipeline

Recording pipeline must capture the final composed frame, not just camera input.

Composition layers:

1. Live camera feed.
2. Marker-anchored AR content.
3. Boss.
4. Portal.
5. Hit effects.
6. Damage numbers.
7. Combo banners.
8. HP and battle UI.
9. KO animation.
10. Loot animation.
11. Item reveal.
12. Rarity effects.
13. Cat Hero reward reaction.
14. Inventory collect pulse.
15. Reward overlays intended for video.

The same composed output feeds:

- On-screen display
- REC video
- PHOTO capture

## Engine Ownership

- `cat_profile_engine`: Cat Hero data, name, title, XP update.
- `boss_engine`: random boss selection and boss lifecycle.
- `ui_engine`: VS screen, HUD, reward screen, overlays.
- `tracking_engine`: marker detection and lock confirmation.
- `animation_engine`: portal, boss emerge, finisher, KO, loot animation.
- `combat_engine`: hits, HP drop, combo, phase change, defeat.
- `loot_engine`: loot drop.
- `inventory_engine`: save item.
- `recording_engine`: composed REC and PHOTO output to Photos.

## Canonical Event Order

```text
cat_updated
-> fight_requested
-> boss_selected
-> vs_intro_started
-> camera_battle_started
-> marker_detected
-> lock_started
-> lock_confirmed
-> portal_opened
-> boss_spawned
-> fight_started
-> boss_hit
-> combo_updated
-> critical_hit
-> impact_effect_played
-> boss_phase_change
-> boss_emotion_changed
-> boss_defeated
-> ko_sequence_started
-> finisher_started
-> ko_triggered
-> portal_unstable
-> loot_dropped
-> loot_energy_started
-> loot_item_launched
-> loot_reveal_started
-> loot_collect_started
-> reward_saved
-> cat_updated
-> battle_history_saved
-> media_saved
```

## Non-Negotiable Rules

- VS screen happens before camera battle.
- Battle happens through live camera.
- Toy remains visible in camera battle mode.
- Portal opens from marker anchor.
- Boss emerges from marker portal.
- Marker is only needed for initial acquisition after stable lock.
- Boss must not disappear from slight camera movement.
- Marker loss must not reset fight, hide HP, or remove boss during grace periods.
- Re-lock must restore smoothly and ignore hits for 400ms.
- REC and PHOTO must capture composed screen output.
- Raw camera-only video is not acceptable.
- Save item, XP, and battle history after victory.
