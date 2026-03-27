# eh_shoerobbery

Binco robbery script with bridge-based client/server framework support.

## Flow
- Smash Binco register with a bat.
- Shoe boxes return weighted metadata loot (rare/mid/low/empty).
- 50/50 police dispatch chance only when nearby NPC peds exist.

## Required setup
- Set your framework and integrations in `shared/config.lua`.
- Ensure your inventory has item `shoebox` if you keep default `Config.ShoeLootItem`.
- Tune store coordinates, cooldowns, and loot metadata/value table in `shared/config.lua`.
