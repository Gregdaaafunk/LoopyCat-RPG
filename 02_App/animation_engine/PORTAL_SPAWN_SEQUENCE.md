# Portal Spawn Sequence

Project title: LoopyCat RPG AR

## Goal

Make the toy feel like it opens a portal and summons the boss.

## Sequence

1. Show `TARGET LOCKED`.
2. Portal ring opens from marker anchor.
3. Vortex spins.
4. Particles pull inward.
5. Smoke / mist builds.
6. Boss eyes appear.
7. Boss head emerges.
8. Boss body rises.
9. Screen flash.
10. Boss name card.
11. HP appears.
12. Battle starts.

## Render Rule

Every portal and boss element is drawn into composed output so recording captures it.

## Anchor Rule

Use the persistent anchor transform.

Do not use raw marker frame transform after lock.
