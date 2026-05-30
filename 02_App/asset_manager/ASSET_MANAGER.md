# Asset Manager

Project title: LoopyCat RPG AR

Purpose:

- Load assets safely.
- Avoid loading all bosses at once.
- Provide references to marker, boss, loot, cat photo, and UI assets.

## Supported Asset Types

Asset Manager supports:

- Boss assets
- Loot assets
- Marker image
- Cat photo
- UI assets

## Foundation Rule

Lazy load content.

Do not load all bosses at once.

Only load assets needed for the current screen or battle.

## Asset Roots

```text
03_AR/
  canonical_marker.jpg

04_Content/Bosses/
  raw_sheets/
  extracted_parts/
  manifests/
  controllers/

04_Content/Loot/
  raw_sheets/
  extracted_items/
  manifests/
  animations/
```

## Loading Policy

### Marker

Load during camera battle setup.

Keep available while tracking is active.

### Boss

Load only selected boss.

Required boss asset groups:

- Manifest
- Extracted parts
- Controller
- Portrait
- Icon
- FX references

### Loot

Load only reward items selected by `loot_engine`.

Required loot asset groups:

- Item sprite
- Icon
- Card
- Reveal animation profile
- Rarity effect references

### Cat Photo

Load runtime-sized image for battle and UI.

Keep original photo separate from runtime texture.

### UI

Load screen-specific UI assets.

Do not keep unused screen assets alive during camera battle.

## Cache Policy

Minimum cache:

- Current marker asset
- Current boss assets
- Current loot reveal assets
- Current Cat Hero preview asset
- Current screen UI assets

Evict:

- Previous boss assets after battle closes.
- Loot reveal effects after reward save.
- Large cat photo source after runtime texture is created.

## Debug Output

Asset Manager reports:

- Loaded asset count
- Loaded texture count
- Estimated memory
- Missing asset errors
- Current boss asset id
- Current loot asset ids
- Current marker loaded state
